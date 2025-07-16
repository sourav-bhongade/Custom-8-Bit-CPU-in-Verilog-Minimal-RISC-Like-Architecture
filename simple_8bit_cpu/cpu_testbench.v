`timescale 1ns/1ps

module cpu_testbench();

    reg clk = 0;
    reg reset = 1;

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    // Instantiate the CPU
    simple_cpu cpu (
        .clk(clk),
        .reset(reset)
    );

    // Create a wire to access internal pc_out from program_counter
    wire [3:0] pc;

    // Connect testbench wire to internal pc_out
    assign pc = cpu.PC.pc_out;

    initial begin
        // Generate VCD file for GTKWave
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_testbench);

        // Initial reset pulse
        #10 reset = 0;

        // Let CPU run
        #200;

        // Display final state
        $display("Final PC = %h", pc);
        $display("R1 = %h", cpu.REGFILE.registers[1]);
        $display("R2 = %h", cpu.REGFILE.registers[2]);
        $display("R3 = %h", cpu.REGFILE.registers[3]);

        $finish;
    end

endmodule
