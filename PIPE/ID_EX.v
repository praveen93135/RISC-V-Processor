module ID_EX(
    input clk,
    input reset,
    input flush,

    input [63:0] imm_gen_in,
    input [63:0] ID_EX_pc_in,
    input [63:0] ID_EX_R1_in,
    input [63:0] ID_EX_R2_in,

    input [4:0] ID_EX_rs1_in,
    input [4:0] ID_EX_rs2_in,
    input [4:0] ID_EX_rd_in,

    input alu_src_in,
    input [1:0] alu_op_in,
    input [2:0] funct3_in,
    input funct7_bit_in,

    input mem_read_in,
    input mem_write_in,
    input branch_in,

    input mem_to_reg_in,
    input reg_write_in,
    input pred_taken_in,
    input pred1_in,
    input pred2_in,

    output reg [63:0] imm_gen_out,
    output reg [63:0] ID_EX_pc_out,
    output reg [63:0] ID_EX_R1_out,
    output reg [63:0] ID_EX_R2_out,

    output reg [4:0] ID_EX_rs1_out,
    output reg [4:0] ID_EX_rs2_out,
    output reg [4:0] ID_EX_rd_out,

    output reg alu_src_out,
    output reg [1:0] alu_op_out,
    output reg [2:0] funct3_out,
    output reg funct7_bit_out,

    output reg mem_read_out,
    output reg mem_write_out,
    output reg branch_out,

    output reg mem_to_reg_out,
    output reg reg_write_out,
    output reg pred_taken_out,
    output reg pred1_out,
    output reg pred2_out 
);

always @(posedge clk or posedge reset) begin

    if (reset || flush) begin

        imm_gen_out   <= 0;
        ID_EX_pc_out  <= 0;
        ID_EX_R1_out  <= 0;
        ID_EX_R2_out  <= 0;

        ID_EX_rs1_out <= 0;
        ID_EX_rs2_out <= 0;
        ID_EX_rd_out  <= 0;

        alu_src_out   <= 0;
        alu_op_out    <= 0;
        funct3_out    <= 0;
        funct7_bit_out <= 0;

        mem_read_out  <= 0;
        mem_write_out <= 0;
        branch_out    <= 0;

        mem_to_reg_out <= 0;
        reg_write_out  <= 0;
        pred_taken_out <= 0;
        pred1_out      <= 0;
        pred2_out      <= 0;
    end

    else begin
        imm_gen_out   <= imm_gen_in;
        ID_EX_pc_out  <= ID_EX_pc_in;
        ID_EX_R1_out  <= ID_EX_R1_in;
        ID_EX_R2_out  <= ID_EX_R2_in;

        ID_EX_rs1_out <= ID_EX_rs1_in;
        ID_EX_rs2_out <= ID_EX_rs2_in;
        ID_EX_rd_out  <= ID_EX_rd_in;

        alu_src_out   <= alu_src_in;
        alu_op_out    <= alu_op_in;
        funct3_out    <= funct3_in;
        funct7_bit_out <= funct7_bit_in;

        mem_read_out  <= mem_read_in;
        mem_write_out <= mem_write_in;
        branch_out    <= branch_in;

        mem_to_reg_out <= mem_to_reg_in;
        reg_write_out  <= reg_write_in;
        pred_taken_out <= pred_taken_in;
        pred1_out      <= pred1_in;
        pred2_out      <= pred2_in;
    end

end

endmodule