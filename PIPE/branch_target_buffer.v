module branch_target_buffer (
    input clk,
    input reset,
    
    input [63:0] pc_if,
    output [63:0] btb_target,
    
    input update,
    input [63:0] pc_ex,
    input [63:0] actual_target
);
    reg [63:0] btb_array [63:0];
    wire [5:0] index_if = pc_if[7:2];
    wire [5:0] index_ex = pc_ex[7:2];
    
    assign btb_target = btb_array[index_if];
    
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for(i=0; i<64; i=i+1)
                btb_array[i] <= 64'd0;
        end else if (update) begin
            btb_array[index_ex] <= actual_target;
        end
    end
endmodule