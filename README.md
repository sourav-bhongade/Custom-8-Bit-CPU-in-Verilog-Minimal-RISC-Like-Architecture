# Custom-8-Bit-CPU-in-Verilog-Minimal-RISC-Like-Architecture
# 🧠 Custom 8-Bit CPU in Verilog  
### 🚀 A Minimal RISC-Inspired Architecture for Digital Design Exploration

---

## 📘 Overview

This project is a hand-built 8-bit CPU written in **Verilog HDL**, developed as part of a deep dive into computer architecture, digital systems, and hardware design. The CPU features a **custom 3-2-3 instruction format**, ALU, branching logic, and a compact register file — designed for **educational clarity**, **simulation correctness**, and **modular extensibility**.

Whether you're simulating on EDA Playground or integrating into larger HDL systems, this CPU provides a clean and understandable foundation for low-level computing concepts.

---

## 📐 Instruction Format

This CPU uses a fixed-width 8-bit instruction format:

```
[ OPCODE | DEST | SRC ]
   3 bits   2 bits  3 bits
```

- **OPCODE**: Specifies the operation (ADD, MOV, AND, etc.)
- **DEST**: Destination register
- **SRC**: Source register or immediate value (context-dependent)

---

## ⚙️ Supported Instructions

| Opcode | Mnemonic | Description                              |
|--------|----------|------------------------------------------|
| `000`  | ADD      | reg[dest] ← reg[dest] + reg[src]         |
| `001`  | MUL      | reg[dest] ← reg[dest] * reg[src]         |
| `010`  | AND      | reg[dest] ← reg[dest] & reg[src]         |
| `011`  | OR / JMP | OR or unconditional jump (dest = 11)     |
| `100`  | XOR / JZ | XOR or jump if zero flag is set          |
| `101`  | MOV / JNZ| MOV (immediate/register) or jump if !Z   |
| `110`  | CMP      | Compare two registers → sets zero flag   |
| `111`  | COM      | reg[dest] ← ~reg[dest] (bitwise NOT)     |

---

## 📦 Project Structure

```
📁 8bit-cpu/
├── simple_cpu.v             # Top-level control module
├── register_file.v          # 4-register bank with masking logic
├── program_counter.v        # PC with reset and jump logic
├── instruction_decoder.v    # 3-2-3 instruction field extractor
├── instruction_memory.v     # ROM for hardcoded test programs
├── alu.v                    # ALU supporting all major operations
├── testbench.v              # Sample testbench with instructions
├── cpu.vcd                  # Simulation waveform (for GTKWave)
├── README.md                # Project overview and guide
├── LICENSE                  # Open-source MIT License
└── .gitignore               # Files to exclude from version control
```

---

## 💡 Immediate vs Register MOV Logic

To distinguish between `MOV` (register) and `MOVI` (immediate), this design uses:
- `dest[2] = 1` → Indicates **immediate mode**
- Internally, `R4–R7` are mapped to `R0–R3` using masking logic
- Ensures unified register addressing while maintaining instruction encoding clarity

This allows MOV instructions to support both immediate and register operations without wasting opcode space.

---

## 🔬 Simulation Output Example

```verilog
MOV R1, #5
MOV R2, #7
ADD R3, R1, R2
```

**Expected Output:**
```
R1 = 05
R2 = 07
R3 = 0C
```

All operations are verified using `$display` debug statements and waveform analysis via `cpu.vcd`.

---

## 🛠️ Tools Used

- Verilog HDL  
- EDA Playground (for online simulation)  
- GTKWave (for waveform visualization)  
- Git and GitHub (for version control)  
- Icarus Verilog (optional local simulation)

---

## 📈 Learning Goals

This project demonstrates:

- Digital design using Verilog HDL  
- Custom instruction set design and decoding  
- Register file architecture and masking techniques  
- ALU and condition flags implementation  
- Program counter, branching, and control logic  
- Debugging using `$display` and waveform analysis

---

## 👨‍💻 Author

**Sourav bhongade**  
B.Tech in Electronics and Telecommunication Engineering  
Aspiring Embedded Systems & Digital Hardware Engineer  

> “I built this project to strengthen my understanding of how processors work under the hood, from the gates up.”

---

## 📄 License

This project is licensed under the **MIT License** — feel free to use, modify, and build upon it.

---

## ⭐️ Like this Project?

If this project helped you learn or impressed you, consider starring the repo and following me on GitHub! Let's grow as open-source learners 🚀
