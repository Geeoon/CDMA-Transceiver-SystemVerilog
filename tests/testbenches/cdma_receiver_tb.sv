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
    parameter int CLOCK_FREQ=16,
    parameter int CHIP_FREQ=1,

    localparam int DIV_FREQ=CLOCK_FREQ/(CHIP_FREQ*OVERSAMPLING),
    localparam int LAYERS=1+$clog2(CODE_LENGTH*OVERSAMPLING)
) ();
    // inputs
    logic clk;
    logic rst;
    logic signal;

    // outputs
    logic out;
    logic acquired;


    logic tx_rst;
    logic data;
    cdma_transmitter #(
        .PRN(PRN),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ),
        .N(20)
    ) signal_generator (
        .clk,
        .rst(tx_rst),
        .data,
        
        .code(signal),
        .done()
    );

    cdma_receiver #(
        .PRN(PRN),
        .CODE_LENGTH(CODE_LENGTH),
        .OVERSAMPLING(OVERSAMPLING),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ)
    ) dut (
        .clk,
        .rst,
        .signal,

        .out,
        .acquired
    );

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    initial begin
        // dump waveforms
        $dumpfile("waveforms/cdma_receiver_tb.vcd");
        $dumpvars;
        // reset
        rst = 1;
        tx_rst = 1;
        data = 1;
        @(posedge clk); #5;
        rst = 0;
        repeat(100) begin
            @(posedge clk); #5;
        end
        tx_rst = 0;
        
        @(posedge acquired); #5;
        $display("Received bit: %b", out);
        data = 0;
        @(posedge acquired); #5;
        $display("Received bit: %b", out);

        $display(" -- Starting cdma_receiver test -- ");
        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // cdma_receiver_tb
