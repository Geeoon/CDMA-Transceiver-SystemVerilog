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
 * @param[out] bit          whether the kernel has been fully loaded
 * @param[out] acquired     whether it's possible to shift on this cycle
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
    output logic acquired
);
    logic shift_on, shift_early, shift_late, start_timer;
    logic shiftable, valids, in_range, done;
    cdma_receiver_ctrl cdma_receiver_ctrl_m (
        .clk,
        .rst,
        .shiftable,
        .valids,
        .in_range,
        .done,

        .shift_on,
        .shift_early,
        .shift_late,
        .start_timer
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

        .shift_on,
        .shift_early,
        .shift_late,
        .start_timer,

        .shiftable,
        .valids,
        .in_range,
        .done,

        .output_bit(out),
        .output_valid(acquired)
    );
endmodule  // cdma_receiver
