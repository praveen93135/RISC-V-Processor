`timescale 1ns/1ps

module register_file_tb;

reg clk;
reg reset;
reg reg_write_en;
reg [4:0] read_reg1;
reg [4:0] read_reg2;
reg [4:0] write_reg;
reg [63:0] write_data;

wire [63:0] read_data1;
wire [63:0] read_data2;

register_file uut (
    .clk(clk),
    .reset(reset),
    .reg_write_en(reg_write_en),
    .read_reg1(read_reg1),
    .read_reg2(read_reg2),
    .write_reg(write_reg),
    .write_data(write_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $display("Time  WR  Wreg  Wdata   R1  D1   R2  D2");
    $monitor("%4t  %b   %d   %d   %d  %d   %d  %d",
             $time, reg_write_en, write_reg, write_data,
             read_reg1, read_data1,
             read_reg2, read_data2);

    reset = 1;
    reg_write_en = 0;
    read_reg1 = 0;
    read_reg2 = 0;
    #12;
    reset = 0;

    write_reg = 5'd1;
    write_data = 64'd10;
    reg_write_en = 1;
    #10;

    write_reg = 5'd2;
    write_data = 64'd20;
    #10;

    reg_write_en = 0;

    read_reg1 = 5'd1;
    read_reg2 = 5'd2;
    #10;

    reg_write_en = 1;
    write_reg = 5'd0;
    write_data = 64'd999;
    #10;

    reg_write_en = 0;
    read_reg1 = 5'd0;
    #10;

    reg_write_en = 1;
    write_reg = 5'd1;
    write_data = 64'd55;
    #10;

    reg_write_en = 0;
    read_reg1 = 5'd1;
    #10;

    $finish;
end

endmodule
