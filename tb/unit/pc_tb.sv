`timescale 1ns/1ps

module pc_tb;

    logic        i_clk;
    logic        i_reset;
    logic [31:0] i_pc_next;

    logic [31:0] o_pc;

    int pass_count = 0;
    int fail_count = 0;

    pc dut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_pc_next(i_pc_next),

        .o_pc(o_pc)
    );

    initial begin 
        i_clk = 1'b0;
        forever #5 i_clk = ~i_clk;
    end

    task automatic apply_and_check (
        input logic        reset,
        input logic [31:0] pc_next,

        input logic [31:0] expected
    );
        begin 
            @(negedge i_clk);

            i_reset = reset;
            i_pc_next = pc_next;

            @(posedge i_clk);
            #1;

            if(o_pc === expected) begin 
                pass_count++;
                $display (
                    "PASS: pc=%h expected=%h", o_pc, expected
                );
            end
            else begin 
                fail_count++;
                $display (
                    "FAI:: actual=%h expected=%h", o_pc, expected
                );
            end
        end
    endtask

    initial begin 
        $dumpfile("build/pc.vcd");
        $dumpvars(0, pc_tb);

        i_reset     = 1'b1;
        i_pc_next = 32'h0000_0000;

        apply_and_check(1'b1, 32'hDEAD_BEEF, 32'h0000_0000);
        apply_and_check(1'b0, 32'h0000_0004, 32'h0000_0004);
        apply_and_check(1'b0, 32'h0000_0008, 32'h0000_0008);
        apply_and_check(1'b0, 32'h0000_1000, 32'h0000_1000);
        apply_and_check(1'b1, 32'hCAFE_BABE, 32'h0000_0000);

        $display(
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count,
            fail_count
        );

        if (fail_count != 0)
            $fatal(1, "PC TEST FAILED");

        $display("ALL PC TESTS PASSED");
        $finish;
    end
endmodule 


        
