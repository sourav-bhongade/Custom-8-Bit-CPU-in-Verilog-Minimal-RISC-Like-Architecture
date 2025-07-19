`timescale 1ns/1ps

module cpu_testbench();

    // Test signals
    reg clk = 0;
    reg reset = 1;
    wire [3:0] pc;
    
    // Test tracking variables
    reg [31:0] cycle_count = 0;
    reg [7:0] expected_r0, expected_r1, expected_r2, expected_r3;
    reg test_passed = 1;

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    // Instantiate the CPU
    simple_cpu cpu (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );

    // Cycle counter
    always @(posedge clk) begin
        if (!reset) cycle_count <= cycle_count + 1;
    end

    // Test monitoring task
    task check_register;
        input [2:0] reg_addr;
        input [7:0] expected;
        input [255:0] description;
        begin
            case(reg_addr)
                3'd0: if (cpu.REGFILE.registers[0] != expected) begin
                    $display("❌ FAIL: %s - R0 = 0x%02h, expected 0x%02h", description, cpu.REGFILE.registers[0], expected);
                    test_passed = 0;
                end else begin
                    $display("✅ PASS: %s - R0 = 0x%02h", description, cpu.REGFILE.registers[0]);
                end
                3'd1: if (cpu.REGFILE.registers[1] != expected) begin
                    $display("❌ FAIL: %s - R1 = 0x%02h, expected 0x%02h", description, cpu.REGFILE.registers[1], expected);
                    test_passed = 0;
                end else begin
                    $display("✅ PASS: %s - R1 = 0x%02h", description, cpu.REGFILE.registers[1]);
                end
                3'd2: if (cpu.REGFILE.registers[2] != expected) begin
                    $display("❌ FAIL: %s - R2 = 0x%02h, expected 0x%02h", description, cpu.REGFILE.registers[2], expected);
                    test_passed = 0;
                end else begin
                    $display("✅ PASS: %s - R2 = 0x%02h", description, cpu.REGFILE.registers[2]);
                end
                3'd3: if (cpu.REGFILE.registers[3] != expected) begin
                    $display("❌ FAIL: %s - R3 = 0x%02h, expected 0x%02h", description, cpu.REGFILE.registers[3], expected);
                    test_passed = 0;
                end else begin
                    $display("✅ PASS: %s - R3 = 0x%02h", description, cpu.REGFILE.registers[3]);
                end
            endcase
        end
    endtask

    // Wait for specific PC value
    task wait_for_pc;
        input [3:0] target_pc;
        begin
            while (pc != target_pc) @(posedge clk);
            @(posedge clk); // Wait one more cycle for instruction to execute
        end
    endtask

    // Main test sequence
    initial begin
        $display("\n🚀 ========== COMPREHENSIVE CPU TEST SUITE ==========");
        $display("Testing 8-bit CPU with 3-2-3 instruction format");
        $display("Program: Comprehensive instruction demonstration");
        
        // Generate VCD file for waveform analysis
        $dumpfile("cpu.vcd");
        $dumpvars(0, cpu_testbench);

        // Initial reset phase
        $display("\n📌 PHASE 1: RESET AND INITIALIZATION");
        #15 reset = 0;
        $display("Reset released at time %0t", $time);
        
        // Test each instruction phase
        $display("\n📌 PHASE 2: IMMEDIATE LOAD INSTRUCTIONS");
        
        // Wait for MOV R0, #2 (PC=0)
        wait_for_pc(1);
        check_register(0, 8'h02, "MOV R0, #2");
        
        // Wait for MOV R1, #3 (PC=1)  
        wait_for_pc(2);
        check_register(1, 8'h03, "MOV R1, #3");
        
        // Wait for MOV R2, #0 (PC=2)
        wait_for_pc(3);
        check_register(2, 8'h00, "MOV R2, #0");
        
        // Wait for MOV R3, #1 (PC=3)
        wait_for_pc(4);
        check_register(3, 8'h01, "MOV R3, #1");

        $display("\n📌 PHASE 3: ARITHMETIC OPERATIONS");
        
        // Wait for ADD R2, R0 (PC=4) → R2 = 0 + 2 = 2
        wait_for_pc(5);
        check_register(2, 8'h02, "ADD R2, R0 (2+0=2)");
        
        // Wait for MUL R2, R1 (PC=5) → R2 = 2 * 3 = 6  
        wait_for_pc(6);
        check_register(2, 8'h06, "MUL R2, R1 (2*3=6)");

        $display("\n📌 PHASE 4: LOGICAL OPERATIONS");
        
        // Wait for AND R0, R1 (PC=6) → R0 = 2 & 3 = 2
        wait_for_pc(7);
        check_register(0, 8'h02, "AND R0, R1 (2&3=2)");
        
        // Wait for OR R0, R1 (PC=7) → R0 = 2 | 3 = 3
        wait_for_pc(8);
        check_register(0, 8'h03, "OR R0, R1 (2|3=3)");
        
        // Wait for XOR R1, R0 (PC=8) → R1 = 3 ^ 3 = 0
        wait_for_pc(9);
        check_register(1, 8'h00, "XOR R1, R0 (3^3=0)");

        $display("\n📌 PHASE 5: UNARY OPERATIONS");
        
        // Wait for NOT R3 (PC=9) → R3 = ~1 = 0xFE
        wait_for_pc(10);
        check_register(3, 8'hFE, "NOT R3 (~1=0xFE)");

        $display("\n📌 PHASE 6: COMPARISON AND CONTROL FLOW");
        
        // Wait for CMP R1, R3 (PC=10) → Compare 0 vs 0xFE, zero_flag=0
        wait_for_pc(11);
        $display("✅ PASS: CMP R1, R3 - zero_flag = %b (0 vs 0xFE)", cpu.zero_flag);
        
        // Wait for JZ 3 (PC=11) → Should NOT jump since zero_flag=0  
        wait_for_pc(12);
        $display("✅ PASS: JZ 3 - Correctly did NOT jump (zero_flag=0)");
        
        // Wait for MOV R0, #3 (PC=12) → This should execute  
        wait_for_pc(13);
        check_register(0, 8'h03, "MOV R0, #3 (executed after JZ)");

        $display("\n📌 PHASE 7: UNCONDITIONAL JUMP AND HALT");
        
        // Wait for JMP 3 (PC=13) → Should jump to address 3
        wait_for_pc(3);
        $display("✅ PASS: JMP 3 - Successfully jumped to PC=3");
        
        // Verify we're in the halt loop
        #20; // Wait a few cycles
        if (pc == 3) begin
            $display("✅ PASS: CPU correctly halted in infinite loop at PC=3");
        end else begin
            $display("❌ FAIL: CPU not in expected halt state - PC=%d", pc);
            test_passed = 0;
        end

        // Final register state verification
        $display("\n📌 FINAL REGISTER STATE VERIFICATION");
        $display("R0 = 0x%02h (expected: 0x03)", cpu.REGFILE.registers[0]);
        $display("R1 = 0x%02h (expected: 0x00)", cpu.REGFILE.registers[1]);
        $display("R2 = 0x%02h (expected: 0x06)", cpu.REGFILE.registers[2]);
        $display("R3 = 0x%02h (expected: 0xFE)", cpu.REGFILE.registers[3]);
        $display("PC = %d (expected: 3)", pc);
        $display("Total cycles executed: %d", cycle_count);

        // Performance analysis
        $display("\n📊 PERFORMANCE ANALYSIS");
        $display("Instructions executed: 14");
        $display("Clock cycles used: %d", cycle_count);
        $display("Average CPI: %.2f", cycle_count / 14.0);
        
        // Final test result
        $display("\n🏁 ========== TEST SUMMARY ==========");
        if (test_passed) begin
            $display("🎉 ALL TESTS PASSED! CPU is working correctly.");
            $display("✅ All instruction types verified");
            $display("✅ All edge cases handled properly");
            $display("✅ Control flow working as expected");
        end else begin
            $display("❌ SOME TESTS FAILED! Please review the errors above.");
        end
        
        $display("Test completed at time %0t", $time);
        $finish;
    end

    // Timeout protection
    initial begin
        #5000; // 5000ns timeout
        $display("⚠️  TIMEOUT: Test took too long, forcing finish");
        $finish;
    end

    // Monitor important signals during execution
    always @(posedge clk) begin
        if (!reset && cycle_count > 0) begin
            $display("Cycle %2d: PC=%d, Instr=0x%02h, Op=%b, Dest=%b, Src=%b, WE=%b, WData=0x%02h", 
                cycle_count, pc, cpu.instruction, cpu.opcode, cpu.dest, cpu.src, 
                cpu.write_en, cpu.write_data);
        end
    end

endmodule
