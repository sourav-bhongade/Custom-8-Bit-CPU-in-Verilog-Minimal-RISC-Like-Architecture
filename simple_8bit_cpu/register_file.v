`timescale 1ns/1ps

module register_file (
    input clk,
    input write_en,
    input [2:0] write_addr,
    input [7:0] write_data,
    input [2:0] read_addr1,
    input [2:0] read_addr2,
    output [7:0] read_data1,
    output [7:0] read_data2
);

// Only 4 general-purpose registers physically used: R0 to R3
reg [7:0] registers [3:0];

// Masked addresses
wire [1:0] actual_write_addr = write_addr[1:0];
wire [1:0] actual_read_addr1 = read_addr1[1:0];
wire [1:0] actual_read_addr2 = read_addr2[1:0];

// Combinational read
assign read_data1 = registers[actual_read_addr1];
assign read_data2 = registers[actual_read_addr2];

// Sequential write
always @(posedge clk) begin
    if (write_en) begin
        registers[actual_write_addr] <= write_data;
        $display("REG WRITE: R[%0d] = %h", write_addr, write_data);
    end
end

endmodule
