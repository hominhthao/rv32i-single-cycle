`timescale 1ns/1ps
module regfile_tb;
    
    logic i_clk;
    logic i_rst_n;
    
    logic i_rd_wren;
    logic [4:0] i_rd_addr;
    logic [4:0] i_rs1_addr;
    logic [4:0] i_rs2_addr;
    logic [31:0] i_rd_data; 

    logic [31:0] o_rs1_data;
    logic [31:0] o_rs2_data;

    regfile dut (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),

        .i_rd_wren(i_rd_wren),
        .i_rd_addr(i_rd_addr),
        .i_rs1_addr(i_rs1_addr),
        .i_rs2_addr(i_rs2_addr),
        .i_rd_data(i_rd_data),

        .o_rs1_data(o_rs1_data),
        .o_rs2_data(o_rs2_data)
    );

task write_reg (
    input logic [4:0] addr,
    input logic [31:0] data
);
    begin 
        @(negedge i_clk);
        i_rd_wren = 1'b1;
        i_rd_addr = addr;
        i_rd_data = data;

        @(negedge i_clk);
        i_rd_wren = 1'b0;
        i_rd_addr = 5'd0;
        i_rd_data = 32'd0;
    end
endtask

task check_read (
    input logic [4:0] rs1_addr,
    input logic [31:0] expected_rs1_data,

    input logic [4:0] rs2_addr,
    input logic [31:0] expected_rs2_data
);
    begin 
        i_rs1_addr = rs1_addr;
        i_rs2_addr = rs2_addr;

        #1;

        if ((o_rs1_data === expected_rs1_data) && (o_rs2_data === expected_rs2_data)) begin
            $display (
                "PASS: rs1=x%0d data=%h | rs2=x%0d data=%h",
                i_rs1_addr, o_rs1_data, i_rs2_addr, o_rs2_data
            );
        end
        else begin 
            $display (
                "FAIL: rs1=x%0d actual=%h expected=%h | rs2=x%0d actual=%h expected=%h",
                i_rs1_addr, o_rs1_data, expected_rs1_data, i_rs2_addr, o_rs2_data, expected_rs2_data
            );
        end
    end
endtask

initial begin 
    i_clk = 1'b0;
    forever #5 i_clk = ~i_clk;
end

initial begin 
    $dumpfile("build/regfile.vcd");
    $dumpvars(0,regfile_tb);

    i_rst_n = 1'b0;
    i_rd_addr = 5'd0;
    i_rd_wren = 1'b0;
    i_rs1_addr = 5'd0;
    i_rs2_addr = 5'd0;
    i_rd_data  = 32'd0;

    #12;
    i_rst_n = 1'b1;

    //after reset
    check_read(5'd1, 32'h0, 5'd2, 32'h0);

    //write x1 and x2
    write_reg(5'd1, 32'h1234_5678);
    write_reg(5'd2, 32'hABCD_EF01);
    check_read(5'd1, 32'h1234_5678, 5'd2, 32'hABCD_EF01);

    //write x0 shoule be ignored 
    write_reg(5'd0, 32'hFFFF_FFFF);
    check_read(5'd0, 32'h0000_0000, 5'd1, 32'h1234_5678);

    //overwrite x1
    write_reg(5'd1, 32'hDEAD_BEEF);
    check_read(5'd1, 32'hDEAD_BEEF, 5'd2, 32'hABCD_EF01);

    //write disable should not modify
    @(negedge i_clk);
    i_rd_wren = 1'b0;
    i_rd_addr = 5'd2;
    i_rd_data = 32'h1111_1111;

    @(negedge i_clk);
    check_read(5'd2, 32'hABCD_EF01, 5'd1, 32'hDEAD_BEEF);

    $finish;
end
endmodule 
