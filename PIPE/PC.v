module pc (
    input  wire        clk,
    input  wire        reset,
    input  wire        pc_write, 
    input  wire [63:0] pc_in,
    output wire [63:0] pc_out
);

reg [63:0] pc_reg;

always @(posedge clk or posedge reset) begin
    if (reset)
        pc_reg <= 64'h0;
    else if (pc_write)
        pc_reg <= pc_in;
end

assign pc_out = pc_reg;

endmodule