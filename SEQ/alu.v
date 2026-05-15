module HA(Sum,Cout,A,B);
input A,B;
output Sum,Cout;

xor x1(Sum,A,B);
and a1(Cout,A,B);
endmodule


module FA(Sum,Cout,A,B,Cin);
input A,B,Cin;
output Cout,Sum;
wire Hsum,Hcarry,Bcout;

HA h1(Hsum,Hcarry,A,B);
HA h2(Sum,Bcout,Hsum,Cin);
or o1(Cout,Bcout,Hcarry);
endmodule


module Port_In(Sum,Cout,A,B,Cin);
output [64:0] Cout;
output [63:0] Sum;
input [63:0] A,B;
input Cin;

assign Cout[0] = Cin;
genvar i;

generate
    for (i = 0;i < 64; i = i + 1) begin
        FA fa(.Sum(Sum[i]),.Cout(Cout[i+1]),.A(A[i]),.B(B[i]),.Cin(Cout[i]));
    end
endgenerate
endmodule


module slt(out, A, B);
output out;
input  [63:0] A, B;

wire [63:0] B_bar;
wire [63:0] Sum;
wire [64:0] Cout;
wire overflow;
genvar i;
generate
    for (i = 0; i < 64; i = i + 1)
        not n1(B_bar[i], B[i]);
endgenerate

assign overflow = Cout[63] ^ Cout[64];

Port_In FA ( .Sum(Sum), .Cout(Cout), .A(A), .B(B_bar), .Cin(1'b1));

assign out = Sum[63] ^ overflow;
endmodule


module sltu(out, A, B);
output out;
input  [63:0] A, B;

wire [63:0] B_bar;
wire [63:0] Sum;
wire [64:0] Cout;

genvar i;
generate
    for (i = 0; i < 64; i = i + 1)
        not n1(B_bar[i], B[i]);
endgenerate

Port_In FA ( .Sum(Sum), .Cout(Cout), .A(A), .B(B_bar), .Cin(1'b1));

not n2(out,Cout[64]);
endmodule


module MUX(Y, I0, I1, S);
output Y;
input  I0, I1, S;

assign Y = S ? I1 : I0;
endmodule


module sl_logic(OUT, IN, S);
output [63:0] OUT;
input  [63:0] IN;
input  [5:0]  S;

wire [63:0] S1, S2, S3, S4, S5;
genvar i;

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i == 0)
      MUX m (S1[i], IN[i], 1'b0, S[0]);
    else
      MUX m (S1[i], IN[i], IN[i-1], S[0]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i < 2)
      MUX m (S2[i], S1[i], 1'b0, S[1]);
    else
      MUX m (S2[i], S1[i], S1[i-2], S[1]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i < 4)
      MUX m (S3[i], S2[i], 1'b0, S[2]);
    else
      MUX m (S3[i], S2[i], S2[i-4], S[2]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i < 8)
      MUX m (S4[i], S3[i], 1'b0, S[3]);
    else
      MUX m (S4[i], S3[i], S3[i-8], S[3]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i < 16)
      MUX m (S5[i], S4[i], 1'b0, S[4]);
    else
      MUX m (S5[i], S4[i], S4[i-16], S[4]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i < 32)
      MUX m (OUT[i], S5[i], 1'b0, S[5]);
    else
      MUX m (OUT[i], S5[i], S5[i-32], S[5]);
  end
endgenerate
endmodule


module sr_logic(OUT, IN, S);
output [63:0] OUT;
input  [63:0] IN;
input  [5:0]  S;

wire [63:0] S1, S2, S3, S4, S5;
genvar i;

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i == 63)
      MUX m (S1[i], IN[i], 1'b0, S[0]);
    else
      MUX m (S1[i], IN[i], IN[i+1], S[0]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 61)
      MUX m (S2[i], S1[i], 1'b0, S[1]);
    else
      MUX m (S2[i], S1[i], S1[i+2], S[1]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 59)
      MUX m (S3[i], S2[i], 1'b0, S[2]);
    else
      MUX m (S3[i], S2[i], S2[i+4], S[2]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 55)
      MUX m (S4[i], S3[i], 1'b0, S[3]);
    else
      MUX m (S4[i], S3[i], S3[i+8], S[3]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 47)
      MUX m (S5[i], S4[i], 1'b0, S[4]);
    else
      MUX m (S5[i], S4[i], S4[i+16], S[4]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 31)
      MUX m (OUT[i], S5[i], 1'b0, S[5]);
    else
      MUX m (OUT[i], S5[i], S5[i+32], S[5]);
  end
endgenerate
endmodule


module sr_arithmatic(OUT, IN, S);
output [63:0] OUT;
input  [63:0] IN;
input  [5:0]  S;

wire [63:0] S1, S2, S3, S4, S5;
genvar i;

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i == 63)
      MUX m (S1[i], IN[i], IN[63], S[0]);
    else
      MUX m (S1[i], IN[i], IN[i+1], S[0]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 61)
      MUX m (S2[i], S1[i], IN[63], S[1]);
    else
      MUX m (S2[i], S1[i], S1[i+2], S[1]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 59)
      MUX m (S3[i], S2[i], IN[63], S[2]);
    else
      MUX m (S3[i], S2[i], S2[i+4], S[2]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 55)
      MUX m (S4[i], S3[i], IN[63], S[3]);
    else
      MUX m (S4[i], S3[i], S3[i+8], S[3]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 47)
      MUX m (S5[i], S4[i], IN[63], S[4]);
    else
      MUX m (S5[i], S4[i], S4[i+16], S[4]);
  end
endgenerate

generate
  for (i = 0; i < 64; i = i + 1) begin
    if (i > 31)
      MUX m (OUT[i], S5[i], IN[63], S[5]);
    else
      MUX m (OUT[i], S5[i], S5[i+32], S[5]);
  end
endgenerate
endmodule


module bit_xor(C,A,B);
output [63:0] C;
input  [63:0] A,B;

genvar i;
generate
    for (i = 0;i < 64; i = i + 1)
        xor x1(C[i],A[i],B[i]);
endgenerate
endmodule


module bit_and(C,A,B);
output [63:0] C;
input  [63:0] A,B;

genvar i;
generate
    for (i = 0;i < 64; i = i + 1)
        and a1(C[i],A[i],B[i]);
endgenerate
endmodule


module bit_or(C,A,B);
output [63:0] C;
input  [63:0] A,B;

genvar i;
generate
    for (i = 0;i < 64; i = i + 1)
        or o1(C[i],A[i],B[i]);
endgenerate
endmodule

module alu_64_bit(
    input  [63:0] a, b,
    input  [3:0]  opcode,
    output reg [63:0] result,
    output        cout,
    output reg    carry_flag,
    output reg    overflow_flag,
    output        zero_flag
);

wire [63:0] add_sum;
wire [64:0] add_cout;
wire add_overflow;

wire [63:0] sub_sum;
wire [64:0] sub_cout;
wire sub_overflow;

wire slt_bit, sltu_bit;
wire [63:0] and_out, or_out, xor_out;
wire [63:0] sll_out, srl_out, sra_out;
wire [63:0] b_bar;

genvar i;
generate
    for (i = 0; i < 64; i = i + 1)
        not n1(b_bar[i], b[i]);
endgenerate

Port_In add1(add_sum, add_cout, a, b, 1'b0);
xor x_add_ov (add_overflow, add_cout[63], add_cout[64]);

Port_In sub1(sub_sum, sub_cout, a, b_bar, 1'b1);
xor x_sub_ov (sub_overflow, sub_cout[63], sub_cout[64]);

slt  s1(slt_bit,  a, b);
sltu s2(sltu_bit, a, b);

bit_and a1(and_out, a, b);
bit_or  o1(or_out,  a, b);
bit_xor x1(xor_out, a, b);

sl_logic      shl(sll_out, a, b[5:0]);
sr_logic      shr(srl_out, a, b[5:0]);
sr_arithmatic sha(sra_out, a, b[5:0]);

assign cout = add_cout[64];
assign zero_flag = (result == 64'b0);

always @(*) begin
    result        = 64'b0;
    carry_flag    = 1'b0;
    overflow_flag = 1'b0;

    case (opcode)
        4'b0010: begin // ADD
            result        = add_sum;
            carry_flag    = add_cout[64];
            overflow_flag = add_overflow;
        end

        4'b0110: begin // SUB
            result        = sub_sum;
            carry_flag    = ~sub_cout[64];  
            overflow_flag = sub_overflow;
        end

        4'b1000: begin // SLT
            result = {63'b0, slt_bit};
        end

        4'b1001: begin // SLTU
            result = {63'b0, sltu_bit};
        end

        4'b0101: result = sll_out; // SLL
        4'b0011: result = srl_out; // SRL
        4'b0111: result = sra_out; // SRA
        4'b0000: result = and_out; // AND
        4'b0001: result = or_out;  // OR
        4'b0100: result = xor_out; // XOR

        default: result = 64'b0;
    endcase
end

endmodule
