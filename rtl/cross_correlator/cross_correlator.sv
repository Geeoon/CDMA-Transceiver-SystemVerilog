/**
 * @file cross_correlator.sv
 * @author Geeoon Chung
 * @brief performs a cross correlation on a 1-bit input stream and kernel
 * @param KERNEL_LENGTH     the length of the kernel
 * @param LUT_SIZE          the size of the LUTs on the target system. you can set
 *                              this to 2 for a binary tree structure.
 * @param ADDER_SIZE        the size of the adders on the target system. you can
 *                              set this to 2 for a binary tree structure.
 * @param CONVOLVE          set to 1'b1 to do a convolution instead of correlation
 *                          (i.e., flip the kernel)
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] start         the signal to start the correlation
 * @param[in] signal_in     the streamed sample bit
 * @param[in] kernel        the kernel to convolve with
 * @param[out] valid        whether or output is valid
 * @param[out] out          the result
 */ 
module cross_correlator #(
    parameter int KERNEL_LENGTH,
    parameter int LUT_SIZE=6,
    parameter int ADDER_SIZE=3,
    parameter bit CONVOLVE=1'b0
)(
    input logic                                 clk,
    input logic                                 rst,
    input logic                                 signal_in,
    input logic [KERNEL_LENGTH-1:0]             kernel,
    input logic                                 en,

    output logic                                valid,
    output logic [$clog2(KERNEL_LENGTH+1)-1:0]  out
);
    // -- SUBMODULES --
    // INPUT SHIFTER
    // intermediate signals
    logic filled;
    logic [KERNEL_LENGTH-1:0] signal;
    input_shifter #(
        .KERNEL_LENGTH(KERNEL_LENGTH),
        .CONVOLVE(CONVOLVE)
    ) input_shifter_m (
        // inputs
        .clk,
        .rst,
        .signal_in,
        .en,
        
        // outputs
        .filled,
        .signal
    );
    
    // MULTIPLIER
    // intermediate signals
    logic [KERNEL_LENGTH-1:0] multiplier_out;
    multiplier #(
        .SIGNAL_LENGTH(KERNEL_LENGTH),
        .XNOR(1)
    ) multiplier_m (
        // inputs
        .signal_1(signal),
        .signal_2(kernel),

        // outputs
        .out(multiplier_out)
    );

    // ADDER
   popcount #(
        .IN_LENGTH(KERNEL_LENGTH),
        .LUT_SIZE(6),
        .ADDER_SIZE(3)
   ) adder_m (
        // inputs
        .clk,
        .start(filled),
        .in_arr(multiplier_out),

        // outputs
        .out_arr(out),
        .valid
    );
endmodule  // cross_correlator
