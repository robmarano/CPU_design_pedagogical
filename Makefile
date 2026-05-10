# MIPS32 Pedagogical CPU - Master Makefile

# Tools
ASSEMBLER = python3 scripts/assembler.py
IVCC      = iverilog -g2012
VERILATOR = verilator

# Verilator Flags
VFLAGS      = -Wall -Wno-fatal -Isrc/pipelined_computer -cc src/pipelined_computer/computer.sv --exe src/verilator/sim_main.cpp
SDL_CFLAGS  = -I/opt/homebrew/include
SDL_LDFLAGS = -L/opt/homebrew/lib -lSDL2

.PHONY: all clean lab1 lab2 lab3 lab4

all:
	@echo "Please specify a lab target: make lab1, make lab2, make lab3, or make lab4"

# --- Lab 1: Single-Cycle CPU ---
lab1:
	@echo "==> Assembling basic_test.asm"
	$(ASSEMBLER) programs/basic_test.asm memfile.dat
	@echo "==> Compiling Single-Cycle Simulation"
	$(IVCC) -I src/single_cycle_computer -o single_sim tests/single_cycle_computer/tb_computer.sv src/single_cycle_computer/*.sv
	@echo "==> Running Single-Cycle Simulation"
	./single_sim

# --- Lab 2: Multi-Cycle CPU ---
lab2:
	@echo "==> Assembling basic_test.asm"
	$(ASSEMBLER) programs/basic_test.asm memfile.dat
	@echo "==> Compiling Multi-Cycle Simulation"
	$(IVCC) -I src/multi_cycle_computer -o multi_sim tests/multi_cycle_computer/tb_computer.sv src/multi_cycle_computer/*.sv
	@echo "==> Running Multi-Cycle Simulation"
	./multi_sim

# --- Lab 3: Pipelined CPU (Quake III) ---
lab3:
	@echo "==> Assembling quake3.asm"
	$(ASSEMBLER) programs/quake3.asm programs/memfile_quake3.dat
	@echo "==> Compiling Pipelined CPU Simulation"
	$(IVCC) -I src/pipelined_computer -o quake_sim tests/pipelined_computer/tb_quake.sv src/pipelined_computer/*.sv
	@echo "==> Running Quake III Fast Inverse Square Root"
	./quake_sim

# --- Lab 4: Interactive Terminal (Verilator + SDL2) ---
obj_dir/Vcomputer.mk: src/pipelined_computer/*.sv src/verilator/sim_main.cpp
	$(VERILATOR) $(VFLAGS) -CFLAGS "$(SDL_CFLAGS) -I../src/verilator" -LDFLAGS "$(SDL_LDFLAGS)"

obj_dir/Vcomputer: obj_dir/Vcomputer.mk
	make -j -C obj_dir -f Vcomputer.mk Vcomputer

lab4: obj_dir/Vcomputer
	@echo "==> Assembling terminal.asm"
	$(ASSEMBLER) programs/terminal.asm programs/memfile.dat
	@echo "==> Launching Interactive MMIO Terminal"
	./obj_dir/Vcomputer

# --- Clean-up ---
clean:
	rm -rf obj_dir *_sim *.vcd programs/*.dat memfile.dat
