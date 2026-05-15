module branch_predictor(
    input clk,
    input reset,

    input  [63:0] pc_if,
    output reg pred_taken,
    output pred1_out,       
    output pred2_out,       

    input update,
    input [63:0] pc_ex,
    input actual_taken,
    input pred1_ex,         
    input pred2_ex          
);

    reg pred1 [63:0];          
    reg [1:0] pred2 [63:0];    
    reg [1:0] selector [63:0]; 

    wire [5:0] index_if = pc_if[7:2];
    wire [5:0] index_ex = pc_ex[7:2];

    integer i;


    assign pred1_out = pred1[index_if];
    assign pred2_out = pred2[index_if][1];   

    always @(*) begin
        if(selector[index_if][1])
            pred_taken = pred2_out;
        else
            pred_taken = pred1_out;
    end


    always @(posedge clk or posedge reset) begin
        if(reset) begin
            for(i=0; i<64; i=i+1) begin
                pred1[i]    <= 1'b0;        
                pred2[i]    <= 2'b01;       
                selector[i] <= 2'b01; 
            end
        end
        else if(update) begin
            pred1[index_ex] <= actual_taken;

            case(pred2[index_ex])
                2'b00: if(actual_taken)  pred2[index_ex] <= 2'b01;
                2'b01: if(actual_taken)  pred2[index_ex] <= 2'b10;
                       else              pred2[index_ex] <= 2'b00;
                2'b10: if(actual_taken)  pred2[index_ex] <= 2'b11;
                       else              pred2[index_ex] <= 2'b01;
                2'b11: if(!actual_taken) pred2[index_ex] <= 2'b10;
            endcase

            if((pred1_ex == actual_taken) && (pred2_ex != actual_taken)) begin
                if(selector[index_ex] != 2'b00)
                    selector[index_ex] <= selector[index_ex] - 2'b01;
            end
            else if((pred2_ex == actual_taken) && (pred1_ex != actual_taken)) begin
                if(selector[index_ex] != 2'b11)
                    selector[index_ex] <= selector[index_ex] + 2'b01;
            end
        end
    end

endmodule