`timescale 1ns/1ps

module instruction_memory (
    input [3:0] addr,
    output [7:0] data
);
    reg [7:0] memory [0:15];
    assign data = memory[addr];

    initial begin
        memory[ 0] = 8'hA6; // MOV R0, #2
        memory[ 1] = 8'hAF; // MOV R1, #3
        memory[ 2] = 8'hB4; // MOV R2, #0
        memory[ 3] = 8'hBD; // MOV R3, #1
        memory[ 4] = 8'h10; // ADD R2, R0
        memory[ 5] = 8'h31; // MUL R2, R1
        memory[ 6] = 8'h41; // AND R0, R1
        memory[ 7] = 8'h61; // OR R0, R1
        memory[ 8] = 8'h88; // XOR R1, R0
        memory[ 9] = 8'hF8; // NOT R3
        memory[10] = 8'hCB; // CMP R1, R3
        memory[11] = 8'h9B; // JZ 3
        memory[12] = 8'hA7; // MOV R0, #3
        memory[13] = 8'h7B; // JMP 3
        memory[14] = 8'h00; // NOP
        memory[15] = 8'h00; // NOP
    end
endmodule
