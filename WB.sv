module WB(
	input logic clk,
	input logic [4:0] MEMWB_write_reg_out,
	input logic [31:0] reg_write_data,
	input logic MEMWB_register_write_valid_out,
	output logic [4:0] WB_write_reg_out,
	output logic [31:0] WB_reg_write_data_out,
	output logic WB_register_write_valid_out
);
	always@(posedge clk) begin
		WB_write_reg_out = MEMWB_write_reg_out;
		WB_reg_write_data_out = reg_write_data;
		WB_register_write_valid_out = MEMWB_register_write_valid_out;
	end
endmodule

// module WB_testbench();
// 	logic clk;
// 	logic [4:0] MEMWB_write_reg_out;
// 	logic [31:0] reg_write_data;
// 	logic MEMWB_register_write_valid_out;
// 	logic [4:0] WB_write_reg_out;
// 	logic [31:0] WB_reg_write_data_out;
// 	logic WB_register_write_valid_out;
	
// 	WB dut (.clk, .MEMWB_write_reg_out, .reg_write_data, .MEMWB_register_write_valid_out,
// 	.WB_write_reg_out, .WB_reg_write_data_out, .WB_register_write_valid_out);

// 	parameter CLOCK_PERIOD=100;
// 	initial begin
// 		clk <= 0;
// 		forever #(CLOCK_PERIOD/2) clk <= ~clk;
// 	end

// 	initial begin
// 		MEMWB_write_reg_out = 5'b00000;
// 		reg_write_data = 32'b00000000000000000000000000001111;
// 		MEMWB_register_write_valid_out = 1; #500
		
// 		MEMWB_write_reg_out = 5'b10101;
// 		reg_write_data = 32'b00000000000000000000000000000000;
// 		MEMWB_register_write_valid_out = 0; #500
// 		$stop;
// 	end
// endmodule