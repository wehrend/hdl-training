// The 7-segment decoder from chapter 23 on real hardware.
// The four buttons form a 4-bit number (button 1 = bit 0), the right display shows it as a hex digit.
// The Go Board's segments are active low (0 = segment on), so the outputs of the decoder are inverted.
module hex_display (
    input  wire i_Switch_1,
    input  wire i_Switch_2,
    input  wire i_Switch_3,
    input  wire i_Switch_4,
    output wire o_Segment2_A,
    output wire o_Segment2_B,
    output wire o_Segment2_C,
    output wire o_Segment2_D,
    output wire o_Segment2_E,
    output wire o_Segment2_F,
    output wire o_Segment2_G
);
    wire [3:0] value = {i_Switch_4, i_Switch_3, i_Switch_2, i_Switch_1};
    wire [6:0] seg;                                  // {g, f, e, d, c, b, a}, 1 = on

    seven_seg dec (.value(value), .seg(seg));

    assign {o_Segment2_G, o_Segment2_F, o_Segment2_E, o_Segment2_D,
            o_Segment2_C, o_Segment2_B, o_Segment2_A} = ~seg;
endmodule
