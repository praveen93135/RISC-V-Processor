`timescale 1ns/1ps

module alu_control_tb;

reg  [1:0] ALUOp;
reg  [2:0] funct3;
reg        funct7_bit;
wire [3:0] ALUControl;

alu_control DUT (
    .ALUOp(ALUOp),
    .funct3(funct3),
    .funct7_bit(funct7_bit),
    .ALUControl(ALUControl)
);

initial begin
    $display("ALUOp funct3 funct7 -> ALUControl");
    $display("--------------------------------");

    ALUOp = 2'b00; funct3 = 3'b000; funct7_bit = 0; #5;
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    ALUOp = 2'b01; funct3 = 3'b000; funct7_bit = 0; #5;
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    ALUOp = 2'b10;

    funct3 = 3'b000; funct7_bit = 0; #5;   
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b000; funct7_bit = 1; #5;   
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b001; funct7_bit = 0; #5;   
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b010; funct7_bit = 0; #5;  
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b011; funct7_bit = 0; #5;  
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b100; funct7_bit = 0; #5;   
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b101; funct7_bit = 0; #5;   
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b101; funct7_bit = 1; #5;   
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b110; funct7_bit = 0; #5;  
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    funct3 = 3'b111; funct7_bit = 0; #5;  
    $display("%b   %b   %b  -> %b", ALUOp, funct3, funct7_bit, ALUControl);

    $display("Test completed.");
    $finish;
end

endmodule
