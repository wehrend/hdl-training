// Logarithmic barrel shifter: shifts by any amount in log2(WIDTH) stages.
// op = 00: sll (shift left logical)
// op = 01: srl (shift right logical)
// op = 11: sra (shift right arithmetic, fills with the sign bit)
module barrel_shifter #(
    parameter WIDTH = 8,
    parameter LOG2W = 3          // number of stages = bits of the shift amount
) (
    input  wire [WIDTH-1:0] a,
    input  wire [LOG2W-1:0] shamt,
    input  wire [1:0]       op,
    output wire [WIDTH-1:0] y
);
    wire left = (op == 2'b00);
    wire fill = op[1] & a[WIDTH-1];   // sra: sign bit, otherwise 0

    // a left shift is a right shift of the bit-reversed word
    wire [WIDTH-1:0] a_rev, y_rev;
    wire [WIDTH-1:0] stage [0:LOG2W];

    genvar i, s;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : reverse
            assign a_rev[i] = a[WIDTH-1-i];
            assign y_rev[i] = stage[LOG2W][WIDTH-1-i];
        end

        assign stage[0] = left ? a_rev : a;

        // stage s shifts by 2^s, if bit s of the shift amount is set
        for (s = 0; s < LOG2W; s = s + 1) begin : shift_stage
            assign stage[s+1] = shamt[s]
                ? { {(1<<s){fill}}, stage[s][WIDTH-1:(1<<s)] }
                : stage[s];
        end
    endgenerate

    assign y = left ? y_rev : stage[LOG2W];
endmodule
