`timescale 1ns / 1ps

module seq101_tb;
    reg  clk = 0;
    reg  rst = 1;
    reg  x   = 0;
    wire z_mealy, z_moore;

    // input sequence, sent from left to right
    localparam [11:0] PATTERN = 12'b1010_1101_0010;
    integer i;

    seq101_mealy mealy (.clk(clk), .rst(rst), .x(x), .z(z_mealy));
    seq101_moore moore (.clk(clk), .rst(rst), .x(x), .z(z_moore));

    // clock: period 10 ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("seq101.vcd");
        $dumpvars(0, seq101_tb);
        #12 rst = 0;
        for (i = 11; i >= 0; i = i - 1) begin
            x = PATTERN[i];
            #10;
        end
        x = 0;
        #20;
        $finish;
    end

    // sample input and outputs at every rising clock edge,
    // before the state registers take over their new value
    always @(posedge clk)
        if (!rst)
            $display("t=%0d ns  x=%b  z_mealy=%b z_moore=%b", $time, x, z_mealy, z_moore);
endmodule
