/**
 * @file cdma_transmitter.sv
 * @author Geeoon Chung
 * @brief combines data with the code
 * @param PRN           the PRN signal number
 * @param[in] clk       the clock driving the sequential logic
 * @param[in] rst       the synchronous reset
 * @param[in] en        the enable signal to generate the next code
 * @param[out] code     the output code
 */

module cdma_transmitter #(
    parameter int PRN=1
) (
    input logic clk,
    input logic rst,
    input logic en,

    output logic code
);
    assign code = get_g2_taps(g2_state) ^ g1_state[9];
endmodule  // lfsr_code
