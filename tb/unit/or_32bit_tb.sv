`timescale 1ns/1ps
module or_32bit_tb;

    logic [31:0] i_a;
    logic [31:0] i_b;

    logic [31:0] o_y;

or_32bit dut (
    .i_a(i_a),
    .i_b(i_b),
    
    .o_y(o_y)
);

task check_case (
    input logic [31:0] test_a,
    input logic [31:0] test_b
);
    logic [31:0] expected;

    begin 
        i_a = test_a;
        i_b = test_b;

        #1;

        expected = test_a | test_b;

        if (o_y === expected) begin 
            $display(
                "PASS: a=%h b=%h y=%h",
                i_a, i_b, o_y
            );
        end
        else begin 
            $display(
                "FAIL: a=%h b=%h | actual=%h expected=%h",
                i_a, i_b, o_y, expected
            );
        end
    end
endtask

initial begin 
    $dumpfile("build/or_32bit.vcd");
    $dumpvars(0,or_32bit_tb);

    check_case(32'h0000_0000, 32'h0000_0000);
    check_case(32'hFFFF_FFFF, 32'h0000_0000);
    check_case(32'hFFFF_FFFF, 32'hFFFF_FFFF);
    check_case(32'hAAAA_AAAA, 32'h5555_5555);
    check_case(32'h1234_5678, 32'hFFFF_0000);
    check_case(32'h1234_5678, 32'h0000_FFFF);

    for (int i = 0; i < 100; i++) begin
        check_case($urandom, $urandom);
    end

    $finish;
end
endmodule 