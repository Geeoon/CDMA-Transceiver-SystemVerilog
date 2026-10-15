/**
 * @file cdma_receiver_data.sv
 * @author Geeoon Chung
 * @brief data path for the CDMA receiver
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           the active HIGH reset signal
 * @param[in] signal        the CDMA signal coming in
 * @param[in] shift_on      active HIGH shift for the on-time correlator
 * @param[in] shift_early   active HIGH shift for the early correlator
 * @param[in] shift_late    active HIGH shift for the late correlator
 * @param[in] start_timer   active HIGH start signal for the timer
 * @param[out] shiftable    whether all the correlators are shiftable
 * @param[out] valids       whether the correlation outputs are valid
 * @param[out] in_range     whether the signal has been acquired
 * @param[out] done         whether the timer is done
 * @param[out] output_bit   the actualy received bit
 * @param[out] output_valid the whether \p output_bit should be sampled
 */

module cdma_receiver_data #(
    parameter int PRN=1,
    parameter int CODE_LENGTH=1023,
    parameter int OVERSAMPLING=2,
    parameter int CLOCK_FREQ=163_680_000,
    parameter int CHIP_FREQ=1023,

    localparam int CORRELATOR_BIT_WIDTH=$clog2(CODE_LENGTH*OVERSAMPLING+1),
    localparam int LAYERS=1+$clog2(CODE_LENGTH*OVERSAMPLING),
    localparam int DELAY_THRESHOLD=OVERSAMPLING*CODE_LENGTH/4,  // threshold for if if the late and early correlators are approximately the same
    localparam int LOCKED_THRESHOLD=OVERSAMPLING*CODE_LENGTH/4  // threshold for if the on-time correlator is correct
) (
    input logic clk,
    input logic rst,
    input logic signal,

    input logic shift_on,
    input logic shift_early,
    input logic shift_late,
    input logic start_timer,

    output logic shiftable,
    output logic valids,
    output logic in_range,
    output logic done,

    output logic [CORRELATOR_BIT_WIDTH-1:0] output_bit,
    output logic output_valid
);
    logic [CORRELATOR_BIT_WIDTH-1:0] late_out, on_out, early_out;
    logic late_valid, on_valid, early_valid, late_shiftable, on_shiftable, early_shiftable;

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
        .shift(shift_on),

        .out(on_out),
        .valid(on_valid),
        .shiftable(on_shiftable)
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
        .shift(shift_early),

        .out(early_out),
        .valid(early_valid),
        .shiftable(early_shiftable)
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
        .shift(shift_late),

        .out(late_out),
        .valid(late_valid),
        .shiftable(late_shiftable)
    );

    lfsr_timer #(
        .COUNT(LAYERS-1)
    ) timer_m (
        .clk,
        .rst(start_timer),
        .en(1),
        
        .done
    );

    assign shiftable = early_shiftable & on_shiftable & late_shiftable;
    assign valids = early_valid & on_valid & late_valid;

    assign output_valid = in_range;  // might attempt to do bit alignment which would make this more complex

    always_comb begin
        out_bit = 'x;
        in_range = 0;
        if (on_out < ) out_bit = 1;
        else if (on_out > ) out_bit = 0;
    end  // always_comb
endmodule  // cdma_receiver_data
