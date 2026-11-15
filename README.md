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

Waveforms are written as `.vcd` files and can be opened with `gtkwave <file>.vcd`.