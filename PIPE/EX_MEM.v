module EX_MEM (
    input clk,
    input reset,

    input [63:0] ALU_data,
    input [63:0] rd_data,
    input [63:0] branch_target,
    input zero,

    input [4:0] Rd,

    input MemtoReg,
    input regwrite,
    input branch,
    input MemRead,
    input MemWrite,

    output reg [63:0] branch_target_out,
    output reg [63:0] ALU_data_out,
    output reg [63:0] rd_data_out,
    output reg zero_out,

    output reg MemtoReg_out,
    output reg regwrite_out,
    output reg branch_out,
    output reg MemRead_out,
    output reg MemWrite_out,

    output reg [4:0] EX_MEM_rd
);

always @(posedge clk or posedge reset) begin

    if (reset) begin
        ALU_data_out      <= 64'b0;
        rd_data_out       <= 64'b0;
        branch_target_out <= 64'b0;
        zero_out          <= 1'b0;

        MemtoReg_out      <= 1'b0;
        regwrite_out      <= 1'b0;
        branch_out        <= 1'b0;
        MemRead_out       <= 1'b0;
        MemWrite_out      <= 1'b0;

        EX_MEM_rd         <= 5'b0;
    end
    else begin
        ALU_data_out      <= ALU_data;
        rd_data_out       <= rd_data;
        branch_target_out <= branch_target;
        zero_out          <= zero;

        MemtoReg_out      <= MemtoReg;
        regwrite_out      <= regwrite;
        branch_out        <= branch;
        MemRead_out       <= MemRead;
        MemWrite_out      <= MemWrite;

        EX_MEM_rd         <= Rd;
    end

end

endmodule