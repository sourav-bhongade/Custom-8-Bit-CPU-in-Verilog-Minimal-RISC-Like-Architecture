#!/usr/bin/env python3
"""
Simple CPU Logic Test - Verifies instruction decoding and execution logic
"""

class SimpleCPU:
    def __init__(self):
        # Registers (4 physical registers R0-R3)
        self.registers = [0] * 4
        self.pc = 0
        self.zero_flag = 0
        
        # Instruction memory (from our comprehensive test program)
        self.memory = [
            0xA6, 0xAF, 0xB4, 0xBD,  # MOV instructions
            0x10, 0x31, 0x41, 0x61,  # ADD, MUL, AND, OR
            0x88, 0xF8, 0xCB, 0x9B,  # XOR, NOT, CMP, JZ
            0xA7, 0x7B, 0x00, 0x00   # MOV, JMP, NOP, NOP
        ]
        
    def decode_instruction(self, instruction):
        """Decode 8-bit instruction into fields"""
        opcode = (instruction >> 5) & 0x7      # bits 7:5
        dest_field = (instruction >> 3) & 0x3  # bits 4:3
        src_field = instruction & 0x7          # bits 2:0
        
        # Pad dest to 3 bits
        dest = dest_field  # This will be 0-3, representing R0-R3
        
        return opcode, dest, src_field
    
    def execute_instruction(self, instruction):
        """Execute a single instruction"""
        opcode, dest, src = self.decode_instruction(instruction)
        
        print(f"PC {self.pc:2d}: 0x{instruction:02X} ({instruction:08b}) - op:{opcode:03b} dest:{dest:02b} src:{src:03b}")
        
        # Check for jump instructions first
        if dest == 3 and opcode == 3:  # JMP: OR with dest=11
            jump_addr = src
            print(f"  JMP to address {jump_addr}")
            self.pc = jump_addr
            return True
            
        elif dest == 3 and opcode == 4:  # JZ: XOR with dest=11
            if self.zero_flag:
                jump_addr = src
                print(f"  JZ to address {jump_addr} (zero_flag=1)")
                self.pc = jump_addr
            else:
                print(f"  JZ not taken (zero_flag=0)")
                self.pc += 1  # Increment PC when jump not taken
            return True
            
        elif dest == 3 and opcode == 6:  # JNZ: CMP with dest=11
            if not self.zero_flag:
                jump_addr = src
                print(f"  JNZ to address {jump_addr} (zero_flag=0)")
                self.pc = jump_addr
            else:
                print(f"  JNZ not taken (zero_flag=1)")
                self.pc += 1  # Increment PC when jump not taken
            return True
        
        # Regular instruction execution
        if opcode == 0:  # ADD
            result = self.registers[dest] + self.registers[src]
            self.registers[dest] = result & 0xFF
            self.zero_flag = 1 if result == 0 else 0
            print(f"  ADD R{dest}, R{src} → R{dest} = {self.registers[dest]:02X}")
            
        elif opcode == 1:  # MUL
            result = self.registers[dest] * self.registers[src]
            self.registers[dest] = result & 0xFF
            self.zero_flag = 1 if result == 0 else 0
            print(f"  MUL R{dest}, R{src} → R{dest} = {self.registers[dest]:02X}")
            
        elif opcode == 2:  # AND
            result = self.registers[dest] & self.registers[src]
            self.registers[dest] = result & 0xFF
            self.zero_flag = 1 if result == 0 else 0
            print(f"  AND R{dest}, R{src} → R{dest} = {self.registers[dest]:02X}")
            
        elif opcode == 3:  # OR
            result = self.registers[dest] | self.registers[src]
            self.registers[dest] = result & 0xFF
            self.zero_flag = 1 if result == 0 else 0
            print(f"  OR R{dest}, R{src} → R{dest} = {self.registers[dest]:02X}")
            
        elif opcode == 4:  # XOR
            result = self.registers[dest] ^ self.registers[src]
            self.registers[dest] = result & 0xFF
            self.zero_flag = 1 if result == 0 else 0
            print(f"  XOR R{dest}, R{src} → R{dest} = {self.registers[dest]:02X}")
            
        elif opcode == 5:  # MOV
            if src >= 4:  # Immediate mode
                immediate_val = src - 4
                self.registers[dest] = immediate_val
                print(f"  MOV R{dest}, #{immediate_val} → R{dest} = {self.registers[dest]:02X}")
            else:  # Register mode
                self.registers[dest] = self.registers[src]
                print(f"  MOV R{dest}, R{src} → R{dest} = {self.registers[dest]:02X}")
                
        elif opcode == 6:  # CMP
            result = self.registers[dest] - self.registers[src]
            self.zero_flag = 1 if result == 0 else 0
            print(f"  CMP R{dest}, R{src} → zero_flag = {self.zero_flag}")
            
        elif opcode == 7:  # NOT
            result = (~self.registers[dest]) & 0xFF
            self.registers[dest] = result
            self.zero_flag = 1 if result == 0 else 0
            print(f"  NOT R{dest} → R{dest} = {self.registers[dest]:02X}")
            
        else:
            print(f"  Unknown opcode: {opcode:03b}")
            
        # Increment PC unless it was a jump
        if not (dest == 3 and opcode in [3, 4, 6]):
            self.pc += 1
            
        return False  # Not a jump
    
    def run_program(self, max_cycles=50):
        """Run the program until halt or max cycles"""
        print("=== CPU SIMULATION ===")
        print("Initial state:")
        print(f"  PC = {self.pc}")
        print(f"  R0 = {self.registers[0]:02X}, R1 = {self.registers[1]:02X}, R2 = {self.registers[2]:02X}, R3 = {self.registers[3]:02X}")
        print(f"  zero_flag = {self.zero_flag}")
        print()
        
        cycle = 0
        while cycle < max_cycles and self.pc < len(self.memory):
            instruction = self.memory[self.pc]
            was_jump = self.execute_instruction(instruction)
            
            cycle += 1
            print(f"  Registers: R0={self.registers[0]:02X} R1={self.registers[1]:02X} R2={self.registers[2]:02X} R3={self.registers[3]:02X}")
            print(f"  PC={self.pc}, zero_flag={self.zero_flag}")
            print()
            
            # Check for halt condition (infinite loop at PC=3)
            if self.pc == 3 and cycle > 10:
                print("  HALT: Infinite loop detected at PC=3")
                break
                
        print("=== FINAL STATE ===")
        print(f"PC = {self.pc}")
        print(f"R0 = {self.registers[0]:02X}, R1 = {self.registers[1]:02X}, R2 = {self.registers[2]:02X}, R3 = {self.registers[3]:02X}")
        print(f"zero_flag = {self.zero_flag}")
        print(f"Total cycles: {cycle}")
        
        return self.registers

if __name__ == "__main__":
    cpu = SimpleCPU()
    final_registers = cpu.run_program()
    
    # Expected final state from testbench
    expected = [0x03, 0x00, 0x06, 0xFE]  # R0=3, R1=0, R2=6, R3=FE
    
    print("\n=== TEST RESULTS ===")
    all_passed = True
    for i, (actual, exp) in enumerate(zip(final_registers, expected)):
        if actual == exp:
            print(f"✅ R{i} = 0x{actual:02X} (expected: 0x{exp:02X})")
        else:
            print(f"❌ R{i} = 0x{actual:02X} (expected: 0x{exp:02X})")
            all_passed = False
    
    if all_passed:
        print("\n🎉 ALL TESTS PASSED!")
    else:
        print("\n❌ SOME TESTS FAILED!")