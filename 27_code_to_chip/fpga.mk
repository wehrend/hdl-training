# Shared build rules for the Go Board examples (included by every Makefile in this folder).
# Each Makefile sets TOP (top module), SRC (Verilog files) and optionally TB (testbench).
#
#   make        synthesis, place & route, bitstream  ->  $(TOP).bin
#   make prog   load the bitstream onto the Go Board (via USB)
#   make stat   resource usage after synthesis
#   make sim    simulate the testbench with Icarus Verilog
#   make clean  remove generated files

PCF ?= ../go_board.pcf

all: $(TOP).bin

# 1. synthesis: Verilog -> netlist of iCE40 cells (LUTs, flip-flops, block RAM)
$(TOP).json: $(SRC)
	yosys -q -l $(TOP)_yosys.log -p "synth_ice40 -top $(TOP) -json $@" $(SRC)

# 2. place & route: every cell gets a place on the chip, then the wires are routed;
#    --freq 25: timing analysis against the 25 MHz clock of the Go Board
$(TOP).asc: $(TOP).json $(PCF)
	nextpnr-ice40 --hx1k --package vq100 --freq 25 --json $< --pcf $(PCF) --asc $@ \
	    2>&1 | tee $(TOP)_nextpnr.log | grep -E "(ICESTORM_LC|ICESTORM_RAM|SB_IO): |Max frequency for clock|ERROR"

# 3. bitstream: the configuration of the chip as a binary file
$(TOP).bin: $(TOP).asc
	icepack $< $@

# 4. load it onto the board
prog: $(TOP).bin
	iceprog $<

stat: $(SRC)
	yosys -q -p "synth_ice40 -top $(TOP); tee -o /dev/stdout stat" $(SRC)

sim: $(TB) $(SRC)
	iverilog -o sim $(TB) $(SRC) && vvp sim

clean:
	rm -f *.json *.asc *.bin *.log *.vcd *.svg *.dot sim

.PHONY: all prog stat sim clean
