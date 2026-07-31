`timescale 1ns/1ps

module pc (
    input logic         i_clk,
    input logic         i_reset,
    input logic [31:0]  i_pc_next,

    output logic [31:0] o_pc
);
    always_ff @(posedge i_clk) begin 
        if (i_reset) begin 
            o_pc <= 32'h0000_0000;
        end
        else begin 
            o_pc <= i_pc_next;
        end
    end
endmodule  
