`timescale 1ns / 1ps

// Testbench for the complete Go Board design.
// CE_DIV = 4 instead of 6,250,000: one instruction every 4 clock cycles.
// The testbench prints one line per instruction and checks the result at the end:
// x1 = 10, the PC loops at 0x18, and the displays show "0A".
// The LEDs show the instruction number of the NEXT instruction (PC / 4).
module go_board_top_tb;
    reg  clk = 0, sw1 = 0;
    wire l1, l2, l3, l4;
    wire s1a, s1b, s1c, s1d, s1e, s1f, s1g;
    wire s2a, s2b, s2c, s2d, s2e, s2f, s2g;
    integer n = 0;
    reg [31:0] pc_now;

    always #20 clk = ~clk;                                   // 25 MHz

    go_board_top #(.CE_DIV(4)) dut (
        .i_Clk(clk), .i_Switch_1(sw1),
        .o_LED_1(l1), .o_LED_2(l2), .o_LED_3(l3), .o_LED_4(l4),
        .o_Segment1_A(s1a), .o_Segment1_B(s1b), .o_Segment1_C(s1c), .o_Segment1_D(s1d),
        .o_Segment1_E(s1e), .o_Segment1_F(s1f), .o_Segment1_G(s1g),
        .o_Segment2_A(s2a), .o_Segment2_B(s2b), .o_Segment2_C(s2c), .o_Segment2_D(s2d),
        .o_Segment2_E(s2e), .o_Segment2_F(s2f), .o_Segment2_G(s2g)
    );

    // one line per executed instruction (at every clock edge with ce = 1, after reset)
    always @(posedge clk)
        if (dut.ce && !dut.rst) begin
            n = n + 1;
            pc_now = dut.cpu.pc;                             // PC of the instruction executed now
            #1 $display("instruction %2d  PC=0x%02h  x1=%2d  -> LEDs show %b%b%b%b",
                        n, pc_now[7:0], dut.cpu.dbg_x1, l4, l3, l2, l1);
        end

    initial begin
        $dumpfile("go_board_top.vcd");
        $dumpvars(0, go_board_top_tb);
        #(40 * 4 * 40);                                      // 40 instructions
        $display("display: left gfedcba = %b%b%b%b%b%b%b, right gfedcba = %b%b%b%b%b%b%b (0 = on)",
                 s1g, s1f, s1e, s1d, s1c, s1b, s1a, s2g, s2f, s2e, s2d, s2c, s2b, s2a);
        if (dut.cpu.dbg_x1 == 10 && dut.cpu.pc == 32'h18 &&
            {s1g, s1f, s1e, s1d, s1c, s1b, s1a} == ~7'b0111111 &&     // "0"
            {s2g, s2f, s2e, s2d, s2c, s2b, s2a} == ~7'b1110111)       // "A"
            $display("PASSED: x1 = 10, display shows 0A, CPU loops at 0x18");
        else
            $display("FAILED: x1 = %0d, PC = 0x%h", dut.cpu.dbg_x1, dut.cpu.pc);
        $finish;
    end
endmodule
