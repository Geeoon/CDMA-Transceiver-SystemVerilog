/**
 * @file multiplier.sv
 * @author Geeoon Chung
 * @brief element-wise multiplication of two signals with samples of 1-bit in
 *          depth
 * @param SIGNAL_LENGTH     the length of the signal in terms of number of samples
 * @param XNOR              0 to perform an AND, 1 to perform XNOR
 * @param[in] signal_1      the first operand
 * @param[in] signal_2      the second operand
 * @param[out] out          the result
 */
module multiplier #(
    parameter int SIGNAL_LENGTH,
    parameter bit XNOR=0
)(
    input logic [SIGNAL_LENGTH-1:0]     signal_1,
    input logic [SIGNAL_LENGTH-1:0]     signal_2,

    output logic [SIGNAL_LENGTH-1:0]    out
);
    if (XNOR == 0) begin
        assign out = signal_1 & signal_2;
    end begin
        assign out = signal_1 ~^ signal_2;
    end
endmodule  // multiplier
