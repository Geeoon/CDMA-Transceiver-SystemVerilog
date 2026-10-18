/**
 * @file cdma_correlator.sv
 * @author Geeoon Chung
 * @brief acquires and correlates the CDMA signal
 * @param PRN               the PRN from 1-37
 * @param CODE_LENGTH       the length of the code (epoch)
 * @param OVERSAMPLING      the resolution of the acquisition (2 means 1/2 chip resolution)
 * @param CLOCK_FREQ        the frequency of \p clk in Hz
 * @param CHIP_FREQ         the chip rate in Hz
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           the active HIGH reset signal
 * @param[in] signal        the incoming signal coming in at the clock frequency
 * @param[in] lshift        active HIGH left shift
 * @param[in] rshift        active HIGH right shift
 * @param[out] out          the correlation for the code (epoch)
 * @param[out] valid        whether the kernel has been fully loaded
 * @param[out] lshiftable   whether it's possible to left shift on this cycle
 * @param[out] rshiftable   whether it's possible to right shift on this cycle
 * @param[out] cycled       whether the gold code has cycled
 * @note asserting \p lshift and \p rshift at the same time is undefined
 */

module cdma_correlator #(
    parameter int PRN=1,
    parameter int CODE_LENGTH=1023,
    parameter int OVERSAMPLING=2,
    parameter int CLOCK_FREQ=163_680_000,
    parameter int CHIP_FREQ=1023,

    localparam int DIV_FREQ=CLOCK_FREQ/(CHIP_FREQ*OVERSAMPLING)
) (
    input logic clk,
    input logic rst,
    input logic signal,
    input logic lshift,
    input logic rshift,

    output logic [$clog2(CODE_LENGTH*OVERSAMPLING+1)-1:0] out,
    output logic valid,
    output logic lshiftable,
    output logic rshiftable,
    output logic cycled
);
    if ((CLOCK_FREQ % (CHIP_FREQ*OVERSAMPLING)) != 0) $error("The clock frequency needs to be a multiple of the chip frequency times oversampling");
    if (OVERSAMPLING < 2) $error("You must oversample by at least 2");
    if (DIV_FREQ == 1) $error("The main clock is too slow");
    logic [OVERSAMPLING*CODE_LENGTH-1:0] kernel;
    // SUBMODULES
    // intermediate signals
    logic sample_en;
    logic code_en;
    logic code;

    // cross-correlator
    cross_correlator #(
        .KERNEL_LENGTH(CODE_LENGTH*OVERSAMPLING)
    ) correlator_m (
        .clk,
        .rst,
        .signal_in(signal),
        .kernel,
        .en(sample_en),

        .valid,
        .out
    );

    // sample enable generator
    lfsr_timer #(
        .COUNT(DIV_FREQ-1)
    ) sample_enable_gen_m (
        .clk,
        .rst(rst | sample_en),
        .en(1),

        .done(sample_en)
    );

    // code enable generator
    lfsr_timer #(
        .COUNT(OVERSAMPLING-1)
    ) code_enable_gen_m (
        .clk,
        .rst(rst | (~rshift & code_en & (sample_en | lshift))),
        .en(~rshift & (sample_en | lshift)),

        .done(code_en)
    );

    // code generator(s):
    gold_code #(
        .PRN(PRN)
    ) code_module_m (
        .clk,
        .rst,
        .en(~rshift & code_en & (sample_en | lshift)),

        .code,
        .cycled(cycled)
    );

    always_ff @(posedge clk) begin
        if (~rshift & (sample_en | lshift)) begin
            kernel <= { code, kernel[OVERSAMPLING*CODE_LENGTH-1:1] }; 
        end

    end  // always_ff

    always_comb begin
        lshiftable = ~sample_en;
        rshiftable = sample_en;
    end  // always_comb
endmodule  // cdma_correlator
