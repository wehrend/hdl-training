// detects the bit sequence 101 (overlapping) - Moore machine
// the output depends only on the state
module seq101_moore (
    input  wire clk,
    input  wire rst,
    input  wire x,
    output wire z
);
    localparam S0 = 2'd0;   // nothing useful received
    localparam S1 = 2'd1;   // received ...1
    localparam S2 = 2'd2;   // received ...10
    localparam S3 = 2'd3;   // received ...101

    reg [1:0] state, next;

    always @(posedge clk) begin
        if (rst)
            state <= S0;
        else
            state <= next;
    end

    always @(*) begin
        case (state)
            S0:      next = x ? S1 : S0;
            S1:      next = x ? S1 : S2;
            S2:      next = x ? S3 : S0;
            S3:      next = x ? S1 : S2;
            default: next = S0;
        endcase
    end

    assign z = (state == S3);
endmodule
