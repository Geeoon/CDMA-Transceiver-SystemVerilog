/**
 * @file cdma_receiver.sv
 * @author Geeoon Chung
 * @brief receives a CDMA bit
 * @param PRN               the PRN from 1-37
 * @param CODE_LENGTH       the length of the code (epoch)
 * @param OVERSAMPLING      the resolution of the acquisition (2 means 1/2 chip resolution)
 * @param CLOCK_FREQ        the frequency of \p clk in Hz
 * @param CHIP_FREQ         the chip rate in Hz
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           the active HIGH reset signal
 * @param[in] signal        the incoming signal coming in at the clock frequency
 * @param[out] bit          the bit that is detected
 * @param[out] acquired     whether or not the signal has been acquired
 * @param[out] valid        whether or not \p bit is valid
 */

module cdma_receiver #(
    parameter int PRN=1,
    parameter int CODE_LENGTH=1023,
    parameter int OVERSAMPLING=2,
    parameter int CLOCK_FREQ=163_680_000,
    parameter int CHIP_FREQ=1023
) (
    input logic clk,
    input logic rst,
    input logic signal,

    output logic out,
    output logic acquired,
    output logic valid
);
    logic lshift_on, lshift_early, lshift_late;
    logic rshift_on, rshift_early, rshift_late;
    logic start_timer, lshiftable, rshiftable, valids, lbias, rbias, in_range, done;
    logic cycled;
    cdma_receiver_ctrl cdma_receiver_ctrl_m (
        .clk,
        .rst,
        .lshiftable,
        .rshiftable,
        .valids,
        .in_range,
        .lbias,
        .rbias,
        .done,
        .cycled,

        .lshift_on,
        .lshift_early,
        .lshift_late,
        .rshift_on,
        .rshift_early,
        .rshift_late,
        .start_timer,
        .acquired
    );

    cdma_receiver_data #(
        .PRN(PRN),
        .CODE_LENGTH(CODE_LENGTH),
        .OVERSAMPLING(OVERSAMPLING),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ)
    ) cdma_receiver_data_m (
        .clk,
        .rst,
        .signal,

        .lshift_on,
        .lshift_early,
        .lshift_late,
        .rshift_on,
        .rshift_early,
        .rshift_late,
        .start_timer,

        .lshiftable,
        .rshiftable,
        .valids,
        .in_range,
        .lbias,
        .rbias,
        .done,

        .output_bit(out),
        .cycled
    );
    assign valid = acquired & cycled;
endmodule  // cdma_receiver
