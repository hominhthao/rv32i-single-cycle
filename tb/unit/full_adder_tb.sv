`timescale 1ns/1ps

module full_adder_tb;

    logic i_a;
    logic i_b;
    logic i_cin;

    logic o_sum;
    logic o_cout;

    logic expected_sum;
    logic expected_cout;

    full_adder dut (
        .i_a    (i_a),
        .i_b    (i_b),
        .i_cin  (i_cin),

        .o_sum  (o_sum),
        .o_cout (o_cout)
    );

    initial begin
        $dumpfile("build/full_adder.vcd");
        $dumpvars(0, full_adder_tb);

        for (int i = 0; i < 8; i++) begin
            // Generate one of the eight input combinations
            {i_a, i_b, i_cin} = i[2:0];

            // Allow combinational outputs to update
            #1;

            // Golden/reference model
            {expected_cout, expected_sum} =
                i_a + i_b + i_cin;

            if ((o_sum === expected_sum) &&
                (o_cout === expected_cout)) begin

                $display(
                    "PASS: a=%0b b=%0b cin=%0b | sum=%0b cout=%0b",
                    i_a, i_b, i_cin, o_sum, o_cout
                );

            end
            else begin

                $display(
                    "FAIL: a=%0b b=%0b cin=%0b actual={%0b,%0b} expected={%0b,%0b}",
                    i_a, i_b, i_cin,
                    o_cout, o_sum,
                    expected_cout, expected_sum
                );

            end
        end

        $finish;
    end

endmodule