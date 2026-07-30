`timescale 1ns/1ps

module lsu (
    input  logic        i_clk,
    input  logic        i_reset,

    input  logic [31:0] i_lsu_addr,
    input  logic [31:0] i_st_data,
    input  logic        i_lsu_wren,
    input  logic [2:0]  i_func3,

    output logic [31:0] o_ld_data,

    output logic [31:0] o_io_ledr,
    output logic [31:0] o_io_ledg,
    output logic [6:0]  o_io_hex0,
    output logic [6:0]  o_io_hex1,
    output logic [6:0]  o_io_hex2,
    output logic [6:0]  o_io_hex3,
    output logic [6:0]  o_io_hex4,
    output logic [6:0]  o_io_hex5,
    output logic [6:0]  o_io_hex6,
    output logic [6:0]  o_io_hex7,
    output logic [31:0] o_io_lcd,

    input  logic [31:0] i_io_sw
);

    localparam logic [2:0]
        LB  = 3'b000,
        SB  = 3'b000,
        LH  = 3'b001,
        SH  = 3'b001,
        LW  = 3'b010,
        SW  = 3'b010,
        LBU = 3'b100,
        LHU = 3'b101;

    localparam logic [31:0]
        DMEM_TOP   = 32'h0000_07FF,
        LEDR_BASE  = 32'h1000_0000,
        LEDR_TOP   = 32'h1000_0FFF,
        LEDG_BASE  = 32'h1000_1000,
        LEDG_TOP   = 32'h1000_1FFF,
        HEX03_BASE = 32'h1000_2000,
        HEX03_TOP  = 32'h1000_2FFF,
        HEX47_BASE = 32'h1000_3000,
        HEX47_TOP  = 32'h1000_3FFF,
        LCD_BASE   = 32'h1000_4000,
        LCD_TOP    = 32'h1000_4FFF,
        SW_BASE    = 32'h1001_0000,
        SW_TOP     = 32'h1001_0FFF;

    logic is_dmem;
    logic is_ledr;
    logic is_ledg;
    logic is_hex03;
    logic is_hex47;
    logic is_lcd;
    logic is_sw;

    logic [31:0] mem_addr;
    logic [31:0] mem_wdata;
    logic [3:0]  mem_bmask;
    logic        mem_wren;
    logic [31:0] mem_rdata;

    logic [1:0] byte_offset;
    logic       half_sel;

    logic [7:0]  load_byte;
    logic [15:0] load_half;

    assign is_dmem  = (i_lsu_addr <= DMEM_TOP);
    assign is_ledr  = (i_lsu_addr >= LEDR_BASE)  && (i_lsu_addr <= LEDR_TOP);
    assign is_ledg  = (i_lsu_addr >= LEDG_BASE)  && (i_lsu_addr <= LEDG_TOP);
    assign is_hex03 = (i_lsu_addr >= HEX03_BASE) && (i_lsu_addr <= HEX03_TOP);
    assign is_hex47 = (i_lsu_addr >= HEX47_BASE) && (i_lsu_addr <= HEX47_TOP);
    assign is_lcd   = (i_lsu_addr >= LCD_BASE)   && (i_lsu_addr <= LCD_TOP);
    assign is_sw    = (i_lsu_addr >= SW_BASE)    && (i_lsu_addr <= SW_TOP);

    assign byte_offset = i_lsu_addr[1:0];
    assign half_sel    = i_lsu_addr[1];

    assign mem_addr = {i_lsu_addr[31:2], 2'b00};
    assign mem_wren = i_lsu_wren && is_dmem;

    always_comb begin
        mem_bmask = 4'b0000;
        mem_wdata = 32'b0;

        unique case (i_func3)
            SB: begin
                unique case (byte_offset)
                    2'b00: begin
                        mem_bmask = 4'b0001;
                        mem_wdata = {24'b0, i_st_data[7:0]};
                    end

                    2'b01: begin
                        mem_bmask = 4'b0010;
                        mem_wdata = {16'b0, i_st_data[7:0], 8'b0};
                    end

                    2'b10: begin
                        mem_bmask = 4'b0100;
                        mem_wdata = {8'b0, i_st_data[7:0], 16'b0};
                    end

                    2'b11: begin
                        mem_bmask = 4'b1000;
                        mem_wdata = {i_st_data[7:0], 24'b0};
                    end
                endcase
            end

            SH: begin 
                if (!half_sel) begin 
                    mem_bmask = 4'b0011;
                    mem_wdata = {16'b0, i_st_data[15:0]};
                end
                else begin 
                    mem_bmask = 4'b1100;
                    mem_wdata = {i_st_data[15:0], 16'b0};
                end
            end

            SW: begin 
                mem_bmask = 4'b1111;
                mem_wdata = i_st_data;
            end

            default: begin 
                mem_bmask = 4'b0000;
                mem_wdata = 32'b0;
            end
        endcase
    end

    memory u_dmem (
        .i_clk   (i_clk),
        .i_reset (i_reset),

        .i_addr  (mem_addr),
        .i_wdata (mem_wdata),
        .i_bmask (mem_bmask),
        .i_wren  (mem_wren),
        .o_rdata (mem_rdata)
    );

    always_comb begin 
        unique case (byte_offset)
            2'b00: load_byte = mem_rdata[7:0];
            2'b01: load_byte = mem_rdata[15:8];
            2'b10: load_byte = mem_rdata[23:16];
            2'b11: load_byte = mem_rdata[31:24];
            default: load_byte = 8'b0;
        endcase
    end

    always_comb begin 
        if(!half_sel) begin 
            load_half = mem_rdata[15:0];
        end 
        else begin 
            load_half = mem_rdata[31:16];
        end
    end

    always_comb begin 
        o_ld_data = 32'b0;

        if (is_dmem) begin 
            unique case (i_func3)
                LB: begin 
                    o_ld_data = {{24{load_byte[7]}}, load_byte};
                end

                LBU: begin 
                    o_ld_data = {24'b0, load_byte};
                end

                LH: begin 
                    o_ld_data = {{16{load_half[15]}}, load_half};
                end

                LHU: begin 
                    o_ld_data = {16'b0, load_half};
                end

                LW: begin 
                    o_ld_data = mem_rdata;
                end

                default: begin 
                    o_ld_data = 32'b0;
                end
            endcase
        end

        else if (is_sw) begin 
            unique case (i_func3)
                LB: begin 
                    unique case (byte_offset)
                        2'b00: o_ld_data = {{24{i_io_sw[7]}}, i_io_sw[7:0]};
                        2'b01: o_ld_data = {{24{i_io_sw[15]}},i_io_sw[15:8]};
                        2'b10: o_ld_data = {{24{i_io_sw[23]}},i_io_sw[23:16]};
                        2'b11: o_ld_data = {{24{i_io_sw[31]}},i_io_sw[31:24]};
                    endcase
                end

                LBU: begin 
                    unique case (byte_offset)
                        2'b00: o_ld_data = {24'b0, i_io_sw[7:0]};
                        2'b01: o_ld_data = {24'b0, i_io_sw[15:8]};
                        2'b10: o_ld_data = {24'b0, i_io_sw[23:16]};
                        2'b11: o_ld_data = {24'b0, i_io_sw[31:24]};
                    endcase
                end

                LH: begin 
                    if (!half_sel) begin 
                        o_ld_data = {{16{i_io_sw[15]}}, i_io_sw[15:0]};
                    end
                    else begin 
                        o_ld_data = {{16{i_io_sw[31]}}, i_io_sw[31:16]};
                    end
                end

                LHU: begin 
                    if (!half_sel) begin 
                        o_ld_data = {16'b0, i_io_sw[15:0]};
                    end
                    else begin 
                        o_ld_data = {16'b0, i_io_sw[31:16]};
                    end
                end

                LW: begin 
                    o_ld_data = i_io_sw;
                end

                default begin 
                    o_ld_data = 32'b0;
                end
            endcase
        end
    end

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            o_io_ledr <= 32'b0;
            o_io_ledg <= 32'b0;
            o_io_hex0 <= 7'b0;
            o_io_hex1 <= 7'b0;
            o_io_hex2 <= 7'b0;
            o_io_hex3 <= 7'b0;
            o_io_hex4 <= 7'b0;
            o_io_hex5 <= 7'b0;
            o_io_hex6 <= 7'b0;
            o_io_hex7 <= 7'b0;
            o_io_lcd  <= 32'b0;
        end
        else if (i_lsu_wren) begin
            if (is_ledr) begin
                o_io_ledr <= i_st_data;
            end
            else if (is_ledg) begin
                o_io_ledg <= i_st_data;
            end
            else if (is_hex03) begin
                o_io_hex0 <= i_st_data[6:0];
                o_io_hex1 <= i_st_data[14:8];
                o_io_hex2 <= i_st_data[22:16];
                o_io_hex3 <= i_st_data[30:24];
            end
            else if (is_hex47) begin
                o_io_hex4 <= i_st_data[6:0];
                o_io_hex5 <= i_st_data[14:8];
                o_io_hex6 <= i_st_data[22:16];
                o_io_hex7 <= i_st_data[30:24];
            end
            else if (is_lcd) begin
                o_io_lcd <= i_st_data;
            end
        end
    end

endmodule

