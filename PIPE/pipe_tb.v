`timescale 1ns/1ps

`include "PC.v"
`include "instruction_mem.v"
`include "control_unit.v"
`include "imm_gen.v"
`include "register_file.v"
`include "alu_control.v"
`include "alu.v"
`include "data_mem.v"
`include "mux2_64.v"
`include "sum64.v"
`include "IF_ID.v"
`include "ID_EX.v"
`include "EX_MEM.v"
`include "MEM_WB.v"
`include "hazard_unit.v"
`include "forward_unit.v"
`include "forward_mux.v"
`include "branch_mux.v"
`include "integrate.v"
`include "ld_sd_forward.v"
`include "branch_predictor.v"
`include "branch_target_buffer.v"
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
    #15; 
    reset = 0;

    for (i = 0; i < 1000; i = i + 1) begin
        @(posedge clk);
        
        cycle_count = cycle_count + 1;

        $display("\n=== Cycle %0d ===", cycle_count);
        $display("  [IF ] PC=%h  Instr_Fetched=%h", 
                 DUT.pc_out, DUT.instruction);
        $display("  [ID ] PC=%h  Instr_In_ID=%h",
                 DUT.pc_IF_ID, DUT.instr_IF_ID);
        $display("  [EX ] PC=%h  rd=x%0d  ALU_Res=%h",
                 DUT.pc_ID_EX, DUT.rd_ID_EX, DUT.alu_result);

        if (DUT.instruction == 32'h00000000 && cycle_count >= 1) begin
            $display("\n[TERMINATE] Null instruction detected in IF Stage at Cycle %0d.", cycle_count);
            
            outfile = $fopen("register_file.txt", "w");
            for (integer j = 0; j < 32; j = j + 1)
                $fdisplay(outfile, "%016h", DUT.U_REGFILE.registers[j]);

            $fdisplay(outfile, "%0d", cycle_count);
            $fclose(outfile);

            $display("Program finished.");
            $finish; 
        end
    end

    $display("Simulation reached timeout.");
    $finish;
end

endmodule