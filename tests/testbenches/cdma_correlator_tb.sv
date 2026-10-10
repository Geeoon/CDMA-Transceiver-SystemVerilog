/**
 * @file cdma_correlator_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the cdma_correlator module
 */

module cdma_correlator_tb #(
    parameter CLOCK_PERIOD=100,
    parameter int PRN=1,
    parameter int CODE_LENGTH=1023,
    parameter int OVERSAMPLING=4,
    parameter int CLOCK_FREQ=8,
    parameter int CHIP_FREQ=1
) ();
    // inputs
    logic clk;
    logic rst;
    logic signal;
    logic shift;

    // outputs
    logic [$clog2(CODE_LENGTH*OVERSAMPLING+1)-1:0] out;
    logic valid;
    logic shiftable;

    logic data;

    cdma_transmitter #(
        .PRN(PRN),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ),
        .N(20)
    ) signal_generator (
        .clk,
        .rst,
        .data,
        
        .code(signal),
        .done()
    );

    cdma_correlator #(
        .PRN(PRN),
        .CODE_LENGTH(CODE_LENGTH),
        .OVERSAMPLING(OVERSAMPLING),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ)
    ) dut (
        .clk,
        .rst,
        .signal,
        .shift,
        
        .out,
        .valid,
        .shiftable
    );

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

        $display(" -- Starting cdma_correlator test -- ");
        rst = 1;
        data = 0;
        shift = 0;
        @(posedge clk); #5;
        rst = 0;

        repeat(1023*4) begin
            @(posedge clk); #5;
        end

        repeat(16) begin
            $display(" -- -- -- -- ");
            $display("dut.correlator_m.signal: %b", dut.correlator_m.signal[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
            $display("dut.correlator_m.kernel: %b", dut.correlator_m.kernel[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
            $display("dut.code_enable_gen_m.done: %b. dut.code_en: %b. dut.sample_en: %b", dut.code_enable_gen_m.done, dut.code_en, dut.sample_en );
            @(posedge clk); #5;
        end

        repeat(10) begin
            $display("In-phase: %d", out);
            assert(int'(out) == CODE_LENGTH*OVERSAMPLING);
            @(posedge clk); #5;
        end

        for (int i = 1; i < 25; i++) begin
            shift = shiftable;
            $display(" -- -- -- -- ");
            $display("dut.correlator_m.signal: %b", dut.correlator_m.signal[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
            $display("dut.correlator_m.kernel: %b", dut.correlator_m.kernel[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
            $display("dut.code_enable_gen_m.done: %b. dut.code_en: %b", dut.code_enable_gen_m.done, dut.code_en );
            // if (out > 1000) begin
            //     $display("%d/2 chips off: %d", i, out);
            // end
            @(posedge clk); #5;

        end

        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // cdma_correlator_tb
