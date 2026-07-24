`timescale 1ns/1ps

module adder_32bit (

    input logic [31:0] i_a,
    input logic [31:0] i_b,
    input logic        i_cin,

    output logic [31:0] o_sum,
    output logic        o_cout
);
    logic [32:0]        carry;

    genvar i;

    generate 
        for(i = 0; i < 32; i++) begin: gen_fa
            full_adder fa(
                .i_a(i_a[i]),
                .i_b(i_b[i]), 
                .i_cin(carry[i]),
                .o_sum(o_sum[i]), 
                .o_cout(carry[i+1])
            );
        end
    endgenerate

    assign carry[0] = i_cin;
    assign o_cout   = carry[32];

endmodule 
