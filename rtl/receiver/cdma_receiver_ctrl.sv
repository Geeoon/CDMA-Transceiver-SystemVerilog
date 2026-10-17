/**
 * @file cdma_receiver_ctrl.sv
 * @author Geeoon Chung
 * @brief control path for the CDMA receiver
 * @param[in] clk           the clock driving the sequential logic
 * @param[in] rst           the active HIGH reset signal
 * @param[in] lshiftable    whether all the correlators are left shiftable
 * @param[in] rshiftable    whether all the correlators are right shiftable
 * @param[in] valids        whether the correlation outputs are valid
 * @param[in] in_range      whether the signal has been acquired
 * @param[in] lbias         whether the correlation is left biased
 * @param[in] rbias         whether the correlation is right biased
 * @param[in] done          whether the timer is done
 * @param[out] lshift_on    active HIGH left shift for the on-time correlator
 * @param[out] lshift_early active HIGH left shift for the early correlator
 * @param[out] lshift_late  active HIGH left shift for the late correlator
 * @param[out] rshift_on    active HIGH right shift for the on-time correlator
 * @param[out] rshift_early active HIGH right shift for the early correlator
 * @param[out] rshift_late  active HIGH right shift for the late correlator
 * @param[out] start_timer  active HIGH start signal for the timer
 * @param[out] acquired     the whether \p output_bit is valid / can be sampled
 */
module cdma_receiver_ctrl (
    input logic clk,
    input logic rst,
    input logic lshiftable,
    input logic rshiftable,
    input logic valids,
    input logic in_range,
    input logic lbias,
    input logic rbias,
    input logic done,

    output logic lshift_on,
    output logic lshift_early,
    output logic lshift_late,
    output logic rshift_on,
    output logic rshift_early,
    output logic rshift_late,
    output logic start_timer,
    output logic acquired
    
);
    enum logic [2:0] { s_init1, s_init2, s_wait, s_acquire, s_await } ps, ns;
    
    always_ff @(posedge clk) begin
        if (rst) ps <= s_init1;
        else ps <= ns;
    end  // always_ff

    always_comb begin
        ns = s_init1;
        lshift_on = 0;
        lshift_early = 0;
        lshift_late = 0;
        rshift_on = 0;
        rshift_early = 0;
        rshift_late = 0;
        acquired = 0;
        start_timer = 0;

        unique case (ps)
            s_init1: begin
                if (lshiftable) begin
                    ns = s_init2;
                    lshift_on = 1;
                    lshift_late = 1;
                end else begin
                    ns = s_init1;
                end
            end  // s_init1

            s_init2: begin
                if (lshiftable) begin
                    lshift_late = 1;
                    ns = s_wait;
                end else begin
                    ns = s_init2;
                end
            end  // s_init2

            s_wait: begin
                if (valids) begin
                    ns = s_acquire;
                end else begin
                    ns = s_wait;
                end
            end  // s_wait

            s_acquire: begin
                if (in_range) begin
                    acquired = 1;
                    if (lbias) begin
                        if (rshiftable) begin
                            rshift_on = 1;
                            rshift_early = 1;
                            rshift_late = 1;
                            start_timer = 1;
                            ns = s_await;
                        end else begin
                            ns = s_acquire;
                        end
                    end else begin
                        if (rbias) begin
                            if (lshiftable) begin
                                lshift_on = 1;
                                lshift_early = 1;
                                lshift_late = 1;
                                start_timer = 1;
                                ns = s_await;
                            end else begin
                                ns = s_acquire;
                            end
                        end else begin
                            ns = s_acquire;
                        end
                    end
                end else begin
                    lshift_early = 1;
                    lshift_on = 1;
                    lshift_late = 1;
                    start_timer = 1;
                    ns = s_await;
                end
            end  // s_acquire

            s_await: begin
                acquired = in_range;
                if (done) ns = s_acquire;
                else ns = s_await;
            end  // s_await

            default: ns = s_init1;
        endcase
    end  // always_comb
endmodule  // cdma_receiver_ctrl
