module control	(
	input logic clk,
	input logic [31:0] instruction_read,
	output logic signed [31:0] imm,
	output logic register_write_valid,
	output logic [3:0] data_write_byte
);

	always @(*) begin
		imm = 0;
		if (instruction_read[6:0] == 7'b0110011) begin // R-type instructions							
				data_write_byte = 0;
				register_write_valid = 1;
		end
		
		else if (instruction_read[6:0] == 7'b0010011) begin // I-type instructions
			data_write_byte = 0;
			register_write_valid = 1;
		end
		
		else if (instruction_read[6:0] == 7'b0000011) begin // LOAD
			imm = {{20{instruction_read[31]}},instruction_read[31:20]};
			data_write_byte = 0;
			register_write_valid = 1;
		end
		
		else if (instruction_read[6:0] == 7'b0100011) begin // STORE
			imm = {{20{instruction_read[31]}},instruction_read[31:25],instruction_read[11:7]};
			register_write_valid = 0;
			
			case(instruction_read[14:12])
				3'b000: begin
				data_write_byte = 4'b0001; // SB
				end
				3'b001: begin
				data_write_byte = 4'b0011; // SH
				end
				3'b010: begin
				data_write_byte = 4'b1111; // SW
			 end
			endcase			
		end
		
		else if (instruction_read[6:0] == 7'b1100011) begin // BRANCH
			//imm = {{20{instruction_read[31]}},instruction_read[31],instruction_read[7],instruction_read[30:25],instruction_read[11:8]};
			imm = (instruction_read[14:12] == 3'b110 | instruction_read[14:12] == 3'b111)? {{20{1'b0}}, instruction_read[31], instruction_read[7], instruction_read[30:25], instruction_read[11:8],1'b0}: {{20{instruction_read[31]}}, instruction_read[31], instruction_read[7], instruction_read[30:25], instruction_read[11:8],1'b0};
			data_write_byte = 0;
			register_write_valid = 0;
		end
		
		else if (instruction_read[6:0] == 7'b1100111) begin // JALR
			imm = {{20{instruction_read[31]}},instruction_read[31:20]};
			data_write_byte = 0;
			register_write_valid = 1;			
		end
		
		else if (instruction_read[6:0] == 7'b1101111) begin // JAL
			imm = {{11{instruction_read[31]}},instruction_read[31],instruction_read[19:12],instruction_read[20],instruction_read[30:21],1'b0};	
			data_write_byte = 0;
			register_write_valid = 1;			
		end
		else if (instruction_read[6:0] == 7'b0010111) begin // AUPIC
			imm = {instruction_read[31:12],12'b0};
			data_write_byte = 0;			
			register_write_valid = 1;	
		end
		else if (instruction_read[6:0] == 7'b0110111) begin // LUI
			imm = {instruction_read[31:12],12'b0};	
			data_write_byte = 0;			
			register_write_valid = 1;			
		end
	end
endmodule

module control_testbench ();
	logic clk;
	logic [31:0] instruction_read;
	logic signed [31:0] imm;
	logic register_write_valid;
	logic [3:0] data_write_byte;

	// Instantiating modules
	control dut (.clk, .instruction_read, .imm, .register_write_valid, .data_write_byte);

	parameter CLOCK_PERIOD=100;
 	initial begin
 		clk <= 0;
 		forever #(CLOCK_PERIOD/2) clk <= ~clk;
 	end
	
	initial begin	
		// R type
		instruction_read = 32'h00940333; #50
		instruction_read = 32'h413903b3; #50
		instruction_read = 32'h015a12b3; #50
		instruction_read = 32'h017b2e33; #50
		instruction_read = 32'h019c4eb3; #50
		instruction_read = 32'h013a53b3; #50
		instruction_read = 32'h4154de33; #50
		instruction_read = 32'h00d5e7b3; #50
		instruction_read = 32'h00d77533; #50
		
		// I type
		instruction_read = 32'h00040313; #50
		instruction_read = 32'h00091393; #50
		instruction_read = 32'h000a2293; #50
		instruction_read = 32'h000b3e13; #50
		instruction_read = 32'h000b4e13; #50
		instruction_read = 32'h000c5e93; #50
		instruction_read = 32'h400a5393; #50
		instruction_read = 32'h0005e793; #50
		instruction_read = 32'h00077513; #50
		
		// L type
		instruction_read = 32'h005e8e03; #50
		instruction_read = 32'h005e9e03; #50
		instruction_read = 32'h005eae03; #50
		instruction_read = 32'h005ece03; #50
		instruction_read = 32'h005ede03; #50
		
		// S type
		instruction_read = 32'h00c702a3; #50
		instruction_read = 32'h00c712a3; #50
		instruction_read = 32'h00c722a3; #50
		
		// B type
		instruction_read = 32'h06f9d263; #50
		instruction_read = 32'h06d94263; #50
		
		// JALR
		instruction_read = 32'h014589e7; #50
		instruction_read = 32'h03c906e7; #50
		
		// JAL
		instruction_read = 32'h00c00a6f; #50
		instruction_read = 32'h0820066f; #50

		// AUPIC
		instruction_read = 32'h00000997; #50
		instruction_read = 32'h00000697; #50

		// LUI
		instruction_read = 32'h000004b7; #50
		instruction_read = 32'h000007b7; #50
		$stop;
	end
endmodule