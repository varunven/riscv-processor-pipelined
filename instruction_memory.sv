module instruction_memory(
	input logic [31:0] instruction_addr,
	output logic [31:0] instruction_read
);

	// keeps track of instruction memory
	logic [31:0] memory [31:0];
	initial begin 
		$readmemh("imem_ini.mem", memory);
	end
	assign instruction_read = memory[instruction_addr[31:2]];
endmodule

// module instruction_memory_testbench ();
// 	logic [31:0] instruction_addr, instruction_read;
	
//  	instruction_memory dut (.instruction_addr, .instruction_read);

//  	initial begin
//  		#120
//  		instruction_addr = 0; #80
//  		instruction_addr = 1; #80
//  		instruction_addr = 2; #80
//  		instruction_addr = 3; #80
		
//  		instruction_addr = 4; #80
//  		instruction_addr = 5; #80
//  		instruction_addr = 6; #80
//  		instruction_addr = 7; #80
		
//  		instruction_addr = 8; #80
//  		instruction_addr = 9; #80
//  		instruction_addr = 10; #80
//  		instruction_addr = 11; #80
		
//  		instruction_addr = 12; #80
//  		instruction_addr = 13; #80
//  		instruction_addr = 14; #80
//  		instruction_addr = 15; #80
		
//  		instruction_addr = 16; #80
//  		instruction_addr = 17; #80
//  		instruction_addr = 18; #80
//  		instruction_addr = 19; #80
		
//  		instruction_addr = 20; #80
//  		instruction_addr = 21; #80
//  		instruction_addr = 22; #80
//  		instruction_addr = 23; #80
		
//  		instruction_addr = 24; #80
//  		instruction_addr = 25; #80
//  		instruction_addr = 26; #80
//  		instruction_addr = 27; #80
		
//  		instruction_addr = 28; #80
//  		instruction_addr = 29; #80
//  		instruction_addr = 30; #80
//  		instruction_addr = 31; #80
//  		$stop;
//  	end
// endmodule