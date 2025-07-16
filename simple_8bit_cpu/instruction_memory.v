`timescale 1ns/1ps

module instruction_memory (
    input [3:0] addr,
    output [7:0] data
);
    reg [7:0] memory [0:15];
    assign data = memory[addr];

    initial begin
memory[0] = 8'hAD;  // MOV R1, #1 → 101 01 101 (dest=R1, src=101, imm value=01)
memory[1] = 8'hB6;  // MOV R2, #2 → 101 10 110 (dest=R2, src=110, imm value=10)
memory[2] = 8'h1A;  // ADD R3, R1, R2 → 000 11 010

    end
endmodule
