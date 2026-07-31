`timescale 1ns/1ps

module memory_tb;

    logic        i_clk;
    logic        i_reset;

    logic [31:0] i_addr;
    logic [31:0] i_wdata;
    logic [3:0]  i_bmask;
    logic        i_wren;

    logic [31:0] o_rdata;

    int pass_count = 0;
    int fail_count = 0;

    memory dut (
        .i_clk   (i_clk),
        .i_reset (i_reset),

        .i_addr  (i_addr),
        .i_wdata (i_wdata),
        .i_bmask (i_bmask),
        .i_wren  (i_wren),

        .o_rdata (o_rdata)
    );

    task automatic check_read (
        input logic [31:0] addr,
        input logic [31:0] expected
    );
        begin
            i_addr  = addr;
            i_wren  = 1'b0;
            i_wdata = 32'b0;
            i_bmask = 4'b0000;

            #1;

            if (o_rdata === expected) begin
                pass_count++;

                $display(
                    "PASS: addr=%h rdata=%h",
                    addr, o_rdata
                );
            end
            else begin
                fail_count++;

                $display(
                    "FAIL: addr=%h | actual=%h expected=%h",
                    addr, o_rdata, expected
                );
            end
        end
    endtask

    task automatic store (
        input logic [31:0] addr,
        input logic [31:0] data,
        input logic [3:0]  bmask
    );
        begin
            @(negedge i_clk);

            i_addr  = addr;
            i_wdata = data;
            i_bmask = bmask;
            i_wren  = 1'b1;

            @(negedge i_clk);

            i_wren  = 1'b0;
            i_wdata = 32'b0;
            i_bmask = 4'b0000;
        end
    endtask

    initial begin
        i_clk = 1'b0;
        forever #5 i_clk = ~i_clk;
    end

    initial begin
        $dumpfile("build/memory.vcd");
        $dumpvars(0, memory_tb);

        i_reset = 1'b1;
        i_addr  = 32'b0;
        i_wdata = 32'b0;
        i_bmask = 4'b0000;
        i_wren  = 1'b0;

        @(posedge i_clk);
        #1;

        check_read(32'h0000_0000, 32'h0000_0000);

        i_reset = 1'b0;

        // Full word write/read
        store(
            32'h0000_0000,
            32'h1234_5678,
            4'b1111
        );

        check_read(
            32'h0000_0000,
            32'h1234_5678
        );

        // Byte lane 0
        store(
            32'h0000_0000,
            32'h0000_00AA,
            4'b0001
        );

        check_read(
            32'h0000_0000,
            32'h1234_56AA
        );

        // Byte lane 1
        store(
            32'h0000_0000,
            32'h0000_BB00,
            4'b0010
        );

        check_read(
            32'h0000_0000,
            32'h1234_BBAA
        );

        // Byte lane 2
        store(
            32'h0000_0000,
            32'h00CC_0000,
            4'b0100
        );

        check_read(
            32'h0000_0000,
            32'h12CC_BBAA
        );

        // Byte lane 3
        store(
            32'h0000_0000,
            32'hDD00_0000,
            4'b1000
        );

        check_read(
            32'h0000_0000,
            32'hDDCC_BBAA
        );

        // Lower halfword write
        store(
            32'h0000_0004,
            32'h0000_BEEF,
            4'b0011
        );

        check_read(
            32'h0000_0004,
            32'h0000_BEEF
        );

        // Upper halfword write
        store(
            32'h0000_0004,
            32'hCAFE_0000,
            4'b1100
        );

        check_read(
            32'h0000_0004,
            32'hCAFE_BEEF
        );

        // Write disabled should not modify memory
        @(negedge i_clk);
        i_addr  = 32'h0000_0004;
        i_wdata = 32'h1111_2222;
        i_bmask = 4'b1111;
        i_wren  = 1'b0;

        @(posedge i_clk);
        #1;

        check_read(
            32'h0000_0004,
            32'hCAFE_BEEF
        );

        // Word address truncates lower 2 bits: 0x8 and 0x9 access same word
        store(
            32'h0000_0008,
            32'hAABB_CCDD,
            4'b1111
        );

        check_read(
            32'h0000_0008,
            32'hAABB_CCDD
        );

        check_read(
            32'h0000_0009,
            32'hAABB_CCDD
        );

        // Last valid word in 32 KiB memory: 0x0000_7FFC
        store(
            32'h0000_7FFC,
            32'hDEAD_BEEF,
            4'b1111
        );

        check_read(
            32'h0000_7FFC,
            32'hDEAD_BEEF
        );

        // Out of range read: 0x0000_8000 is outside 0x0000_0000 - 0x0000_7FFF
        check_read(
            32'h0000_8000,
            32'h0000_0000
        );

        // Out of range write should be ignored
        store(
            32'h0000_8000,
            32'hCAFE_BABE,
            4'b1111
        );

        check_read(
            32'h0000_8000,
            32'h0000_0000
        );

        // High unrelated address should also read zero
        check_read(
            32'h1000_0000,
            32'h0000_0000
        );

        $display(
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count,
            fail_count
        );

        if (fail_count != 0)
            $fatal(1, "MEMORY TEST FAILED");

        $display("ALL MEMORY TESTS PASSED");
        $finish;
    end

endmodule
