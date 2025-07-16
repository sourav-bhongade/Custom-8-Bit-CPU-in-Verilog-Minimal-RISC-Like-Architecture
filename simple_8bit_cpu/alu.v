`timescale 1ns/1ps

module alu (
input [2:0] opcode,
input [7:0] operand1,
input [7:0] operand2,
output reg [7:0] result,
output reg zero_flag
);
always @(*) begin
case (opcode)
3'b000: result = operand1 + operand2; // ADD
3'b001: result = operand1 * operand2; // MUL
3'b010: result = operand1 & operand2; // AND
3'b011: result = operand1 | operand2; // OR
3'b100: result = operand1 ^ operand2; // XOR
3'b101: result = operand2; // MOV / JMP (forwarded)
3'b110: result = operand1 - operand2; // CMP (used internally for flags)
3'b111: result = ~operand1; // NOT
default: result = 8'b00000000;
endcase
// Zero flag set if result == 0
zero_flag = (result == 0) ? 1'b1 : 1'b0;
end
endmodule
