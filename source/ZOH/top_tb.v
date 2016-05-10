`timescale 1ns / 1ps
module top_tb ();

reg sysclk, bclk, rst, lr_clk;
reg data_in;
wire serial_out, clk_out, LE;

integer clk_count = 0;

top_pipelined UUT (.CLK(sysclk),
                .RST(rst),
                .serial_clk(bclk),
                .lr_clk(lr_clk),
                .serial_in(data_in),
                .serial_out(serial_out),
                .clk_out(clk_out),
                .LE(LE));

task send_data;
input [15:0] task_data_in;
integer i;
    begin
        data_in = task_data_in[15];
        #354;
        data_in = task_data_in[14];
        #354;
        data_in = task_data_in[13];
        #354;
        data_in = task_data_in[12];
        #354;
        data_in = task_data_in[11];
        #354;
        data_in = task_data_in[10];
        #354;
        data_in = task_data_in[9];
        #354;
        data_in = task_data_in[8];
        #354;
        data_in = task_data_in[7];
        #354;
        data_in = task_data_in[6];
        #354;
        data_in = task_data_in[5];
        #354;
        data_in = task_data_in[4];
        #354;
        data_in = task_data_in[3];
        #354;
        data_in = task_data_in[2];
        #354;
        data_in = task_data_in[1];
        #354;
        data_in = task_data_in[0];                  
    end
endtask

always begin
  #5 sysclk = 0;
  #5 sysclk = 1;
end

always begin    // create free-running BCLK
  #177 bclk = 0;
  #177 bclk = 1;
end

always begin    // create free-running LR_clk
  @ (negedge bclk);
  if (clk_count == 32) begin
    clk_count = 0;
    lr_clk = ~lr_clk;
  end else begin
    clk_count = clk_count + 1;
  end
end

wire signed [19:0] timmy;
assign timmy = UUT.test_unit.Q; 

always begin
 @ (negedge LE);
 $display ("{%d,%d}",$time,timmy);
end

initial begin    // What to do starting at time 0
//$monitor ("LE=%b,outputsample=%d", UUT.LE,UUT.test_unit.Q);
  rst = 1;       // Apply reset
  data_in = 1'b0;
  sysclk = 1;
  bclk = 1;      // Start clock at 1 at time 0
  lr_clk = 1;
  #500;           // Wait 15 ns
  rst = 0;       // unreset
  
repeat (2)
begin
  
  @ (negedge lr_clk);
  #354
  send_data(16'd100);
  @ (negedge lr_clk);
  #354
  send_data(16'd1950);
  @ (negedge lr_clk);
  #354;
  send_data(16'd3826);
  @ (negedge lr_clk);
  #354;
  send_data(16'd5555);
  @ (negedge lr_clk);
  #354;
  send_data(16'd7071);
  @ (negedge lr_clk);
  #354;
  send_data(16'd8314);
  @ (negedge lr_clk);
  #354;
  send_data(16'd9238);
  @ (negedge lr_clk);
  #354;
  send_data(16'd9807);
  @ (negedge lr_clk);
  #354;
  send_data(16'd10000);
  @ (negedge lr_clk);
  #354;
  send_data(16'd9807);
  @ (negedge lr_clk);
  #354;   
  send_data(16'd9238);
  @ (negedge lr_clk);
  #354;    
  send_data(16'd8314);
  @ (negedge lr_clk);
  #354;   
  send_data(16'd7071);
  @ (negedge lr_clk);
  #354;                      
  send_data(16'd5555);
  @ (negedge lr_clk);
  #354;  
  send_data(16'd3826);
  @ (negedge lr_clk);
  #354;  
  send_data(16'd1950);
  @ (negedge lr_clk);
  #354;  
  send_data(16'd0);
  @ (negedge lr_clk);
  #354;
  //half period  
  send_data(-16'd1950);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd3826);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd5555);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd7071);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd8314);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd9238);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd9807);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd10000);
  @ (negedge lr_clk);
  #354;
  send_data(-16'd9807);
  @ (negedge lr_clk);
  #354;   
  send_data(-16'd9238);
  @ (negedge lr_clk);
  #354;    
  send_data(-16'd8314);
  @ (negedge lr_clk);
  #354;   
  send_data(-16'd7071);
  @ (negedge lr_clk);
  #354;                      
  send_data(-16'd5555);
  @ (negedge lr_clk);
  #354;  
  send_data(-16'd3826);
  @ (negedge lr_clk);
  #354;  
  send_data(-16'd1950);
 
end
  
  $stop(1);
end

endmodule