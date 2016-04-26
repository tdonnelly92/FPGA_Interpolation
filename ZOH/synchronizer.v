module synchronizer(clk, rst, in, out);
input clk, rst, in;
output out;
reg Q1, Q2;
wire D1, D2;

always @ (posedge clk)	 // Create the first flip-flop
if (rst==1) Q1 <= 1'b0;
else Q1 <= D1;

always @ (posedge clk)	 // Create the second flip-flop
if (rst==1) Q2 <= 1'b0;
else Q2 <= D2;

assign D2 = Q1;

assign D1 = in;
assign out = Q2;

endmodule
