`timescale 1ns/1ps
`include "control_unit.v"

module control_unit_tb;

reg  [6:0] opcode;

wire Branch;
wire MemRead;
wire MemtoReg;
wire [1:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;

control_unit uut (
    .opcode(opcode),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
);

initial begin
    $display(" opcode | Br MR M2R MW AS RW | ALUOp ");
    $display("------------------------------------");

    opcode = 7'b0110011; #5;
    $display("%b | %b  %b  %b   %b  %b  %b  | %b", 
             opcode, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);

    opcode = 7'b0010011; #5;
    $display("%b | %b  %b  %b   %b  %b  %b  | %b", 
             opcode, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);

    opcode = 7'b0000011; #5;
    $display("%b | %b  %b  %b   %b  %b  %b  | %b", 
             opcode, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);

    opcode = 7'b0100011; #5;
    $display("%b | %b  %b  %b   %b  %b  %b  | %b", 
             opcode, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);

    opcode = 7'b1100011; #5;
    $display("%b | %b  %b  %b   %b  %b  %b  | %b", 
             opcode, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);

    opcode = 7'b1111111; #5;
    $display("%b | %b  %b  %b   %b  %b  %b  | %b", 
             opcode, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, ALUOp);

    $finish;
end

endmodule
