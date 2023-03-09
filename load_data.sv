module load_data(
	input logic clk,
	input logic [6:0] MEMWB_opcode_out,
	input logic [2:0] MEMWB_funct3_out,
	input logic [31:0] MEMWB_data_addr_out, MEMWB_data_read, MEMWB_reg_write_data_out,
	output logic [31:0] reg_write_data
);

	reg [31:0] offset;

	always@(*)  //If this is a load instruction, then read has to be modified and written to reg file. Else, ALU output MW_regdata_out is used.
	begin
	  if(MEMWB_opcode_out!=7'b0000011)  //If not load instruction
			reg_write_data = MEMWB_reg_write_data_out;     
	  else begin
			offset = 32'(MEMWB_data_addr_out[1:0]<<3);  //offset = 8*rv1[1:0]-1 ,eg, 8*1=8, so drdata[15:8]
			case(MEMWB_funct3_out)
			3'b000: reg_write_data = {{24{MEMWB_data_read[offset+7]}}, MEMWB_data_read[offset +: 8]};    //LB
			3'b001: reg_write_data = {{16{MEMWB_data_read[offset+15]}}, MEMWB_data_read[offset +: 16]};  //LH
			3'b010: reg_write_data = MEMWB_data_read;                                   		//LW
			3'b100: reg_write_data = {24'b0, MEMWB_data_read[offset +: 8]};             		//LBU
			3'b101: reg_write_data = {16'b0, MEMWB_data_read[offset +: 16]};            		//LHU
			default: begin end
			endcase
	  end
	end
endmodule

// module load_data_testbench ();
// 	logic clk;
// 	logic [6:0] MEMWB_opcode_out;
// 	logic [2:0] MEMWB_funct3_out;
// 	logic [31:0] MEMWB_data_addr_out, MEMWB_data_read, MEMWB_reg_write_data_out;
// 	logic [31:0] reg_write_data;
 
//  	// Instantiating modules
// 	load_data dut(.clk, .MEMWB_opcode_out, .MEMWB_funct3_out, .MEMWB_data_addr_out,
// 	.MEMWB_data_read, .MEMWB_reg_write_data_out, .reg_write_data);
	
// 	parameter CLOCK_PERIOD=10;
//  	initial begin
//  		clk <= 0;
//  		forever #(CLOCK_PERIOD/2) clk <= ~clk;
//  	end
	
//  	initial begin
// 		MEMWB_opcode_out = 1;
// 		MEMWB_funct3_out = 11;
// 		MEMWB_data_addr_out = 32'b00000000111000000000000000000001;
// 		MEMWB_data_read = 32'b00000000000000000000000000000011;
// 		MEMWB_reg_write_data_out = 12; #50
		
// 		MEMWB_opcode_out = 7'b0000011;
// 		MEMWB_funct3_out = 3'b000; #50
// 		MEMWB_funct3_out = 3'b001; #50
// 		MEMWB_funct3_out = 3'b010; #50
// 		MEMWB_funct3_out = 3'b100; #50
// 		MEMWB_funct3_out = 3'b101; #50
//  		$stop;
//  	end
// endmodule