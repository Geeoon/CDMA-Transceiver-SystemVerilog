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

    logic correct_code [1:37];
    logic chirps [1:37];
    logic code_enable;

    for (genvar PRN = 1; PRN <= 37; PRN++) begin
        cdma_transmitter #(
            .PRN(PRN),
            .CLOCK_FREQ(2),
            .CHIRP_FREQ(1),
            .N(N)
        ) dut (
            .clk,
            .rst,
            .data,
            
            .code(code[PRN]),
            .done(done[PRN])
        );

        gold_code #(
            .PRN(PRN)
        ) correct_code_m (
            .clk,
            .rst,
            .en(code_enable),

            .code(correct_code),
            .cycled()
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
        en = 0;
        data = 1;
        @(posedge clk); #5;
        rst = 0;

        $display(" -- Testing all 1 data bits -- ");


        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // cdma_transmitter_tb
