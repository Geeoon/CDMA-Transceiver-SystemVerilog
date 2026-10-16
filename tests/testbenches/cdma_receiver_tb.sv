/**
 * @file cdma_receiver_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the cdma_receiver module
 */

module cdma_receiver_tb #(
    parameter CLOCK_PERIOD=100,
    parameter int PRN=1,
    parameter int CODE_LENGTH=1023,
    parameter int OVERSAMPLING=4,
    parameter int CLOCK_FREQ=8,
    parameter int CHIP_FREQ=1,

    localparam int DIV_FREQ=CLOCK_FREQ/(CHIP_FREQ*OVERSAMPLING),
    localparam int LAYERS=1+$clog2(CODE_LENGTH*OVERSAMPLING)
) ();
    // inputs
    // outputs

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    initial begin
        // dump waveforms
        $dumpfile("waveforms/cdma_correlator_tb.vcd");
        $dumpvars;

        $display(" -- Starting cdma_receiver test -- ");
        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // cdma_correlator_tb
