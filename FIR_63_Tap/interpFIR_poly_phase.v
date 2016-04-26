module interpFIR_poly_phase(clk, rst, inputSample, FIR_en, FIR_sel, outputSample);

parameter over_sample_factor = 16;

input clk, rst, inputSample, FIR_en, FIR_sel;
output outputSample;
wire [4:0] FIR_sel;
wire signed [15:0] inputSample;
wire signed [17:0] outputSample;


wire signed [10:0] b [0:4*over_sample_factor-1];
assign b[0] = -11'sd16;
assign b[1] = -11'sd32;
assign b[2] = -11'sd48;
assign b[3] = -11'sd63;
assign b[4] = -11'sd76;
assign b[5] = -11'sd87;
assign b[6] = -11'sd95;
assign b[7] = -11'sd101;	
assign b[8] = -11'sd103;	
assign b[9] = -11'sd101;	
assign b[10] = -11'sd95;	
assign b[11] = -11'sd84;	
assign b[12] = -11'sd70;	
assign b[13] = -11'sd50;	
assign b[14] = -11'sd27;
assign b[15] = 11'sd0;	
assign b[16] = 11'sd35;	
assign b[17] = 11'sd72;	
assign b[18] = 11'sd112;	
assign b[19] = 11'sd154;	
assign b[20] = 11'sd197;	
assign b[21] = 11'sd240;	
assign b[22] = 11'sd282;
assign b[23] = 11'sd323;	
assign b[24] = 11'sd362;	
assign b[25] = 11'sd397;	
assign b[26] = 11'sd429;	
assign b[27] = 11'sd457;	
assign b[28] = 11'sd479;	
assign b[29] = 11'sd496;	
assign b[30] = 11'sd507;	
assign b[31] = 11'sd512;	
assign b[32] = 11'sd507;	
assign b[33] = 11'sd496;	
assign b[34] = 11'sd479;	
assign b[35] = 11'sd457;	
assign b[36] = 11'sd429;	
assign b[37] = 11'sd397;	
assign b[38] = 11'sd362;	
assign b[39] = 11'sd323;	
assign b[40] = 11'sd282;	
assign b[41] = 11'sd240;	
assign b[42] = 11'sd197;	
assign b[43] = 11'sd154;
assign b[44] = 11'sd112;	
assign b[45] = 11'sd72;	
assign b[46] = 11'sd35;	
assign b[47] = 11'sd0;	
assign b[48] = -11'sd27;	
assign b[49] = -11'sd50;	
assign b[50] = -11'sd70;	
assign b[51] = -11'sd84;	
assign b[52] = -11'sd95;	
assign b[53] = -11'sd101;	
assign b[54] = -11'sd103;	
assign b[55] = -11'sd101;	
assign b[56] = -11'sd95;	
assign b[57] = -11'sd87;	
assign b[58] = -11'sd76;	
assign b[59] = -11'sd63;	
assign b[60] = -11'sd48;
assign b[61] = -11'sd32;	
assign b[62] = -11'sd16;
assign b[63] = 11'sd0;

reg signed [15:0] delay [0:4-1];
genvar i;
always @ (posedge clk) begin
	if (rst) begin
        delay[0] <= 0;
    end else if (FIR_en) begin
        delay[0] <= inputSample;
    end else begin
        delay[0] <= delay[0];
    end
end
generate
  for (i=1; i < 4; i=i+1) begin
    always @ (posedge clk) begin
    	if (rst) begin
            delay[i] <= 0;
        end else if (FIR_en) begin
            delay[i] <= delay[i-1];
        end else begin
            delay[i] <= delay[i];
        end
    end
  end
endgenerate

reg signed [26:0] mult_reg [0:4-1];
reg signed [26:0] mult [0:4-1];
genvar j;
generate
  for (j=0; j < 4; j=j+1) begin
  always @* begin
    case (FIR_sel)
      5'd0: mult[j] <= b[16*j+0];
      5'd1: mult[j] <= b[16*j+1];
      5'd2: mult[j] <= b[16*j+2];
      5'd3: mult[j] <= b[16*j+3];
      5'd4: mult[j] <= b[16*j+4];
      5'd5: mult[j] <= b[16*j+5];
      5'd6: mult[j] <= b[16*j+6];
      5'd7: mult[j] <= b[16*j+7];
      5'd8: mult[j] <= b[16*j+8];
      5'd9: mult[j] <= b[16*j+9];
      5'd10: mult[j] <= b[16*j+10];
      5'd11: mult[j] <= b[16*j+11];
      5'd12: mult[j] <= b[16*j+12];
      5'd13: mult[j] <= b[16*j+13];
      5'd14: mult[j] <= b[16*j+14];
      5'd15: mult[j] <= b[16*j+15];   
      default: mult[j] <= b[63];
    endcase
 end     
    always @ (posedge clk) begin
        if (rst) begin
            mult_reg[j] <= 0;
        end else begin
            mult_reg[j] <= mult[j]*delay[j];
        end
    end
 end
endgenerate

reg signed [26:0] sum_reg [0:3-1];

always @ (posedge clk) begin
    if (rst) begin
        sum_reg[0] <= 0;
        sum_reg[1] <= 0;
        sum_reg[2] <= 0;
    end else begin
        sum_reg[0] <= mult_reg[0]+mult_reg[1];
        sum_reg[1] <= mult_reg[2]+sum_reg[0];
        sum_reg[2] <= mult_reg[3]+sum_reg[1];
    end
end

assign outputSample = sum_reg[2] >>> 9;

endmodule