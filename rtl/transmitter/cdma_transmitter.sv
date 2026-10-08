/**
 * @file cdma_transmitter.sv
 * @author Geeoon Chung
 * @brief combines data with the code using short codes
 * @param PRN           set between 1-37 to use Gold codes
 * @param CLOCK_FREQ    the frequency of the clock in Hz
 * @param CHIRP_FREQ    the frequency of the chirps in Hz
 * @param N             the number of repetitions of the code
 * @param[in] clk       the clock driving the sequential logic
 * @param[in] rst       the synchronous reset
 * @param[in] data      the data bit to code
 * @param[out] code     the baseband bit. to be modulated and sent
 * @param[out] done     whether the code is the final coded bit for the \p data
 */

module cdma_transmitter #(
    parameter int PRN=1,
    parameter int CLOCK_FREQ=163_680_000,
    parameter int CHIRP_FREQ=1023,
    parameter int N=20,

    localparam int DIV_FREQ=CLOCK_FREQ/CHIRP_FREQ
) (
    input logic clk,
    input logic rst,
    input logic data,

    output logic code,
    output logic done
);
    if ((CLOCK_FREQ % CHIRP_FREQ) != 0) $error("The clock frequency needs to be a multiple of the chirp frequency");
    // SUBMODULES
    // intermediate signals
    logic en;
    logic cycled;
    logic code_chirp;

    // done generator
    lfsr_timer #(
        .COUNT(N)
    ) counter_m (
        .clk,
        .rst,
        .en(cycled & en),

        .done
    );

    // enable generator
    lfsr_timer #(
        .COUNT(DIV_FREQ-1)
    ) enable_gen_m (
        .clk,
        .rst(rst | en),
        .en(1),

        .done(en)
    );

    // code generator(s):
    gold_code #(
        .PRN(PRN)
    ) gold_code_m (
        .clk,
        .rst,
        .en,

        .code(code_chirp),
        .cycled
    );

    assign code = code_chirp ^ data;
endmodule  // cdma_transmitter
