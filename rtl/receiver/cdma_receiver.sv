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
    parameter int CHIP_FREQ=1023,

    localparam int CORRELATOR_BIT_WIDTH=$clog2(CODE_LENGTH*OVERSAMPLING+1)
) (
    input logic clk,
    input logic rst,
    input logic signal,

    output logic out,
    output logic acquired
);
    // cdma_correlator #(
    //     .PRN(PRN),
    //     .CODE_LENGTH(CODE_LENGTH),
    //     .OVERSAMPLING(OVERSAMPLING),
    //     .CLOCK_FREQ(CLOCK_FREQ),
    //     .CHIP_FREQ(CHIP_FREQ)
    // ) correlator_on_m (
    //     .clk,
    //     .rst,
    //     .signal,
    //     .shift,

    //     .out,
    //     .valid,
    //     .shiftable
    // );

    // cdma_correlator #(
    //     .PRN(PRN),
    //     .CODE_LENGTH(CODE_LENGTH),
    //     .OVERSAMPLING(OVERSAMPLING),
    //     .CLOCK_FREQ(CLOCK_FREQ),
    //     .CHIP_FREQ(CHIP_FREQ)
    // ) correlator_early_m (
    //     .clk,
    //     .rst,
    //     .signal,
    //     .shift,

    //     .out,
    //     .valid,
    //     .shiftable
    // );

    // cdma_correlator #(
    //     .PRN(PRN),
    //     .CODE_LENGTH(CODE_LENGTH),
    //     .OVERSAMPLING(OVERSAMPLING),
    //     .CLOCK_FREQ(CLOCK_FREQ),
    //     .CHIP_FREQ(CHIP_FREQ)
    // ) correlator_late_m (
    //     .clk,
    //     .rst,
    //     .signal,
    //     .shift,

    //     .out,
    //     .valid,
    //     .shiftable
    // );

endmodule  // cdma_receiver
