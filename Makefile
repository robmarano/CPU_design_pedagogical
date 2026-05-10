# Makefile for Verilator + SDL2 MIPS CPU
VERILATOR = verilator
VFLAGS = -Wall -Wno-fatal -Isrc/pipelined_computer -cc src/pipelined_computer/computer.sv --exe src/verilator/sim_main.cpp

# Handle macOS Apple Silicon SDL2 paths (homebrew)
SDL_CFLAGS = -I/opt/homebrew/include
SDL_LDFLAGS = -L/opt/homebrew/lib -lSDL2

all: sim

obj_dir/Vcomputer.mk: src/pipelined_computer/*.sv src/verilator/sim_main.cpp
	$(VERILATOR) $(VFLAGS) -CFLAGS "$(SDL_CFLAGS) -I../src/verilator" -LDFLAGS "$(SDL_LDFLAGS)"

sim: obj_dir/Vcomputer.mk
	make -j -C obj_dir -f Vcomputer.mk Vcomputer

clean:
	rm -rf obj_dir
