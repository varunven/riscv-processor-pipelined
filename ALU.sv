/*
Uses ALU control to perform operation on two operands and provide output
*/

module ALU (
	input logic clk, bit_th,
	input logic [2:0] funct3,
   	input logic [6:0] opcode,
	input logic [31:0] read_data1, read_data2, imm, 
	input logic [3:0] data_write_byte,
	input logic [31:0] instruction_addr,
	input logic pc_replace_old,
	input logic flag_old,
	output logic [31:0] reg_write_data, data_write, data_addr,
	output logic [3:0] data_write_byte_out,
	output logic [31:0] pc_new,
	output logic pc_replace, pc_JALR
);
	logic [31:0] temp1, temp2, offset;
	
	logic jump_flag;
	
	always @(*) begin
		pc_new=0;
		pc_replace=0;
		pc_JALR=0;
		// R type
		if(opcode == 7'b0110011) begin
			temp1 = read_data1;
			temp2 = read_data2;
			
			case({bit_th,funct3})
				4'b0000:    reg_write_data = read_data1+read_data2;          //add
				4'b1000:    reg_write_data = read_data1-read_data2;          //sub
				4'b0001:    reg_write_data = read_data1<<read_data2[4:0];	  //sll
				4'b0010:    reg_write_data = {32{read_data1<read_data2}};          //slt
				4'b0011:    reg_write_data = {32{temp1<temp2}};        //sltu
				4'b0100:    reg_write_data = read_data1^read_data2;          //xor
				4'b0101:    reg_write_data = read_data1>>read_data2[4:0];    //srl
				4'b1101:    reg_write_data = read_data1>>>read_data2[4:0];   //sra
				4'b0110:    reg_write_data = read_data1|read_data2;          //or
				4'b0111:    reg_write_data = read_data1&read_data2;          //and
				default: begin end
			endcase
		end
		
		// I type
		else if(opcode == 7'b0010011) begin
			temp1 = read_data1;
			temp2 = imm;
			case(funct3)
				3'b000: reg_write_data = read_data1+imm;          //addi
				3'b010: reg_write_data = {32{read_data1<imm}};          //slti
				3'b011: reg_write_data = {32{temp1<temp2}};         //sltiu
				3'b100: reg_write_data = read_data1 ^ imm;        //xori
				3'b110: reg_write_data = read_data1 | imm;        //ori
				3'b111: reg_write_data = read_data1 & imm;        //andi
				3'b001: reg_write_data = read_data1<<imm[4:0];    //slli
				3'b101:
				begin
					if(bit_th)           //srli
						reg_write_data = read_data1>>imm[4:0]; 
					else                    //srai
						reg_write_data = read_data1>>>imm[4:0];
				end
				default: begin end
			endcase
		
			reg_write_data = reg_write_data[31:0];
		end
		
		// LOAD
		else if(opcode == 7'b0000011) begin
			data_addr = read_data1 + imm;
			data_write_byte_out = data_write_byte;
		end
		
		// STORE
		else if(opcode == 7'b0100011) begin
			data_addr = read_data1 + imm;
			case(funct3)
				 3'b000: begin
					data_write = {read_data2[7:0],read_data2[7:0],read_data2[7:0],read_data2[7:0]};
				 end
				 3'b001: begin
					data_write = {read_data2[15:0], read_data2[15:0]};
				 end
				 3'b010: begin
					data_write = read_data2;
				 end
				default: begin end
			endcase
			data_write_byte_out = data_write_byte<<data_addr[1:0];
		end
		
		// BRANCH
		else if(opcode == 7'b1100011) begin
			temp1 = read_data1;
			temp2 = read_data2;
			case(funct3)
				3'b000: begin
					pc_new = (read_data1==read_data2)? (imm-12) : (0);
					jump_flag = (read_data1==read_data2)?1'b1:1'b0;
				end
				3'b001: begin
					pc_new = (read_data1!=read_data2)? (imm-12) : (0);
					jump_flag = (read_data1!=read_data2)?1'b1:1'b0;
				end
				3'b100: begin
					pc_new = (read_data1<read_data2)? (imm-12) : (0);
					jump_flag = (read_data1<read_data2)?1'b1:1'b0;
				end
				3'b101: begin
					pc_new = (read_data1>=read_data2)? (imm-12) : (0);
					jump_flag = (read_data1>=read_data2)?1'b1:1'b0;
				end
				3'b110: begin
					pc_new = (temp1<temp2)? (imm-12) : (0);
					jump_flag = (temp1<temp2)?1'b1:1'b0;
				end
				3'b111: begin
					pc_new = (temp1>=temp2)? (imm-12) : (0);
					jump_flag = (temp1>=temp2)?1'b1:1'b0;
				end
				default: begin end
			endcase
			pc_replace=(pc_replace_old|!flag_old)?1'b0:jump_flag;
			
			data_write_byte_out = data_write_byte;
		end
		
		// JALR
		else if(opcode == 7'b1100111) begin
			reg_write_data = instruction_addr+4;
			pc_new = (read_data1+imm)&32'hfffffffe;
			pc_replace=(pc_replace_old|!flag_old)?1'b0:1'b1;
			pc_JALR=1;
			
			data_write_byte_out = data_write_byte;
		end
		
		// JAL
		else if(opcode == 7'b1101111) begin
			reg_write_data = instruction_addr+4;
			data_write_byte_out = data_write_byte;
			pc_new = imm-12;
			pc_replace=(pc_replace_old|!flag_old)?1'b0:1'b1;
		end
		
		// AUIPIC
		else if(opcode == 7'b0010111) begin
			reg_write_data = instruction_addr+imm;
			data_write_byte_out = data_write_byte;
		end
		
		// LUI
		else if(opcode == 7'b0110111) begin
			reg_write_data = imm;
			data_write_byte_out = data_write_byte;
		end
	end
endmodule

// module ALU_testbench ();
 
// 	logic clk, bit_th;
// 	logic [2:0] funct3;
// 	logic [6:0] opcode;
// 	logic [31:0] read_data1, read_data2, imm;
// 	logic [3:0] data_write_byte;
// 	logic [31:0] instruction_addr;x
// 	logic pc_replace_old;
// 	logic flag_old;
// 	logic [31:0] reg_write_data, data_write, data_addr;
// 	logic [3:0] data_write_byte_out;
// 	logic [31:0] pc_new;
// 	logic pc_replace, pc_JALR;

//  	// Instantiating modules
// 	ALU ALU_module (.clk, .bit_th, .funct3, .opcode, .read_data1, .read_data2, .imm,
// 	.data_write_byte, .instruction_addr, .pc_replace_old, .flag_old,.reg_write_data,
// 	.data_write, .data_addr, .data_write_byte_out, .pc_new, .pc_replace, .pc_JALR);	
 	
// 	parameter CLOCK_PERIOD=100;
//  	initial begin
//  		clk <= 0;
//  		forever #(CLOCK_PERIOD/2) clk <= ~clk;
//  	end
	
// 	initial begin		
// 		// R type
// 		read_data1 = 5'b01000;
// 		read_data2 = 5'b01001;
// 		imm = 0;
// 		data_write_byte = 0;
// 		instruction_addr = 11;
// 		pc_replace_old = 0;
// 		flag_old = 0;
		
// 		bit_th = 0;
// 		opcode = 7'b0110011;
// 		funct3 = 3'b000; #50
		
// 		bit_th = 1; #50
		
// 		funct3 = 3'b001; #50
		
// 		funct3 = 3'b010; #50
		
// 		funct3 = 3'b011; #50
		
// 		funct3 = 3'b100; #50
		
// 		funct3 = 3'b101; #50
		
// 		bit_th = 1; #50
		
// 		bit_th = 0;
// 		funct3 = 3'b110; #50
		
// 		funct3 = 3'b111; #50
		
// 		// I type
// 		imm = 9;
		
// 		bit_th = 0;
// 		opcode = 7'b0010011;
// 		funct3 = 3'b000; #50
		
// 		bit_th = 1; #50
		
// 		bit_th = 0;
// 		funct3 = 3'b001; #50
		
// 		funct3 = 3'b010; #50
		
// 		funct3 = 3'b011; #50
		
// 		funct3 = 3'b100; #50
		
// 		funct3 = 3'b110; #50
		
// 		funct3 = 3'b111; #50
		
// 		funct3 = 3'b101;
// 		bit_th = 1; #50
		
// 		bit_th = 0; #50
		
// 		// L type
// 		opcode = 7'b0000011; #50
		
// 		// S type
// 		imm = 5;
// 		opcode = 7'b0100011;
// 		funct3 = 3'b000; #50
		
// 		funct3 = 3'b001; #50
		
// 		funct3 = 3'b010; #50
		
// 		// B type
// 		imm = 100;
// 		opcode = 7'b1100011;
// 		funct3 = 3'b000; #50
		
// 		funct3 = 3'b001; #50
		
// 		funct3 = 3'b100; #50
		
// 		funct3 = 3'b101; #50
		
// 		funct3 = 3'b110; #50
		
// 		funct3 = 3'b111; #50
		
// 		// JALR
// 		imm = 20;
// 		opcode = 7'b1100111; #50
		
// 		// JAL
// 		opcode = 7'b1101111; #50

// 		// AUPIC
// 		opcode = 7'b0010111; #50

// 		// LUI
// 		opcode = 7'b0110111; #50
//  		$stop;
// 	end
// endmodule