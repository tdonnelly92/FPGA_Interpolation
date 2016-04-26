module pcm1702_interface(clk, rst, sample_rdy, data, shift_done, clk_out, serial_out, LE);
input clk, rst, sample_rdy;
input signed [17:0] data;
output shift_done, clk_out, serial_out, LE;
wire clk, rst, serial_out;
reg shifting_done;
reg LE;
reg shift_complete;

reg clk_out;

reg ENP;
wire counter_shifting_done;

wire LD, ENT, ENP_clk_div;
wire [3:0] ld_cnt;
wire [4:0] ld_cnt_wide;
wire [3:0] clk_div_cnt_out;
wire [4:0] counter_cnt_out;
wire [4:0] d_cnt_counter;

wire rin, lin; //Vrshftreg
reg [2:0] sA;
wire [17:0] dA;
wire [17:0] qA;

wire falling_edge, rising_edge;
reg rising_edge_delayed;

wire [3:0] d_cnt_clk_div;
wire clk_div_done;

reg [3:0] Sreg, Snext;          // State register and next state
parameter [3:0] INIT            = 4'b0000,  // Define the states
                LOAD            = 4'b0001,
                SHIFT           = 4'b0010,
                SHIFT_WAIT      = 4'b0011,
                SHIFT_COMPLETE  = 4'b0100,
	            SHIFT_COMPLETE2 = 4'b0101,
	            SHIFT_COMPLETE3 = 4'b0110,
                DONE            = 4'b0111,
		        INIT_DELAY      = 4'b1000;


always @ (posedge clk)	 // Create the state memory
  if (rst==1) Sreg <= INIT;
  else Sreg <= Snext;

always @ (sample_rdy, counter_shifting_done, falling_edge, rising_edge, Sreg) begin  // Next-state logic
case (Sreg)
  INIT:             if (sample_rdy==1)  Snext = INIT_DELAY;
                    else       Snext = INIT;
  INIT_DELAY:	    if (falling_edge==1)  Snext = LOAD;
                    else       Snext = INIT_DELAY;
  LOAD:             Snext = SHIFT_WAIT;
  SHIFT:            Snext = SHIFT_WAIT;
  SHIFT_WAIT:       if (counter_shifting_done==1) Snext = SHIFT_COMPLETE;
                    else if (rising_edge==1) Snext = SHIFT;
                    else Snext = SHIFT_WAIT;
  SHIFT_COMPLETE:   Snext = SHIFT_COMPLETE2;
  SHIFT_COMPLETE2:  Snext = SHIFT_COMPLETE3;                 
  SHIFT_COMPLETE3:  if (rising_edge==1) Snext = DONE;
		            else Snext = SHIFT_COMPLETE3;		   				
  DONE:             Snext = INIT;
  default Snext = INIT;
endcase
end

always @ (Sreg) // Output logic
begin
    shifting_done = 1'b0;
    sA = 3'b000;
    ENP = 1'b0;
    LE = 1'b1;
case (Sreg)
  INIT:             begin
                    end
  LOAD:             begin
                    sA = 3'b001;
                    end
  SHIFT:            begin        
                    sA = 3'b011;
                    ENP = 1'b1;
                    end                  
  SHIFT_WAIT:       begin
                    end                                                    
  SHIFT_COMPLETE:   begin
  					end
  SHIFT_COMPLETE3:	begin
                    LE = 1'b0;
  					end
  DONE:             begin
					shifting_done = 1'b1;
					LE = 1'b0;
					end
  default:          begin          
                    shifting_done = 1'b0;
                    sA = 3'b000;
                    ENP = 1'b0;
                    LE = 1'b1;                    
                    end
endcase
end

Vr74x163_wide counter (.CLK(clk),
                  .CLR(rst),
                  .LD(counter_shifting_done),
                  .ENP(ENP),
                  .ENT(ENT),
                  .D(d_cnt_counter),
                  .Q(counter_cnt_out),
                  .RCO());

falling_edge_detector falling_edge_detector1 (.clk(clk), .rst(rst), .signal(clk_out), .falling_edge(falling_edge));
rising_edge_detector rising_edge_detector1 (.clk(clk), .rst(rst), .signal(clk_out), .rising_edge(rising_edge));                
     
                  
Vrshftreg #(.DATA_WIDTH(18)) PtoS (.CLK(clk),
                   .RST(rst),
                   .RIN(rin),
                   .LIN(lin),
                   .S(sA),
                   .D(dA),
                   .Q(qA));                  
                  
assign dA = data;           
assign LD = 1'b0;
assign ENT = 1'b1;
assign ENP_clk_div = 1'b1;
assign ld_cnt = 4'b0;
assign d_cnt_counter = 5'b0;
assign d_cnt_clk_div = 4'b0;
assign rin = 1'b0;
assign lin = 1'b0;

assign counter_shifting_done = counter_cnt_out[4] && !counter_cnt_out[3] && counter_cnt_out[2] && !counter_cnt_out[1] && counter_cnt_out[0];    
assign serial_out = qA[17];
assign shift_done = shifting_done;

reg clk_div1;
always @ (posedge clk, posedge rst)
if (rst) clk_div1 <= 1'b0;
else  clk_div1 <= !clk_div1;

always @ (posedge clk_div1, posedge rst)
if (rst) clk_out <= 1'b0;
else  clk_out <= !clk_out;

endmodule
