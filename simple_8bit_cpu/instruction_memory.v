`timescale 1ns/1ps

module instruction_memory (
    input [3:0] addr,
    output [7:0] data
);
    reg [7:0] memory [0:15];
    assign data = memory[addr];

    initial begin
        // Comprehensive instruction test program
        memory[0] = 8'hAD;  // MOV R1, #1 → 101 01 101 (Load immediate 1 into R1)
        memory[1] = 8'hB6;  // MOV R2, #2 → 101 10 110 (Load immediate 2 into R2)
        memory[2] = 8'hC7;  // MOV R3, #3 → 101 11 111 (Load immediate 3 into R3)
        memory[3] = 8'h0A;  // ADD R1, R2 → 000 01 010 (R1 = R1 + R2 = 1 + 2 = 3)
        memory[4] = 8'h32;  // MUL R2, R2 → 001 10 010 (R2 = R2 * R2 = 2 * 2 = 4)
        memory[5] = 8'h4B;  // AND R1, R3 → 010 01 011 (R1 = R1 & R3 = 3 & 3 = 3) 
        memory[6] = 8'h6B;  // OR R1, R3 → 011 01 011 (R1 = R1 | R3 = 3 | 3 = 3)
        memory[7] = 8'h7F;  // JMP 7 → 011 11 111 (Jump to address 7 - infinite loop HALT)
        memory[8] = 8'h8B;  // XOR R1, R3 → 100 01 011 (Should not execute)
        memory[9] = 8'hD2;  // CMP R2, R2 → 110 10 010 (Should not execute)
        memory[10] = 8'hF0; // COM R0 → 111 00 000 (Should not execute)
        memory[11] = 8'h00; // Should not execute
        memory[12] = 8'h00; // Should not execute
        memory[13] = 8'h00; // Should not execute
        memory[14] = 8'h00; // Should not execute
        memory[15] = 8'h00;
    end
endmodule
