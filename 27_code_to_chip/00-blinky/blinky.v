// Blinky - the "hello world" of FPGAs.
// A free-running counter divides the 25 MHz clock of the Go Board.
// The four highest bits drive the four LEDs: they show a binary counter.
// With WIDTH = 24, the highest bit toggles every 2^23 clock cycles,
// so LED 4 is on for 0.34 s and off for 0.34 s.
module blinky #(
    parameter WIDTH = 24
) (
    input  wire i_Clk,
    output wire o_LED_1,
    output wire o_LED_2,
    output wire o_LED_3,
    output wire o_LED_4
);
    reg [WIDTH-1:0] count = 0;          // initial value: the iCE40 starts with 0

    always @(posedge i_Clk)
        count <= count + 1;

    assign {o_LED_4, o_LED_3, o_LED_2, o_LED_1} = count[WIDTH-1 -: 4];
endmodule
