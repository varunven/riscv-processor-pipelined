module MEM_WB(
	input logic clk,
	input logic [6:0] EXMEM_opcode_out,
	input logic [2:0] EXMEM_funct3_out,
	input logic [31:0] EXMEM_data_addr_out,
	input logic EXMEM_register_write_valid_out,
	input logic [4:0] EXMEM_write_reg_out,
	input logic [31:0] EXMEM_reg_write_data_out, data_read,
	output logic [6:0] MEMWB_opcode_out,
	output logic [2:0] MEMWB_funct3_out,
	output logic [31:0] MEMWB_data_addr_out,
	output logic MEMWB_register_write_valid_out,
	output logic [4:0] MEMWB_write_reg_out,
	output logic [31:0] MEMWB_reg_write_data_out, MEMWB_data_read
);

	always@(posedge clk) begin
	  MEMWB_opcode_out = EXMEM_opcode_out;
	  MEMWB_funct3_out = EXMEM_funct3_out;
	  MEMWB_data_addr_out = EXMEM_data_addr_out;
	  MEMWB_register_write_valid_out = EXMEM_register_write_valid_out;
	  MEMWB_write_reg_out = EXMEM_write_reg_out;
	  MEMWB_reg_write_data_out = EXMEM_reg_write_data_out;
	  MEMWB_data_read = data_read;
	end
endmodule

module MEM_WB_testbench();
	logic clk;
	logic [6:0] EXMEM_opcode_out;
	logic [2:0] EXMEM_funct3_out;
	logic [31:0] EXMEM_data_addr_out;
	logic EXMEM_register_write_valid_out;
	logic [4:0] EXMEM_write_reg_out;
	logic [31:0] EXMEM_reg_write_data_out, data_read;

	logic [6:0] MEMWB_opcode_out;
	logic [2:0] MEMWB_funct3_out;
	logic [31:0] MEMWB_data_addr_out;
	logic MEMWB_register_write_valid_out;
	logic [4:0] MEMWB_write_reg_out;
	logic [31:0] MEMWB_reg_write_data_out, MEMWB_data_read;
	
	MEM_WB dut (.clk, .EXMEM_opcode_out, .EXMEM_funct3_out, .EXMEM_data_addr_out,
	.EXMEM_register_write_valid_out, .EXMEM_write_reg_out, .EXMEM_reg_write_data_out,
	.data_read, .MEMWB_opcode_out, .MEMWB_funct3_out, .MEMWB_data_addr_out,
	.MEMWB_register_write_valid_out, .MEMWB_write_reg_out, .MEMWB_reg_write_data_out,
	.MEMWB_data_read);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		EXMEM_opcode_out = 7'b0011001;
		EXMEM_funct3_out = 3'b011;
		EXMEM_data_addr_out = 32'b00000000000000000000000001110000;
		EXMEM_register_write_valid_out = 1;
		EXMEM_write_reg_out = 5'b10101; 
		EXMEM_reg_write_data_out = 32'b00000000000000000000000000000011;
		data_read = 32'b00001100000000000000000000000000; #500
		$stop;
	end
endmodule