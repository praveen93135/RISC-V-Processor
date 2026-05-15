module MEM_WB (
    input clk,
    input reset,

    input [63:0] ALU_data,
    input [63:0] read_Data,

    input MemtoReg,
    input regwrite,

    input [4:0] EX_MEM_rd,

    output reg MemtoReg_out,
    output reg regwrite_out,

    output reg [63:0] ALU_data_out,
    output reg [63:0] read_Data_out,

    output reg [4:0] MEM_WB_rd
);

always @(posedge clk or posedge reset) begin

    if (reset) begin
        read_Data_out <= 64'b0;
        ALU_data_out  <= 64'b0;

        MemtoReg_out  <= 1'b0;
        regwrite_out  <= 1'b0;

        MEM_WB_rd     <= 5'b0;
    end

    else begin
        read_Data_out <= read_Data;
        ALU_data_out  <= ALU_data;

        MemtoReg_out  <= MemtoReg;
        regwrite_out  <= regwrite;

        MEM_WB_rd     <= EX_MEM_rd;
    end

end

endmodule