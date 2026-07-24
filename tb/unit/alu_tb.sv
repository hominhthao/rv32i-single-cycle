`timescale 1ns/1ps
module alu_tb;

    logic [3:0]  i_alu_op;
    logic [31:0] i_operand_a;
    logic [31:0] i_operand_b;

    logic [31:0] o_alu_data;

    alu dut (
        .i_alu_op(i_alu_op),
        .i_operand_a(i_operand_a),
        .i_operand_b(i_operand_b),

        .o_alu_data(o_alu_data)
    );

    localparam logic [3:0] ALU_ADD  = 4'b0000;
    localparam logic [3:0] ALU_SUB  = 4'b0001;
    localparam logic [3:0] ALU_SLL  = 4'b0010;
    localparam logic [3:0] ALU_SLT  = 4'b0011;
    localparam logic [3:0] ALU_SLTU = 4'b0100;
    localparam logic [3:0] ALU_XOR  = 4'b0101;
    localparam logic [3:0] ALU_SRL  = 4'b0110;
    localparam logic [3:0] ALU_SRA  = 4'b0111;
    localparam logic [3:0] ALU_OR   = 4'b1000;
    localparam logic [3:0] ALU_AND  = 4'b1001;

task check_op (
    input logic [3:0] test_op,
    input logic [31:0] test_a,
    input logic [31:0] test_b
);
    logic [31:0] expected;

    begin 
        i_alu_op    = test_op;
        i_operand_a = test_a;
        i_operand_b = test_b;

        #1;
        case (test_op)
            ALU_ADD:  expected = test_a + test_b;
            ALU_SUB:  expected = test_a - test_b;
            ALU_SLL:  expected = test_a << test_b[4:0];
            ALU_SLT:  expected = ($signed(test_a) < $signed(test_b)) ? 32'd1 : 32'd0;
            ALU_SLTU: expected = (test_a < test_b) ? 32'd1 : 32'd0;
            ALU_XOR:  expected = test_a ^ test_b;
            ALU_SRL:  expected = test_a >> test_b[4:0];
            ALU_SRA:  expected = $signed(test_a) >>> test_b[4:0];
            ALU_OR:   expected = test_a | test_b;
            ALU_AND:  expected = test_a & test_b;
            default:  expected = 32'b0;
        endcase

        if (o_alu_data === expected) begin 
            $display(
                "PASS: op=%b a=%h b=%h | y=%h",
                test_op, test_a, test_b, o_alu_data
            );
        end
        else begin 
            $display (
                "FAIL: op=%b a=%h b=%h | actual=%h expected=%h",
                test_op, test_a, test_b, o_alu_data, expected
            );
        end
    end
endtask

initial begin 
    $dumpfile("build/alu.vcd");
    $dumpvars(0,alu_tb);

    check_op(ALU_ADD,  32'h0000_0001, 32'h0000_0002);
    check_op(ALU_SUB,  32'h0000_0005, 32'h0000_0003);
    check_op(ALU_SLL,  32'h0000_0001, 32'h0000_0004);
    check_op(ALU_SLT,  32'hFFFF_FFFF, 32'h0000_0001);
    check_op(ALU_SLTU, 32'hFFFF_FFFF, 32'h0000_0001);
    check_op(ALU_XOR,  32'hAAAA_AAAA, 32'h5555_5555);
    check_op(ALU_SRL,  32'h8000_0000, 32'h0000_0001);
    check_op(ALU_SRA,  32'h8000_0000, 32'h0000_0001);
    check_op(ALU_OR,   32'h1234_0000, 32'h0000_5678);
    check_op(ALU_AND,  32'h1234_5678, 32'hFFFF_0000);

    for (int i = 0; i < 100; i++) begin
        check_op(ALU_ADD,  $urandom, $urandom);
        check_op(ALU_SUB,  $urandom, $urandom);
        check_op(ALU_SLL,  $urandom, $urandom);
        check_op(ALU_SLT,  $urandom, $urandom);
        check_op(ALU_SLTU, $urandom, $urandom);
        check_op(ALU_XOR,  $urandom, $urandom);
        check_op(ALU_SRL,  $urandom, $urandom);
        check_op(ALU_SRA,  $urandom, $urandom);
        check_op(ALU_OR,   $urandom, $urandom);
        check_op(ALU_AND,  $urandom, $urandom);
    end

    $finish;
end
endmodule 
