module riscv32#(parameter reset_pc=32'h00010000)  // On reset, set the PC to this value
(
	input logic clk, reset
);

	// register_file   
	logic [31:0] read_data1, read_data2; // rv1, rv2
	logic [31:0] reg_write_data; // data to write to register		
	logic [4:0] read_reg1, read_reg2, write_reg;
	logic [31:0] instruction_addr, instruction_read;
	logic [31:0] data_read;
			 
	logic flag, act, pc_replace, pc_JALR;
	logic [31:0] pc_new;
	logic [31:0] instruction_addr_upd;
	logic [31:0] IFID_instruction_read_out, IFID_instruction_addr_out;
	
	logic [4:0] IDEX_read_reg1_out, IDEX_read_reg2_out, IDEX_write_reg_out;
	logic [2:0] IDEX_funct3_out;
	logic [6:0] IDEX_opcode_out;
	logic signed [31:0] IDEX_imm_out;
	logic IDEX_register_write_valid_out, IDEX_bit_th_out;
	logic [31:0] IDEX_read_data1_out, IDEX_read_data2_out;
	logic [3:0] IDEX_data_write_byte_out;
	logic [31:0] IDEX_instruction_addr_out;
	logic IDEX_flag_out;
	
	logic [6:0] EXMEM_opcode_out;
	logic [2:0] EXMEM_funct3_out;
	logic [31:0] EXMEM_data_addr_out;
	logic [3:0] EXMEM_data_write_byte_out;
	logic EXMEM_register_write_valid_out;
	logic [4:0] EXMEM_write_reg_out;
	logic [31:0] EXMEM_reg_write_data_out, EXMEM_data_write_out;
	logic EXMEM_pc_replace_out;
	logic EXMEM_flag_out;
	
	logic [6:0] MEMWB_opcode_out;
	logic [2:0] MEMWB_funct3_out;
	logic [31:0] MEMWB_data_addr_out;
	logic MEMWB_register_write_valid_out;
	logic [4:0] MEMWB_write_reg_out;
	logic [31:0] MEMWB_reg_write_data_out, MEMWB_data_read;
	
	logic [4:0] WB_write_reg_out;
	logic [31:0] WB_reg_write_data_out;
	logic WB_register_write_valid_out;
	
	logic [31:0] control_imm_out;
	logic control_register_write_valid_out;
	logic [3:0] control_data_write_byte_out;
	
	logic [31:0] ALU_read_data1_in, ALU_read_data2_in;
	logic [3:0] ALU_data_write_byte_out;
	logic [31:0] ALU_reg_write_data_out, ALU_data_addr_out, ALU_data_write_out;

	//Assigning values to registers
	logic [4:0] write_reg_final;
		
	always@(posedge clk) begin
		if(reset) instruction_addr = 0;
		else if((!flag || !pc_replace) && instruction_addr_upd) instruction_addr = instruction_addr+4-instruction_addr_upd;
		else if((!flag || !pc_replace)) instruction_addr = instruction_addr+4;
		else if(!pc_JALR) instruction_addr = instruction_addr+4-instruction_addr_upd+pc_new;
		else begin instruction_addr = pc_new; end
	end

	assign read_reg1 = IFID_instruction_read_out[19:15];
	assign read_reg2 = IFID_instruction_read_out[24:20];
	assign write_reg = IFID_instruction_read_out[11:7];
	assign write_reg_final = (instruction_addr<16)?5'b00000:MEMWB_write_reg_out;

	always@(*) begin		
		flag=1;
		act=1;
		
		if(EXMEM_write_reg_out == IDEX_read_reg1_out &&
		EXMEM_register_write_valid_out && instruction_addr>=12) begin
			if(EXMEM_opcode_out == 7'b0000011) begin
				instruction_addr_upd = 4;
				flag=0;
				act=0;
			end
			else begin
				instruction_addr_upd = 0;
				ALU_read_data1_in = EXMEM_reg_write_data_out;
			end
		end
		
		else if(MEMWB_write_reg_out == IDEX_read_reg1_out &&
		MEMWB_register_write_valid_out && instruction_addr>=16) begin
			instruction_addr_upd = 0;
			ALU_read_data1_in = reg_write_data;
		end
		
		else if(WB_write_reg_out == IDEX_read_reg1_out
		&& WB_register_write_valid_out && instruction_addr>=20) begin
			instruction_addr_upd = 0;
			ALU_read_data1_in = WB_reg_write_data_out;
		end
			
		else begin
			instruction_addr_upd = 0;
			ALU_read_data1_in = IDEX_read_data1_out;
		end
		
		if(EXMEM_write_reg_out == IDEX_read_reg2_out && EXMEM_register_write_valid_out 
		&& instruction_addr>=12 && (IDEX_opcode_out[6:4]==3'b110 || 
		IDEX_opcode_out[6:4]==3'b011 || IDEX_opcode_out[6:4]==3'b010))
		begin // store, r-type, branch/jalr/jal
			if(EXMEM_opcode_out == 7'b0000011) begin // load
				instruction_addr_upd = 4;
				flag=0;
				act=0;
			end
			else begin
				instruction_addr_upd = 0;
				ALU_read_data2_in = EXMEM_reg_write_data_out;
			end
		end
		
		else if(MEMWB_write_reg_out == IDEX_read_reg2_out &&
		MEMWB_register_write_valid_out && instruction_addr>=16 &&
		(IDEX_opcode_out[6:4]==3'b110 || IDEX_opcode_out[6:4]==3'b011 ||
		IDEX_opcode_out[6:4]==3'b010)) begin
			instruction_addr_upd = 0;
			ALU_read_data2_in = reg_write_data;
		end
		
		else if(WB_write_reg_out == IDEX_read_reg2_out &&
		WB_register_write_valid_out && instruction_addr>=20
		&& (IDEX_opcode_out[6:4]==3'b110 || IDEX_opcode_out[6:4]==3'b011
		|| IDEX_opcode_out[6:4]==3'b010)) begin
			instruction_addr_upd = 0;
			ALU_read_data2_in = WB_reg_write_data_out;
		end
		
		else begin
			instruction_addr_upd = 0;
			ALU_read_data2_in = IDEX_read_data2_out;
		end
	end

	//	TODO: all read_valid and write_valid
	instruction_memory instruction_memory_module (.instruction_addr, .instruction_read);

	IF_ID IFID_module (.clk, .flag, .pc_replace, .instruction_read, .instruction_addr,
	.IFID_instruction_read(IFID_instruction_read_out), .IFID_instruction_addr(IFID_instruction_addr_out));
	
	control control_module (.clk, .instruction_read(IFID_instruction_read_out),
	.imm(control_imm_out), .register_write_valid(control_register_write_valid_out),
	.data_write_byte(control_data_write_byte_out));
	
	register_file register_file_module (.clk, .reset, .read_reg1, .read_reg2,
	.register_write_valid(MEMWB_register_write_valid_out), .write_reg(write_reg_final),
	.reg_write_data, .read_data1, .read_data2);
	
	ID_EX IDEX_module (.clk, .flag, .pc_replace, .bit_th_in(IFID_instruction_read_out[30]),
	.read_reg1_in(read_reg1), .read_reg2_in(read_reg2), .write_reg_in(write_reg),
	.funct3_in(IFID_instruction_read_out[14:12]), .opcode_in(IFID_instruction_read_out[6:0]),
	.imm_in(control_imm_out), .read_data1_in(read_data1), .read_data2_in(read_data2),
	.register_write_valid_in(control_register_write_valid_out),
	.data_write_byte_in(control_data_write_byte_out),
	.instruction_addr_in(IFID_instruction_addr_out), .bit_th_out(IDEX_bit_th_out),
	.IDEX_read_reg1_out, .IDEX_read_reg2_out,	.IDEX_write_reg_out, .IDEX_funct3_out,
	.IDEX_opcode_out, .IDEX_imm_out, .IDEX_register_write_valid_out,
	.IDEX_read_data1_out, .IDEX_read_data2_out,
	.IDEX_data_write_byte_out, .IDEX_instruction_addr_out, .IDEX_flag_out);	

	EX_MEM EXMEM_module (.clk, .act, .pc_replace, .flag, .IDEX_opcode_out,
	.ALU_data_write_byte_out, .IDEX_funct3_out, .ALU_data_addr_out, 
	.IDEX_register_write_valid_out, .IDEX_write_reg_out, .ALU_reg_write_data_out,
	.ALU_data_write_out, .EXMEM_opcode_out, .EXMEM_funct3_out, .EXMEM_data_addr_out,
	.EXMEM_data_write_byte_out, .EXMEM_register_write_valid_out, .EXMEM_write_reg_out,
	.EXMEM_reg_write_data_out, .EXMEM_data_write_out, .EXMEM_pc_replace_out,
	.EXMEM_flag_out);
	
	ALU ALU_module (.clk, .bit_th(IDEX_bit_th_out), .funct3(IDEX_funct3_out),
	.opcode(IDEX_opcode_out), .read_data1(ALU_read_data1_in),
	.read_data2(ALU_read_data2_in), .imm(IDEX_imm_out),
	.data_write_byte(IDEX_data_write_byte_out), .instruction_addr(IDEX_instruction_addr_out),
	.pc_replace_old(EXMEM_pc_replace_out), .flag_old(EXMEM_flag_out),
	.reg_write_data(ALU_reg_write_data_out), .data_write(ALU_data_write_out),
	.data_addr(ALU_data_addr_out), .data_write_byte_out(ALU_data_write_byte_out),
	.pc_new, .pc_replace, .pc_JALR);		
	
	memory memory_module (.clk, .reset, .data_write_byte(EXMEM_data_write_byte_out),
	.data_addr(EXMEM_data_addr_out), .data_read, .data_write(EXMEM_data_write_out));
	
	MEM_WB mw1(.clk, .EXMEM_opcode_out, .EXMEM_funct3_out, .EXMEM_data_addr_out,
	.EXMEM_register_write_valid_out, .EXMEM_write_reg_out, .EXMEM_reg_write_data_out,
	.data_read, .MEMWB_opcode_out, .MEMWB_funct3_out, .MEMWB_data_addr_out,
	.MEMWB_register_write_valid_out, .MEMWB_write_reg_out, .MEMWB_reg_write_data_out,
	.MEMWB_data_read);
	
	load_data load_data_module (.clk, .MEMWB_opcode_out, .MEMWB_funct3_out,
	.MEMWB_data_addr_out, .MEMWB_data_read, .MEMWB_reg_write_data_out, .reg_write_data);
	
	WB wb1(.clk, .MEMWB_write_reg_out, .reg_write_data, .MEMWB_register_write_valid_out,
	.WB_write_reg_out, .WB_reg_write_data_out, .WB_register_write_valid_out);
endmodule

// module riscv32_testbench();
//  	logic clk, reset;

//  	riscv32 dut (.clk, .reset);

//  	parameter CLOCK_PERIOD=100;
//  	initial begin
//  		clk <= 0;
//  		forever #(CLOCK_PERIOD/2) clk <= ~clk;
//  	end
	
//  	initial begin
// 		reset = 1; #5000
//  		reset = 0; #5000
//  		$stop;
//  	end
// endmodule
