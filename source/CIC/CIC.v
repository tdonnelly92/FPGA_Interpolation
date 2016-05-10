module CIC(clk, rst, inputSample, CIC_en, pulse_slow, pulse_fast, data_select, outputSample, load_result_slow, load_result_fast);
input clk, rst, inputSample, CIC_en, pulse_slow, pulse_fast, data_select, load_result_slow, load_result_fast;
output signed [19:0] outputSample;
wire signed [27:0] inputSample, c;
reg signed [27:0] x, a, b, d, y, w;
reg signed [27:0] delay0, delay1, delay2, delay3, delay4, delay5, delay6;

always @ (posedge clk) begin
	if (rst) begin
		delay1 <= 0;
		delay2 <= 0;
		delay3 <= 0;
	end else if (CIC_en && pulse_slow) begin
		delay1 <= inputSample;
		delay2 <= x;
		delay3 <= a;
	end else begin
        delay1 <= delay1;
        delay2 <= delay2;
        delay3 <= delay3;
	end
end

always @ (posedge clk) begin
	if (rst) begin
		delay4 <= 0;
		delay5 <= 0;
		delay6 <= 0;
	end else if (CIC_en && pulse_fast) begin
		delay4 <= delay4 + c;
		delay5 <= delay5 + d;
		delay6 <= delay6 + y;
	end else begin
        delay4 <= delay4;
        delay5 <= delay5;
        delay6 <= delay6;
	end
end

always @ (posedge clk) begin
	if (rst) begin
	    x <= 0;
		a <= 0;
		b <= 0;
	end else if (CIC_en && load_result_slow) begin
		x <= inputSample - delay1;
		a <= x - delay2;
        b <= a - delay3;
	end else begin
        x <= x;
        a <= a;
        b <= b;
	end
end

always @ (posedge clk) begin
	if (rst) begin
		d <= 0;
		y <= 0;
		w <= 0;
	end else if (CIC_en && load_result_fast) begin
		d <= delay4 + c;
		y <= delay5 + d;
		w <= delay6 + y;
	end else begin
        d <= d;
        y <= y;
        w <= w;
	end
end

assign c = (data_select) ? b : 28'b0;

assign outputSample = w >>> 6;

endmodule