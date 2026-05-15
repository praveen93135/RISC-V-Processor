
module branch_mux(
    input branch,
    input mem_read,
    input mem_to_reg,
    input [3:0] op,
    input mem_write,
    input alu_src,
    input reg_write_en,

    input control_mux_sel,

    output branch_out,
    output mem_read_out,
    output mem_to_reg_out,
    output [3:0] op_out,
    output mem_write_out,
    output alu_src_out,
    output reg_write_en_out
);

    assign branch_out       = control_mux_sel ? 1'b0 : branch;
    assign mem_read_out     = control_mux_sel ? 1'b0 : mem_read;
    assign mem_to_reg_out   = control_mux_sel ? 1'b0 : mem_to_reg;
    assign mem_write_out    = control_mux_sel ? 1'b0 : mem_write;
    assign alu_src_out      = control_mux_sel ? 1'b0 : alu_src;
    assign reg_write_en_out = control_mux_sel ? 1'b0 : reg_write_en;

    assign op_out = control_mux_sel ? 4'b0000 : op;

endmodule