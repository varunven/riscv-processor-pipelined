module register_file(
    input logic clk, reset,
    input logic [4:0] read_reg1, // rs1
    input logic [4:0] read_reg2, // rs2
	 input logic register_write_valid,
	 input logic [4:0] write_reg, //rd (destination reg)
    input logic [31:0] reg_write_data,
	 output logic [31:0] read_data1,
    output logic [31:0] read_data2
);
//make under control of if alu is complete or not?
	reg [31:0] reg_memory [0:31]; // 32 memory locations each 32 bits wide
	
	integer i;
	initial begin
		reg_memory[31] = 0;
		for(i=0; i<31; i = i+1)
			reg_memory[i]=i;
	end

	always @(posedge clk) begin
	  if (register_write_valid) begin
			reg_memory[write_reg] = reg_write_data;
	  end
	end
	
	assign read_data1 = reg_memory[read_reg1];
	assign read_data2 = reg_memory[read_reg2];
endmodule

module register_file_testbench ();
	logic clk;
	logic reset;
	logic [4:0] read_reg1;
	logic [4:0] read_reg2;
	logic register_write_valid;
	logic [4:0] write_reg;
	logic [31:0] reg_write_data;
	logic [31:0] read_data1;
	logic [31:0] read_data2;
	 
 	// Instantiating modules
	register_file dut(
     .clk, .reset, .read_reg1, .read_reg2, .register_write_valid, .write_reg, .reg_write_data,
 	 .read_data1, .read_data2);

 	// Test conditions
 	parameter CLOCK_PERIOD=10;
 	initial begin
 		clk <= 0;
 		forever #(CLOCK_PERIOD/2) clk <= ~clk;
 	end
	
 	initial
 	begin
 		reset = 1; #20
		
 		reset = 0;
 		read_reg1 = 4;
 		read_reg2 = 8;
 		register_write_valid = 0; #50
		
 		register_write_valid = 1;
 		write_reg = 0;
 		reg_write_data = 32'h10; #50
		
 		register_write_valid = 1;
 		write_reg = 10;
 		reg_write_data = 32'h20; #50
		
 		register_write_valid = 1;
 		write_reg = 11;
 		reg_write_data = 32'h21; #50
		
 		read_reg1 = 11;
 		read_reg2 = 10;
 		register_write_valid = 0; #50
		
 		reset = 1; #50
		
 		reset = 0;
 		register_write_valid = 1;
 		write_reg = 20;
 		reg_write_data = 32'h15; #50
 		$stop;
 	end
endmodule