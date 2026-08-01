`timescale  1ns/1ps

module mux4_32bit (

    input logic [1:0]   i_sel,
    input logic [31:0]  i_data0,
    input logic [31:0]  i_data1,
    input logic [31:0]  i_data2,
    input logic [31:0]  i_data3,

    output logic [31:0] o_data
);

    always_comb begin 
        unique case (i_sel)
            2'b00: o_data = i_data0;
            2'b01: o_data = i_data1;
            2'b10: o_data = i_data2;
            2'b11: o_data = i_data3;
            default : o_data = 32'b0;
        endcase
    end
endmodule 
