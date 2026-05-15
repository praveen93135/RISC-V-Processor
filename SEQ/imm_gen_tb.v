`timescale 1ns/1ps
`include "imm_gen.v"

module imm_gen_tb;

reg  [31:0] instr;
wire [63:0] imm;

imm_gen uut (
    .instruction(instr),
    .imm_ext(imm)
);

initial begin
    $display("Instruction        Immediate (decimal)    Immediate (hex)");
    $display("---------------------------------------------------------");

    instr = 32'h00500113; #5;
    $display("%h    %0d    %h", instr, imm, imm);

    instr = 32'h00A00193; #5;
    $display("%h    %0d    %h", instr, imm, imm);

    instr = 32'h0012B023; #5;
    $display("%h    %0d    %h", instr, imm, imm);

    instr = 32'h0002B503; #5;
    $display("%h    %0d    %h", instr, imm, imm);

    instr = 32'h00520263; #5;
    $display("%h    %0d    %h", instr, imm, imm);

    instr = 32'h00000063; #5;
    $display("%h    %0d    %h", instr, imm, imm);

    instr = 32'hFFB10113; #5;
    $display("%h    %0d    %h", instr, imm, imm);

    $finish;
end

endmodule
