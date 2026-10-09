/**
 * @file lfsr_timer_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the lfsr_timer module
 */

module lfsr_timer_tb #(
    parameter int COUNT=2,
    parameter int CLOCK_PERIOD=100
) ();
    // inputs
    logic clk, rst, en;

    // outputs
    logic done;

    lfsr_timer #(
        .COUNT(COUNT)
    ) dut (
        .clk, .rst, .en,
        .done
    );

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    initial begin
        // dump waveforms
        $dumpfile("waveforms/lfsr_timer_tb.vcd");
        $dumpvars;

        $display(" -- Starting lfsr_timer test -- ");
        repeat(10) begin
            // start timer
            rst = 1;
            en = 1;
            @(posedge clk); #5;
            rst = 0;

            // there should be COUNT cycles before the signal is high
            repeat(COUNT) begin
                assert(~done);
                @(posedge clk); #5;
            end  // repeat

            repeat(10) begin
                assert(done);
                @(posedge clk); #5;
            end  // repeat
        end  // repeat
        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // lfsr_timer_tb
