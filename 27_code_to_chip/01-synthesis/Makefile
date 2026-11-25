TOP = hex_display
SRC = hex_display.v seven_seg.v
TB  = hex_display_tb.v

include ../fpga.mk

# schematic of the decoder after synthesis, as SVG (needs graphviz)
schematic: seven_seg.v
	yosys -q -p "synth_ice40 -top seven_seg; show -format svg -prefix seven_seg_ice40" seven_seg.v

.PHONY: schematic
