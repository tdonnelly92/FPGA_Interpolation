module sinc_interp_optimal(clk, rst, inputSample, sinc_en, sinc_select, pre_load, outputSample);
input clk, rst, inputSample, sinc_en, sinc_select, pre_load;
output outputSample;
wire [4:0] sinc_select;
wire signed [15:0] inputSample;
wire signed [19:0] outputSample;
wire pre_load;

reg signed [15:0] temp1;
always @ (posedge clk) begin
	if (rst) begin
        temp1 <= 0;
    end else if (pre_load) begin
        temp1 <= inputSample;
    end else begin
        temp1 <= temp1;
    end
end
reg signed [15:0] temp2;
always @ (posedge clk) begin
	if (rst) begin
        temp2 <= 0;
    end else if (pre_load) begin
        temp2 <= temp1;
    end else begin
        temp2 <= temp2;
    end
end


reg signed [15:0] delay [1:19];
always @ (posedge clk) begin
	if (rst) begin
        delay[1] <= 0;
    end else if (sinc_en) begin
        delay[1] <= temp2;
    end else begin
        delay[1] <= delay[1];
    end
end

genvar i;
generate
  for (i=2; i < 20; i=i+1) begin
    always @ (posedge clk) begin
    	if (rst) begin
            delay[i] <= 0;
        end else if (sinc_en) begin
            delay[i] <= delay[i-1];
        end else begin
            delay[i] <= delay[i];
        end
    end
  end
endgenerate

wire signed [10:0] sinc_samples [1:101];
assign sinc_samples[1] =11'sd512;
assign sinc_samples[2] =11'sd503;
assign sinc_samples[3] =11'sd478;
assign sinc_samples[4] =11'sd438;
assign sinc_samples[5] =11'sd386;
assign sinc_samples[6] =11'sd325;
assign sinc_samples[7] =11'sd258;
assign sinc_samples[8] =11'sd188;
assign sinc_samples[9] =11'sd120;
assign sinc_samples[10] =11'sd56;
assign sinc_samples[11] =11'sd0;
assign sinc_samples[12] =-11'sd44;
assign sinc_samples[13] =-11'sd78;
assign sinc_samples[14] =-11'sd98;
assign sinc_samples[15] =-11'sd107;
assign sinc_samples[16] =-11'sd105;
assign sinc_samples[17] =-11'sd94;
assign sinc_samples[18] =-11'sd75;
assign sinc_samples[19] =-11'sd52;
assign sinc_samples[20] =-11'sd26;
assign sinc_samples[21] =11'sd0;
assign sinc_samples[22] =11'sd22;
assign sinc_samples[23] =11'sd40;
assign sinc_samples[24] =11'sd53;
assign sinc_samples[25] =11'sd59;
assign sinc_samples[26] =11'sd60;
assign sinc_samples[27] =11'sd55;
assign sinc_samples[28] =11'sd45;
assign sinc_samples[29] =11'sd32;
assign sinc_samples[30] =11'sd16;
assign sinc_samples[31] =11'sd0;
assign sinc_samples[32] =-11'sd14;
assign sinc_samples[33] =-11'sd25;
assign sinc_samples[34] =-11'sd34;
assign sinc_samples[35] =-11'sd39;
assign sinc_samples[36] =-11'sd40;
assign sinc_samples[37] =-11'sd37;
assign sinc_samples[38] =-11'sd30;
assign sinc_samples[39] =-11'sd21;
assign sinc_samples[40] =-11'sd11;
assign sinc_samples[41] =11'sd0;
assign sinc_samples[42] =11'sd9;
assign sinc_samples[43] =11'sd17;
assign sinc_samples[44] =11'sd23;
assign sinc_samples[45] =11'sd27;
assign sinc_samples[46] =11'sd27;
assign sinc_samples[47] =11'sd26;
assign sinc_samples[48] =11'sd21;
assign sinc_samples[49] =11'sd15;
assign sinc_samples[50] =11'sd8;
assign sinc_samples[51] =11'sd0;
assign sinc_samples[52] =-11'sd6;
assign sinc_samples[53] =-11'sd12;
assign sinc_samples[54] =-11'sd16;
assign sinc_samples[55] =-11'sd19;
assign sinc_samples[56] =-11'sd19;
assign sinc_samples[57] =-11'sd18;
assign sinc_samples[58] =-11'sd15;
assign sinc_samples[59] =-11'sd11;
assign sinc_samples[60] =-11'sd6;
assign sinc_samples[61] =11'sd0;
assign sinc_samples[62] =11'sd4;
assign sinc_samples[63] =11'sd8;
assign sinc_samples[64] =11'sd11;
assign sinc_samples[65] =11'sd13;
assign sinc_samples[66] =11'sd14;
assign sinc_samples[67] =11'sd13;
assign sinc_samples[68] =11'sd11;
assign sinc_samples[69] =11'sd8;
assign sinc_samples[70] =11'sd4;
assign sinc_samples[71] =11'sd0;
assign sinc_samples[72] =-11'sd3;
assign sinc_samples[73] =-11'sd6;
assign sinc_samples[74] =-11'sd8;
assign sinc_samples[75] =-11'sd9;
assign sinc_samples[76] =-11'sd9;
assign sinc_samples[77] =-11'sd9;
assign sinc_samples[78] =-11'sd7;
assign sinc_samples[79] =-11'sd5;
assign sinc_samples[80] =-11'sd3;
assign sinc_samples[81] =11'sd0;
assign sinc_samples[82] =11'sd2;
assign sinc_samples[83] =11'sd4;
assign sinc_samples[84] =11'sd5;
assign sinc_samples[85] =11'sd6;
assign sinc_samples[86] =11'sd6;
assign sinc_samples[87] =11'sd6;
assign sinc_samples[88] =11'sd5;
assign sinc_samples[89] =11'sd4;
assign sinc_samples[90] =11'sd2;
assign sinc_samples[91] =11'sd0;
assign sinc_samples[92] =-11'sd1;
assign sinc_samples[93] =-11'sd2;
assign sinc_samples[94] =-11'sd3;
assign sinc_samples[95] =-11'sd4;
assign sinc_samples[96] =-11'sd4;
assign sinc_samples[97] =-11'sd4;
assign sinc_samples[98] =-11'sd3;
assign sinc_samples[99] =-11'sd2;
assign sinc_samples[100] =-11'sd1;
assign sinc_samples[101] =11'sd0;

reg signed [10:0] mult_comb [1:19];

genvar k;
generate
  for (k=1; k < 20; k=k+1) begin
    
    if (k == 1) begin
        always @* begin
            case (sinc_select)
                5'd1: mult_comb[k] <= sinc_samples[91-10*k+0];
                5'd2: mult_comb[k] <= sinc_samples[91-10*k+1];
                5'd3: mult_comb[k] <= sinc_samples[91-10*k+2];
                5'd4: mult_comb[k] <= sinc_samples[91-10*k+3];
                5'd5: mult_comb[k] <= sinc_samples[91-10*k+4];
                5'd6: mult_comb[k] <= sinc_samples[91-10*k+5];
                5'd7: mult_comb[k] <= sinc_samples[91-10*k+6];
                5'd8: mult_comb[k] <= sinc_samples[91-10*k+7];
                5'd9: mult_comb[k] <= sinc_samples[91-10*k+8];
                5'd10: mult_comb[k] <= sinc_samples[91-10*k+9];
                5'd11: mult_comb[k] <= sinc_samples[91-10*k+10];
                default: mult_comb[k] <= 11'b0;
            endcase
        end
    end else if (k < 10) begin
        always @* begin
            case (sinc_select)
                5'd1: mult_comb[k] <= sinc_samples[91-10*k+0];
                5'd2: mult_comb[k] <= sinc_samples[91-10*k+1];
                5'd3: mult_comb[k] <= sinc_samples[91-10*k+2];
                5'd4: mult_comb[k] <= sinc_samples[91-10*k+3];
                5'd5: mult_comb[k] <= sinc_samples[91-10*k+4];
                5'd6: mult_comb[k] <= sinc_samples[91-10*k+5];
                5'd7: mult_comb[k] <= sinc_samples[91-10*k+6];
                5'd8: mult_comb[k] <= sinc_samples[91-10*k+7];
                5'd9: mult_comb[k] <= sinc_samples[91-10*k+8];
                5'd10: mult_comb[k] <= sinc_samples[91-10*k+9];
                5'd11: mult_comb[k] <= sinc_samples[91-10*k+10];
                5'd12: mult_comb[k] <= sinc_samples[91-10*k+11];             
                5'd13: mult_comb[k] <= sinc_samples[91-10*k+12];
                5'd14: mult_comb[k] <= sinc_samples[91-10*k+13];
                5'd15: mult_comb[k] <= sinc_samples[91-10*k+14];
                5'd16: mult_comb[k] <= sinc_samples[91-10*k+15];
                5'd17: mult_comb[k] <= sinc_samples[91-10*k+16];
                5'd18: mult_comb[k] <= sinc_samples[91-10*k+17];
                5'd19: mult_comb[k] <= sinc_samples[91-10*k+18];
                5'd20: mult_comb[k] <= sinc_samples[91-10*k+19];
                5'd21: mult_comb[k] <= sinc_samples[91-10*k+20];
                default: mult_comb[k] <= 11'b0;
            endcase
        end
    end else if (k == 10) begin
        always @* begin
            case (sinc_select)
                5'd1: mult_comb[k] <= sinc_samples[11];
                5'd2: mult_comb[k] <= sinc_samples[10];
                5'd3: mult_comb[k] <= sinc_samples[9];
                5'd4: mult_comb[k] <= sinc_samples[8];
                5'd5: mult_comb[k] <= sinc_samples[7];
                5'd6: mult_comb[k] <= sinc_samples[6];
                5'd7: mult_comb[k] <= sinc_samples[5];
                5'd8: mult_comb[k] <= sinc_samples[4];
                5'd9: mult_comb[k] <= sinc_samples[3];
                5'd10: mult_comb[k] <= sinc_samples[2];
                5'd11: mult_comb[k] <= sinc_samples[1];
                5'd12: mult_comb[k] <= sinc_samples[2];             
                5'd13: mult_comb[k] <= sinc_samples[3];
                5'd14: mult_comb[k] <= sinc_samples[4];
                5'd15: mult_comb[k] <= sinc_samples[5];
                5'd16: mult_comb[k] <= sinc_samples[6];
                5'd17: mult_comb[k] <= sinc_samples[7];
                5'd18: mult_comb[k] <= sinc_samples[8];
                5'd19: mult_comb[k] <= sinc_samples[9];
                5'd20: mult_comb[k] <= sinc_samples[10];
                5'd21: mult_comb[k] <= sinc_samples[11];
                default: mult_comb[k] <= 11'b0;
            endcase
        end     
    end else if (k == 19) begin
        always @* begin
            case (sinc_select)
                5'd11: mult_comb[k] <= sinc_samples[11+10*(k-10)-10];
                5'd12: mult_comb[k] <= sinc_samples[11+10*(k-10)-11];             
                5'd13: mult_comb[k] <= sinc_samples[11+10*(k-10)-12];
                5'd14: mult_comb[k] <= sinc_samples[11+10*(k-10)-13];
                5'd15: mult_comb[k] <= sinc_samples[11+10*(k-10)-14];
                5'd16: mult_comb[k] <= sinc_samples[11+10*(k-10)-15];
                5'd17: mult_comb[k] <= sinc_samples[11+10*(k-10)-16];
                5'd18: mult_comb[k] <= sinc_samples[11+10*(k-10)-17];
                5'd19: mult_comb[k] <= sinc_samples[11+10*(k-10)-18];
                5'd20: mult_comb[k] <= sinc_samples[11+10*(k-10)-19];
                5'd21: mult_comb[k] <= sinc_samples[11+10*(k-10)-20];
                default: mult_comb[k] <= 11'b0;
            endcase
        end
    end else begin
        always @* begin
            case (sinc_select)
                5'd1: mult_comb[k] <= sinc_samples[11+10*(k-10)-0];
                5'd2: mult_comb[k] <= sinc_samples[11+10*(k-10)-1];
                5'd3: mult_comb[k] <= sinc_samples[11+10*(k-10)-2];
                5'd4: mult_comb[k] <= sinc_samples[11+10*(k-10)-3];
                5'd5: mult_comb[k] <= sinc_samples[11+10*(k-10)-4];
                5'd6: mult_comb[k] <= sinc_samples[11+10*(k-10)-5];
                5'd7: mult_comb[k] <= sinc_samples[11+10*(k-10)-6];
                5'd8: mult_comb[k] <= sinc_samples[11+10*(k-10)-7];
                5'd9: mult_comb[k] <= sinc_samples[11+10*(k-10)-8];
                5'd10: mult_comb[k] <= sinc_samples[11+10*(k-10)-9];
                5'd11: mult_comb[k] <= sinc_samples[11+10*(k-10)-10];
                5'd12: mult_comb[k] <= sinc_samples[11+10*(k-10)-11];             
                5'd13: mult_comb[k] <= sinc_samples[11+10*(k-10)-12];
                5'd14: mult_comb[k] <= sinc_samples[11+10*(k-10)-13];
                5'd15: mult_comb[k] <= sinc_samples[11+10*(k-10)-14];
                5'd16: mult_comb[k] <= sinc_samples[11+10*(k-10)-15];
                5'd17: mult_comb[k] <= sinc_samples[11+10*(k-10)-16];
                5'd18: mult_comb[k] <= sinc_samples[11+10*(k-10)-17];
                5'd19: mult_comb[k] <= sinc_samples[11+10*(k-10)-18];
                5'd20: mult_comb[k] <= sinc_samples[11+10*(k-10)-19];
                5'd21: mult_comb[k] <= sinc_samples[11+10*(k-10)-20];
                default: mult_comb[k] <= 11'b0;
            endcase
        end
    end    
  end
endgenerate

reg signed [26:0] mult_reg [1:19];
genvar n;
generate
  for (n=1; n < 20; n=n+1) begin
    always @ (posedge clk) begin
        if (rst) begin
            mult_reg[n] <= 0;
        end else begin
            mult_reg[n] <= mult_comb[20-n]*delay[n];
        end
     end
  end
endgenerate

wire signed [27*19:1] in_words;
wire signed [26:0] out_at0;
genvar j;
for (j=1; j<20; j=j+1) assign in_words[27*j:27*j-26] = mult_reg[j];


adder_tree at0 (.clk(clk),.in_words(in_words),.out(out_at0),.extra_bit_in(1'b0),.extra_bit_out());
	defparam at0 .NUM_IN_WORDS = (19);
	defparam at0 .BITS_PER_IN_WORD = 27;
	defparam at0 .OUT_BITS = 27;
	defparam at0 .SIGN_EXT = 1;
	defparam at0 .REGISTER_OUTPUT = 1;
	defparam at0 .REGISTER_MIDDLE = 0;
	defparam at0 .SHIFT_DIST = 0;
	defparam at0 .EXTRA_BIT_USED = 0;

assign outputSample = out_at0 >>> 7;

endmodule