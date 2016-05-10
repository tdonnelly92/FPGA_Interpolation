module top(CLK_temp, RST, serial_clk, lr_clk, serial_in, clk_out, serial_out, LE);
input CLK_temp, RST, serial_clk, lr_clk, serial_in;
output clk_out, serial_out, LE;
wire rst; //General
wire clk;
wire rin, lin; //Vrshftreg
wire [2:0] sA, sB, sC;
wire [15:0] dA, dB, dC;
wire [15:0] qA, qB, qC; 
wire [15:0] sample; //pcm2706_interface
wire data_rdy, serial_in_sync, serial_clk_sync, lr_clk_sync;
wire [15:0] sample1, sample2; //interpolate

wire [16:0] d; //need extra bit to span possible outcomes (ex: max positive - (max negative))
wire [15:0] d_div_temp;
reg [15:0] d_div;
wire [15:0] sum_output_temp;
reg [15:0] sum_output;


wire ld_shifting_counter, ENT, ENP_interp_counter;

wire [3:0] ld_cnt_interpolate_counter;
wire [3:0] interp_cnt_out, shifting_cnt_out, clk_div_cnt_out;
wire rco_clk_div;
wire shifting_done;
wire interpolate_done;
wire init;

wire sample_rdy;

assign clk = CLK_temp;

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
                .RegA(sA),
                .RegB(sB),
                .RegC(sC),
                .interpolate_count_ENP(ENP_interp_counter),
                .init_C(init),
                .sample_rdy(sample_rdy));
               
  pcm2706_interface pcm2706_interface1 (.sysclk(clk),
                                      .RST(rst),
                                      .serial_clk(serial_clk_sync),
                                      .lr_clk(lr_clk_sync),
                                      .serial_in(serial_in_sync),
                                      .parallel_out(sample),
                                      .data_rdy(data_rdy));
   
  Vrshftreg VrshftregA (.CLK(clk),
                       .RST(rst),
                       .RIN(rin),
                       .LIN(lin),
                       .S(sA),
                       .D(dA),
                       .Q(qA));
                       
   Vrshftreg VrshftregB (.CLK(clk),
                        .RST(rst),
                        .RIN(rin),
                        .LIN(lin),
                        .S(sB),
                        .D(dB),
                        .Q(qB));
                        
    Vrshftreg VrshftregC (.CLK(clk),
                         .RST(rst),
                         .RIN(rin),
                         .LIN(lin),
                         .S(sC),
                         .D(dC),
                         .Q(qC));                        
                         
    Vrsubtract #(17) difference (.A({sample2[15], sample2}),
                   .B({sample1[15],sample1}),
                   .D(d),
                   .OVFL());
                   
    assign d_div_temp = {d[16],d[16],d[16],d[16:4]}; 

    always @ (posedge clk)
        if (rst==1) d_div <= 16'b0;
        else d_div <= d_div_temp;

    Vradders Vradder (.A(qC),
                     .B(d_div),
                     .S(sum_output_temp),
                     .OVFL());  
      
     always @ (posedge clk)
         if (rst==1) sum_output <= 16'b0;
         else sum_output <= sum_output_temp;
      
    pcm1702_interface pcm1702_interface1 (.clk(clk),
                    .rst(rst),
                    .sample_rdy(sample_rdy),
                    .data(qC),
                    .shift_done(shifting_done),
                    .clk_out(clk_out),
                    .serial_out(serial_out),
                    .LE(LE)); 
      
 Vr74x163 interp_counter (.CLK(clk),
                   .CLR(rst),
                   .LD(ld_interp_counter),
                   .ENP(ENP_interp_counter),
                   .ENT(ENT),
                   .D(ld_cnt_interpolate_counter),
                   .Q(interp_cnt_out),
                   .RCO()); 
                   
                   
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
assign rst = RST;
assign rin = 1'b0;
assign lin = 1'b0;

assign dA = qB;
assign dB = sample;
assign dC = init ? qA : sum_output;

assign sample1 = qA;
assign sample2 = qB;

assign ld_interp_counter = interp_cnt_out[3] && interp_cnt_out[2] && interp_cnt_out[1] && interp_cnt_out[0];

endmodule