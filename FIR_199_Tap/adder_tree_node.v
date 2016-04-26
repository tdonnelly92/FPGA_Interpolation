// baeckler - 01-02-2007
// a relatively fancy adder tree node

module adder_tree_node (clk,a,b,out);

parameter IN_BITS = 16;
parameter OUT_BITS = 17;
parameter SIGN_EXT = 1;
parameter REGISTER_MIDDLE = 0;  // register within adder chains
parameter REGISTER_OUTPUT = 1;	// register adder outputs
parameter B_SHIFT = 1;

// for the placement of the midway pipeline registers
localparam LS_WIDTH = OUT_BITS / 2;
localparam MS_WIDTH = OUT_BITS - LS_WIDTH;

input clk;
input [IN_BITS-1:0] a,b;
output [OUT_BITS-1:0] out;

// sign extension
wire [OUT_BITS-1:0] a_ext,b_ext;
generate
	if (SIGN_EXT) begin
		assign a_ext = {{(OUT_BITS-IN_BITS){a[IN_BITS-1]}},a};
		assign b_ext = {{(OUT_BITS-IN_BITS){b[IN_BITS-1]}},b};
	end
	else begin
		assign a_ext = {{(OUT_BITS-IN_BITS){1'b0}},a};
		assign b_ext = {{(OUT_BITS-IN_BITS){1'b0}},b};
	end
endgenerate

// offset B
wire [OUT_BITS-1:0] b_ext_shft;
assign b_ext_shft = b_ext << B_SHIFT;

// addition
wire [OUT_BITS-1:0] sum;
generate
	if (REGISTER_MIDDLE) begin

		// pipeline in the middle of the adder chain
		reg [LS_WIDTH-1+1:0] ls_adder;
		wire cross_carry = ls_adder[LS_WIDTH];
		always @(posedge clk) begin
			ls_adder <= {1'b0,a_ext[LS_WIDTH-1:0]} + {1'b0,b_ext_shft[LS_WIDTH-1:0]};
		end

		reg [MS_WIDTH-1:0] ms_data_a,ms_data_b;
		always @(posedge clk) begin
			ms_data_a <= a_ext[OUT_BITS-1:OUT_BITS-MS_WIDTH];
			ms_data_b <= b_ext_shft[OUT_BITS-1:OUT_BITS-MS_WIDTH];
		end

		wire [MS_WIDTH-1+1:0] ms_adder;
		assign ms_adder = {ms_data_a,cross_carry} + 
				{ms_data_b,cross_carry};

		assign sum = {ms_adder[MS_WIDTH:1],ls_adder[LS_WIDTH-1:0]};
	end
	else begin
		// simple addition
		assign sum = a_ext + b_ext_shft;
	end
endgenerate

// optional output register
reg [OUT_BITS-1:0] out;
generate 
	if (REGISTER_OUTPUT) begin
		always @(posedge clk) begin
			out <= sum;	
		end
	end
	else begin
		always @(*) begin
			out = sum;	
		end	
	end
endgenerate

endmodule