module rising_edge_detector(clk, rst, signal, rising_edge);
input clk, rst, signal;
output rising_edge;

wire d1, d2;
reg q1, q2;

always @ (posedge clk)	 // Create the state memory
if (rst==1) begin
    q1 <= 1'b0;
    q2 <= 1'b0;
end    
else begin
    q1 <= d1;
    q2 <= d2;
end

assign d1 = signal;
assign d2 = q1;
assign rising_edge = q1 & ~q2; 

endmodule
