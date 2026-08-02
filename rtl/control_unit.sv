`timescale 1ns/1ps

module control_unit (
    /* verilator lint_off UNUSEDSIGNAL */   
    input  logic [31:0] i_instr,
    /* verilator lint_on UNUSEDSIGNAL */
    input  logic        i_br_less,
    input  logic        i_br_equal,

    output logic        o_pc_sel,
    output logic        o_rd_wren,
    output logic        o_insn_vld,
    output logic        o_br_un,
    output logic        o_opa_sel,
    output logic        o_opb_sel,
    output logic        o_mem_wren,
    output logic        o_lui_sel,
    output logic [1:0]  o_wb_sel,
    output logic [3:0]  o_alu_op
);

    // ALU operation encoding
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

    // Opcode encoding
    localparam logic [6:0] OPCODE_R      = 7'b0110011;
    localparam logic [6:0] OPCODE_I      = 7'b0010011;
    localparam logic [6:0] OPCODE_LOAD   = 7'b0000011;
    localparam logic [6:0] OPCODE_STORE  = 7'b0100011;
    localparam logic [6:0] OPCODE_BRANCH = 7'b1100011;
    localparam logic [6:0] OPCODE_LUI    = 7'b0110111;
    localparam logic [6:0] OPCODE_AUIPC  = 7'b0010111;
    localparam logic [6:0] OPCODE_JAL    = 7'b1101111;
    localparam logic [6:0] OPCODE_JALR   = 7'b1100111;

    // funct3 encoding for ALU
    localparam logic [2:0] F3_ADD_SUB = 3'b000;
    localparam logic [2:0] F3_SLL     = 3'b001;
    localparam logic [2:0] F3_SLT     = 3'b010;
    localparam logic [2:0] F3_SLTU    = 3'b011;
    localparam logic [2:0] F3_XOR     = 3'b100;
    localparam logic [2:0] F3_SRL_SRA = 3'b101;
    localparam logic [2:0] F3_OR      = 3'b110;
    localparam logic [2:0] F3_AND     = 3'b111;

    // funct3 encoding for branch
    localparam logic [2:0] F3_BEQ  = 3'b000;
    localparam logic [2:0] F3_BNE  = 3'b001;
    localparam logic [2:0] F3_BLT  = 3'b100;
    localparam logic [2:0] F3_BGE  = 3'b101;
    localparam logic [2:0] F3_BLTU = 3'b110;
    localparam logic [2:0] F3_BGEU = 3'b111;

    // funct3 encoding for load
    localparam logic [2:0] F3_LB  = 3'b000;
    localparam logic [2:0] F3_LH  = 3'b001;
    localparam logic [2:0] F3_LW  = 3'b010;
    localparam logic [2:0] F3_LBU = 3'b100;
    localparam logic [2:0] F3_LHU = 3'b101;

    // funct3 encoding for store
    localparam logic [2:0] F3_SB = 3'b000;
    localparam logic [2:0] F3_SH = 3'b001;
    localparam logic [2:0] F3_SW = 3'b010;

    // mux encoding
    localparam logic       PC_PLUS4 = 1'b0;
    localparam logic       PC_ALU   = 1'b1;

    localparam logic       OPA_RS1  = 1'b0;
    localparam logic       OPA_PC   = 1'b1;

    localparam logic       OPB_RS2  = 1'b0;
    localparam logic       OPB_IMM  = 1'b1;

    localparam logic [1:0] WB_LD    = 2'b00;
    localparam logic [1:0] WB_ALU   = 2'b01;
    localparam logic [1:0] WB_PC4   = 2'b10;
    localparam logic [1:0] WB_ZERO  = 2'b11;

    logic [6:0] opcode;
    logic [2:0] funct3;
    logic       funct7_bit5;

    assign opcode      = i_instr[6:0];
    assign funct3      = i_instr[14:12];
    assign funct7_bit5 = i_instr[30];

    always_comb begin
        // Safe defaults
        o_pc_sel   = PC_PLUS4;
        o_rd_wren  = 1'b0;
        o_insn_vld = 1'b0;
        o_br_un    = 1'b0;
        o_opa_sel  = OPA_RS1;
        o_opb_sel  = OPB_RS2;
        o_mem_wren = 1'b0;
        o_lui_sel  = 1'b0;
        o_wb_sel   = WB_ALU;
        o_alu_op   = ALU_ADD;

        unique case (opcode)

            OPCODE_R: begin
                o_pc_sel   = PC_PLUS4;
                o_rd_wren  = 1'b1;
                o_insn_vld = 1'b1;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_RS1;
                o_opb_sel  = OPB_RS2;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_ALU;

                unique case (funct3)
                    F3_ADD_SUB: o_alu_op = funct7_bit5 ? ALU_SUB : ALU_ADD;
                    F3_SLL:     o_alu_op = ALU_SLL;
                    F3_SLT:     o_alu_op = ALU_SLT;
                    F3_SLTU:    o_alu_op = ALU_SLTU;
                    F3_XOR:     o_alu_op = ALU_XOR;
                    F3_SRL_SRA: o_alu_op = funct7_bit5 ? ALU_SRA : ALU_SRL;
                    F3_OR:      o_alu_op = ALU_OR;
                    F3_AND:     o_alu_op = ALU_AND;

                    default: begin
                        o_insn_vld = 1'b0;
                        o_rd_wren  = 1'b0;
                        o_alu_op   = ALU_ADD;
                    end
                endcase
            end

            OPCODE_I: begin
                o_pc_sel   = PC_PLUS4;
                o_rd_wren  = 1'b1;
                o_insn_vld = 1'b1;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_RS1;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_ALU;

                unique case (funct3)
                    F3_ADD_SUB: o_alu_op = ALU_ADD;  // ADDI
                    F3_SLL:     o_alu_op = ALU_SLL;  // SLLI
                    F3_SLT:     o_alu_op = ALU_SLT;  // SLTI
                    F3_SLTU:    o_alu_op = ALU_SLTU; // SLTIU
                    F3_XOR:     o_alu_op = ALU_XOR;  // XORI
                    F3_SRL_SRA: o_alu_op = funct7_bit5 ? ALU_SRA : ALU_SRL; // SRAI/SRLI
                    F3_OR:      o_alu_op = ALU_OR;   // ORI
                    F3_AND:     o_alu_op = ALU_AND;  // ANDI

                    default: begin
                        o_insn_vld = 1'b0;
                        o_rd_wren  = 1'b0;
                        o_alu_op   = ALU_ADD;
                    end
                endcase
            end

            OPCODE_LOAD: begin
                o_pc_sel   = PC_PLUS4;
                o_rd_wren  = 1'b1;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_RS1;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_LD;
                o_alu_op   = ALU_ADD;

                unique case (funct3)
                    F3_LB,
                    F3_LH,
                    F3_LW,
                    F3_LBU,
                    F3_LHU: begin
                        o_insn_vld = 1'b1;
                    end

                    default: begin
                        o_insn_vld = 1'b0;
                        o_rd_wren  = 1'b0;
                    end
                endcase
            end

            OPCODE_STORE: begin
                o_pc_sel   = PC_PLUS4;
                o_rd_wren  = 1'b0;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_RS1;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b1;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_ZERO;
                o_alu_op   = ALU_ADD;

                unique case (funct3)
                    F3_SB,
                    F3_SH,
                    F3_SW: begin
                        o_insn_vld = 1'b1;
                    end

                    default: begin
                        o_insn_vld = 1'b0;
                        o_mem_wren = 1'b0;
                    end
                endcase
            end

            OPCODE_BRANCH: begin
                o_rd_wren  = 1'b0;
                o_opa_sel  = OPA_PC;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_ZERO;
                o_alu_op   = ALU_ADD;

                unique case (funct3)
                    F3_BEQ: begin
                        o_insn_vld = 1'b1;
                        o_br_un    = 1'b0;
                        o_pc_sel   = i_br_equal ? PC_ALU : PC_PLUS4;
                    end

                    F3_BNE: begin
                        o_insn_vld = 1'b1;
                        o_br_un    = 1'b0;
                        o_pc_sel   = (!i_br_equal) ? PC_ALU : PC_PLUS4;
                    end

                    F3_BLT: begin
                        o_insn_vld = 1'b1;
                        o_br_un    = 1'b0;
                        o_pc_sel   = i_br_less ? PC_ALU : PC_PLUS4;
                    end

                    F3_BGE: begin
                        o_insn_vld = 1'b1;
                        o_br_un    = 1'b0;
                        o_pc_sel   = (!i_br_less) ? PC_ALU : PC_PLUS4;
                    end

                    F3_BLTU: begin
                        o_insn_vld = 1'b1;
                        o_br_un    = 1'b1;
                        o_pc_sel   = i_br_less ? PC_ALU : PC_PLUS4;
                    end

                    F3_BGEU: begin
                        o_insn_vld = 1'b1;
                        o_br_un    = 1'b1;
                        o_pc_sel   = (!i_br_less) ? PC_ALU : PC_PLUS4;
                    end

                    default: begin
                        o_insn_vld = 1'b0;
                        o_br_un    = 1'b0;
                        o_pc_sel   = PC_PLUS4;
                    end
                endcase
            end

            OPCODE_LUI: begin
                o_pc_sel   = PC_PLUS4;
                o_rd_wren  = 1'b1;
                o_insn_vld = 1'b1;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_RS1;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b1;   // force operand_a = 0 in datapath
                o_wb_sel   = WB_ALU;
                o_alu_op   = ALU_ADD;
            end

            OPCODE_AUIPC: begin
                o_pc_sel   = PC_PLUS4;
                o_rd_wren  = 1'b1;
                o_insn_vld = 1'b1;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_PC;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_ALU;
                o_alu_op   = ALU_ADD;
            end

            OPCODE_JAL: begin
                o_pc_sel   = PC_ALU;
                o_rd_wren  = 1'b1;
                o_insn_vld = 1'b1;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_PC;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_PC4;
                o_alu_op   = ALU_ADD;
            end

            OPCODE_JALR: begin
                o_pc_sel   = PC_ALU;
                o_rd_wren  = 1'b1;
                o_insn_vld = 1'b1;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_RS1;
                o_opb_sel  = OPB_IMM;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_PC4;
                o_alu_op   = ALU_ADD;
            end

            default: begin
                o_pc_sel   = PC_PLUS4;
                o_rd_wren  = 1'b0;
                o_insn_vld = 1'b0;
                o_br_un    = 1'b0;
                o_opa_sel  = OPA_RS1;
                o_opb_sel  = OPB_RS2;
                o_mem_wren = 1'b0;
                o_lui_sel  = 1'b0;
                o_wb_sel   = WB_ZERO;
                o_alu_op   = ALU_ADD;
            end

        endcase
    end

endmodule
