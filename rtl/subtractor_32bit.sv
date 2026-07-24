`timescale 1ns/1ps

module subtractor_32bit (
    input logic [31:0] i_a,
    input logic [31:0] i_b,

    output logic [31:0] o_diff,
    output logic        o_cout
);

    adder_32bit u_sub (
        .i_a    (i_a),
        .i_b    (~i_b),
        .i_cin  (1'b1),

        .o_sum  (o_diff),
        .o_cout (o_cout)
    );

endmodule 
