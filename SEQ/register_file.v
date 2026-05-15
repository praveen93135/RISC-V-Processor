module register_file (
    input  wire        clk,
    input  wire        reset,        
    input  wire        reg_write_en, 
    input  wire [4:0]  read_reg1,    
    input  wire [4:0]  read_reg2,    
    input  wire [4:0]  write_reg,    
    input  wire [63:0] write_data,   
    output wire [63:0] read_data1,   
    output wire [63:0] read_data2    
);
    reg [63:0] registers [0:31];
    integer i;

    assign read_data1 = (read_reg1 == 5'd0) ? 64'd0 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'd0) ? 64'd0 : registers[read_reg2];

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 64'd0;
        end else if (reg_write_en && (write_reg != 5'd0)) begin
            registers[write_reg] <= write_data;
        end
    end
endmodule
