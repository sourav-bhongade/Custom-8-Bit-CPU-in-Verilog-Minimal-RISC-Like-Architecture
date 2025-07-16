# assembler.py

INSTRUCTION_SET = {
    "ADD": "000",
    "MUL": "001",
    "AND": "010",
    "OR":  "011",
    "XOR": "100",
    "MOV": "101",  # MOV reg, imm or reg, reg
    "CMP": "110",
    "NOT": "111",
    "JMP": "011",  # (same as OR for reuse)
    "JZ":  "100",  # Reuse opcode as needed
    "JNZ": "101",
    "INC": "110",
    "DEC": "111",
    "NOP": "000"
}


REGISTERS = {
    "R0": "000",
    "R1": "001",
    "R2": "010",
    "R3": "011",
    "R4": "100",
    "R5": "101",
    "R6": "110",
    "R7": "111"
}


def to_bin(value, bits):
    return format(int(value), f'0{bits}b')

def assemble_line(line):
    parts = line.strip().replace(',', '').split()
    if not parts:
        return None

    instr = parts[0].upper()

    if instr == "NOP":
        return "00000000"

    elif instr == "MOV" and '#' in parts[2]:  # MOV reg, #imm
        opcode = INSTRUCTION_SET["MOV"]
        reg1 = REGISTERS[parts[1].upper()]
        imm = to_bin(parts[2][1:], 3)
        return opcode + reg1 + imm

    elif instr == "MOV":  # MOV reg1, reg2
        opcode = INSTRUCTION_SET["MOV"]
        reg1 = REGISTERS[parts[1].upper()]
        reg2 = REGISTERS[parts[2].upper()]
        return opcode + reg1 + reg2

    elif instr in ["ADD", "MUL", "AND", "OR", "XOR", "CMP"]:
        opcode = INSTRUCTION_SET[instr]
        reg1 = REGISTERS[parts[1].upper()]
        reg2 = REGISTERS[parts[2].upper()]
        return opcode + reg1 + reg2

    elif instr in ["INC", "DEC", "NOT"]:
        opcode = INSTRUCTION_SET[instr]
        reg1 = REGISTERS[parts[1].upper()]
        return opcode + reg1 + "000"

    elif instr in ["JMP", "JZ", "JNZ"]:
        opcode = INSTRUCTION_SET[instr]
        reg = "00"
        addr = to_bin(parts[1], 3)
        return opcode + reg + addr

    else:
        return "00000000"  # fallback NOP

def assemble_program(lines):
    binary_output = []
    for idx, line in enumerate(lines):
        line = line.strip()
        if not line or line.startswith("//"): continue

        bin_code = assemble_line(line)
        if bin_code:
            value = int(bin_code, 2) & 0xFF  # Ensure only 8 bits
            hex_code = f"{value:02X}"       # Always 2-digit uppercase hex
            binary_output.append(f"8'h{hex_code}")
    return binary_output

def write_verilog_rom(hex_lines):
    with open("instruction_memory.v", "w") as f:
        f.write("""`timescale 1ns/1ps

module instruction_memory (
    input [3:0] addr,
    output [7:0] data
);
    reg [7:0] memory [0:15];
    assign data = memory[addr];

    initial begin
""")
        for i, val in enumerate(hex_lines):
            f.write(f"        memory[{i}] = {val};\n")
        f.write("""    end
endmodule
""")

if __name__ == "__main__":
    with open("program.txt", "r") as f:
        lines = f.readlines()

    hex_lines = assemble_program(lines)
    write_verilog_rom(hex_lines)
    print("✅ ROM generated successfully as instruction_memory.v")
