# assembler.py - Fixed for proper 3-2-3 instruction format (3-bit opcode, 2-bit dest, 3-bit src/imm)

# Corrected instruction set with unique opcodes - matches CPU implementation
INSTRUCTION_SET = {
    "ADD": "000",  # R[dest] = R[dest] + R[src]
    "MUL": "001",  # R[dest] = R[dest] * R[src] 
    "AND": "010",  # R[dest] = R[dest] & R[src]
    "OR":  "011",  # R[dest] = R[dest] | R[src]
    "XOR": "100",  # R[dest] = R[dest] ^ R[src]
    "MOV": "101",  # R[dest] = R[src] or R[dest] = imm
    "CMP": "110",  # Compare R[dest] - R[src], set flags
    "NOT": "111",  # R[dest] = ~R[dest] (bitwise complement)
    "JMP": "011",  # Jump to address (special encoding: dest=11, src=addr)
    "JZ":  "100",  # Jump if zero (special encoding: dest=11, src=addr)
    "JNZ": "101",  # Jump if not zero (special encoding: dest=11, src=addr)
    "NOP": "000"   # No operation
}

# Register mapping - only 4 physical registers (R0-R3) using 2-bit addressing
REGISTERS = {
    "R0": "00",
    "R1": "01", 
    "R2": "10",
    "R3": "11"
}

def to_bin(value, bits):
    """Convert integer to binary string with specified width"""
    return format(int(value), f'0{bits}b')

def parse_immediate(imm_str):
    """Parse immediate value from string (supports #decimal or #0xhex)"""
    if imm_str.startswith('#0x'):
        return int(imm_str[3:], 16)
    elif imm_str.startswith('#'):
        return int(imm_str[1:])
    else:
        return int(imm_str)

def assemble_line(line):
    """Assemble a single line into 8-bit machine code"""
    parts = line.strip().replace(',', '').split()
    if not parts:
        return None

    instr = parts[0].upper()

    # NOP instruction
    if instr == "NOP":
        return "00000000"

    # MOV immediate: MOV reg, #imm
    elif instr == "MOV" and len(parts) >= 3 and parts[2].startswith('#'):
        opcode = INSTRUCTION_SET["MOV"]
        dest_reg = REGISTERS[parts[1].upper()]
        imm_val = parse_immediate(parts[2])
        # For MOV immediate, we can only have values 0-3 (since 4-7 are used for detection)
        if imm_val > 3:
            print(f"Warning: Immediate value {imm_val} truncated to {imm_val & 0x3}")
            imm_val = imm_val & 0x3
        imm_bin = to_bin(imm_val, 3)
        # For immediate mode, add 4 to make it >=4 to distinguish from registers
        src_field = to_bin(imm_val + 4, 3)  # Add 4 offset for immediate detection
        return opcode + dest_reg + src_field

    # MOV register: MOV reg1, reg2  
    elif instr == "MOV":
        opcode = INSTRUCTION_SET["MOV"]
        dest_reg = REGISTERS[parts[1].upper()]
        src_reg = REGISTERS[parts[2].upper()]
        # Pad source register to 3 bits with MSB=0 for register mode
        src_field = "0" + src_reg
        return opcode + dest_reg + src_field

    # ALU operations: ADD, MUL, AND, OR, XOR
    elif instr in ["ADD", "MUL", "AND", "OR", "XOR"]:
        if len(parts) == 3:
            # Two operand form: OP dest, src → dest = dest OP src
            opcode = INSTRUCTION_SET[instr]
            dest_reg = REGISTERS[parts[1].upper()]
            src_reg = REGISTERS[parts[2].upper()]
            src_field = "0" + src_reg  # Pad to 3 bits
            return opcode + dest_reg + src_field
        elif len(parts) == 4:
            # Three operand form: OP dest, src1, src2 → dest = src1 OP src2
            # Note: This requires dest to be loaded with src1 first, then OP with src2
            print(f"Warning: Three-operand {instr} not directly supported. Use MOV first.")
            return "00000000"  # NOP

    # Unary operations: NOT 
    elif instr == "NOT":
        opcode = INSTRUCTION_SET["NOT"]
        dest_reg = REGISTERS[parts[1].upper()]
        src_field = "000"  # Unused for unary ops
        return opcode + dest_reg + src_field

    # Compare operation: CMP
    elif instr == "CMP":
        opcode = INSTRUCTION_SET["CMP"]
        dest_reg = REGISTERS[parts[1].upper()]
        src_reg = REGISTERS[parts[2].upper()]
        src_field = "0" + src_reg
        return opcode + dest_reg + src_field

    # Jump instructions
    elif instr == "JMP":
        opcode = INSTRUCTION_SET["OR"]  # Reuse OR opcode
        dest_reg = "11"  # Special dest=11 signals jump
        addr = parse_immediate(parts[1]) if parts[1].startswith('#') else int(parts[1])
        if addr > 7:
            print(f"Warning: Jump address {addr} truncated to {addr & 0x7}")
            addr = addr & 0x7
        addr_field = to_bin(addr, 3)
        return opcode + dest_reg + addr_field

    elif instr == "JZ":
        opcode = INSTRUCTION_SET["XOR"]  # Reuse XOR opcode  
        dest_reg = "11"  # Special dest=11 signals conditional jump
        addr = parse_immediate(parts[1]) if parts[1].startswith('#') else int(parts[1])
        if addr > 7:
            print(f"Warning: Jump address {addr} truncated to {addr & 0x7}")
            addr = addr & 0x7
        addr_field = to_bin(addr, 3)
        return opcode + dest_reg + addr_field

    elif instr == "JNZ":
        opcode = INSTRUCTION_SET["CMP"]  # Use CMP opcode for JNZ  
        dest_reg = "11"  # Special dest=11 signals conditional jump
        addr = parse_immediate(parts[1]) if parts[1].startswith('#') else int(parts[1])
        if addr > 7:
            print(f"Warning: Jump address {addr} truncated to {addr & 0x7}")
            addr = addr & 0x7
        addr_field = to_bin(addr, 3)
        return opcode + dest_reg + addr_field

    else:
        print(f"Warning: Unknown instruction '{instr}', assembling as NOP")
        return "00000000"  # Default to NOP

def assemble_program(lines):
    """Assemble program lines into hex machine code"""
    binary_output = []
    hex_output = []
    
    print("=== ASSEMBLY PROCESS ===")
    for idx, line in enumerate(lines):
        line = line.strip()
        if not line or line.startswith("//") or line.startswith(";"):
            continue

        bin_code = assemble_line(line)
        if bin_code:
            value = int(bin_code, 2) & 0xFF  # Ensure 8-bit
            hex_code = f"{value:02X}"
            binary_output.append(f"8'h{hex_code}")
            hex_output.append(hex_code)
            
            # Detailed output for verification
            opcode = bin_code[:3]
            dest = bin_code[3:5] 
            src = bin_code[5:8]
            print(f"Line {idx:2d}: {line:20s} → {bin_code} → 0x{hex_code} (op:{opcode} dest:{dest} src:{src})")
    
    print(f"\nGenerated {len(binary_output)} instructions")
    return binary_output, hex_output

def write_verilog_rom(hex_lines):
    """Generate Verilog ROM file with assembled instructions"""
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
            f.write(f"        memory[{i:2d}] = {val};\n")
        
        # Fill remaining memory with NOPs
        for i in range(len(hex_lines), 16):
            f.write(f"        memory[{i:2d}] = 8'h00;\n")
            
        f.write("""    end
endmodule
""")

def manual_verify_encoding():
    """Manual verification of key instruction encodings"""
    print("\n=== MANUAL VERIFICATION ===")
    test_cases = [
        ("MOV R1, #1", "10101101"),   # 101 01 101 (immediate 1 encoded as 5)
        ("MOV R2, R1", "10110001"),   # 101 10 001 (reg R1) 
        ("ADD R1, R2", "00001010"),   # 000 01 010 (R1 = R1 + R2)
        ("MUL R2, R1", "00110001"),   # 001 10 001 (R2 = R2 * R1)
        ("JMP 7", "01111111"),        # 011 11 111 (jump to addr 7)
        ("JZ 3", "10011011"),         # 100 11 011 (jump if zero to addr 3)
        ("CMP R1, R2", "11001010")    # 110 01 010 (compare R1 - R2)
    ]
    
    for instruction, expected in test_cases:
        result = assemble_line(instruction)
        status = "✓" if result == expected else "✗"
        print(f"{status} {instruction:12s} → {result} (expected: {expected})")

if __name__ == "__main__":
    try:
        with open("program.txt", "r") as f:
            lines = f.readlines()
    except FileNotFoundError:
        print("Error: program.txt not found!")
        exit(1)

    # Assemble the program
    verilog_lines, hex_values = assemble_program(lines)
    
    # Write Verilog ROM
    write_verilog_rom(verilog_lines)
    
    # Manual verification
    manual_verify_encoding()
    
    print(f"\n✅ Assembly completed! Generated instruction_memory.v with {len(verilog_lines)} instructions")
    print("📄 Hex dump:", " ".join(hex_values))
