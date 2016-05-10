module Vrshftreg (CLK, RST, RIN, LIN, S, D, Q);
  parameter DATA_WIDTH = 16;
  input CLK, RST, RIN, LIN;
  input [2:0] S;
  input [(DATA_WIDTH-1):0] D;
  output [(DATA_WIDTH-1):0] Q;
  reg [(DATA_WIDTH-1):0] Q; 

  always @ (posedge CLK)
    if (RST == 1) Q <= 0;
    else case (S)
      0: Q <= Q;               // Hold 
      1: Q <= D;               // Load
      2: Q <= {RIN, Q[(DATA_WIDTH-1):1]};   // Shift right
      3: Q <= {Q[(DATA_WIDTH-2):0], LIN};   // Shift left
      4: Q <= {Q[0], Q[(DATA_WIDTH-1):1]};  // Shift circular right
      5: Q <= {Q[(DATA_WIDTH-2):0], Q[(DATA_WIDTH-1)]};  // Shift circular left
      6: Q <= {Q[(DATA_WIDTH-1)], Q[(DATA_WIDTH-1):1]};  // Shift arithmetic right
      7: Q <= {Q[(DATA_WIDTH-2):0], 1'b0};  // Shift arithmetic left
      default Q <= 15'bx;	      // should not occur
      endcase
endmodule