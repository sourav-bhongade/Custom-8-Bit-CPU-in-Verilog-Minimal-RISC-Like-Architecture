`timescale 1ns/1ps

module simple_test();
    reg clk = 0;
    reg reset = 1;
    wire [3:0] pc;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Instantiate the CPU
    simple_cpu cpu (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );
    
    initial begin
        $display("=== SIMPLE CPU TEST ===");
        
        // Generate VCD file
        $dumpfile("simple_test.vcd");
        $dumpvars(0, simple_test);
        
        // Reset sequence
        #10 reset = 0;
        $display("Reset released at time %0t", $time);
        
        // Wait for a few instructions
        #100;
        
        $display("=== REGISTER STATE ===");
        $display("R0 = %h", cpu.REGFILE.registers[0]);
        $display("R1 = %h", cpu.REGFILE.registers[1]);
        $display("R2 = %h", cpu.REGFILE.registers[2]);
        $display("R3 = %h", cpu.REGFILE.registers[3]);
        $display("PC = %d", pc);
        
        #100;
        $finish;
    end
    
endmodule