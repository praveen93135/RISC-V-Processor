module hazard_unit(
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    input [4:0] ID_EX_rd,
    input ID_EX_MemRead,

    output reg stall,
    output reg IF_ID_Write,
    output reg PC_Write
);

always @(*) begin

    stall = 0;
    IF_ID_Write = 1;
    PC_Write = 1;

    if (ID_EX_MemRead &&
       ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2)) &&
       (ID_EX_rd != 0)) 
    begin
        stall = 1;
        IF_ID_Write = 0;
        PC_Write = 0;
    end

end

endmodule
