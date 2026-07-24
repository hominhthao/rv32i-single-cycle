`timescale 1ns/1ps
module sltu_32bit (
    input logic [31:0] i_a,
    input logic [31:0] i_b,

    output logic [31:0] o_y
);
    assign o_y = (i_a < i_b) ? 32'd1 : 32'd0;
endmodule 
