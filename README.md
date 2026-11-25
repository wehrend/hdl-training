# hdl-training

Verilog examples for part 3 of the course
[How does a CPU work?](https://wehrend.github.io/pages/20_digital_logic_3/)

Requirements: [Icarus Verilog](https://steveicarus.github.io/iverilog/), and GTKWave or Surfer to view waveforms.

| Folder | Simulate |
|---|---|
| `22_simulation/00-full-adder` | `iverilog -o sim full_adder_tb.v full_adder.v && vvp sim` |
| | `iverilog -o sim full_adder_tb_check.v full_adder.v && vvp sim` (self-checking) |
| `22_simulation/01-counter` | `iverilog -o sim counter_tb.v counter.v && vvp sim` |
| `23_combinational_verilog/00-seven-segment-decoder` | `iverilog -o sim seven_seg_tb.v seven_seg.v && vvp sim` |
| `23_combinational_verilog/01-ripple-carry-adder` | `iverilog -o sim ripple_adder_tb.v ripple_adder.v full_adder.v && vvp sim` |
| `23_combinational_verilog/02-latch` | `iverilog -o sim mux3_tb.v mux3_latch.v && vvp sim` (with latch) |
| | `iverilog -o sim mux3_tb.v mux3.v && vvp sim` (fixed) |
| `24_sequential_verilog/00-latch-vs-flipflop` | `iverilog -o sim latch_vs_ff_tb.v d_ff.v d_latch.v && vvp sim` |
| `24_sequential_verilog/01-shift-register` | `iverilog -o sim shift_reg_tb.v shift_reg.v shift_reg_blocking.v && vvp sim` |
| `24_sequential_verilog/02-counter` | `iverilog -o sim counter_updown_tb.v counter_updown.v && vvp sim` |
| `24_sequential_verilog/03-traffic-light` | `iverilog -o sim traffic_light_tb.v traffic_light.v traffic_light_eq.v && vvp sim` |
| `24_sequential_verilog/04-sequence-detector` | `iverilog -o sim seq101_tb.v seq101_mealy.v seq101_moore.v && vvp sim` (bonus) |
| `25_arithmetic_units/00-barrel-shifter` | `iverilog -o sim shifters_tb.v sll.v srl.v sra.v shifter_all.v && vvp sim` |
| `25_arithmetic_units/01-array-multiplier` | `iverilog -o sim array_multiplier_tb.v array_multiplier.v ripple_adder.v full_adder.v && vvp sim` |
| `25_arithmetic_units/02-shift-add-multiplier` | `iverilog -o sim seq_multiplier_tb.v seq_multiplier.v && vvp sim` |
| `25_arithmetic_units/03-divider` | `iverilog -o sim seq_divider_tb.v seq_divider.v && vvp sim` |
| `26_cpu_verilog/00-register-file` | `iverilog -o sim regfile_tb.v regfile.v && vvp sim` |
| `26_cpu_verilog/01-alu` | `iverilog -o sim alu_tb.v alu.v alu_cell.v && vvp sim` |
| `26_cpu_verilog/02-control` | `iverilog -o sim control_tb.v control.v alu_control.v imm_gen.v && vvp sim` |
| `26_cpu_verilog/03-cpu` | `iverilog -o sim cpu_tb.v cpu.v instr_mem.v data_mem.v regfile.v alu.v alu_cell.v control.v alu_control.v imm_gen.v && vvp sim` |

Waveforms are written as `.vcd` files and can be opened with `gtkwave <file>.vcd`.

The exhaustive tests of the sequential multiplier and divider run through all 65,536 input combinations
and take a few seconds.
In `26_cpu_verilog/03-cpu`, Icarus warns that `program.hex` has fewer than 64 words. That is fine:
the rest of the instruction memory is never used.

## Chapter 27: on the FPGA (Nandland Go Board)

The examples in `27_code_to_chip` run on the [Nandland Go Board](https://nandland.com/the-go-board/)
(Lattice iCE40 HX1K, VQ100). Additional requirements: the open-source FPGA toolchain
[Yosys](https://github.com/YosysHQ/yosys), [nextpnr](https://github.com/YosysHQ/nextpnr) (`nextpnr-ice40`)
and [Project IceStorm](https://github.com/YosysHQ/icestorm) (`icepack`, `iceprog`) - for example from the
[OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) or the packages `yosys nextpnr-ice40 fpga-icestorm`.

Every folder has a `Makefile` (shared rules in `27_code_to_chip/fpga.mk`), the pins are in `27_code_to_chip/go_board.pcf`:

| Folder | Commands |
|---|---|
| `27_code_to_chip/00-blinky` | `make sim` (simulate), `make` (bitstream), `make prog` (load onto the board) |
| `27_code_to_chip/01-synthesis` | `make sim`, `make stat` (resource usage), `make schematic` (SVG, needs graphviz), `make`, `make prog` |
| `27_code_to_chip/02-cpu-go-board` | `make sim`, `make`, `make prog` |

`make clean` removes all generated files. On Linux, `iceprog` may need permission to access the USB device
(udev rule or `sudo`).
