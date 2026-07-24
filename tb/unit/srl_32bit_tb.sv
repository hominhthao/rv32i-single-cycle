`timescale 1ns/1ps
module srl_32bit_tb;

    logic [31:0] i_a;
    logic [4:0]  i_shamt;

    logic [31:0] o_y;

    srl_32bit dut (
        .i_a(i_a),
        .i_shamt(i_shamt),

        .o_y(o_y)
    );

task check_case (
    input logic [31:0] test_a,
    input logic [4:0]  test_shamt
);
    logic [31:0] expected;

    begin 
        i_a = test_a;
        i_shamt = test_shamt;

        #1;
        expected = test_a >> test_shamt;

        if (o_y === expected) begin 
            $display(
                "PASS: a=%h shamt=%d y=%h",
                i_a, i_shamt, o_y
            );
        end
        else begin 
            $display(
                "FAIL: a=%h shamt=%d | actual=%h expected=%h",
                i_a, i_shamt, o_y, expected
            );
        end
    end
endtask

initial begin 
    $dumpfile("build/srl_32bit.vcd");
    $dumpvars(0,srl_32bit_tb);

    check_case(32'h0000_0001, 5'd0);
    check_case(32'h0000_0001, 5'd1);
    check_case(32'h0000_0001, 5'd4);
    check_case(32'h8000_0000, 5'd1);
    check_case(32'hFFFF_FFFF, 5'd1);
    check_case(32'h1234_5678, 5'd4);
    check_case(32'h1234_5678, 5'd8);
    check_case(32'h1234_5678, 5'd16);
    check_case(32'h1234_5678, 5'd31);

    for (int i=0; i<100; i++) begin 
        check_case($urandom, $urandom_range(0,31));
    end

    $finish;
end
endmodule 
