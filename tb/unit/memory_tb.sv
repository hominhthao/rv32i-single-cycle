`timescale 1ns/1ps

module memory_tb;

    logic        i_clk;
    logic        i_rst_n;

    logic        i_wren;
    logic [31:0] i_wrdata;
    logic [31:0] i_addr;
    logic [2:0]  i_func3;

    logic [31:0] o_rdata;

    int pass_count = 0;
    int fail_count = 0;

    localparam logic [2:0]
        LB  = 3'b000,
        SB  = 3'b000,
        LH  = 3'b001,
        SH  = 3'b001,
        LW  = 3'b010,
        SW  = 3'b010,
        LBU = 3'b100,
        LHU = 3'b101;

    memory dut (
        .i_clk    (i_clk),
        .i_rst_n  (i_rst_n),
        .i_addr   (i_addr),
        .i_wrdata (i_wrdata),
        .i_wren   (i_wren),
        .i_func3  (i_func3),
        .o_rdata  (o_rdata)
    );

    task automatic wr_mem (
        input logic [31:0] addr,
        input logic [31:0] data,
        input logic [2:0]  funct3
    );
        begin
            @(negedge i_clk);

            i_addr   = addr;
            i_wrdata = data;
            i_func3  = funct3;
            i_wren   = 1'b1;

            @(negedge i_clk);

            i_wren   = 1'b0;
            i_wrdata = 32'b0;
        end
    endtask

    task automatic check_read (
        input logic [31:0] addr,
        input logic [2:0]  funct3,
        input logic [31:0] expected
    );
        begin
            i_addr  = addr;
            i_func3 = funct3;
            i_wren  = 1'b0;

            #1;

            if (o_rdata === expected) begin
                pass_count++;
                $display("PASS: addr=%h funct3=%b data=%h",
                         addr, funct3, o_rdata);
            end
            else begin
                fail_count++;
                $display("FAIL: addr=%h funct3=%b | actual=%h expected=%h",
                         addr, funct3, o_rdata, expected);
            end
        end
    endtask

    initial begin
        i_clk = 1'b0;
        forever #5 i_clk = ~i_clk;
    end

    initial begin
        $dumpfile("build/memory.vcd");

        // Dump only TB-level signals, not the whole d_mem array.
        $dumpvars(0, i_clk);
        $dumpvars(0, i_rst_n);
        $dumpvars(0, i_addr);
        $dumpvars(0, i_wrdata);
        $dumpvars(0, i_wren);
        $dumpvars(0, i_func3);
        $dumpvars(0, o_rdata);

        i_rst_n  = 1'b0;
        i_addr   = 32'b0;
        i_wrdata = 32'b0;
        i_wren   = 1'b0;
        i_func3  = LW;

        #12;
        i_rst_n = 1'b1;

        // SW / LW
        wr_mem(32'h0000_0100, 32'h1234_5678, SW);
        check_read(32'h0000_0100, LW, 32'h1234_5678);

        // SB / LB / LBU, negative byte
        wr_mem(32'h0000_0200, 32'h0000_00FF, SB);
        check_read(32'h0000_0200, LB,  32'hFFFF_FFFF);
        check_read(32'h0000_0200, LBU, 32'h0000_00FF);

        // SB / LB / LBU, positive byte
        wr_mem(32'h0000_0204, 32'h0000_007F, SB);
        check_read(32'h0000_0204, LB,  32'h0000_007F);
        check_read(32'h0000_0204, LBU, 32'h0000_007F);

        // SH / LH / LHU, negative halfword
        wr_mem(32'h0000_0300, 32'h0000_80FF, SH);
        check_read(32'h0000_0300, LH,  32'hFFFF_80FF);
        check_read(32'h0000_0300, LHU, 32'h0000_80FF);

        // SH / LH / LHU, positive halfword
        wr_mem(32'h0000_0304, 32'h0000_7FFF, SH);
        check_read(32'h0000_0304, LH,  32'h0000_7FFF);
        check_read(32'h0000_0304, LHU, 32'h0000_7FFF);

        // SB preserves upper bytes
        wr_mem(32'h0000_0400, 32'hAABB_CCDD, SW);
        wr_mem(32'h0000_0400, 32'h0000_0011, SB);
        check_read(32'h0000_0400, LW, 32'hAABB_CC11);

        // SH preserves upper two bytes
        wr_mem(32'h0000_0500, 32'h1122_3344, SW);
        wr_mem(32'h0000_0500, 32'h0000_BEEF, SH);
        check_read(32'h0000_0500, LW, 32'h1122_BEEF);

        // Valid boundary byte access
        wr_mem(32'h0000_7FFF, 32'h0000_00AA, SB);
        check_read(32'h0000_7FFF, LBU, 32'h0000_00AA);

        // Invalid boundary half/word access should read 0
        check_read(32'h0000_7FFF, LH, 32'h0000_0000);
        check_read(32'h0000_7FFD, LW, 32'h0000_0000);

        // Address outside memory range
        check_read(32'h1000_0000, LW, 32'h0000_0000);

        $display("\nSUMMARY: PASS=%0d FAIL=%0d",
                 pass_count, fail_count);

        if (fail_count != 0)
            $fatal(1, "MEMORY TEST FAILED");

        $display("ALL MEMORY TESTS PASSED");
        $finish;
    end

endmodule