module ld_sd_forward(
    input [4:0] ld_rd,
    input [4:0] sd_rs2_data,
    input ld_sd_mem_to_reg,
    input ld_sd_mem_write,
    output reg ld_sd_sel
);

always @(*) begin
    ld_sd_sel = 1'b0;

    if(ld_sd_mem_to_reg &&
       ld_sd_mem_write &&
       (ld_rd != 5'b0) &&
       (ld_rd == sd_rs2_data))
    begin
        ld_sd_sel = 1'b1;
    end
end

endmodule
