`timescale 1ns/1ps
module regfile (
    input logic         i_clk,
    input logic         i_rst_n,
    
    input logic         i_rd_wren,
    input logic [4:0]   i_rs1_addr,
    input logic [4:0]   i_rs2_addr,
    input logic [4:0]   i_rd_addr,

    input logic [31:0]  i_rd_data,

    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data
);
    //array: 32 register of 32 bits each
    logic [31:0] regs [0:31];

    always_ff @( posedge i_clk or negedge i_rst_n ) begin
        if (!i_rst_n) begin 
            for (int i =0; i<32; i++) begin 
                regs[i] <= 32'b0;
            end
        end
        else if (i_rd_wren && i_rd_addr != 5'b0) begin  //x0 luôn bằng 0 -> cấm ghi x0
            regs[i_rd_addr] <= i_rd_data;
        end
    end
    //Read port 1: read data form regs[i_rs1_data]
    assign o_rs1_data = (i_rs1_addr == 5'b0) ? 32'd0 : regs[i_rs1_addr];
    assign o_rs2_data = (i_rs2_addr == 5'b0) ? 32'd0 : regs[i_rs2_addr];
endmodule 
