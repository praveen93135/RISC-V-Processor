module forward_mux(
    input signed [63:0] ID_EX_rs1_value,
    input signed [63:0] ID_EX_rs2_value,
    input signed [63:0] EX_MEM_ALU_Out,
    input signed [63:0] writeback_mux_value,
    input [1:0] ForwardA,
    input [1:0] ForwardB,
    output signed [63:0] alu_in_A,
    output signed [63:0] alu_in_B
);

    assign alu_in_A =
        (ForwardA == 2'b00) ? ID_EX_rs1_value :
        (ForwardA == 2'b01) ? writeback_mux_value :
        (ForwardA == 2'b10) ? EX_MEM_ALU_Out :
                              ID_EX_rs1_value;

    assign alu_in_B =
        (ForwardB == 2'b00) ? ID_EX_rs2_value :
        (ForwardB == 2'b01) ? writeback_mux_value :
        (ForwardB == 2'b10) ? EX_MEM_ALU_Out :
                              ID_EX_rs2_value;

endmodule