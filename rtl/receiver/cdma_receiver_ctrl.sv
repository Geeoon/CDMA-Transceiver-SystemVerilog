/**
 * @file cdma_receiver_ctrl.sv
 * @author Geeoon Chung
 * @brief control path for the CDMA receiver
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           the active HIGH reset signal
 * @param[in] shiftable     whether all the correlators are shiftable
 * @param[in] valids        whether the correlation outputs are valid
 * @param[in] in_range      whether the signal has been acquired
 * @param[in] done          whether the timer is done
 * @param[out] shift_on     active HIGH shift for the on-time correlator
 * @param[out] shift_early  active HIGH shift for the early correlator
 * @param[out] shift_late   active HIGH shift for the late correlator
 * @param[out] start_timer  active HIGH start signal for the timer
 */

module cdma_receiver_ctrl (
    input logic clk,
    input logic rst,
    input logic shiftable,
    input logic valids,
    input logic in_range,
    input logic done,

    output logic shift_on,
    output logic shift_early,
    output logic shift_late,
    output logic start_timer
);
    enum logic [2:0] { s_init1, s_init2, s_wait, s_acquire, s_await } ps, ns;
    
    always_ff @(posedge clk) begin
        if (reset) ps <= s_init1;
        else ps <= ns;
    end  // always_ff

    always_comb begin
        shift_on = 0;
        shift_early = 0;
        shift_late = 0;
        shift_timer = 0;
        ns = 'x;
        case (ps)
            s_init1: begin
                shift_on = 1;
                shift_early = 1;
                if (shiftable) ns = s_init1;
                else ns = s_init2;
            end  // s_init1

            s_init2: begin
                if (shiftable) begin
                    shift_early = 1;
                    ns = s_wait;
                end else begin
                    ns = s_init2;
                end
            end  // s_init2

            s_wait: begin
                if (valids) ns = s_acquire;
                else ns = s_wait;
            end  // s_wait

            s_acquire: begin
                if (in_range) begin
                    ns = s_acquire;
                end else if (~shiftable) begin
                    ns = s_acquire;
                end else begin
                    shift_late = 1;
                    shift_on = 1;
                    shift_early = 1;
                    start_timer = 1;
                    ns = s_await;
                end
            end  // s_acquire

            s_await: begin
                if (done) ns = s_acquire;
                else ns = s_await;
            end  // s_await
        endcase
    end  // always_comb
endmodule  // cdma_receiver_ctrl
