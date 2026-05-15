module alu_control (
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire       funct7_bit,  
    output reg  [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: 
            ALUControl = 4'b0010;

        2'b01: 
            ALUControl = 4'b0110;

        2'b10: begin 
            case (funct3)
                3'b000: ALUControl = funct7_bit ? 4'b0110 : 4'b0010; 
                3'b001: ALUControl = 4'b0101;                       
                3'b010: ALUControl = 4'b1000;                       
                3'b011: ALUControl = 4'b1001;                       
                3'b100: ALUControl = 4'b0100;                        
                3'b101: ALUControl = funct7_bit ? 4'b0111 : 4'b0011;
                3'b110: ALUControl = 4'b0001;                        
                3'b111: ALUControl = 4'b0000;                        
                default: ALUControl = 4'b0000;                      
            endcase
        end

        default: ALUControl = 4'b0000;
    endcase
end

endmodule
