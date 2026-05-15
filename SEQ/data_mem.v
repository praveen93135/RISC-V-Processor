
`define DMEM_SIZE 1024

module data_mem (
    input  wire        clk,
    input  wire        reset,

    input  wire        mem_read,    
    input  wire        mem_write,     
    input  wire [63:0] addr,        
    input  wire [63:0] write_data,    

    output reg  [63:0] read_data     
);

    reg [7:0] dmem [0:`DMEM_SIZE-1];
    integer i;

    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < `DMEM_SIZE; i = i + 1)
                dmem[i] <= 8'h00;
        end else if (mem_write) begin
            dmem[addr[9:0]]     <= write_data[63:56];  // MSB
            dmem[addr[9:0] + 1] <= write_data[55:48];
            dmem[addr[9:0] + 2] <= write_data[47:40];
            dmem[addr[9:0] + 3] <= write_data[39:32];
            dmem[addr[9:0] + 4] <= write_data[31:24];
            dmem[addr[9:0] + 5] <= write_data[23:16];
            dmem[addr[9:0] + 6] <= write_data[15:8];
            dmem[addr[9:0] + 7] <= write_data[7:0];   // LSB
        end
    end

    always @(*) begin
        if (mem_read)
            read_data = {
                dmem[addr[9:0]],       
                dmem[addr[9:0] + 1],
                dmem[addr[9:0] + 2],
                dmem[addr[9:0] + 3],
                dmem[addr[9:0] + 4],
                dmem[addr[9:0] + 5],
                dmem[addr[9:0] + 6],
                dmem[addr[9:0] + 7]    
            };
        else
            read_data = 64'b0;
    end

endmodule
