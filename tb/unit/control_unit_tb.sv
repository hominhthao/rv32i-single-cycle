`timescale 1ns/1ps

module control_unit_tb;

    logic [31:0] i_instr;
    logic        i_br_less;
    logic        i_br_equal;

    logic        o_pc_sel;
    logic        o_rd_wren;
    logic        o_insn_vld;
    logic        o_br_un;
    logic        o_opa_sel;
    logic        o_opb_sel;
    logic        o_mem_wren;
    logic        o_lui_sel;
    logic [1:0]  o_wb_sel;
    logic [3:0]  o_alu_op;

    int pass_count = 0;
    int fail_count = 0;

    control_unit dut (
        .i_instr    (i_instr),
        .i_br_less  (i_br_less),
        .i_br_equal (i_br_equal),

        .o_pc_sel   (o_pc_sel),
        .o_rd_wren  (o_rd_wren),
        .o_insn_vld (o_insn_vld),
        .o_br_un    (o_br_un),
        .o_opa_sel  (o_opa_sel),
        .o_opb_sel  (o_opb_sel),
        .o_mem_wren (o_mem_wren),
        .o_lui_sel  (o_lui_sel),
        .o_wb_sel   (o_wb_sel),
        .o_alu_op   (o_alu_op)
    );

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

    task automatic check_case (
        input string       name,
        input logic [31:0] test_instr,
        input logic        test_br_less,
        input logic        test_br_equal,

        input logic        exp_pc_sel,
        input logic        exp_rd_wren,
        input logic        exp_insn_vld,
        input logic        exp_br_un,
        input logic        exp_opa_sel,
        input logic        exp_opb_sel,
        input logic        exp_mem_wren,
        input logic        exp_lui_sel,
        input logic [1:0]  exp_wb_sel,
        input logic [3:0]  exp_alu_op
    );
        begin
            i_instr    = test_instr;
            i_br_less  = test_br_less;
            i_br_equal = test_br_equal;

            #1;

            if ((o_pc_sel   === exp_pc_sel)   &&
                (o_rd_wren  === exp_rd_wren)  &&
                (o_insn_vld === exp_insn_vld) &&
                (o_br_un    === exp_br_un)    &&
                (o_opa_sel  === exp_opa_sel)  &&
                (o_opb_sel  === exp_opb_sel)  &&
                (o_mem_wren === exp_mem_wren) &&
                (o_lui_sel  === exp_lui_sel)  &&
                (o_wb_sel   === exp_wb_sel)   &&
                (o_alu_op   === exp_alu_op)) begin

                pass_count++;

                $display(
                    "PASS: %s instr=%h",
                    name,
                    test_instr
                );
            end
            else begin
                fail_count++;

                $display("FAIL: %s instr=%h", name, test_instr);

                $display(
                    "  pc_sel   actual=%b expected=%b",
                    o_pc_sel,
                    exp_pc_sel
                );

                $display(
                    "  rd_wren  actual=%b expected=%b",
                    o_rd_wren,
                    exp_rd_wren
                );

                $display(
                    "  insn_vld actual=%b expected=%b",
                    o_insn_vld,
                    exp_insn_vld
                );

                $display(
                    "  br_un    actual=%b expected=%b",
                    o_br_un,
                    exp_br_un
                );

                $display(
                    "  opa_sel  actual=%b expected=%b",
                    o_opa_sel,
                    exp_opa_sel
                );

                $display(
                    "  opb_sel  actual=%b expected=%b",
                    o_opb_sel,
                    exp_opb_sel
                );

                $display(
                    "  mem_wren actual=%b expected=%b",
                    o_mem_wren,
                    exp_mem_wren
                );

                $display(
                    "  lui_sel  actual=%b expected=%b",
                    o_lui_sel,
                    exp_lui_sel
                );

                $display(
                    "  wb_sel   actual=%b expected=%b",
                    o_wb_sel,
                    exp_wb_sel
                );

                $display(
                    "  alu_op   actual=%b expected=%b",
                    o_alu_op,
                    exp_alu_op
                );
            end
        end
    endtask

    initial begin
        $dumpfile("build/control_unit.vcd");
        $dumpvars(0, control_unit_tb);

        // ADD x3, x1, x2
        check_case(
            "ADD",
            32'h0020_81B3,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_RS2,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_ADD
        );

        // SUB x3, x1, x2
        check_case(
            "SUB",
            32'h4020_81B3,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_RS2,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_SUB
        );

        // SLL x3, x1, x2
        check_case(
            "SLL",
            32'h0020_91B3,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_RS2,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_SLL
        );

        // SRL x3, x1, x2
        check_case(
            "SRL",
            32'h0020_D1B3,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_RS2,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_SRL
        );

        // SRA x3, x1, x2
        check_case(
            "SRA",
            32'h4020_D1B3,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_RS2,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_SRA
        );

        // ADDI x1, x0, 5
        check_case(
            "ADDI",
            32'h0050_0093,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_ADD
        );

        // ANDI x1, x0, 5
        check_case(
            "ANDI",
            32'h0050_7093,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_AND
        );

        // LW x2, 8(x1)
        check_case(
            "LW",
            32'h0080_A103,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_LD,
            ALU_ADD
        );

        // LBU x2, 8(x1)
        check_case(
            "LBU",
            32'h0080_C103,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_LD,
            ALU_ADD
        );

        // SW x2, 8(x1)
        check_case(
            "SW",
            32'h0020_A423,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b0,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b1,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // SB x2, 8(x1)
        check_case(
            "SB",
            32'h0020_8423,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b0,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b1,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // BEQ taken
        check_case(
            "BEQ taken",
            32'h0020_8063,
            1'b0,
            1'b1,
            PC_ALU,
            1'b0,
            1'b1,
            1'b0,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // BEQ not taken
        check_case(
            "BEQ not taken",
            32'h0020_8063,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b0,
            1'b1,
            1'b0,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // BNE taken
        check_case(
            "BNE taken",
            32'h0020_9063,
            1'b0,
            1'b0,
            PC_ALU,
            1'b0,
            1'b1,
            1'b0,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // BLT taken
        check_case(
            "BLT taken",
            32'h0020_C063,
            1'b1,
            1'b0,
            PC_ALU,
            1'b0,
            1'b1,
            1'b0,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // BGE taken
        check_case(
            "BGE taken",
            32'h0020_D063,
            1'b0,
            1'b0,
            PC_ALU,
            1'b0,
            1'b1,
            1'b0,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // BLTU taken
        check_case(
            "BLTU taken",
            32'h0020_E063,
            1'b1,
            1'b0,
            PC_ALU,
            1'b0,
            1'b1,
            1'b1,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // BGEU taken
        check_case(
            "BGEU taken",
            32'h0020_F063,
            1'b0,
            1'b0,
            PC_ALU,
            1'b0,
            1'b1,
            1'b1,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        // LUI x1, 0x12345
        check_case(
            "LUI",
            32'h1234_50B7,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b0,
            1'b1,
            WB_ALU,
            ALU_ADD
        );

        // AUIPC x1, 0x12345
        check_case(
            "AUIPC",
            32'h1234_5097,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b1,
            1'b1,
            1'b0,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_ALU,
            ALU_ADD
        );

        // JAL x1, 0
        check_case(
            "JAL",
            32'h0000_00EF,
            1'b0,
            1'b0,
            PC_ALU,
            1'b1,
            1'b1,
            1'b0,
            OPA_PC,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_PC4,
            ALU_ADD
        );

        // JALR x1, 0(x2)
        check_case(
            "JALR",
            32'h0001_00E7,
            1'b0,
            1'b0,
            PC_ALU,
            1'b1,
            1'b1,
            1'b0,
            OPA_RS1,
            OPB_IMM,
            1'b0,
            1'b0,
            WB_PC4,
            ALU_ADD
        );

        // Invalid opcode
        check_case(
            "INVALID",
            32'h0000_0000,
            1'b0,
            1'b0,
            PC_PLUS4,
            1'b0,
            1'b0,
            1'b0,
            OPA_RS1,
            OPB_RS2,
            1'b0,
            1'b0,
            WB_ZERO,
            ALU_ADD
        );

        $display(
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count,
            fail_count
        );

        if (fail_count != 0)
            $fatal(1, "CONTROL_UNIT TEST FAILED");

        $display("ALL CONTROL_UNIT TESTS PASSED");
        $finish;
    end

endmodule
