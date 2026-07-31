`timescale 1ns/1ps

module mux2_32bit_tb;

    logic           i_sel;
    logic [31:0]    i_data0;
    logic [31:0]    i_data1;

    logic [31:0]    o_data;

    int pass_count = 0;
    int fail_count = 0;

    mux2_32bit dut (
        .i_sel  (i_sel),
        .i_data0(i_data0),
        .i_data1(i_data1),

        .o_data(o_data)
    );

    task automatic check_case (
        input logic         test_sel,
        input logic [31:0]  test_data0,
        input logic [31:0]  test_data1,
        input logic [31:0]  expected
    );
        begin 
            i_sel   = test_sel;
            i_data0 = test_data0;
            i_data1 = test_data1;
            
            #1;
            if(o_data === expected) begin 
                pass_count++;

                $display (
                    "PASS: sel=%b data0=%h data1=%h | out=%h",
                    i_sel, i_data0, i_data1, o_data
                );
            end
            else begin 
                fail_count++;

                $display(
                    "FAIL: sel=%b data0=%h data1=%h | actual=%h expected=%h",
                    i_sel, i_data0, i_data1, o_data, expected
                );
            end
        end
    endtask

    initial begin 
        $dumpfile("build/mux2_32bit.vcd");
        $dumpvars(0,mux2_32bit_tb);

        check_case(
            1'b0,
            32'hAAAA_AAAA,
            32'h5555_5555,
            32'hAAAA_AAAA
        );

        check_case(
            1'b1,
            32'hAAAA_AAAA,
            32'h5555_5555,
            32'h5555_5555
        );

        check_case(
            1'b0,
            32'h0000_0000,
            32'hFFFF_FFFF,
            32'h0000_0000
        );

        check_case(
            1'b1,
            32'h0000_0000,
            32'hFFFF_FFFF,
            32'hFFFF_FFFF
        );

        for (int i = 0; i < 100; i++) begin 
            logic           rand_sel;
            logic [31:0]    rand_data0;
            logic [31:0]    rand_data1;
            logic [31:0]    expected;

            rand_sel    = ($urandom_range(0, 1) != 0);
            rand_data0  = $urandom;
            rand_data1  = $urandom;
            expected    = rand_sel ? rand_data1 : rand_data0;

            check_case (
                rand_sel,
                rand_data0,
                rand_data1,
                expected
            );
        end

        $display (
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count, fail_count
        );

        if (fail_count != 0)
            $fatal(1, "MUX2_32BIT TEST FAILED");

        $display("ALL MUX2_32BIT TESTS PASSED");
        $finish;
    end

endmodule


