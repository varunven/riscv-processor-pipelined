# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./riscv32.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work riscv32_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do riscv32_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
# riscv32
# control
# ALU
# IF_ID
# ID_EX
# EX_MEM
# MEM_WB
# WB
# instruction_memory
# register_file
# memory
# load_data