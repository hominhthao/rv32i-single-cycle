`timescale 1ns/1ps

module memory (
    input  logic        i_clk,
    input  logic        i_rst_n,

    input  logic [31:0] i_addr,
    input  logic [31:0] i_wrdata,
    input  logic        i_wren,
    input  logic [2:0]  i_func3,

    output logic [31:0] o_rdata
);

    localparam int MEM_SIZE_BYTES = 32768;

    localparam logic [2:0]
        LB  = 3'b000,
        SB  = 3'b000,
        LH  = 3'b001,
        SH  = 3'b001,
        LW  = 3'b010,
        SW  = 3'b010,
        LBU = 3'b100,
        LHU = 3'b101;

    logic [7:0] d_mem [0:MEM_SIZE_BYTES-1];

    logic [14:0] byte_addr;
    logic        byte_valid;
    logic        half_valid;
    logic        word_valid;

    assign byte_addr  = i_addr[14:0];
    assign byte_valid = (i_addr <= 32'h0000_7FFF);
    assign half_valid = (i_addr <= 32'h0000_7FFE);
    assign word_valid = (i_addr <= 32'h0000_7FFC);

    always_ff @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            for (int i = 0; i < MEM_SIZE_BYTES; i++) begin
                d_mem[i] <= 8'b0;
            end
        end
        else if (i_wren) begin
            unique case (i_func3)
                SB: begin
                    if (byte_valid) begin
                        d_mem[byte_addr] <= i_wrdata[7:0];
                    end
                end

                SH: begin
                    if (half_valid) begin
                        d_mem[byte_addr]     <= i_wrdata[7:0];
                        d_mem[byte_addr + 1] <= i_wrdata[15:8];
                    end
                end

                SW: begin
                    if (word_valid) begin
                        d_mem[byte_addr]     <= i_wrdata[7:0];
                        d_mem[byte_addr + 1] <= i_wrdata[15:8];
                        d_mem[byte_addr + 2] <= i_wrdata[23:16];
                        d_mem[byte_addr + 3] <= i_wrdata[31:24];
                    end
                end

                default: begin
                end
            endcase
        end
    end

    always_comb begin
        o_rdata = 32'b0;

        if (!i_wren) begin
            unique case (i_func3)
                LB: begin
                    if (byte_valid) begin
                        o_rdata = {{24{d_mem[byte_addr][7]}},
                                   d_mem[byte_addr]};
                    end
                end

                LBU: begin
                    if (byte_valid) begin
                        o_rdata = {24'b0,
                                   d_mem[byte_addr]};
                    end
                end

                LH: begin
                    if (half_valid) begin
                        o_rdata = {{16{d_mem[byte_addr + 1][7]}},
                                   d_mem[byte_addr + 1],
                                   d_mem[byte_addr]};
                    end
                end

                LHU: begin
                    if (half_valid) begin
                        o_rdata = {16'b0,
                                   d_mem[byte_addr + 1],
                                   d_mem[byte_addr]};
                    end
                end

                LW: begin
                    if (word_valid) begin
                        o_rdata = {d_mem[byte_addr + 3],
                                   d_mem[byte_addr + 2],
                                   d_mem[byte_addr + 1],
                                   d_mem[byte_addr]};
                    end
                end

                default: begin
                    o_rdata = 32'b0;
                end
            endcase
        end
    end

endmodule