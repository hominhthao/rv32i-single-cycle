`timescale 1ns/1ps
module sra_32bit (
    input logic [31:0] i_a,
    input logic [4:0]  i_shamt,

    output logic [31:0] o_y
);

    assign o_y = $signed(i_a) >>> i_shamt;
endmodule 
