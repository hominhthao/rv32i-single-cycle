`timescale 1ns/1ps

module immgen_tb;

    logic [31:0] i_instr;
    logic [31:0] o_immgen;

    int pass_count = 0;
    int fail_count = 0;

    immgen dut (
        .i_instr   (i_instr),
        .o_immgen  (o_immgen)
    );

    task automatic check_case (
        input logic [31:0] test_instr,
        input logic [31:0] expected
    );
        begin
            i_instr = test_instr;

            #1;

            if (o_immgen === expected) begin
                pass_count++;

                $display(
                    "PASS: instr=%h | imm=%h",
                    i_instr,
                    o_immgen
                );
            end
            else begin
                fail_count++;

                $display(
                    "FAIL: instr=%h | actual=%h expected=%h",
                    i_instr,
                    o_immgen,
                    expected
                );
            end
        end
    endtask

    initial begin
        $dumpfile("build/immgen.vcd");
        $dumpvars(0, immgen_tb);

        // R-type and invalid opcode
        check_case(32'h0000_0033, 32'h0000_0000);
        check_case(32'h0000_0000, 32'h0000_0000);

        // I-format: ADDI, Load, JALR
        check_case(32'h0010_0013, 32'h0000_0001);
        check_case(32'hFFF0_0013, 32'hFFFF_FFFF);
        check_case(32'h0040_0003, 32'h0000_0004);
        check_case(32'h0080_0067, 32'h0000_0008);

        // S-format
        check_case(32'h0020_2223, 32'h0000_0004);
        check_case(32'hFE20_2E23, 32'hFFFF_FFFC);

        // B-format
        check_case(32'h0000_0063, 32'h0000_0000);
        check_case(32'hFE00_0EE3, 32'hFFFF_FFFC);

        // U-format
        check_case(32'h1234_5037, 32'h1234_5000);
        check_case(32'h1234_5017, 32'h1234_5000);

        // J-format
        check_case(32'h0000_006F, 32'h0000_0000);
        check_case(32'hFFDFF06F, 32'hFFFF_FFFC);

        $display(
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count,
            fail_count
        );

        if (fail_count != 0)
            $fatal(1, "IMMGEN TEST FAILED");

        $display("ALL IMMGEN TESTS PASSED");
        $finish;
    end

endmodule
