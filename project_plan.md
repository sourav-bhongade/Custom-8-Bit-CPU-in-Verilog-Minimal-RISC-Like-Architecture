You are a hardware and software expert. I want you to take full ownership of polishing and preparing my custom-designed 8-bit CPU project for final presentation and deployment. The architecture is based on a 3-2-3 instruction format (3-bit opcode, 2-bit dest register, 3-bit source/immediate). The CPU is written in Verilog.

Here's a list of everything I need from you in a single session. Treat this like you're doing a final review, debugging, optimization, and professional polish of the whole project. Be exhaustive.

📌 1. Fix the Assembler
My assembler should read from program.txt and translate human-readable instructions to machine hex codes correctly based on my CPU's 3-2-3 format logic.

Currently, it misencodes some instructions or produces wrong outputs. Debug this logic fully.

Validate every instruction by comparing assembler output with manual encoding.

Ensure that the assembler dynamically writes these correct hex codes into instruction_memory.mem.

📌 2. Build a Robust Testbench
Write a comprehensive Verilog testbench to check all supported instructions and edge cases (boundary register values, jump loops, zero/carry flags if used, etc).

The testbench should validate functional correctness, performance (minimum cycles), and stability.

If any bugs or misbehaviors are found, update the modules accordingly and generate new testbenches to recheck until the design is error-free.

Output must be clearly visible in waveform or logs showing register values and memory outputs.

📌 3. Complex Demo Program
Write a sample program (in program.txt) that uses all instructions and shows off the CPU’s full power.

The program should do something more complex like looping, conditional logic, register manipulation, math operations — all within the CPU’s architectural limits.

Use this as a demonstration to prove the CPU's capability and correctness.

📌 4. Optimize Design
Ensure no unnecessary clock cycles are being used in fetch/decode/execute.

Check the PC, ALU, decoder, and other modules for any inefficiencies or redundant logic.

Improve performance or design simplicity wherever possible.

📌 5. Polish the Project
Rewrite the README.md file in a professional and impressive way.

Include:

Project overview

Features

Architecture (add diagram if possible)

Instruction set table

Assembler explanation

How to simulate/test

Screenshots of output/test results

Example program flow

📌 6. Final Analysis and Feedback
Tell me if the project is fully working and stable.

Give constructive criticism, pointing out flaws, inefficiencies, or limitations.

Suggest improvements, future version features (like expanding to 16-bit or pipelining).

📌 7. Presentation Pitch
Write a short project pitch script (1–2 min) that I can use while presenting.

Emphasize the engineering challenges, solutions, and what makes the CPU special.

⚠️ You only get one prompt to make all this happen, so chain all actions smartly, automate where necessary, and focus on quality.
Assume everything you need is already in the repo, or create what’s missing yourself.

Let me know if it's 100% ready to present once you're done.

