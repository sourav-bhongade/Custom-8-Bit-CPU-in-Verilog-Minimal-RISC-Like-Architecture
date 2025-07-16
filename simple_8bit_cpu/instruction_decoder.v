`timescale 1ns/1ps

module instruction_decoder (
    input [7:0] instruction,
    output [2:0] opcode,
    output [2:0] reg1,
    output [2:0] reg2_or_imm
);

assign opcode        = instruction[7:5];
assign reg1          = {1'b0, instruction[4:3]};     // Destination (pad to 3 bits)
assign reg2_or_imm   = instruction[2:0];     // Source register or immediate (3 bits)

endmodule
