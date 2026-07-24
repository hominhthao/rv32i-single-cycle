`timescale 1ns/1ps
module alu (
    input logic [3:0] i_alu_op,
    input logic [31:0] i_operand_a,
    input logic [31:0] i_operand_b,

    output logic [31:0] o_alu_data
);
    logic [31:0] add_y;
    logic [31:0] sub_y;
    logic [31:0] sll_y;
    logic [31:0] srl_y;
    logic [31:0] sra_y;
    logic [31:0] and_y;
    logic [31:0] or_y;
    logic [31:0] xor_y;
    logic [31:0] slt_y;
    logic [31:0] sltu_y;

/* verilator lint_off UNUSEDSIGNAL */
logic add_cout;
logic sub_cout;
/* verilator lint_on UNUSEDSIGNAL */


adder_32bit u_add (
    .i_a    (i_operand_a),
    .i_b    (i_operand_b),
    .i_cin  (1'b0),

    .o_sum  (add_y),
    .o_cout (add_cout)
);

subtractor_32bit u_sub (
    .i_a    (i_operand_a),
    .i_b    (i_operand_b),

    .o_diff (sub_y),
    .o_cout (sub_cout)
);

sll_32bit   u_sll (
    .i_a    (i_operand_a),
    .i_shamt(i_operand_b[4:0]),

    .o_y    (sll_y)
);

srl_32bit   u_srl (
    .i_a    (i_operand_a),
    .i_shamt(i_operand_b[4:0]),

    .o_y    (srl_y)
);

sra_32bit   u_sra (
    .i_a    (i_operand_a),
    .i_shamt(i_operand_b[4:0]),

    .o_y    (sra_y)
);

and_32bit   u_and (
    .i_a    (i_operand_a),
    .i_b    (i_operand_b),

    .o_y    (and_y)
);

or_32bit    u_or (
    .i_a    (i_operand_a),
    .i_b    (i_operand_b),

    .o_y    (or_y)
);

xor_32bit   u_xor (
    .i_a    (i_operand_a),
    .i_b    (i_operand_b),

    .o_y    (xor_y)
);

slt_32bit   u_slt (
    .i_a    (i_operand_a),
    .i_b    (i_operand_b),

    .o_y    (slt_y)
);

sltu_32bit  u_sltu (
    .i_a    (i_operand_a),
    .i_b    (i_operand_b),

    .o_y    (sltu_y)
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

always_comb begin 
    unique case (i_alu_op)
        ALU_ADD: o_alu_data = add_y;
        ALU_SUB: o_alu_data = sub_y;
        ALU_SLL:  o_alu_data = sll_y;
        ALU_SLT:  o_alu_data = slt_y;
        ALU_SLTU: o_alu_data = sltu_y;
        ALU_XOR:  o_alu_data = xor_y;
        ALU_SRL:  o_alu_data = srl_y;
        ALU_SRA:  o_alu_data = sra_y;
        ALU_OR:   o_alu_data = or_y;
        ALU_AND:  o_alu_data = and_y;
        default:  o_alu_data = 32'b0;
    endcase
end
endmodule 
