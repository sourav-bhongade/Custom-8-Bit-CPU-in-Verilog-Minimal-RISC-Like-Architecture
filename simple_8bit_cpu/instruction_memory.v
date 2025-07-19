`timescale 1ns/1ps

module instruction_memory (
    input [3:0] addr,
    output [7:0] data
);
    reg [7:0] memory [0:15];
    assign data = memory[addr];

    initial begin
        memory[ 0] = 8'hA6;
        memory[ 1] = 8'hAF;
        memory[ 2] = 8'hB4;
        memory[ 3] = 8'hBD;
        memory[ 4] = 8'hF8;
        memory[ 5] = 8'hCB;
        memory[ 6] = 8'hA7;
        memory[ 7] = 8'h78;
        memory[ 8] = 8'h00;
        memory[ 9] = 8'h00;
        memory[10] = 8'h00;
        memory[11] = 8'h00;
        memory[12] = 8'h00;
        memory[13] = 8'h00;
        memory[14] = 8'h00;
        memory[15] = 8'h00;
    end
endmodule
