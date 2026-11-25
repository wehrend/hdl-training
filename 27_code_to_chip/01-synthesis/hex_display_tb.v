`timescale 1ns / 1ps

// Testbench for hex_display: all 16 button combinations, checked against the decoder table.
module hex_display_tb;
    reg  [3:0] sw;
    wire a, b, c, d, e, f, g;
    reg  [6:0] expected;
    integer i, errors = 0;

    hex_display dut (
        .i_Switch_1(sw[0]), .i_Switch_2(sw[1]), .i_Switch_3(sw[2]), .i_Switch_4(sw[3]),
        .o_Segment2_A(a), .o_Segment2_B(b), .o_Segment2_C(c), .o_Segment2_D(d),
        .o_Segment2_E(e), .o_Segment2_F(f), .o_Segment2_G(g)
    );

    initial begin
        for (i = 0; i < 16; i = i + 1) begin
            sw = i;
            #10;
            case (i)                              // {g,f,e,d,c,b,a}, 1 = on (table from chapter 23)
                0: expected = 7'b0111111;  1: expected = 7'b0000110;
                2: expected = 7'b1011011;  3: expected = 7'b1001111;
                4: expected = 7'b1100110;  5: expected = 7'b1101101;
                6: expected = 7'b1111101;  7: expected = 7'b0000111;
                8: expected = 7'b1111111;  9: expected = 7'b1101111;
               10: expected = 7'b1110111; 11: expected = 7'b1111100;
               12: expected = 7'b0111001; 13: expected = 7'b1011110;
               14: expected = 7'b1111001; 15: expected = 7'b1110001;
            endcase
            if ({g, f, e, d, c, b, a} !== ~expected) errors = errors + 1;
            $display("buttons %b  pins gfedcba = %b%b%b%b%b%b%b", sw, g, f, e, d, c, b, a);
        end
        if (errors == 0) $display("PASSED: all 16 digits (pins are active low)");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
