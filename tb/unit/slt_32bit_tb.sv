`timescale 1ns/1ps
module slt_32bit_tb;

    logic [31:0] i_a;
    logic [31:0] i_b;

    logic [31:0] o_y;

    slt_32bit dut (
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
        expected = ($signed (test_a) < $signed (test_b)) ? 32'd1 : 32'd0;

        if (o_y === expected) begin 
            $display (
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
    $dumpfile ("build/slt_32bit.vcd");
    $dumpvars (0,slt_32bit_tb);

    check_case(32'h0000_0000, 32'h0000_0000); // 0 < 0 false
    check_case(32'h0000_0001, 32'h0000_0002); // 1 < 2 true
    check_case(32'h0000_0002, 32'h0000_0001); // 2 < 1 false

    check_case(32'hFFFF_FFFF, 32'h0000_0001); // -1 < 1 true
    check_case(32'h0000_0001, 32'hFFFF_FFFF); // 1 < -1 false
    check_case(32'h8000_0000, 32'h0000_0000); // min neg < 0 true
    check_case(32'h7FFF_FFFF, 32'h8000_0000); // max pos < min neg false
    check_case(32'h8000_0000, 32'h7FFF_FFFF); // min neg < max pos true

    for (int i = 0; i < 100; i++) begin
        check_case($urandom, $urandom);
    end

    $finish;   
end
endmodule 
