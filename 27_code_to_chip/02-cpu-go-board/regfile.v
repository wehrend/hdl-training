// RISC-V register file in block RAM (chapter 26: built from flip-flops).
//
// The iCE40 block RAM can only be read on a clock edge. So reading is no longer combinational:
// rd1 and rd2 show the registers that were selected by rs1 and rs2 at the last rising edge.
// A block RAM has one read port, so there are two copies (bank1, bank2) that are always
// written together - one copy per read port.
//
// Important: this only works because of the clock enable in the CPU. After every instruction
// (ce = 1), the register file needs one more clock edge to read the operands of the next
// instruction. So ce must never be 1 in two clock cycles in a row.
module regfile (
    input  wire        clk,
    input  wire [4:0]  rs1,         // read port 1
    input  wire [4:0]  rs2,         // read port 2
    output wire [31:0] rd1,
    output wire [31:0] rd2,
    input  wire        we,          // RegWrite (already combined with ce)
    input  wire [4:0]  rd,          // write port
    input  wire [31:0] wd
);
    reg [31:0] bank1 [0:31];
    reg [31:0] bank2 [0:31];
    reg [31:0] q1, q2;
    reg        zero1, zero2;        // was register x0 selected?

    always @(posedge clk) begin     // read: synchronous -> block RAM
        q1    <= bank1[rs1];
        q2    <= bank2[rs2];
        zero1 <= (rs1 == 0);
        zero2 <= (rs2 == 0);
    end

    always @(posedge clk)           // write
        if (we && rd != 0) begin
            bank1[rd] <= wd;
            bank2[rd] <= wd;
        end

    assign rd1 = zero1 ? 32'd0 : q1;    // x0 always reads as 0
    assign rd2 = zero2 ? 32'd0 : q2;
endmodule
