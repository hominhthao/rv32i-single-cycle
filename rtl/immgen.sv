`timescale 1ns/1ps 
module immgen (
    input logic [31:0] i_instr,

    output logic [31:0] o_immgen
);
    logic [6:0] opcode;
    assign opcode = i_instr[6:0];

//OP_Code
localparam logic [6:0] R_type   = 7'b0110011,
                       I_type   = 7'b0010011,
                       S_type   = 7'b0100011, // Store
                       L_type   = 7'b0000011, // Load
                       B_type   = 7'b1100011, // Branch
                       UL_type  = 7'b0110111, // LUI
                       UA_type  = 7'b0010111, // AUIPC
                       UJ_type  = 7'b1101111, // JAL
                       IJ_type  = 7'b1100111; // JALR (I_type format)

always_comb begin 
    o_immgen = 32'b0;

    unique case (opcode) 
        R_type: 
            o_immgen = 32'b0; // R_type has no imediate 

        //I_type (ADDI, JALR)
        I_type, L_type, IJ_type: 
            o_immgen = {{20{i_instr[31]}}, i_instr[31:20]};
        
        //S_type (SW, SH, SB)
        S_type:
            o_immgen = {{20{i_instr[31]}}, i_instr[31:25], i_instr[11:7]};

        //B-type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
        B_type: 
            o_immgen = {{19{i_instr[31]}}, i_instr [31], i_instr[7], i_instr[30:25], i_instr[11:8], 1'b0};
        
        //U_type (LUI, AUIPC)
        UL_type, UA_type:
            o_immgen ={i_instr[31:12], 12'b0};
        
        //UJ_type (JAL)
        UJ_type:
            o_immgen = {{11{i_instr[31]}}, i_instr[31], i_instr[19:12], i_instr[20], i_instr[30:21], 1'b0};
        
        default: 
            o_immgen = 32'h0;
    endcase
end
endmodule 




