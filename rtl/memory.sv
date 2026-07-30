`timescale 1ns/1ps

module memory (
    input  logic        i_clk,
    input  logic        i_reset,

    input  logic [31:0] i_addr,
    input  logic [31:0] i_wdata,
    input  logic [3:0]  i_bmask,
    input  logic        i_wren,

    output logic [31:0] o_rdata
);

    localparam int MEM_SIZE_BYTES = 2048;
    localparam int MEM_SIZE_WORDS = MEM_SIZE_BYTES / 4;

    logic [31:0] mem [0:MEM_SIZE_WORDS-1];

    logic [8:0]  word_addr;
    logic        word_valid;

    assign word_addr  = i_addr[10:2];
    assign word_valid = (i_addr < MEM_SIZE_BYTES);

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            for (int i = 0; i < MEM_SIZE_WORDS; i++) begin
                mem[i] <= 32'b0;
            end
        end
        else if (i_wren && word_valid) begin
            if (i_bmask[0]) mem[word_addr][7:0]   <= i_wdata[7:0];
            if (i_bmask[1]) mem[word_addr][15:8]  <= i_wdata[15:8];
            if (i_bmask[2]) mem[word_addr][23:16] <= i_wdata[23:16];
            if (i_bmask[3]) mem[word_addr][31:24] <= i_wdata[31:24];
        end
    end

    always_comb begin
        if (word_valid) begin
            o_rdata = mem[word_addr];
        end
        else begin
            o_rdata = 32'b0;
        end
    end

endmodule

