module top(CLK, RST, serial_clk, lr_clk, serial_in, clk_out, serial_out, LE);
input CLK, RST, serial_clk, lr_clk, serial_in;
output clk_out, serial_out, LE;
wire clk, rst; //General
wire rin, lin; //Vrshftreg
wire [2:0] sA, sB, sC;
wire [15:0] dA, dB, dC;
wire [15:0] qA, qB, qC;
wire signed [15:0] outputSample; 
wire signed [15:0] sample, data_out; //pcm2706_interface
wire data_rdy, serial_in_sync, serial_clk_sync, lr_clk_sync;
wire [15:0] sample1, sample2; //interpolate

wire [16:0] d; //need extra bit to span possible outcomes (ex: max positive - (max negative))
reg [15:0] d_div;
reg [15:0] sum_output;


wire ld_shifting_counter, ENT, ENP_interp_counter;

wire [3:0] ld_cnt_interpolate_counter;
wire [3:0] interp_cnt_out, shifting_cnt_out, clk_div_cnt_out;
wire rco_clk_div;
wire shifting_done;
wire interpolate_done;
wire init;

wire sample_rdy;
wire data_select;

  synchronizer synchronizer_clk (.clk(clk),
                              .rst(rst),
                              .in(serial_clk),
                              .out(serial_clk_sync));
  
  synchronizer synchronizer_data (.clk(clk),
                              .rst(rst),
                              .in(serial_in),
                              .out(serial_in_sync));

  synchronizer synchronizer_LRclk (.clk(clk),
                              .rst(rst),
                              .in(lr_clk),
                              .out(lr_clk_sync));                              
             
  pcm2706_interface pcm2706_interface1 (.sysclk(clk),
                                      .RST(rst),
                                      .serial_clk(serial_clk_sync),
                                      .lr_clk(lr_clk_sync),
                                      .serial_in(serial_in_sync),
                                      .parallel_out(data_out),
                                      .data_rdy(data_rdy));
      
    wire signed [19:0] data1702;
    assign data1702 = data_out<<<1; 
    pcm1702_interface_edges pcm1702_interface1 (.clk(clk),
                    .rst(rst),
                    .sample_rdy(data_rdy),
                    .data(data1702),
                    .shift_done(shifting_done),
                    .clk_out(clk_out),
                    .serial_out(serial_out),
                    .LE(LE));           
                    
                    

    ///PCM1702 test register
    wire signed [19:0] test_output;
    
    Vrshftreg #(20) test_unit (.CLK(clk_out),
                      .RST(!LE && clk_out),
                      .RIN(1'b0),
                      .LIN(serial_out),
                      .S(3'd3),
                      .D(20'b0),
                      .Q(test_output));
                                                                       

assign ENT = 1'b1;
assign ld_cnt_interpolate_counter = 4'b0;  
assign clk = CLK;
assign rst = RST;
assign rin = 1'b0;
assign lin = 1'b0;

assign dA = qB;
assign dB = sample;
assign sample = data_out;

assign sample1 = qA;
assign sample2 = qB;

assign ld_interp_counter = interp_cnt_out[3] && interp_cnt_out[2] && interp_cnt_out[1] && interp_cnt_out[0];
endmodule
