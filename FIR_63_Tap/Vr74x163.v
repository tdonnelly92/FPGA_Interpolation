module Vr74x163 (CLK, CLR, LD, ENP, ENT, D, Q, RCO);
  input CLK, CLR, LD, ENP, ENT;
  input [4:0] D;
  output [4:0] Q;
  output RCO;
  reg [4:0] Q;
  reg RCO; 

  always @ (posedge CLK or posedge CLR)  // Create the counter f-f behavior
    if (CLR)                   Q <= 0;
    else if (LD)               Q <= D;
    else if (ENT && ENP)       Q <= Q + 1;
    else                       Q <= Q;
					   
  always @ (Q or ENT)     // Create RCO combinational output
    if (ENT && (Q == 5'b11111))   RCO = 1;
    else                       RCO = 0;
endmodule