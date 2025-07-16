`timescale 1ns/1ps

module instruction_memory (
    input [3:0] addr,
    output [7:0] data
);
    reg [7:0] memory [0:15];
    assign data = memory[addr];

    initial begin
memory[0] = 8'hAD;  // MOV R1, #5 → 101 01 101
memory[1] = 8'hB7;  // MOV R2, #3 → 101 10 111 ← ✅ CHANGED
memory[2] = 8'h1A;  // ADD R3, R1, R2 → 000 11 010



    end
endmodule
