`timescale 1ns/1ps
`include "PC.v"
`include "instruction_mem.v"
`include "control_unit.v"
`include "imm_gen.v"
`include "register_file.v"
`include "alu_control.v"
`include "alu.v"
`include "data_mem.v"
`include "integrate.v"
`include "mux2_64.v"
`include "sum64.v"
module seq_tb;

reg clk;
reg reset;

integer i;
integer cycle_count;
integer outfile;

riscv_cpu DUT (
    .clk(clk),
    .reset(reset)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    cycle_count = 0;

    reset = 1;
    repeat(2) @(posedge clk);
    reset = 0;

    for (i = 0; i < 500; i = i + 1) begin
        @(posedge clk);

        cycle_count = cycle_count + 1;

        $display("\nCycle %0d:", i + 1);
        $display("PC: %h", DUT.pc_out);
        $display("Instruction: %h", DUT.instruction);
        $display("ALU Output: %h", DUT.alu_result);
        $display("Register Write Enable: %b", DUT.RegWrite);
        $display("Memory Write Enable: %b", DUT.MemWrite);
        $display("Branch: %b", DUT.Branch);
        $display("x4: %h\n", DUT.U_REGFILE.registers[4]);

        if (DUT.instruction == 32'h00000000) begin
            $display("\nProgram completed after %0d cycles", i + 1);
            i = 500;
        end
    end

    outfile = $fopen("register_file.txt", "w");

    for (i = 0; i < 32; i = i + 1)
        $fdisplay(outfile, "%016h", DUT.U_REGFILE.registers[i]);

    $fdisplay(outfile, "%0d", cycle_count);
    $fclose(outfile);

    $display("Program finished.");
    $finish;
end

endmodule
