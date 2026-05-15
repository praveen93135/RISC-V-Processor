`timescale 1ns/1ps

module riscv_cpu (
    input wire clk,
    input wire reset
);

wire [63:0] pc_out;
wire [63:0] pc_next;
wire [63:0] pc_plus4;
wire [63:0] pc_branch;

wire [64:0] pc4_cout;
wire [64:0] pcbranch_cout;

wire [63:0] four = 64'd4;

port_in ADD_PC4 (
    .sum(pc_plus4),
    .cout(pc4_cout),
    .a(pc_out),
    .b(four),
    .cin(1'b0)
);

port_in ADD_BRANCH (
    .sum(pc_branch),
    .cout(pcbranch_cout),
    .a(pc_out),
    .b(imm_ext),
    .cin(1'b0)
);

wire pc_sel;
assign pc_sel = Branch & alu_zero;

mux2_64 MUX_PC (
    .a(pc_plus4),
    .b(pc_branch),
    .sel(pc_sel),
    .y(pc_next)
);

pc U_PC (
    .clk(clk),
    .reset(reset),
    .pc_in(pc_next),
    .pc_out(pc_out)
);

wire [31:0] instruction;

instruction_mem U_IMEM (
    .addr(pc_out),
    .clk(clk),
    .reset(reset),
    .instr(instruction)
);

wire Branch;
wire MemRead;
wire MemtoReg;
wire [1:0] ALUOp;
wire MemWrite;
wire ALUSrc;
wire RegWrite;

control_unit U_CTRL (
    .opcode(instruction[6:0]),
    .Branch(Branch),
    .MemRead(MemRead),
    .MemtoReg(MemtoReg),
    .ALUOp(ALUOp),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite)
);

wire [63:0] imm_ext;

imm_gen U_IMMGEN (
    .instruction(instruction),
    .imm_ext(imm_ext)
);

wire [63:0] read_data1;
wire [63:0] read_data2;
wire [63:0] write_back_data;

register_file U_REGFILE (
    .clk(clk),
    .reset(reset),
    .reg_write_en(RegWrite),
    .read_reg1(instruction[19:15]),
    .read_reg2(instruction[24:20]),
    .write_reg(instruction[11:7]),
    .write_data(write_back_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);

wire [63:0] alu_input_b;

mux2_64 MUX_ALU_SRC (
    .a(read_data2),
    .b(imm_ext),
    .sel(ALUSrc),
    .y(alu_input_b)
);

wire [3:0] alu_ctrl;

alu_control U_ALUCTL (
    .ALUOp(ALUOp),
    .funct3(instruction[14:12]),
    .funct7_bit(instruction[30]),
    .ALUControl(alu_ctrl)
);

wire [63:0] alu_result;
wire alu_zero;
wire alu_cout;
wire alu_carry;
wire alu_overflow;

alu_64_bit U_ALU (
    .a(read_data1),
    .b(alu_input_b),
    .opcode(alu_ctrl),
    .result(alu_result),
    .cout(alu_cout),
    .carry_flag(alu_carry),
    .overflow_flag(alu_overflow),
    .zero_flag(alu_zero)
);

wire [63:0] mem_read_data;

data_mem U_DMEM (
    .clk(clk),
    .reset(reset),
    .mem_read(MemRead),
    .mem_write(MemWrite),
    .addr(alu_result),
    .write_data(read_data2),
    .read_data(mem_read_data)
);

mux2_64 MUX_WB (
    .a(alu_result),
    .b(mem_read_data),
    .sel(MemtoReg),
    .y(write_back_data)
);

always @(posedge clk)
    $display("PC=%0d INSTR=%h", pc_out, instruction);

always @(posedge clk)
    if (Branch)
        $display("BEQ: %0d - %0d = %0d", read_data1, read_data2, alu_result);

always @(posedge clk)
    $display("PC=%0d IMM=%0d Branch=%b Zero=%b NextPC=%0d",
              pc_out, imm_ext, Branch, alu_zero, pc_next);

endmodule
