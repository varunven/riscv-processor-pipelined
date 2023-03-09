// ID/EX pipeline register
module ID_EX(
	input logic clk, flag, pc_replace, 
	//Register file inputs
	input logic bit_th_in,
	input logic [4:0] read_reg1_in, read_reg2_in, write_reg_in,
	input logic [2:0] funct3_in,
	input logic [6:0] opcode_in,
	input logic signed [31:0] imm_in,
	input logic [31:0] read_data1_in, read_data2_in,
	//Control block inputs
	input logic register_write_valid_in,
	input logic [3:0] data_write_byte_in,
	input logic [31:0] instruction_addr_in,
	//Register file outputs
	output logic bit_th_out,
	output logic [4:0] IDEX_read_reg1_out, IDEX_read_reg2_out, IDEX_write_reg_out,
	output logic [2:0] IDEX_funct3_out,
	output logic [6:0] IDEX_opcode_out,
	output logic signed [31:0] IDEX_imm_out,
	output logic IDEX_register_write_valid_out,
	output logic [31:0] IDEX_read_data1_out, IDEX_read_data2_out,
	//Control block outputs
	output logic [3:0] IDEX_data_write_byte_out,
	output logic [31:0] IDEX_instruction_addr_out,
	output logic IDEX_flag_out
);
// in case of branch, want to scrap the existing pipelined instr and restart from new point
// keep them in case branch cond fails, so can use pipelined one
    always@(posedge clk)
    begin
		  if(flag) begin
			  bit_th_out = bit_th_in;
			  IDEX_read_reg1_out = read_reg1_in;
			  IDEX_read_reg2_out = read_reg2_in;
			  IDEX_write_reg_out = write_reg_in;
			  IDEX_funct3_out = funct3_in;
			  IDEX_opcode_out = opcode_in;
			  IDEX_imm_out = imm_in;
			  IDEX_register_write_valid_out = register_write_valid_in & !pc_replace & flag;
			  IDEX_read_data1_out = read_data1_in;
			  IDEX_read_data2_out = read_data2_in;
			  IDEX_data_write_byte_out = data_write_byte_in&{!pc_replace&flag,!pc_replace&flag,!pc_replace&flag,!pc_replace&flag};
			  IDEX_instruction_addr_out = instruction_addr_in;
			  IDEX_flag_out = flag;
		  end
    end
endmodule

module ID_EX_testbench();
	logic clk, flag, pc_replace;
	//Register file s
	logic bit_th_in;
	logic [4:0] read_reg1_in, read_reg2_in, write_reg_in;
	logic [2:0] funct3_in;
	logic [6:0] opcode_in;
	logic signed [31:0] imm_in;
	logic [31:0] read_data1_in, read_data2_in;
	//Control block s
	logic register_write_valid_in;
	logic [3:0] data_write_byte_in;
	logic [31:0] instruction_addr_in;
	//Register file s
	logic bit_th_out;
	logic [4:0] IDEX_read_reg1_out, IDEX_read_reg2_out, IDEX_write_reg_out;
	logic [2:0] IDEX_funct3_out;
	logic [6:0] IDEX_opcode_out;
	logic signed [31:0] IDEX_imm_out;
	logic IDEX_register_write_valid_out;
	logic [31:0] IDEX_read_data1_out, IDEX_read_data2_out;
	//Control block s
	logic [3:0] IDEX_data_write_byte_out;
	logic [31:0] IDEX_instruction_addr_out;
	logic IDEX_flag_out;

	ID_EX dut (.clk, .flag, .pc_replace, .bit_th_in,
	.read_reg1_in, .read_reg2_in, .write_reg_in, .funct3_in, .opcode_in,
	.imm_in, .read_data1_in, .read_data2_in, .register_write_valid_in,
	.data_write_byte_in, .instruction_addr_in, .bit_th_out, .IDEX_read_reg1_out,
	.IDEX_read_reg2_out,	.IDEX_write_reg_out, .IDEX_funct3_out, .IDEX_opcode_out,
	.IDEX_imm_out, .IDEX_register_write_valid_out, .IDEX_read_data1_out,
	.IDEX_read_data2_out, .IDEX_data_write_byte_out, .IDEX_instruction_addr_out, .IDEX_flag_out);

	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		flag = 0;
		pc_replace = 0;
		bit_th_in = 1;
		read_reg1_in = 5'b11101;
		read_reg2_in = 5'b11110;
		write_reg_in = 5'b11111;
		funct3_in = 3'b101;
		opcode_in = 7'b1001001;
		imm_in = 32'b0;
		read_data1_in = 32'b00000000000000000000000001110000;
		read_data2_in = 32'b00000000000000000000000001110011;
		register_write_valid_in = 1;
		data_write_byte_in = 4'b1011;
		instruction_addr_in = 32'b00000000000000000000000000010011; #500
		pc_replace = 1;
		flag = 0; #500
		pc_replace = 0;
		flag = 1; #500
		pc_replace = 1;
		flag = 1; #500
		$stop;
	end
endmodule