module ha(sum, cout, a, b);
input a, b;
output sum, cout;

xor x1(sum, a, b);
and a1(cout, a, b);
endmodule


module fa(sum, cout, a, b, cin);
input a, b, cin;
output cout, sum;
wire hsum, hcarry, bcout;

ha h1(hsum, hcarry, a, b);
ha h2(sum, bcout, hsum, cin);
or o1(cout, bcout, hcarry);
endmodule


module port_in(sum, cout, a, b, cin);
output [64:0] cout;
output [63:0] sum;
input  [63:0] a, b;
input  cin;

assign cout[0] = cin;

genvar i;
generate
    for (i = 0; i < 64; i = i + 1) begin
        fa fa_inst (
            .sum (sum[i]),
            .cout(cout[i+1]),
            .a   (a[i]),
            .b   (b[i]),
            .cin (cout[i])
        );
    end
endgenerate
endmodule
