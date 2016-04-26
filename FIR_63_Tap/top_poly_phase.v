module top_poly_phase(CLK, RST, serial_clk, lr_clk, serial_in, clk_out, serial_out, LE);
input CLK, RST, serial_clk, lr_clk, serial_in;
output clk_out, serial_out, LE;
wire clk, rst; //General
wire rin, lin; //Vrshftreg
wire signed [17:0] outputSample; 
wire [15:0] sample, data_out; //pcm2706_interface
wire data_rdy, serial_in_sync, serial_clk_sync, lr_clk_sync;

wire ld_shifting_counter, ENT, ENP_interp_counter;

wire [4:0] interp_cnt_out;
wire shifting_done;
wire interpolate_done;

wire sample_rdy;

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

  VrSMex_poly_phase VrSMex1 (.CLOCK(clk),
                .RESET(rst),
                .Data_RDY(data_rdy),
                .interpolate_count(ld_interp_counter),
                .shift_done(shifting_done),
                .interpolate_count_ENP(ENP_interp_counter),
                .FIR_en(FIR_en),
                .sample_rdy(sample_rdy));
               
  pcm2706_interface pcm2706_interface1 (.sysclk(clk),
                                      .RST(rst),
                                      .serial_clk(serial_clk_sync),
                                      .lr_clk(lr_clk_sync),
                                      .serial_in(serial_in_sync),
                                      .parallel_out(data_out),
                                      .data_rdy(data_rdy));


  interpFIR_poly_phase interp (.clk(clk),
                .rst(rst),
                .inputSample(data_out),
                .FIR_en(FIR_en),
                .FIR_sel(interp_cnt_out),
                .outputSample(outputSample));
      
    pcm1702_interface pcm1702_interface1 (.clk(clk),
                    .rst(rst),
                    .sample_rdy(sample_rdy),
                    .data(outputSample>>>1),
                    .shift_done(shifting_done),
                    .clk_out(clk_out),
                    .serial_out(serial_out),
                    .LE(LE)); 
      
     Vr74x163 #(5) interp_counter (.CLK(clk),
                       .CLR(rst),
                       .LD(ld_interp_counter),
                       .ENP(ENP_interp_counter),
                       .ENT(ENT),
                       .D(5'b0),
                       .Q(interp_cnt_out),
                       .RCO());                                         

assign ENT = 1'b1;
assign clk = CLK;
assign rst = RST;
assign ld_interp_counter = interp_cnt_out[4] & !interp_cnt_out[3] && !interp_cnt_out[2] && !interp_cnt_out[1] && !interp_cnt_out[0];

///PCM1702 test register

wire signed [19:0] test_output;

Vrshftreg #(20) test_unit (.CLK(clk_out),
                   .RST(!LE && clk_out),
                   .RIN(1'b0),
                   .LIN(serial_out),
                   .S(3'd3),
                   .D(20'b0),
                   .Q(test_output));

endmodule