module IF_ID(
    input clk,
    input reset,
    input flush,
    input IF_ID_write,

    input  [63:0] IF_ID_pc_in,
    input  [31:0] inst_in,
    input pred_taken_in,
    input pred1_in,
    input pred2_in,
    
    output reg pred_taken_out,
    output reg pred1_out, 
    output reg pred2_out,
    output reg [63:0] IF_ID_pc_out,
    output reg [31:0] inst_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        IF_ID_pc_out   <= 64'b0;
        inst_out <= 32'b0;
        pred_taken_out <= 1'b0;
        pred1_out      <= 1'b0; 
        pred2_out      <= 1'b0;
    end

    else if (flush) begin
        IF_ID_pc_out   <= 64'b0;
        inst_out <= 32'b0;
        pred_taken_out <= 1'b0;
        pred1_out      <= 1'b0;
        pred2_out      <= 1'b0;
    end

    else if (IF_ID_write) begin
        IF_ID_pc_out   <= IF_ID_pc_in;
        inst_out <= inst_in;
        pred_taken_out <= pred_taken_in;
        pred1_out      <= pred1_in;
        pred2_out      <= pred2_in;
    end
end

endmodule