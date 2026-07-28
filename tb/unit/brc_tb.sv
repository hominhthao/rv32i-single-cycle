`timescale 1ns/1ps
module brc_tb;

    logic [31:0] i_rs1_data;
    logic [31:0] i_rs2_data;

    logic        i_br_un;

    logic        o_br_equal;
    logic        o_br_less;

    brc dut (
        .i_rs1_data(i_rs1_data),
        .i_rs2_data(i_rs2_data),
        .i_br_un(i_br_un),

        .o_br_equal(o_br_equal),
        .o_br_less(o_br_less)
    );

task automatic check_case (
    input logic [31:0] test_rs1,
    input logic [31:0] test_rs2,
    input logic        test_br_un
);

    logic expected_less;
    logic expected_equal;

    begin 
        i_rs1_data = test_rs1;
        i_rs2_data = test_rs2;
        i_br_un    = test_br_un;

        #1;
        expected_equal = (test_rs1 == test_rs2);

        if(test_br_un) begin
            expected_less = (test_rs1 < test_rs2);
        end
        else begin 
            expected_less = ($signed(test_rs1) < $signed(test_rs2));
        end        

        if ((o_br_equal ===  expected_equal) &&
           (o_br_less === expected_less)) begin 
            $display (
                "PASS: rs1=%h rs2=%h unsigned=%b | equal=%b less=%b",
                test_rs1, test_rs2, test_br_un, o_br_equal, o_br_less
            );
        end
        else begin 
            $display (
                "FAIL: rs1=%h rs2=%h unsigned=%b | equal_actual=%b expected=%b | less_actual=%b expected=%b",
                test_rs1, test_rs2, test_br_un, o_br_equal, expected_equal, o_br_less, expected_less
            );
        end
    end
endtask

initial begin 
    $dumpfile("build/brc.vcd");
    $dumpvars(0,brc_tb);

    // 1. Hai số bằng nhau, unsigned
    check_case(
        32'h0000_0005,
        32'h0000_0005,
        1'b1
    );

    // 2. Hai số bằng nhau, signed
    check_case(
        32'hFFFF_FFFF,
        32'hFFFF_FFFF,
        1'b0
    );

    // 3. Unsigned: 5 < 10
    check_case(
        32'h0000_0005,
        32'h0000_000A,
        1'b1
    );

    // 4. Unsigned: 10 không nhỏ hơn 5
    check_case(
        32'h0000_000A,
        32'h0000_0005,
        1'b1
    );

    // 5. Signed: -1 < 1
    check_case(
        32'hFFFF_FFFF,
        32'h0000_0001,
        1'b0
    );

    // 6. Unsigned: 0xFFFF_FFFF > 1
    check_case(
        32'hFFFF_FFFF,
        32'h0000_0001,
        1'b1
    );

    // 7. Signed minimum < signed maximum
    check_case(
        32'h8000_0000,
        32'h7FFF_FFFF,
        1'b0
    );

    // 8. Unsigned: 0x8000_0000 > 0x7FFF_FFFF
    check_case(
        32'h8000_0000,
        32'h7FFF_FFFF,
        1'b1
    );

    // 9. Signed: 1 không nhỏ hơn -1
    check_case(
        32'h0000_0001,
        32'hFFFF_FFFF,
        1'b0
    );

    // 10. Zero < positive
    check_case(
        32'h0000_0000,
        32'h0000_0001,
        1'b0
    );

    // 11. Positive không nhỏ hơn zero
    check_case(
        32'h0000_0001,
        32'h0000_0000,
        1'b1
    );

    // 12. Cả hai bằng zero
    check_case(
        32'h0000_0000,
        32'h0000_0000,
        1'b0
    );

    $finish;
end

endmodule
