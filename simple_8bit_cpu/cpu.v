`timescale 1ns/1ps

module simple_cpu (
    input clk,
    input reset,
    output [3:0] pc
);

// Signals
wire [3:0] pc;
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
    .read_addr1(dest),
    .read_addr2(src),
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
always @(*) begin
    write_en = 0;
    write_addr = dest;
    write_data = 8'b0;
    jump = 0;
    jump_addr = 4'b0;

    case (opcode)

        3'b000: begin // ADD
            write_en = 1;
            write_data = alu_result;
            $display("ADD Executed: R1=%h, R2=%h, RESULT=%h, write_en=%b", reg_data1, reg_data2, alu_result, write_en);
            $display("CPU Cycle - PC=%d, Instruction=%h, Opcode=%b, Dest=%b, Src=%b", pc, instruction, opcode, dest, src);
        end

        3'b001: begin // MUL
            write_en = 1;
            write_data = alu_result;
        end

        3'b010: begin // AND
            write_en = 1;
            write_data = alu_result;
        end

        3'b011: begin // OR
            write_en = 1;
            write_data = alu_result;
        end

        3'b100: begin // XOR
            write_en = 1;
            write_data = alu_result;
        end

        3'b101: begin // MOV
            if (dest[2] == 1'b1) begin
                // MOV immediate: upper dests (R4–R7) → signal imm
                write_addr = {1'b0, dest[1:0]};  // map R4–R7 to R0–R3
                write_en = 1;
                write_data = {5'b00000, src};  // zero-extend imm
                $display("MOV IMM: R%d = #%h", write_addr, write_data);
            end else begin
                // MOV register to register
                write_en = 1;
                write_data = reg_data2;
                $display("MOV REG: R%d = R%d = %h", dest, src, reg_data2);
            end
        end

        3'b110: begin // CMP
            // only sets zero_flag
            write_en = 0;
        end

        3'b111: begin // COM (bitwise NOT)
            write_en = 1;
            write_data = alu_result;
        end

    endcase

    // Handle special jumps
    if (opcode == 3'b011 && dest == 3'b011) begin // JMP
        jump = 1;
        jump_addr = src;
        write_en = 0;
    end 
    else if (opcode == 3'b100 && dest == 3'b011) begin // JZ
        if (zero_flag) begin
            jump = 1;
            jump_addr = src;
            write_en = 0;
        end
    end 
    else if (opcode == 3'b101 && dest == 3'b011) begin // JNZ
        if (!zero_flag) begin
            jump = 1;
            jump_addr = src;
            write_en = 0;
        end
    end
end

endmodule
