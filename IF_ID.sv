module IF_ID(
    input logic clk, flag, pc_replace,
    input logic [31:0] instruction_read, instruction_addr, 
    output logic [31:0] IFID_instruction_read, IFID_instruction_addr
);
	always@(posedge clk)
	begin
		if(flag==1) begin
			//If pc_replace=1 due to branch, then replace idata_out with ADDI R0,R0,0 --> 0
			IFID_instruction_read = pc_replace?(32'b00000000000000000000000000010011):(instruction_read);
			IFID_instruction_addr = instruction_addr;
		end
	end
endmodule

module IF_ID_testbench();
	logic clk, flag, pc_replace;
	logic [31:0] instruction_read, instruction_addr, IFID_instruction_read, IFID_instruction_addr;

	IF_ID dut (.clk, .flag, .pc_replace, .instruction_read, .instruction_addr, .IFID_instruction_read, .IFID_instruction_addr);

	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		flag = 0;
		pc_replace = 0;
		instruction_read = 32'b00000000000000000000000000001111;
		instruction_addr = 32'b00000000000000000000000001110001; #500
		pc_replace = 1;
		instruction_read = 32'b00000000000000000000000000000011;
		instruction_addr = 32'b00000000000000000000000001000001; #500
		
		flag = 1;
		pc_replace = 0;
		instruction_read = 32'b00000000000000000000000000001111;
		instruction_addr = 32'b00000000000000000000000001110001; #500
		pc_replace = 1;
		instruction_read = 32'b00000000000000000000000000000011;
		instruction_addr = 32'b00000000000000000000000001000001; #500
		$stop;
	end
endmodule