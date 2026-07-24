`timescale 1ns/1ps
module subtractor_32bit_tb;

    logic [31:0] i_a;
    logic [31:0] i_b;

    logic [31:0] o_diff;
    logic        o_cout;

subtractor_32bit dut (
    .i_a(i_a),
    .i_b(i_b),

    .o_diff(o_diff),
    .o_cout(o_cout)
);

task check_case (
    input logic [31:0] test_a,
    input logic [31:0] test_b
);
    logic [31:0] expected_diff;
    logic        expected_cout;

    begin
        i_a = test_a;
        i_b = test_b;

        #1;

        expected_diff = test_a - test_b;
        expected_cout = (test_a >= test_b);

        if ((o_diff === expected_diff) && (o_cout === expected_cout)) begin 
            $display(
                "PASS: a=%h b=%h | diff=%h cout=%0b", 
                i_a, i_b, o_diff, o_cout
            );
        end
        else begin 
            $display(
                "FAIL: a=%h b=%h | actual = {couter=%0b, diff=%h} expected={cout=%0b, diff=%h}",
                i_a, i_b, o_cout, o_diff, expected_cout, expected_diff
            );
        end
    end
endtask

initial begin 
    $dumpfile("build/subtractor_32bit.vcd");
    $dumpvars(0,subtractor_32bit_tb);
  
    check_case(32'h0000_0000, 32'h0000_0000);
    check_case(32'h0000_0001, 32'h0000_0000);
    check_case(32'h0000_0001, 32'h0000_0001);
    check_case(32'h0000_0005, 32'h0000_0003);
    check_case(32'h0000_0003, 32'h0000_0005);

    check_case(32'h0000_0000, 32'h0000_0001);
    check_case(32'h0000_0000, 32'hFFFF_FFFF);
    check_case(32'hFFFF_FFFF, 32'h0000_0001);
    check_case(32'hFFFF_FFFF, 32'hFFFF_FFFF);

    check_case(32'h8000_0000, 32'h0000_0001);
    check_case(32'h7FFF_FFFF, 32'hFFFF_FFFF);
    check_case(32'h8000_0000, 32'h8000_0000);

    for(int i = 0; i < 100; i++) begin 
        check_case($urandom, $urandom);
    end

    $finish;
end
endmodule 
