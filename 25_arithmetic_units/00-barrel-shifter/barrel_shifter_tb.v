`timescale 1ns / 1ps

// Exhaustive test: all 256 values, all 8 shift amounts, all 3 operations,
// compared against the Verilog shift operators <<, >> and >>>.
module barrel_shifter_tb;
    reg  [7:0] a;
    reg  [2:0] shamt;
    reg  [1:0] op;
    wire [7:0] y;
    reg  [7:0] expected;
    integer i, j, k, errors = 0, tests = 0;

    barrel_shifter #(.WIDTH(8), .LOG2W(3)) dut (.a(a), .shamt(shamt), .op(op), .y(y));

    initial begin
        // a few examples to read
        a = 8'b1001_0110;
        for (k = 0; k < 3; k = k + 1) begin
            op = (k == 2) ? 2'b11 : k;
            for (j = 0; j < 8; j = j + 3) begin
                shamt = j; #1;
                $display("%s %b by %0d = %b", k == 0 ? "sll" : k == 1 ? "srl" : "sra", a, shamt, y);
            end
        end

        // all combinations
        for (k = 0; k < 3; k = k + 1)
            for (i = 0; i < 256; i = i + 1)
                for (j = 0; j < 8; j = j + 1) begin
                    a = i; shamt = j; op = (k == 2) ? 2'b11 : k; #1;
                    case (op)
                        2'b00: expected = a << shamt;
                        2'b01: expected = a >> shamt;
                        2'b11: expected = $signed(a) >>> shamt;
                    endcase
                    tests = tests + 1;
                    if (y !== expected) begin
                        errors = errors + 1;
                        $display("ERROR: op=%b a=%b shamt=%0d y=%b expected=%b", op, a, shamt, y, expected);
                    end
                end

        if (errors == 0) $display("PASSED: %0d tests", tests);
        else             $display("FAILED: %0d of %0d tests", errors, tests);
        $finish;
    end
endmodule
