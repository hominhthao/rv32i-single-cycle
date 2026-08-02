`timescale 1ns/1ps

module memory #(
    parameter int    MEM_SIZE_BYTES = 32768, // 32 KiB, valid addr: 0x0000_0000 - 0x0000_7FFF
    parameter bit    RESET_CLEAR    = 1'b1,  // 1: reset clears memory, 0: reset keeps memory content
    parameter string INIT_FILE      = ""     // optional $readmemh file
) (
    input  logic        i_clk,
    input  logic        i_reset,

    input  logic [31:0] i_addr,
    input  logic [31:0] i_wdata,
    input  logic [3:0]  i_bmask,
    input  logic        i_wren,

    output logic [31:0] o_rdata
);

    localparam int MEM_SIZE_WORDS = MEM_SIZE_BYTES / 4;
    localparam int WORD_ADDR_W    = $clog2(MEM_SIZE_WORDS);

    logic [31:0] mem [0:MEM_SIZE_WORDS-1];

    logic [WORD_ADDR_W-1:0] word_addr;
    logic                   word_valid;

    assign word_addr  = i_addr[WORD_ADDR_W+1:2];
    assign word_valid = (i_addr < MEM_SIZE_BYTES);

    integer i;

    initial begin
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, mem);
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            if (RESET_CLEAR) begin
                for (i = 0; i < MEM_SIZE_WORDS; i++) begin
                    mem[i] <= 32'b0;
                end
            end
        end
        else if (i_wren && word_valid) begin
            if (i_bmask[0]) begin
                mem[word_addr][7:0] <= i_wdata[7:0];
            end

            if (i_bmask[1]) begin
                mem[word_addr][15:8] <= i_wdata[15:8];
            end

            if (i_bmask[2]) begin
                mem[word_addr][23:16] <= i_wdata[23:16];
            end

            if (i_bmask[3]) begin
                mem[word_addr][31:24] <= i_wdata[31:24];
            end
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
