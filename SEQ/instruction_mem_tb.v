`timescale 1ns/1ps
`include "instruction_mem.v"

module instruction_mem_tb;

reg  [63:0] addr;
wire [31:0] instr;

instruction_mem uut (
    .clk(1'b0),
    .reset(1'b0),
    .addr(addr),
    .instr(instr)
);

initial begin
    $display("Testing Instruction Memory...\n");

    addr = 64'd0;   
    #5 $display("PC = 0   -> instr = %h", instr);

    addr = 64'd4;   
    #5 $display("PC = 4   -> instr = %h", instr);

    addr = 64'd8;   
    #5 $display("PC = 8   -> instr = %h", instr);

    addr = 64'd12;  
    #5 $display("PC = 12  -> instr = %h", instr);

    addr = 64'd16;  
    #5 $display("PC = 16  -> instr = %h", instr);

    addr = 64'd20;  
    #5 $display("PC = 20  -> instr = %h", instr);

    $finish;
end

endmodule
