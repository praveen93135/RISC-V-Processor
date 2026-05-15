`timescale 1ns/1ps

module pc_tb;

reg clk;
reg reset;
reg [63:0] pc_in;
wire [63:0] pc_out;

pc uut (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_in),
    .pc_out(pc_out)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin

    $display("Time   Reset  PC_in  PC_out");
    $monitor("%4t     %b     %d     %d",
              $time, reset, pc_in, pc_out);

    reset = 1;
    pc_in = 64'd0;
    #12;              

    reset = 0;
    pc_in = 64'd4;   #10;
    pc_in = 64'd8;   #10;
    pc_in = 64'd12;  #10;
    pc_in = 64'd16;  #10;

    reset = 1; #10;
    reset = 0;

    pc_in = 64'd100; #10;

    $finish;
end

endmodule
