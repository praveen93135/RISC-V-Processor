module control_unit (
    input  wire [6:0] opcode,

    output wire RegWrite,
    output wire ALUSrc,
    output wire MemRead,
    output wire MemWrite,
    output wire MemtoReg,
    output wire Branch,
    output wire [1:0]ALUOp
);

wire A = opcode[6];
wire B = opcode[5];
wire C = opcode[4];

wire nA, nB, nC;
not (nA, A);
not (nB, B);
not (nC, C);


wire isLD, isADDI, isSD, isR, isBEQ;

and (isLD,   nB, nC);        
and (isADDI, nB, C);         
and (isR,    B,  C);        
and (isBEQ,  A,  B);    

wire t_sd;
and (t_sd, B, nC);
and (isSD, nA, t_sd);

wire rw_or1;
or  (rw_or1, isR, isLD);
or  (RegWrite, rw_or1, isADDI);

wire as_or1;
or  (as_or1, isLD, isSD);
or  (ALUSrc, as_or1, isADDI);

assign MemRead  = isLD;
assign MemWrite = isSD;
assign MemtoReg = isLD;
assign Branch   = isBEQ;
assign ALUOp[1] = isR;
assign ALUOp[0] = isBEQ;

endmodule