// Top module for the Nandland Go Board: the CPU from chapter 26 on the iCE40 HX1K.
//
//  - clock enable: the CPU executes CE_DIV-th clock cycle one instruction.
//    With CE_DIV = 6,250,000: 4 instructions per second at 25 MHz.
//  - reset: automatically after power-up, and while button 1 is pressed.
//  - output: the lowest byte of register x1 as two hex digits on the 7-segment displays,
//    the instruction number (PC / 4) on the four LEDs.
module go_board_top #(
    parameter CE_DIV = 6_250_000          // must be at least 2, see regfile.v
) (
    input  wire i_Clk,                    // 25 MHz
    input  wire i_Switch_1,               // reset
    output wire o_LED_1,
    output wire o_LED_2,
    output wire o_LED_3,
    output wire o_LED_4,
    output wire o_Segment1_A, o_Segment1_B, o_Segment1_C, o_Segment1_D,
    output wire o_Segment1_E, o_Segment1_F, o_Segment1_G,
    output wire o_Segment2_A, o_Segment2_B, o_Segment2_C, o_Segment2_D,
    output wire o_Segment2_E, o_Segment2_F, o_Segment2_G
);
    // ---- reset ------------------------------------------------------------------
    // The button is not synchronous to the clock: two flip-flops in a row (synchronizer)
    // keep a metastable state away from the rest of the circuit.
    reg [1:0] sw_sync = 2'b00;
    always @(posedge i_Clk)
        sw_sync <= {sw_sync[0], i_Switch_1};

    // power-on reset: the first 15 clock cycles after configuration
    reg [3:0] por = 4'd0;
    always @(posedge i_Clk)
        if (por != 4'd15) por <= por + 1;

    wire rst = (por != 4'd15) | sw_sync[1];

    // ---- clock enable ---------------------------------------------------------------
    // Instead of a slower clock, ce is 1 for exactly one cycle every CE_DIV cycles.
    // The whole design runs on the 25 MHz clock, which stays on the global clock network.
    reg [$clog2(CE_DIV)-1:0] div = 0;
    reg                      ce  = 1'b0;
    always @(posedge i_Clk)
        if (div == CE_DIV - 1) begin div <= 0;       ce <= 1'b1; end
        else                   begin div <= div + 1; ce <= 1'b0; end

    // ---- CPU --------------------------------------------------------------------------
    wire [31:0] pc, x1;

    cpu #(.PROGRAM("program.hex")) cpu (
        .clk(i_Clk), .rst(rst), .ce(ce), .dbg_pc(pc), .dbg_x1(x1)
    );

    // ---- output -------------------------------------------------------------------------
    assign {o_LED_4, o_LED_3, o_LED_2, o_LED_1} = pc[5:2];       // instruction number 0..6

    wire [6:0] seg_hi, seg_lo;                                   // {g,f,e,d,c,b,a}, 1 = on
    seven_seg dec_hi (.value(x1[7:4]), .seg(seg_hi));
    seven_seg dec_lo (.value(x1[3:0]), .seg(seg_lo));

    // the segments of the Go Board are active low
    assign {o_Segment1_G, o_Segment1_F, o_Segment1_E, o_Segment1_D,
            o_Segment1_C, o_Segment1_B, o_Segment1_A} = ~seg_hi;
    assign {o_Segment2_G, o_Segment2_F, o_Segment2_E, o_Segment2_D,
            o_Segment2_C, o_Segment2_B, o_Segment2_A} = ~seg_lo;
endmodule
