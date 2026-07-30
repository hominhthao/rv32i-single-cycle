`timescale  1ns/1ps

module lsu_tb;

    logic        i_clk;
    logic        i_reset;

    logic [31:0] i_lsu_addr;
    logic [31:0] i_st_data;
    logic        i_lsu_wren;
    logic [2:0]  i_func3;

    logic [31:0] o_ld_data;

    logic [31:0] o_io_ledr;
    logic [31:0] o_io_ledg;
    logic [6:0]  o_io_hex0;
    logic [6:0]  o_io_hex1;
    logic [6:0]  o_io_hex2;
    logic [6:0]  o_io_hex3;
    logic [6:0]  o_io_hex4;
    logic [6:0]  o_io_hex5;
    logic [6:0]  o_io_hex6;
    logic [6:0]  o_io_hex7;
    logic [31:0] o_io_lcd;

    logic [31:0] i_io_sw;

    lsu dut (
        .i_clk(i_clk),
        .i_reset(i_reset),

        .i_lsu_addr(i_lsu_addr),
        .i_st_data(i_st_data),
        .i_lsu_wren(i_lsu_wren),
        .i_func3(i_func3),

        .o_ld_data(o_ld_data),
        .o_io_ledg(o_io_ledg),
        .o_io_ledr(o_io_ledr),
        .o_io_hex0(o_io_hex0),
        .o_io_hex1(o_io_hex1),
        .o_io_hex2(o_io_hex2),
        .o_io_hex3(o_io_hex3),
        .o_io_hex4(o_io_hex4),
        .o_io_hex5(o_io_hex5),
        .o_io_hex6(o_io_hex6),
        .o_io_hex7(o_io_hex7),
        .o_io_lcd(o_io_lcd),

        .i_io_sw(i_io_sw)
    );

    localparam logic [2:0]
        LB  = 3'b000,
        SB  = 3'b000,
        LH  = 3'b001,
        SH  = 3'b001,
        LW  = 3'b010,
        SW  = 3'b010,
        LBU = 3'b100,
        LHU = 3'b101;

    localparam logic [31:0]
        DMEM_BASE  = 32'h0000_0000,
        LEDR_BASE  = 32'h1000_0000,
        LEDG_BASE  = 32'h1000_1000,
        HEX03_BASE = 32'h1000_2000,
        HEX47_BASE = 32'h1000_3000,
        LCD_BASE   = 32'h1000_4000,
        SW_BASE    = 32'h1001_0000;

        int pass_count = 0;
        int fail_count = 0;

    initial begin 
        i_clk = 1'b0;
        forever #5 i_clk = ~i_clk;
    end

    task automatic store (
        input logic [31:0] addr,
        input logic [31:0] data,
        input logic [2:0]  fucnt3
    );
        begin 
            @(negedge i_clk); 

            i_lsu_addr = addr;
            i_st_data  = data;
            i_func3    = fucnt3;
            i_lsu_wren = 1'b1;

            @(negedge i_clk);

            i_lsu_wren = 1'b0;
            i_st_data  = 32'b0;
        end
    endtask 

    task automatic check_load (
        input logic [31:0] addr, 
        input logic [2:0]  funct3,
        input logic [31:0] expected
    );
        begin
            i_lsu_addr = addr;
            i_func3    = funct3;
            i_lsu_wren = 1'b0; //load

            #1;

            if (o_ld_data === expected) begin 
                pass_count++;
                $display (
                    "PASS LOAD: addr=%h funct3=%b data=%h",
                    addr, funct3, o_ld_data
                );
            end
            else begin 
                fail_count++;
                $display(
                    "FAIL LOAD: addr=%h funct3=%b | actual=%h expected=%h",
                    addr, funct3, o_ld_data, expected
                );
            end
        end
    endtask

    task automatic check_io32 (
        input string        name,
        input logic [31:0] actual,
        input logic [31:0] expected
    );
        begin 
            #1;

            if (actual === expected) begin 
                pass_count++;
                $display(
                    "PASS IO: %s=%h", name, actual
                );
            end
            else begin 
                fail_count++;
                $display(
                    "FAIL IO: %s actual=%h expected=%h",
                    name, actual, expected
                );
            end
        end
    endtask

    initial begin 
        $dumpfile("build/lsu.vcd");
        $dumpvars(1, lsu_tb);

        i_reset     = 1'b1;
        i_lsu_addr  = 32'h0;
        i_st_data   = 32'h0;
        i_lsu_wren  = 1'b0;
        i_func3     = 3'b000;
        i_io_sw     = 32'h0;

        #12;
        i_reset = 1'b0;

        check_io32("ledr_reset", o_io_ledr, 32'h0000_0000);
        check_io32("ledg_reset", o_io_ledg, 32'h0000_0000);

        // DMEM SW/LW
        store(DMEM_BASE + 32'h0000_0100, 32'h1234_5678, SW);
        check_load(DMEM_BASE + 32'h0000_0100, LW, 32'h1234_5678);

        // DMEM SB / LB / LBU, negative byte
        store(DMEM_BASE + 32'h0000_0201, 32'h0000_00FF, SB);
        check_load(DMEM_BASE + 32'h0000_0201, LB,  32'hFFFF_FFFF);
        check_load(DMEM_BASE + 32'h0000_0201, LBU, 32'h0000_00FF);

        // DMEM SB / LB / LBU, positive byte
        store(DMEM_BASE + 32'h0000_0202, 32'h0000_007F, SB);
        check_load(DMEM_BASE + 32'h0000_0202, LB,  32'h0000_007F);
        check_load(DMEM_BASE + 32'h0000_0202, LBU, 32'h0000_007F);

        // DMEM SH / LH / LHU, negative half
        store(DMEM_BASE + 32'h0000_0302, 32'h0000_80FF, SH);
        check_load(DMEM_BASE + 32'h0000_0302, LH,  32'hFFFF_80FF);
        check_load(DMEM_BASE + 32'h0000_0302, LHU, 32'h0000_80FF);

        // DMEM SH / LH / LHU, positive half
        store(DMEM_BASE + 32'h0000_0300, 32'h0000_7FFF, SH);
        check_load(DMEM_BASE + 32'h0000_0300, LH,  32'h0000_7FFF);
        check_load(DMEM_BASE + 32'h0000_0300, LHU, 32'h0000_7FFF);

        // Store byte preserves other lanes
        store(DMEM_BASE + 32'h0000_0400, 32'hAABB_CCDD, SW);
        store(DMEM_BASE + 32'h0000_0401, 32'h0000_0011, SB);
        check_load(DMEM_BASE + 32'h0000_0400, LW, 32'hAABB_11DD);

        // Store half preserves other lanes
        store(DMEM_BASE + 32'h0000_0500, 32'h1122_3344, SW);
        store(DMEM_BASE + 32'h0000_0502, 32'h0000_BEEF, SH);
        check_load(DMEM_BASE + 32'h0000_0500, LW, 32'hBEEF_3344);

        // LEDR / LEDG word store
        store(LEDR_BASE, 32'hCAFE_BABE, SW);
        check_io32("ledr", o_io_ledr, 32'hCAFE_BABE);

        store(LEDG_BASE, 32'h1234_5678, SW);
        check_io32("ledg", o_io_ledg, 32'h1234_5678);

        // Switch load
        i_io_sw = 32'h89AB_CDEF;
        check_load(SW_BASE, LW, 32'h89AB_CDEF);
        check_load(SW_BASE + 32'h1, LBU, 32'h0000_00CD);
        check_load(SW_BASE + 32'h3, LB,  32'hFFFF_FF89);

        // Reserved load returns zero
        check_load(32'h2000_0000, LW, 32'h0000_0000);

        $display(
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count,
            fail_count
        );

        if (fail_count != 0)
            $fatal(1, "LSU TEST FAILED");

        $display("ALL LSU TESTS PASSED");
        $finish;
    end

endmodule
