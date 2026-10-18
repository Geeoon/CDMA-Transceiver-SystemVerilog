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
    parameter int CHIP_FREQ=1,

    localparam int DIV_FREQ=CLOCK_FREQ/(CHIP_FREQ*OVERSAMPLING),
    localparam int LAYERS=1+$clog2(CODE_LENGTH*OVERSAMPLING)
) ();
    // inputs
    logic clk;
    logic rst;
    logic signal;
    logic lshift, rshift;

    // outputs
    logic [$clog2(CODE_LENGTH*OVERSAMPLING+1)-1:0] out;
    logic valid;
    logic lshiftable, rshiftable;
    logic cycled;

    logic data;

    logic done;
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
        .done
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
        .lshift,
        .rshift,
        
        .out,
        .valid,
        .lshiftable,
        .rshiftable,
        .cycled
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
        lshift = 0;
        rshift = 0;
        @(posedge clk); #5;
        rst = 0;

        @(posedge done); #5;
        repeat(LAYERS) begin
            @(posedge clk); #5;
        end

        repeat(DIV_FREQ*OVERSAMPLING*4) begin
            $display("In-phase: %d", out);
            assert(int'(out) == CODE_LENGTH*OVERSAMPLING);
            @(posedge clk); #5;
        end

        repeat(CODE_LENGTH*OVERSAMPLING) begin
            @(posedge lshiftable); #5;
            lshift = 1;
            @(posedge clk); #5;
            lshift = 0;
            repeat(LAYERS) begin
                @(posedge clk); #5;
            end
            $display("Correlation: %d", out);
            $display("signal: %b", dut.correlator_m.signal[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
            $display("kernel: %b", dut.correlator_m.kernel[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
        end

        repeat(DIV_FREQ*OVERSAMPLING*4) begin
            $display("In-phase: %d", out);
            assert(int'(out) == CODE_LENGTH*OVERSAMPLING);
            @(posedge clk); #5;
        end
        repeat(CODE_LENGTH*OVERSAMPLING) begin
            @(posedge rshiftable); #5;
            rshift = 1;
            @(posedge clk); #5;
            rshift = 0;
            repeat(LAYERS) begin
                @(posedge clk); #5;
            end
            $display("Correlation: %d", out);
            $display("signal: %b", dut.correlator_m.signal[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
            $display("kernel: %b", dut.correlator_m.kernel[CODE_LENGTH*OVERSAMPLING-1:CODE_LENGTH*OVERSAMPLING-8]);
        end
        assert(int'(out) == CODE_LENGTH*OVERSAMPLING);
        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // cdma_correlator_tb
