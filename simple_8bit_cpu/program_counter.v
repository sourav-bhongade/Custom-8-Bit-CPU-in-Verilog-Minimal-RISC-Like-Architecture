`timescale 1ns/1ps

module program_counter (
    input clk,
    input reset,
    input jump,
    input [3:0] jump_addr,
    output reg [3:0] pc_out
);

always @(posedge clk or posedge reset) begin
    if (reset)
        pc_out <= 4'b0000;
    else if (jump)
        pc_out <= jump_addr;
    else
        pc_out <= pc_out + 1;
end

endmodule
