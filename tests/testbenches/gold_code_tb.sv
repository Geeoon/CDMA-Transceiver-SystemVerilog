/**
 * @file gold_code_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the timer module
 */

module gold_code_tb #(
    parameter CLOCK_PERIOD=100
) ();
    // inputs
    logic clk;
    logic rst;
    logic en;

    // outputs
    logic code [1:37];

    int chips [1:37] = '{default: 0};
    int real_chips [1:37] = {
        'o1440,
        'o1620,
        'o1710,
        'o1744,
        'o1133,
        'o1455,
        'o1131,
        'o1454,
        'o1626,
        'o1504,
        'o1642,
        'o1750,
        'o1764,
        'o1772,
        'o1775,
        'o1776,
        'o1156,
        'o1467,
        'o1633,
        'o1715,
        'o1746,
        'o1763,
        'o1063,
        'o1706,
        'o1743,
        'o1761,
        'o1770,
        'o1774,
        'o1127,
        'o1453,
        'o1625,
        'o1712,
        'o1745,
        'o1713,
        'o1134,
        'o1456,
        'o1713
    };

    for (genvar PRN = 1; PRN <= 37; PRN++) begin
        gold_code #(
            .PRN(PRN)
        ) dut (
            .clk,
            .rst,
            .en,

            .code(code[PRN])
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
        $dumpfile("waveforms/gold_code_tb.vcd");
        $dumpvars;

        $display(" -- Starting gold_code test -- ");
        rst = 1;
        en = 0;
        @(posedge clk); #5;
        rst = 0;
        en = 1;
        $display(" -- Testing the first 10 chips for PRNs 1-37 -- ");
        repeat(10) begin
            for (int i = 1; i <= 37; i++) begin
                chips[i] = (chips[i] << 1) | 32'(code[i]);
            end
            @(posedge clk); #5;
        end
        for (int i = 1; i <= 37; i++) begin
            $display("PRN %2d: %0o ?= %0o", i, chips[i], real_chips[i]);
            assert(chips[i] == real_chips[i]);
        end
        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // gold_code_tb
