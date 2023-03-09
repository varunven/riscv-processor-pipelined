module EX_MEM(
	input logic clk, act, pc_replace, flag,
	input logic [6:0] IDEX_opcode_out,
	input logic [2:0] IDEX_funct3_out,
	input logic [31:0] ALU_data_addr_out,
	input logic [3:0] ALU_data_write_byte_out,
	input logic IDEX_register_write_valid_out,
	input logic [4:0] IDEX_write_reg_out,
	input logic [31:0] ALU_reg_write_data_out, ALU_data_write_out,
	output logic [6:0] EXMEM_opcode_out,
	output logic [2:0] EXMEM_funct3_out,
	output logic [31:0] EXMEM_data_addr_out,
	output logic [3:0] EXMEM_data_write_byte_out,
	output logic EXMEM_register_write_valid_out,
	output logic [4:0] EXMEM_write_reg_out,
	output logic [31:0] EXMEM_reg_write_data_out, EXMEM_data_write_out,
	output logic EXMEM_pc_replace_out,
	output logic EXMEM_flag_out 
);
    always@(posedge clk) begin
        EXMEM_opcode_out = IDEX_opcode_out;
        EXMEM_funct3_out = IDEX_funct3_out;
        EXMEM_data_addr_out = ALU_data_addr_out;
        EXMEM_data_write_byte_out = ALU_data_write_byte_out&{act,act,act,act};
        EXMEM_register_write_valid_out = IDEX_register_write_valid_out&act;
        EXMEM_write_reg_out = IDEX_write_reg_out;
        EXMEM_reg_write_data_out = ALU_reg_write_data_out;
        EXMEM_data_write_out = ALU_data_write_out;
		  EXMEM_pc_replace_out = pc_replace;
		  EXMEM_flag_out = flag;
    end
endmodule

module EX_MEM_testbench();
	logic clk, act, pc_replace, flag;
	logic [6:0] IDEX_opcode_out;
	logic [2:0] IDEX_funct3_out;
	logic [31:0] ALU_data_addr_out;
	logic [3:0] ALU_data_write_byte_out;
	logic IDEX_register_write_valid_out;
	logic [4:0] IDEX_write_reg_out;
	logic [31:0] ALU_reg_write_data_out, ALU_data_write_out;
	logic [6:0] EXMEM_opcode_out;
	logic [2:0] EXMEM_funct3_out;
	logic [31:0] EXMEM_data_addr_out;
	logic [3:0] EXMEM_data_write_byte_out;
	logic EXMEM_register_write_valid_out;
	logic [4:0] EXMEM_write_reg_out;
	logic [31:0] EXMEM_reg_write_data_out, EXMEM_data_write_out;
	logic EXMEM_pc_replace_out;
	logic EXMEM_flag_out;

	EX_MEM dut (.clk, .act, .pc_replace, .flag, .IDEX_opcode_out,
	.ALU_data_write_byte_out, .IDEX_funct3_out, .ALU_data_addr_out, 
	.IDEX_register_write_valid_out, .IDEX_write_reg_out, .ALU_reg_write_data_out,
	.ALU_data_write_out, .EXMEM_opcode_out, .EXMEM_funct3_out, .EXMEM_data_addr_out,
	.EXMEM_data_write_byte_out, .EXMEM_register_write_valid_out, .EXMEM_write_reg_out,
	.EXMEM_reg_write_data_out, .EXMEM_data_write_out, .EXMEM_pc_replace_out,
	.EXMEM_flag_out);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		act = 1;
		pc_replace = 1;
		flag = 1;
		IDEX_opcode_out = 7'b0011001;
		IDEX_funct3_out = 3'b011;
		ALU_data_addr_out = 32'b00000000000000000000000001110000;
		ALU_data_write_byte_out = 4'b1001;
		IDEX_register_write_valid_out = 1;
		IDEX_write_reg_out = 5'b10101; 
		ALU_reg_write_data_out = 32'b00000000000000000000000000000011;
		ALU_data_write_out = 32'b00001100000000000000000000000000; #500
		act = 0; #500
		$stop;
	end
endmodule