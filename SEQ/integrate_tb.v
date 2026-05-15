`timescale 1ns/1ps


module integrate_tb;


reg clk;
reg reset;


riscv_cpu DUT (
    .clk   (clk),
    .reset (reset)
);


initial clk = 0;
always #5 clk = ~clk;


integer cycle;

initial begin

    $display("=================================================================");
    $display(" Cycle |    PC    |  Instruction  | x1(ra)  | x2(sp)  | x3(gp)  | x4(tp)  | x5(t0)");
    $display("=================================================================");

    reset = 1;
    repeat(2) @(posedge clk);
    reset = 0;


    for (cycle = 0; cycle < 20; cycle = cycle + 1) begin
        @(posedge clk);
        #1; 
        $display(" %3d   | %8h | %b | %8h | %8h | %8h | %8h | %8h",
            cycle,
            DUT.pc_out,
            DUT.instruction,
            DUT.U_REGFILE.registers[1],
            DUT.U_REGFILE.registers[2],
            DUT.U_REGFILE.registers[3],
            DUT.U_REGFILE.registers[4],
            DUT.U_REGFILE.registers[5]
        );
    end

    $display("=================================================================");
    $display("Simulation complete.");
    $finish;
end

initial begin
    $dumpfile("integrate_tb.vcd");
    $dumpvars(0, integrate_tb);
end

endmodule
