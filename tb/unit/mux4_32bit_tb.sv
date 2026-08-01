`timescale  1ns/1ps

module mux4_32bit_tb;

    logic [1:0]     i_sel;
    logic [31:0]    i_data0;
    logic [31:0]    i_data1;
    logic [31:0]    i_data2;
    logic [31:0]    i_data3;

    logic [31:0]    o_data;

    int pass_count = 0;
    int fail_count = 0;

    mux4_32bit dut (
        .i_sel(i_sel),
        .i_data0(i_data0),
        .i_data1(i_data1),
        .i_data2(i_data2),
        .i_data3(i_data3),

        .o_data(o_data)
    );

    task automatic check_case (
        input logic [1:0] test_sel,
        input logic [31:0] test_data0,
        input logic [31:0] test_data1,
        input logic [31:0] test_data2,
        input logic [31:0] test_data3,
        input logic [31:0] expected
    );
        begin 
            i_sel   = test_sel;
            i_data0 = test_data0;
            i_data1 = test_data1;
            i_data2 = test_data2;
            i_data3 = test_data3;

            #1;
            if(o_data === expected ) begin 
                pass_count++;
                $display (
                    "PASS: sel=%b data0=%h data1=%h data2=%h data3=%h | out=%h",
                    test_sel, test_data0, test_data1, test_data2, test_data3, o_data
                );
            end
            else begin 
                fail_count++;
                $display (
                    "FAIL: sel=%b data0=%h data1=%h data2=%h data3=%h | actual=%h expected=%h",
                    test_sel, test_data0, test_data1, test_data2, test_data3, o_data, expected
                );
            end
        end
    endtask

        initial begin 
            $dumpfile ("build/mux4.vcd");
            $dumpvars(0, mux4_32bit_tb);

                    check_case(
            2'b00,
            32'hAAAA_AAAA,
            32'hBBBB_BBBB,
            32'hCCCC_CCCC,
            32'hDDDD_DDDD,
            32'hAAAA_AAAA
        );

        check_case(
            2'b01,
            32'hAAAA_AAAA,
            32'hBBBB_BBBB,
            32'hCCCC_CCCC,
            32'hDDDD_DDDD,
            32'hBBBB_BBBB
        );

        check_case(
            2'b10,
            32'hAAAA_AAAA,
            32'hBBBB_BBBB,
            32'hCCCC_CCCC,
            32'hDDDD_DDDD,
            32'hCCCC_CCCC
        );

        check_case(
            2'b11,
            32'hAAAA_AAAA,
            32'hBBBB_BBBB,
            32'hCCCC_CCCC,
            32'hDDDD_DDDD,
            32'hDDDD_DDDD
        );

        for (int i = 0; i <100; i++) begin 
            logic [1:0]  rand_sel;
            logic [31:0] rand_data0;          
            logic [31:0] rand_data1;
            logic [31:0] rand_data2;
            logic [31:0] rand_data3;
            logic [31:0] expected;

            rand_sel   = 2'($urandom_range(0, 3));
            rand_data0 = $urandom;
            rand_data1 = $urandom;
            rand_data2 = $urandom;
            rand_data3 = $urandom;

            unique case (rand_sel)
                2'b00: expected = rand_data0;
                2'b01: expected = rand_data1;
                2'b10: expected = rand_data2;
                2'b11: expected = rand_data3;
                default: expected = 32'b0;
            endcase

            check_case(
                rand_sel,
                rand_data0,
                rand_data1,
                rand_data2,
                rand_data3,
                expected
            );
        end

        $display(
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count,
            fail_count
        );

        if (fail_count != 0)
            $fatal(1, "MUX4_32BIT TEST FAILED");

        $display("ALL MUX4_32BIT TESTS PASSED");
        $finish;
    end
endmodule





