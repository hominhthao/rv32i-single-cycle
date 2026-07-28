`timescale 1ns/1ps
module brc (

    input logic [31:0] i_rs1_data,
    input logic [31:0] i_rs2_data,
    input logic        i_br_un,

    output logic       o_br_less,
    output logic       o_br_equal
);

    assign o_br_equal = (i_rs1_data == i_rs2_data);

    always_comb begin 
        if (i_br_un) begin 
            o_br_less = (i_rs1_data < i_rs2_data) ;
        end
        else begin 
            o_br_less = ($signed(i_rs1_data)) < ($signed(i_rs2_data)); 
        end
    end
endmodule 
