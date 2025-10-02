`timescale 1ns/1ps

module simple_cpu (
    input clk,
    input reset,
    output [3:0] pc
);

// Signals
wire [7:0] instruction;
wire [2:0] opcode;
wire [2:0] dest;
wire [2:0] src;
wire [7:0] reg_data1, reg_data2;
wire [7:0] alu_result;
wire zero_flag;

reg write_en;
reg [7:0] write_data;
reg [2:0] write_addr;
reg jump;
reg [3:0] jump_addr;

// Instantiate Program Counter
program_counter PC (
    .clk(clk),
    .reset(reset),
    .jump(jump),
    .jump_addr(jump_addr),
    .pc_out(pc)
);

// Instruction Memory
instruction_memory ROM (
    .addr(pc),
    .data(instruction)
);

// Decoder
instruction_decoder DEC (
    .instruction(instruction),
    .opcode(opcode),
    .reg1(dest),
    .reg2_or_imm(src)
);

// Register File (with address masking internally)
register_file REGFILE (
    .clk(clk),
    .write_en(write_en),
    .write_addr(write_addr),
    .write_data(write_data),
    .read_addr1(dest), // First operand comes from dest register
    .read_addr2(src),  // Second operand comes from src register
    .read_data1(reg_data1),
    .read_data2(reg_data2)
);

// ALU
alu ALU (
    .operand1(reg_data1),
    .operand2(reg_data2),
    .opcode(opcode),
    .result(alu_result),
    .zero_flag(zero_flag)
);

// Execution Logic
always @(posedge clk) begin
    if (reset) begin
        write_en <= 0;
        jump <= 0;
        jump_addr <= 4'b0;
        write_addr <= 3'b0;
        write_data <= 8'b0;
    end else begin
        // Default values
        write_en <= 0;
        write_addr <= dest;
        write_data <= 8'b0;
        jump <= 0;
        jump_addr <= 4'b0;

        // Check for jump instructions first (special cases with dest=11 AND specific conditions)
        if (dest == 3'b011 && opcode == 3'b011) begin // JMP: OR with dest=11
            jump <= 1;
            jump_addr <= {1'b0, src[2:0]};  // Pad src to 4 bits
            write_en <= 0;
            $display("JMP to address %d", {1'b0, src[2:0]});
        end else if (dest == 3'b011 && opcode == 3'b100) begin // JZ: XOR with dest=11  
            if (zero_flag) begin
                jump <= 1;
                jump_addr <= {1'b0, src[2:0]};  // Pad src to 4 bits
                write_en <= 0;
                $display("JZ to address %d (zero_flag=1)", {1'b0, src[2:0]});
            end else begin
                jump <= 0;  // Explicitly set jump=0 for PC increment
                write_en <= 0;
                $display("JZ not taken (zero_flag=0)");
            end
        end else if (dest == 3'b011 && opcode == 3'b110) begin // JNZ: CMP with dest=11
            if (!zero_flag) begin
                jump <= 1;
                jump_addr <= {1'b0, src[2:0]};  // Pad src to 4 bits
                write_en <= 0;
                $display("JNZ to address %d (zero_flag=0)", {1'b0, src[2:0]});
            end else begin
                jump <= 0;  // Explicitly set jump=0 for PC increment
                write_en <= 0;
                $display("JNZ not taken (zero_flag=1)");
            end
        end else begin
            // Regular instruction execution for dest=00,01,10
            case (opcode)
                3'b000: begin // ADD
                    write_en <= 1;
                    write_data <= alu_result;
                    $display("ADD R%d, R%d → R%d = %h", dest, src, dest, alu_result);
                end

                3'b001: begin // MUL
                    write_en <= 1;
                    write_data <= alu_result;
                    $display("MUL R%d, R%d → R%d = %h", dest, src, dest, alu_result);
                end

                3'b010: begin // AND
                    write_en <= 1;
                    write_data <= alu_result;
                    $display("AND R%d, R%d → R%d = %h", dest, src, dest, alu_result);
                end

                3'b011: begin // OR
                    write_en <= 1;
                    write_data <= alu_result;
                    $display("OR R%d, R%d → R%d = %h", dest, src, dest, alu_result);
                end

                3'b100: begin // XOR
                    write_en <= 1;
                    write_data <= alu_result;
                    $display("XOR R%d, R%d → R%d = %h", dest, src, dest, alu_result);
                end

                3'b101: begin // MOV
                    if (src >= 3'd4) begin
                        // MOV immediate: src values 4-7 indicate immediate mode
                        write_en <= 1;
                        write_data <= {5'b00000, src[2:0] - 3'd4};  // Subtract 4 offset to get actual immediate value
                        $display("MOV R%d, #%d → R%d = %h", dest, src[2:0] - 3'd4, dest, {5'b00000, src[2:0] - 3'd4});
                    end else begin
                        // MOV register to register: src values 0-3 indicate register mode
                        write_en <= 1;
                        write_data <= reg_data2;
                        $display("MOV R%d, R%d → R%d = %h", dest, src[1:0], dest, reg_data2);
                    end
                end

                3'b110: begin // CMP
                    // Compare operation - only sets flags, no write
                    write_en <= 0;
                    $display("CMP R%d, R%d → zero_flag = %b", dest, src, zero_flag);
                end

                3'b111: begin // NOT (bitwise complement)
                    write_en <= 1;
                    write_data <= alu_result;
                    $display("NOT R%d → R%d = %h", dest, dest, alu_result);
                end

                default: begin
                    write_en <= 0;
                    $display("Unknown opcode: %b", opcode);
                end
            endcase
        end
    end
end

endmodule