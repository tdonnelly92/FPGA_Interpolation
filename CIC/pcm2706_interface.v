module pcm2706_interface(sysclk, RST, serial_clk, lr_clk, serial_in, parallel_out, data_rdy);
input sysclk, RST, serial_clk, lr_clk, serial_in;
output [15:0] parallel_out;
output data_rdy;

wire sysclk, clk, rst;
//StoP signals
wire rin, lin;
reg [2:0] s;
wire [15:0] d;
wire [15:0] q;
//counter signals
reg LD;
reg ENT;
reg ENP;
wire [3:0] ld_cnt;
wire [3:0] cnt_out;
wire rco;
reg data_rdy;
wire falling_edge;
wire rising_edge;

reg [2:0] Sreg, Snext;          // State register and next state
parameter [2:0] INIT = 3'b000,  // Define the states
                FALLING_LRCLK = 3'b001,
                RISING_BCLK = 3'b010,                
                COUNT   = 3'b011,
                DELAY = 3'b100,
                DELAY_2 = 3'b101,
                RISING_BCLK_2 = 3'b110;

always @ (posedge sysclk)	 // Create the state memory
  if (rst==1) Sreg <= INIT;
  else Sreg <= Snext;

always @ (falling_edge, rising_edge, Sreg, cnt_out) begin  // Next-state logic
case (Sreg)
  INIT:   if (falling_edge==0)  Snext = INIT;
          else       Snext = FALLING_LRCLK;
  FALLING_LRCLK: if (rising_edge==0) Snext = FALLING_LRCLK;
          else       Snext = RISING_BCLK;
  RISING_BCLK:       Snext = COUNT;
  COUNT:   if (cnt_out==4'b1111)  Snext = DELAY;
          else       Snext = COUNT;
  DELAY:  Snext = DELAY_2;      
  DELAY_2:  if (rising_edge==0)  Snext = DELAY_2;
          else       Snext = RISING_BCLK_2;
  RISING_BCLK_2:   Snext = INIT;        
  default Snext = INIT;
endcase
end

always @ (Sreg) // Output logic
begin
    ENP = 1'b0;
    ENT = 1'b0;
    s = 3'b000;
    LD = 1'b1;
    data_rdy = 1'b0;
case (Sreg)
  COUNT:        begin          
                    ENP = 1'b1;
                    ENT = 1'b1;
                    s = 3'b011;
                    LD = 1'b0;
                    end
  DELAY:        begin          
                    ENP = 1'b1;
                    ENT = 1'b1;
                    s = 3'b011;
                    LD = 1'b0;
                    end                                 
  DELAY_2:          s = 3'b011;
  RISING_BCLK_2:    data_rdy = 1'b1;               
  default:          begin          
                    ENP = 1'b0;
                    ENT = 1'b0;
                    s = 3'b000;
                    LD = 1'b1;
                    data_rdy = 1'b0;
                    end
endcase
end

falling_edge_detector falling_edge_detector1 (.clk(sysclk), .rst(rst), .signal(lr_clk), .falling_edge(falling_edge));
rising_edge_detector rising_edge_detector1 (.clk(sysclk), .rst(rst), .signal(clk), .rising_edge(rising_edge));

Vrshftreg StoP (.CLK(clk),
                   .RST(rst),
                   .RIN(rin),
                   .LIN(lin),
                   .S(s),
                   .D(d),
                   .Q(q));
                   
Vr74x163 counter (.CLK(clk),
                  .CLR(rst),
                  .LD(LD),
                  .ENP(ENP),
                  .ENT(ENT),
                  .D(ld_cnt),
                  .Q(cnt_out),
                  .RCO(rco));                   

assign rst = RST;
assign clk = serial_clk;
//StoP signals
assign rin = 1'b0;
assign d = 16'h0;
assign lin = serial_in;
assign parallel_out = q;
assign ld_cnt = 4'b0;

endmodule
