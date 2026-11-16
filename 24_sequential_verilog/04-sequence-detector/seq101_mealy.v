// detects the bit sequence 101 (overlapping) - Mealy machine
// the output depends on the state AND the input
module seq101_mealy (
    input  wire clk,
    input  wire rst,
    input  wire x,
    output reg  z
);
    localparam S0 = 2'd0;   // nothing useful received
    localparam S1 = 2'd1;   // received ...1
    localparam S2 = 2'd2;   // received ...10

    reg [1:0] state, next;

    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next;
    end

    always @(*) begin
        next = S0;
        z    = 1'b0;
        case (state)
            S0: next = x ? S1 : S0;
            S1: next = x ? S1 : S2;
            S2: begin
                    next = x ? S1 : S0;
                    z    = x;            // 1 0 1 complete
                end
            default: next = S0;
        endcase
    end
endmodule
