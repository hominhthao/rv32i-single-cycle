`timescale 1ns/1ps

module pc_plus4_tb;
    
    logic [31:0] i_pc;

    logic [31:0] o_pc_four;

    pc_plus4 dut (
        .i_pc(i_pc),
        .o_pc_four(o_pc_four)
    );

    int pass_count =0;
    int fail_count =0;

    task automatic check_case (
        input logic [31:0] pc,
        input logic [31:0] expected
    );        
        begin 
            i_pc      = pc;

            #1;
            if (o_pc_four === expected) begin 
                pass_count++;
                $display (
                    "PASS: pc=%h pc_plus4=%h",
                    pc, o_pc_four
                );
            end
            else begin 
                fail_count++;
                $display (
                    "FAIL: pc=%h | actual=%h expected=%h",
                    pc, o_pc_four, expected
                );
            end
        end
    endtask

    initial begin 
        $dumpfile("build/pc_plus4.vcd");
        $dumpvars(0, pc_plus4_tb);
        
        check_case(32'h0000_0000, 32'h0000_0004);
        check_case(32'h0000_0004, 32'h0000_0008);
        check_case(32'h0000_0008, 32'h0000_000C);
        check_case(32'h0000_1000, 32'h0000_1004);
        check_case(32'hFFFF_FFFC, 32'h0000_0000); // wrap around 32-bit

        $display (
            "\nSUMMARY: PASS=%0d FAIL=%0d",
            pass_count, fail_count
        );

        if(fail_count !=0) begin
            $fatal(1, "PC_PLUS4 TEST FAILED");
        end
        else begin 
            $display("ALL PC_PLUS4 TEST PASSED");
        end
        
        $finish;
    end
endmodule 
