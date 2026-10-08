/**
 * @file cdma_transmitter_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the cmda_transmitter module
 */

module cdma_transmitter_tb #(
    parameter CLOCK_PERIOD=100
) ();
    // inputs
    logic clk;
    logic rst;
    logic data;

    // outputs
    logic code [1:37];
    logic done [1:37];

    for (genvar PRN = 1; PRN <= 37; PRN++) begin
        cdma_transmitter #(
            .PRN(PRN),
            .CLOCK_FREQ(2),
            .CHIRP_FREQ(1),
            .N(20)
        ) dut (
            .clk,
            .rst,
            .data,
            
            .code(code[PRN]),
            .done(done[PRN])
        );
    end

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    initial begin
        // dump waveforms
        $dumpfile("waveforms/cdma_transmitter_tb.vcd");
        $dumpvars;

        $display(" -- Starting cdma_transmitter test -- ");
        rst = 1;
        data = 1;
        @(posedge clk); #5;
        rst = 0;

        $display(" -- Letting it run for 1 HIGH bit -- ");
        repeat(1023*20) begin
            @(posedge clk); #5;
        end

        $display(" -- Letting it run for 1 LOW bit -- ");
        data = 0;
        repeat(1023*20) begin
            @(posedge clk); #5;
        end

        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // cdma_transmitter_tb
