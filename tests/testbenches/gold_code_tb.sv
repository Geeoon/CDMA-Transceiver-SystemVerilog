/**
 * @file gold_code_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the timer module
 */

module gold_code_tb #(
    parameter CLOCK_PERIOD=100,
    parameter int PRN=1
) ();
    // inputs
    logic clk;
    logic rst;
    logic en;

    // outputs
    logic code;

    gold_code #(
        .PRN(PRN)
    ) dut (
        .clk,
        .rst,
        .en,

        .code
    );

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    int chips = 0;
    initial begin
        // dump waveforms
        $dumpfile("waveforms/gold_code_tb.vcd");
        $dumpvars;

        $display(" -- Starting gold_code test -- ");
        rst = 1;
        en = 0;
        @(posedge clk); #5;
        rst = 0;
        en = 1;
        $display(" -- Testing PRN 1 with Chip Code Octal 1440 -- ");
        repeat(10) begin
            chips = (chips << 1) | 32'(code);
            @(posedge clk); #5;
        end
        $display("%o >= %o", chips, 'o1440);
        assert(chips == 'o1440);
        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // gold_code_tb
