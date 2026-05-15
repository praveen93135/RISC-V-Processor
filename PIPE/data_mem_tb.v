`timescale 1ns/1ps

module data_mem_tb;

reg clk;
reg reset;
reg mem_read;
reg mem_write;
reg [63:0] addr;
reg [63:0] write_data;
wire [63:0] read_data;

data_mem DUT (
    .clk(clk),
    .reset(reset),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .addr(addr),
    .write_data(write_data),
    .read_data(read_data)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    reset = 1;
    mem_read = 0;
    mem_write = 0;
    addr = 0;
    write_data = 0;
    #10;

    reset = 0;

    addr = 64'd16;
    write_data = 64'h1122334455667788;
    mem_write = 1;
    #10;
    mem_write = 0;

    mem_read = 1;
    #5;
    $display("Read = %h", read_data);

    addr = 64'd24;
    write_data = 64'hAABBCCDDEEFF0011;
    mem_write = 1;
    mem_read = 0;
    #10;
    mem_write = 0;

    mem_read = 1;
    #5;
    $display("Read = %h", read_data);

    mem_read = 0;
    #20;

    $finish;
end

endmodule
