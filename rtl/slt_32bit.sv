`timescale 1ns/1ps
module slt_32bit (
    input logic [31:0] i_a,
    input logic [31:0] i_b,

    output logic [31:0] o_y
);
    assign o_y = ($signed(i_a) < $signed(i_b)) ? 32'd1 : 32'd0;
endmodule 
