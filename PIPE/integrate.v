`timescale 1ns/1ps

module riscv_cpu (
    input wire clk,
    input wire reset
);


wire [63:0] pc_out;
wire [63:0] pc_next;
wire [63:0] pc_plus4;

wire pc_write;
wire IF_ID_write;
wire flush;
wire stall;

wire pred1_if, pred2_if;

wire pred1_IF_ID, pred2_IF_ID;

wire pred1_ID_EX, pred2_ID_EX;

wire [64:0] pc4_cout;
wire [63:0] four = 64'd4;

wire pred_taken;
wire pred_taken_IF_ID;
wire pred_taken_ID_EX;
wire bp_update;

port_in ADD_PC4 (
    .sum(pc_plus4),
    .cout(pc4_cout),
    .a(pc_out),
    .b(four),
    .cin(1'b0)
);

pc U_PC (
    .clk(clk),
    .reset(reset),
    .pc_write(pc_write),
    .pc_in(pc_next),
    .pc_out(pc_out)
);

branch_predictor U_BP (
    .clk(clk),
    .reset(reset),

    .pc_if(pc_out),
    .pred_taken(pred_taken),
    .pred1_out(pred1_if),
    .pred2_out(pred2_if),

    .update(bp_update),
    .pc_ex(pc_ID_EX),
    .actual_taken(branch_taken),
    .pred1_ex(pred1_ID_EX),
    .pred2_ex(pred2_ID_EX)
);

wire [31:0] instruction;

instruction_mem U_IMEM (
    .addr(pc_out),
    .clk(clk),
    .reset(reset),
    .instr(instruction)
);

wire [63:0] btb_target_out;

branch_target_buffer U_BTB (
    .clk(clk),
    .reset(reset),
    .pc_if(pc_out),
    .btb_target(btb_target_out),
    .update(bp_update),           
    .pc_ex(pc_ID_EX),             
    .actual_target(branch_target)
);


wire [31:0] instr_IF_ID;
wire [63:0] pc_IF_ID;

IF_ID IF_ID_REG (
    .clk(clk),
    .reset(reset),
    .flush(flush),
    .IF_ID_write(IF_ID_write),
    .IF_ID_pc_in(pc_out),
    .inst_in(instruction),
    .pred_taken_in(pred_taken),
    .pred1_in(pred1_if),  
    .pred2_in(pred2_if),  
    .IF_ID_pc_out(pc_IF_ID),
    .inst_out(instr_IF_ID),
    .pred_taken_out(pred_taken_IF_ID),
    .pred1_out(pred1_IF_ID),
    .pred2_out(pred2_IF_ID)
);


wire Branch_ctrl;
wire MemRead_ctrl;
wire MemtoReg_ctrl;
wire [1:0] ALUOp_ctrl;
wire MemWrite_ctrl;
wire ALUSrc_ctrl;
wire RegWrite_ctrl;

control_unit U_CTRL (
    .opcode(instr_IF_ID[6:0]),
    .Branch(Branch_ctrl),
    .MemRead(MemRead_ctrl),
    .MemtoReg(MemtoReg_ctrl),
    .ALUOp(ALUOp_ctrl),
    .MemWrite(MemWrite_ctrl),
    .ALUSrc(ALUSrc_ctrl),
    .RegWrite(RegWrite_ctrl)
);


wire control_mux_sel;
assign control_mux_sel = stall | flush;

wire Branch;
wire MemRead;
wire MemtoReg;
wire [3:0] ALUOp_mux_out;
wire MemWrite;
wire ALUSrc;
wire RegWrite;

branch_mux U_CTRL_MUX (
    .branch(Branch_ctrl),
    .mem_read(MemRead_ctrl),
    .mem_to_reg(MemtoReg_ctrl),
    .op({2'b00, ALUOp_ctrl}),
    .mem_write(MemWrite_ctrl),
    .alu_src(ALUSrc_ctrl),
    .reg_write_en(RegWrite_ctrl),
    .control_mux_sel(control_mux_sel),
    .branch_out(Branch),
    .mem_read_out(MemRead),
    .mem_to_reg_out(MemtoReg),
    .op_out(ALUOp_mux_out),
    .mem_write_out(MemWrite),
    .alu_src_out(ALUSrc),
    .reg_write_en_out(RegWrite)
);

wire [1:0] ALUOp;
assign ALUOp = ALUOp_mux_out[1:0];


wire [63:0] imm_ext;

imm_gen U_IMMGEN (
    .instruction(instr_IF_ID),
    .imm_ext(imm_ext)
);

wire [63:0] read_data1;
wire [63:0] read_data2;
wire [63:0] write_back_data;

wire [4:0] rd_MEM_WB;
wire RegWrite_MEM_WB;

register_file U_REGFILE (
    .clk(clk),
    .reset(reset),
    .reg_write_en(RegWrite_MEM_WB),
    .read_reg1(instr_IF_ID[19:15]),
    .read_reg2(instr_IF_ID[24:20]),
    .write_reg(rd_MEM_WB),
    .write_data(write_back_data),
    .read_data1(read_data1),
    .read_data2(read_data2)
);


wire [4:0] rd_ID_EX;
wire MemRead_ID_EX;

hazard_unit U_HAZARD (
    .IF_ID_rs1(instr_IF_ID[19:15]),
    .IF_ID_rs2(instr_IF_ID[24:20]),
    .ID_EX_rd(rd_ID_EX),
    .ID_EX_MemRead(MemRead_ID_EX),
    .stall(stall),
    .IF_ID_Write(IF_ID_write),
    .PC_Write(pc_write)
);


wire [63:0] read_data1_ID_EX;
wire [63:0] read_data2_ID_EX;
wire [63:0] imm_ID_EX;
wire [63:0] pc_ID_EX;

wire [4:0] rs1_ID_EX;
wire [4:0] rs2_ID_EX;

wire MemWrite_ID_EX;
wire MemtoReg_ID_EX;
wire RegWrite_ID_EX;
wire ALUSrc_ID_EX;
wire [1:0] ALUOp_ID_EX;
wire Branch_ID_EX;
wire [2:0] funct3_ID_EX;
wire funct7_bit_ID_EX;

ID_EX ID_EX_REG(
    .clk(clk),
    .reset(reset),
    .flush(flush),
    .imm_gen_in(imm_ext),
    .ID_EX_pc_in(pc_IF_ID),
    .ID_EX_R1_in(read_data1),
    .ID_EX_R2_in(read_data2),
    .ID_EX_rs1_in(instr_IF_ID[19:15]),
    .ID_EX_rs2_in(instr_IF_ID[24:20]),
    .ID_EX_rd_in(instr_IF_ID[11:7]),
    .alu_src_in(ALUSrc),
    .alu_op_in(ALUOp),
    .funct3_in(instr_IF_ID[14:12]),
    .funct7_bit_in(instr_IF_ID[30]),
    .mem_read_in(MemRead),
    .mem_write_in(MemWrite),
    .branch_in(Branch),
    .mem_to_reg_in(MemtoReg),
    .reg_write_in(RegWrite),

    .pred_taken_in(pred_taken_IF_ID),

    .imm_gen_out(imm_ID_EX),
    .ID_EX_pc_out(pc_ID_EX),
    .ID_EX_R1_out(read_data1_ID_EX),
    .ID_EX_R2_out(read_data2_ID_EX),
    .ID_EX_rs1_out(rs1_ID_EX),
    .ID_EX_rs2_out(rs2_ID_EX),
    .ID_EX_rd_out(rd_ID_EX),
    .alu_src_out(ALUSrc_ID_EX),
    .alu_op_out(ALUOp_ID_EX),
    .funct3_out(funct3_ID_EX),
    .funct7_bit_out(funct7_bit_ID_EX),
    .mem_read_out(MemRead_ID_EX),
    .mem_write_out(MemWrite_ID_EX),
    .branch_out(Branch_ID_EX),
    .mem_to_reg_out(MemtoReg_ID_EX),
    .reg_write_out(RegWrite_ID_EX),
    .pred1_in(pred1_IF_ID),  
    .pred2_in(pred2_IF_ID),  

    .pred_taken_out(pred_taken_ID_EX),
    .pred1_out(pred1_ID_EX),
    .pred2_out(pred2_ID_EX)  
);



wire [4:0] rd_EX_MEM;
wire RegWrite_EX_MEM;
wire [63:0] alu_out_EX_MEM;
wire [63:0] alu_out_MEM_WB;
wire [63:0] mem_data_MEM_WB;
wire MemtoReg_MEM_WB;

mux2_64 MUX_WB (
    .a(alu_out_MEM_WB),
    .b(mem_data_MEM_WB),
    .sel(MemtoReg_MEM_WB),
    .y(write_back_data)
);

wire [1:0] fwd_A;
wire [1:0] fwd_B;

forwarding_unit U_FWD (
    .ID_EX_rs1(rs1_ID_EX),
    .ID_EX_rs2(rs2_ID_EX),
    .EX_MEM_rd(rd_EX_MEM),
    .MEM_WB_rd(rd_MEM_WB),
    .EX_MEM_regWrite(RegWrite_EX_MEM),
    .MEM_WB_regWrite(RegWrite_MEM_WB),
    .fwd_A(fwd_A),
    .fwd_B(fwd_B)
);

wire [63:0] fwd_alu_in_A;
wire [63:0] fwd_alu_in_B_rs2;

forward_mux U_FWDMUX (
    .ID_EX_rs1_value(read_data1_ID_EX),
    .ID_EX_rs2_value(read_data2_ID_EX),
    .EX_MEM_ALU_Out(alu_out_EX_MEM),
    .writeback_mux_value(write_back_data),
    .ForwardA(fwd_A),
    .ForwardB(fwd_B),
    .alu_in_A(fwd_alu_in_A),
    .alu_in_B(fwd_alu_in_B_rs2)
);

wire [63:0] alu_input_b;

mux2_64 MUX_ALU_SRC (
    .a(fwd_alu_in_B_rs2),
    .b(imm_ID_EX),
    .sel(ALUSrc_ID_EX),
    .y(alu_input_b)
);

wire [3:0] alu_ctrl;

alu_control U_ALUCTL (
    .ALUOp(ALUOp_ID_EX),
    .funct3(funct3_ID_EX),
    .funct7_bit(funct7_bit_ID_EX),
    .ALUControl(alu_ctrl)
);

wire [63:0] alu_result;
wire alu_zero;

alu_64_bit U_ALU (
    .a(fwd_alu_in_A),
    .b(alu_input_b),
    .opcode(alu_ctrl),
    .result(alu_result),
    .zero_flag(alu_zero)
);


wire [63:0] branch_target;
wire [64:0] bt_cout;

port_in ADD_BRANCH (
    .sum(branch_target),
    .cout(bt_cout),
    .a(pc_ID_EX),
    .b(imm_ID_EX),
    .cin(1'b0)
);

wire branch_taken = Branch_ID_EX & alu_zero;
wire mispredict = Branch_ID_EX & (pred_taken_ID_EX != branch_taken);

assign bp_update = Branch_ID_EX; 
assign flush = mispredict;

reg [63:0] pc_next_logic;

always @(*) begin
    if (mispredict) begin
        if (branch_taken) 
            pc_next_logic = branch_target;
        else 
            pc_next_logic = pc_ID_EX + 64'd4; 
    end 
    else if (pred_taken) begin
        pc_next_logic = btb_target_out;
    end 
    else begin
        pc_next_logic = pc_plus4;
    end
end

assign pc_next = pc_next_logic;


wire MemRead_EX_MEM;
wire MemWrite_EX_MEM;
wire MemtoReg_EX_MEM;
wire [63:0] data_EX_MEM;

EX_MEM EX_MEM_REG(
    .clk(clk),
    .reset(reset),
    .ALU_data(alu_result),
    .rd_data(fwd_alu_in_B_rs2),
    .branch_target(branch_target),
    .zero(alu_zero),
    .Rd(rd_ID_EX),
    .MemtoReg(MemtoReg_ID_EX),
    .regwrite(RegWrite_ID_EX),
    .branch(Branch_ID_EX),
    .MemRead(MemRead_ID_EX),
    .MemWrite(MemWrite_ID_EX),
    .branch_target_out(),
    .ALU_data_out(alu_out_EX_MEM),
    .rd_data_out(data_EX_MEM),
    .zero_out(),
    .MemtoReg_out(MemtoReg_EX_MEM),
    .regwrite_out(RegWrite_EX_MEM),
    .branch_out(),
    .MemRead_out(MemRead_EX_MEM),
    .MemWrite_out(MemWrite_EX_MEM),
    .EX_MEM_rd(rd_EX_MEM)
);


wire ld_sd_sel;
wire [63:0] store_data;

ld_sd_forward U_LD_SD_FORWARD(
    .ld_rd(rd_MEM_WB),
    .sd_rs2_data(rd_EX_MEM),
    .ld_sd_mem_to_reg(MemtoReg_MEM_WB),
    .ld_sd_mem_write(MemWrite_EX_MEM),
    .ld_sd_sel(ld_sd_sel)
);

assign store_data = ld_sd_sel ? write_back_data : data_EX_MEM;


wire [63:0] mem_read_data;

data_mem U_DMEM (
    .clk(clk),
    .reset(reset),
    .mem_read(MemRead_EX_MEM),
    .mem_write(MemWrite_EX_MEM),
    .addr(alu_out_EX_MEM),
    .write_data(store_data),
    .read_data(mem_read_data)
);


MEM_WB MEM_WB_REG(
    .clk(clk),
    .reset(reset),
    .ALU_data(alu_out_EX_MEM),
    .read_Data(mem_read_data),
    .MemtoReg(MemtoReg_EX_MEM),
    .regwrite(RegWrite_EX_MEM),
    .EX_MEM_rd(rd_EX_MEM),
    .MemtoReg_out(MemtoReg_MEM_WB),
    .regwrite_out(RegWrite_MEM_WB),
    .ALU_data_out(alu_out_MEM_WB),
    .read_Data_out(mem_data_MEM_WB),
    .MEM_WB_rd(rd_MEM_WB)
);

endmodule
