module Vradders(A, B, S, OVFL);
  parameter WID = 16;
  input [WID-1:0] A, B;
  output [WID-1:0] S;
  output OVFL;

  // S and OVFL -- signed interpretation
  assign S = A + B;
  assign OVFL = (A[WID-1] == B[WID-1]) && (S[WID-1] != A[WID-1]);
  
endmodule