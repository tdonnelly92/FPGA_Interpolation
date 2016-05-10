module top(CLK, RST, serial_clk, lr_clk, serial_in, clk_out, serial_out, LE);
input CLK, RST, serial_clk, lr_clk, serial_in;
output clk_out, serial_out, LE;
wire clk, rst; //General
wire rin, lin; //Vrshftreg
wire [2:0] sA, sB, sC;
wire [15:0] dA, dB, dC;
wire [15:0] qA, qB, qC;
wire signed [19:0] outputSample; 
wire signed [15:0] data_out; //pcm2706_interface
wire signed [27:0] sample;
wire data_rdy, serial_in_sync, serial_clk_sync, lr_clk_sync;

wire [16:0] d; //need extra bit to span possible outcomes (ex: max positive - (max negative))
wire [15:0] d_div_temp;
reg [15:0] d_div;
wire [15:0] sum_output_temp;
reg [15:0] sum_output;


wire ENT, ENP_interp_counter;

wire [4:0] ld_cnt_interpolate_counter;
wire [4:0] interp_cnt_out;
wire rco_clk_div;
wire shifting_done;
wire interpolate_done;
wire init;

wire sample_rdy;
wire data_select;

reg signed [27:0] input_reg;
always @ (posedge clk) begin
	if (rst) begin
		input_reg <= 0;
	end else if (data_rdy) begin
		input_reg <= sample;
	end else begin
        input_reg <= input_reg;
	end
end

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

  VrSMex_pipelined VrSMex1 (.CLOCK(clk),
                .RESET(rst),
                .Data_RDY(data_rdy),
                .interpolate_count(ld_interp_counter),
                .shift_done(shifting_done),
                .interpolate_count_ENP(ENP_interp_counter),
                .loaded(loaded),
                .CIC_en(CIC_en),
                .pulse_slow(pulse_slow),
                .pulse_fast(pulse_fast),
                .data_select(data_select),
                .load_result_fast(load_result_fast),
                .load_result_slow(load_result_slow),                
                .sample_rdy(sample_rdy));
               
  pcm2706_interface pcm2706_interface1 (.sysclk(clk),
                                      .RST(rst),
                                      .serial_clk(serial_clk_sync),
                                      .lr_clk(lr_clk_sync),
                                      .serial_in(serial_in_sync),
                                      .parallel_out(data_out),
                                      .data_rdy(data_rdy));


  CIC interp (.clk(clk),
                .rst(rst),
                .inputSample(sample),
                .CIC_en(CIC_en),
                .data_select(data_select),
                .pulse_slow(pulse_slow),
                .pulse_fast(pulse_fast),
                .load_result_slow(load_result_slow),
                .load_result_fast(load_result_fast),
                .outputSample(outputSample));
      
      
    pcm1702_interface_edges pcm1702_interface1 (.clk(clk),
                    .rst(rst),
                    .sample_rdy(sample_rdy),
                    .data(outputSample),
                    .shift_done(shifting_done),
                    .clk_out(clk_out),
                    .loaded(loaded),
                    .serial_out(serial_out),
                    .LE(LE)); 
      
     Vr74x163_wide interp_counter (.CLK(clk),
                       .CLR(rst),
                       .LD(ld_interp_counter),
                       .ENP(ENP_interp_counter),
                       .ENT(ENT),
                       .D(ld_cnt_interpolate_counter),
                       .Q(interp_cnt_out),
                       .RCO());                                         

assign ENT = 1'b1;
assign ld_cnt_interpolate_counter = 5'b0;
assign clk = CLK;
assign rst = RST;
assign rin = 1'b0;
assign lin = 1'b0;

assign dA = qB;
assign dB = sample;
assign sample = {{12{data_out[15]}},data_out};

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
