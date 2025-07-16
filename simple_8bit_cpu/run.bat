@echo off
iverilog -Wall -o cpu_out cpu.v program_counter.v instruction_memory.v instruction_decoder.v register_file.v alu.v cpu_testbench.v
vvp cpu_out
pause
