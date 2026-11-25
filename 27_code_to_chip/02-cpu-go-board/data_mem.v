// Data memory: 8 words (chapter 26: 64 words).
// Reading is combinational (MemRead), writing happens on the rising clock edge (MemWrite).
// With a combinational read, the memory cannot be mapped to block RAM, so it is built from
// flip-flops. 8 words are enough for our counter program, which only uses address 4.
module data_mem (
    input  wire        clk,
    input  wire [31:0] addr,
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [31:0] wd,
    output wire [31:0] rd
);
    reg [31:0] mem [0:7];

    integer i;
    initial for (i = 0; i < 8; i = i + 1) mem[i] = 0;    // initial values work on the iCE40, too

    assign rd = mem_read ? mem[addr[4:2]] : 32'd0;

    always @(posedge clk)
        if (mem_write)
            mem[addr[4:2]] <= wd;
endmodule
