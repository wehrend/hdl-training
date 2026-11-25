`timescale 1ns / 1ps

// Testbench for blinky: with WIDTH = 6 instead of 24, the LEDs change every 4 clock cycles,
// so we can watch them in simulation (with 24 bits we would wait millions of cycles).
module blinky_tb;
    reg  clk = 0;
    wire led1, led2, led3, led4;
    integer i, errors = 0;

    always #20 clk = ~clk;              // 25 MHz: period 40 ns

    blinky #(.WIDTH(6)) dut (
        .i_Clk(clk), .o_LED_1(led1), .o_LED_2(led2), .o_LED_3(led3), .o_LED_4(led4)
    );

    initial begin
        $dumpfile("blinky.vcd");
        $dumpvars(0, blinky_tb);
        for (i = 1; i <= 64; i = i + 1) begin
            @(posedge clk); #1;
            if ({led4, led3, led2, led1} !== i[5:2]) errors = errors + 1;
            if (i % 4 == 0) $display("cycle %2d  LEDs (4..1) = %b%b%b%b", i, led4, led3, led2, led1);
        end
        if (errors == 0) $display("PASSED: LEDs show bits 5..2 of the counter");
        else             $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
