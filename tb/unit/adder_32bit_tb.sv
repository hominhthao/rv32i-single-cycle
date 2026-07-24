`timescale 1ns/1ps

module adder_32bit_tb;

    logic [31:0] i_a;
    logic [31:0] i_b;
    logic        i_cin;

    logic [31:0] o_sum;
    logic        o_cout;

    adder_32bit dut (
        .i_a(i_a),
        .i_b(i_b),
        .i_cin(i_cin),
        
        .o_sum(o_sum),
        .o_cout(o_cout)
    );

task check_case(
    input logic [31:0] test_a,
    input logic [31:0] test_b,
    input logic        test_cin
);
    logic [32:0] expected;

    begin 
        i_a    = test_a;
        i_b    = test_b;
        i_cin  = test_cin;

        #1;

        expected = {1'b0, test_a} + {1'b0, test_b} + test_cin;

        if((o_sum === expected[31:0]) && (o_cout === expected[32])) begin 
            $display(
                "PASS: a=%h b=%h c=%0b | cout=%0b sum=%h", 
                i_a, i_b, i_cin, o_cout, o_sum
            );
        end
        else begin 
            $display(
                "FAIL: a=%h b=%h c=%0b | actual={%0b,%h} expected={%0b,%h}", 
                i_a, i_b, i_cin, o_cout, o_sum, expected[31:0], expected[32] 
            );
        end
    end
endtask

initial begin 
    $dumpfile("build/adder_32bit.vcd");
    $dumpvars(0,adder_32bit_tb);

    check_case(32'h0000_0000, 32'h0000_0000, 1'b0);
    check_case(32'h0000_0000, 32'h0000_0000, 1'b1);
    check_case(32'h0000_0001, 32'h0000_0001, 1'b0);
    check_case(32'h0000_0001, 32'h0000_0001, 1'b1);

    check_case(32'h0000_FFFF, 32'h0000_0001, 1'b0);
    check_case(32'hFFFF_FFFF, 32'h0000_0001, 1'b0);
    check_case(32'hFFFF_FFFF, 32'h0000_0000, 1'b1);

    check_case(32'h1234_5678, 32'h1111_1111, 1'b0);
    check_case(32'h8000_0000, 32'h7FFF_FFFF, 1'b0);
    check_case(32'hFFFF_FFFF, 32'hFFFF_FFFF, 1'b0);
    check_case(32'h8000_0000, 32'h8000_0000, 1'b0);

    for (int i = 0; i <100; i++) begin 
        check_case($urandom, $urandom, $urandom_range(0,1));
    end

    $finish;
end
endmodule 

