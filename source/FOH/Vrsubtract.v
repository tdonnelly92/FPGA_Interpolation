module Vrsubtract(A, B, D, OVFL);
  parameter WID = 16;
  input [WID-1:0] A, B;
  output [WID-1:0] D;
  output OVFL;

  // D and OVFL -- signed interpretation
  assign D = A - B;
  assign OVFL = (A[WID-1] == !B[WID-1]) && (D[WID-1] != A[WID-1]);
  
endmodule