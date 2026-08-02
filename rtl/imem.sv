`timescale 1ns/1ps

module imem #(
    parameter string INIT_FILE = ""
) (
    input  logic        i_clk,
    input  logic        i_reset,
    input  logic [31:0] i_addr,

    output logic [31:0] o_instr
);

    memory #(
        .MEM_SIZE_BYTES (32768),
        .RESET_CLEAR    (1'b0),
        .INIT_FILE      (INIT_FILE)
    ) u_mem (
        .i_clk   (i_clk),
        .i_reset (i_reset),

        .i_addr  (i_addr),
        .i_wdata (32'b0),
        .i_bmask (4'b0000),
        .i_wren  (1'b0),

        .o_rdata (o_instr)
    );

endmodule
