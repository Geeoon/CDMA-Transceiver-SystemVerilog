/**
 * @file cdma_receiver_data.sv
 * @author Geeoon Chung
 * @brief data path for the CDMA receiver
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           the active HIGH reset signal
 * @param[in] signal        the CDMA signal coming in
 * @param[in] lshift_on     active HIGH left shift for the on-time correlator
 * @param[in] lshift_early  active HIGH left shift for the early correlator
 * @param[in] lshift_late   active HIGH left shift for the late correlator
 * @param[in] rshift_on     active HIGH right shift for the on-time correlator
 * @param[in] rshift_early  active HIGH right shift for the early correlator
 * @param[in] rshift_late   active HIGH right shift for the late correlator
 * @param[in] start_timer   active HIGH start signal for the timer
 * @param[out] lshiftable   whether all the correlators are left shiftable
 * @param[out] rshiftable   whether all the correlators are right shiftable
 * @param[out] valids       whether the correlation outputs are valid
 * @param[out] in_range     whether the signal has been acquired
 * @param[out] lbias        whether the correlation is left biased
 * @param[out] rbias        whether the correlation is right biased
 * @param[out] done         whether the timer is done
 * @param[out] output_bit   the actualy received bit
 */

module cdma_receiver_data #(
    parameter int PRN=1,
    parameter int CODE_LENGTH=1023,
    parameter int OVERSAMPLING=2,
    parameter int CLOCK_FREQ=163_680_000,
    parameter int CHIP_FREQ=1023,

    localparam int CORRELATOR_BIT_WIDTH=$clog2(CODE_LENGTH*OVERSAMPLING+1),
    localparam int LAYERS=1+$clog2(CODE_LENGTH*OVERSAMPLING),
    localparam int UPPER_LOCKED_THRESHOLD=3*OVERSAMPLING*CODE_LENGTH/4,  // threshold for if if the on time correlator is locked on a 1 bit
    localparam int LOWER_LOCKED_THRESHOLD=OVERSAMPLING*CODE_LENGTH/4  // threshold for if if the on time correlator is locked on a 0 bit
) (
    input logic clk,
    input logic rst,
    input logic signal,

    input logic lshift_on,
    input logic lshift_early,
    input logic lshift_late,
    input logic rshift_on,
    input logic rshift_early,
    input logic rshift_late,
    input logic start_timer,

    output logic lshiftable,
    output logic rshiftable,
    output logic valids,
    output logic in_range,
    output logic lbias,
    output logic rbias,
    output logic done,

    output logic output_bit
);
    logic [CORRELATOR_BIT_WIDTH-1:0] late_out, on_out, early_out;
    logic late_valid, on_valid, early_valid,
          late_lshiftable, on_lshiftable, early_lshiftable,
          late_rshiftable, on_rshiftable, early_rshiftable;

    // SUBMODULES
    cdma_correlator #(
        .PRN(PRN),
        .CODE_LENGTH(CODE_LENGTH),
        .OVERSAMPLING(OVERSAMPLING),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ)
    ) correlator_on_m (
        .clk,
        .rst,
        .signal,
        .lshift(lshift_on),
        .rshift(rshift_on),

        .out(on_out),
        .valid(on_valid),
        .lshiftable(on_lshiftable),
        .rshiftable(on_rshiftable)
    );

    cdma_correlator #(
        .PRN(PRN),
        .CODE_LENGTH(CODE_LENGTH),
        .OVERSAMPLING(OVERSAMPLING),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ)
    ) correlator_early_m (
        .clk,
        .rst,
        .signal,
        .lshift(lshift_early),
        .rshift(rshift_early),

        .out(early_out),
        .valid(early_valid),
        .lshiftable(early_lshiftable),
        .rshiftable(early_rshiftable)
    );

    cdma_correlator #(
        .PRN(PRN),
        .CODE_LENGTH(CODE_LENGTH),
        .OVERSAMPLING(OVERSAMPLING),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ)
    ) correlator_late_m (
        .clk,
        .rst,
        .signal,
        .lshift(lshift_late),
        .rshift(rshift_late),

        .out(late_out),
        .valid(late_valid),
        .lshiftable(late_lshiftable),
        .rshiftable(late_rshiftable)
    );


    lfsr_timer #(
        .COUNT(LAYERS-1)
    ) timer_m (
        .clk,
        .rst(start_timer),
        .en(1),
        
        .done
    );

    assign lshiftable = early_lshiftable & on_lshiftable & late_lshiftable;
    assign rshiftable = early_rshiftable & on_rshiftable & late_rshiftable;
    assign valids = early_valid & on_valid & late_valid;
    assign lbias = late_out > early_out;  // TODO: add logic to also make sure it's not just a small amount
    assign rbias = late_out < early_out;  // TODO: add logic to also make sure it's not just a small amount

    always_comb begin
        output_bit = 'x;
        if (on_out < (CORRELATOR_BIT_WIDTH)'(LOWER_LOCKED_THRESHOLD)) begin
            in_range = 1;
            output_bit = 1;
        end else if (on_out > (CORRELATOR_BIT_WIDTH)'(UPPER_LOCKED_THRESHOLD)) begin
            in_range = 1;
            output_bit = 0;
        end else begin
            in_range = 0;
        end
    end  // always_comb
endmodule  // cdma_receiver_data
