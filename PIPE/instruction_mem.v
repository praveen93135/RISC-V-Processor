`define IMEM_SIZE 4096

module instruction_mem(
    input  wire [63:0] addr,
    input  wire clk,
    input  wire reset,
    output wire [31:0] instr
);
integer i;

reg [7:0] imem [0:`IMEM_SIZE-1];

initial begin
  for (i = 0; i < `IMEM_SIZE; i = i + 1)
    imem[i] = 8'h00;

   $readmemh("instructions.txt", imem);
end

assign instr = {
    imem[addr[11:0]],
    imem[addr[11:0] + 1],
    imem[addr[11:0] + 2],
    imem[addr[11:0] + 3]
};

endmodule
