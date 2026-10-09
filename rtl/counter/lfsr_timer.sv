/**
 * @file lfsr_timer.sv
 * @author Geeoon Chung
 * @brief An LFSR-based timer
 * @see https://www.physics.otago.ac.nz/reports/electronics/ETR2012-1.pdf
 * @param COUNT         the number of clock cycles to count
 * @param[in] clk       the clock driving the sequential logic
 * @param[in] rst       an active high reset
 * @param[in] en        an active high enable signal
 * @param[out] done     whether or not the timer has reached the end
 */
module lfsr_timer #(
    parameter int COUNT,

    localparam int N=$clog2(COUNT+1)
)(
    input logic clk,
    input logic rst,
    input logic en,

    output logic done
);
    if (COUNT < 0) begin
        $error("COUNT needs to be at least 0.");
    end else if (COUNT == 0) begin
        assign done = 1;
    end else begin
        /* verilator lint_off SELRANGE */
        /* verilator lint_off WIDTHTRUNC */
        function automatic logic [N-1:0] get_next_state(logic [N-1:0] current_state);
            logic feedback;
            unique case (N)
                1: return '1;
                2: feedback = current_state[1] ^ current_state[0];
                3: feedback = current_state[2] ^ current_state[1];
                4: feedback = current_state[3] ^ current_state[2];
                5: feedback = current_state[4] ^ current_state[2];
                6: feedback = current_state[5] ^ current_state[4];
                7: feedback = current_state[6] ^ current_state[5];
                8: feedback = current_state[7] ^ current_state[5] ^ current_state[4] ^ current_state[3];
                9: feedback = current_state[8] ^ current_state[4];
                10: feedback = current_state[9] ^ current_state[6];
                11: feedback = current_state[10] ^ current_state[8];
                12: feedback = current_state[11] ^ current_state[10] ^ current_state[7] ^ current_state[5];
                13: feedback = current_state[12] ^ current_state[11] ^ current_state[9] ^ current_state[8];
                14: feedback = current_state[13] ^ current_state[12] ^ current_state[10] ^ current_state[8];
                15: feedback = current_state[14] ^ current_state[13];
                16: feedback = current_state[15] ^ current_state[13] ^ current_state[12] ^ current_state[10];
                17: feedback = current_state[16] ^ current_state[13];
                18: feedback = current_state[17] ^ current_state[10];
                19: feedback = current_state[18] ^ current_state[17] ^ current_state[16] ^ current_state[13];
                20: feedback = current_state[19] ^ current_state[16];
                21: feedback = current_state[20] ^ current_state[18];
                22: feedback = current_state[21] ^ current_state[20];
                23: feedback = current_state[22] ^ current_state[17];
                24: feedback = current_state[23] ^ current_state[22] ^ current_state[20] ^ current_state[19];
                25: feedback = current_state[24] ^ current_state[21];
                26: feedback = current_state[25] ^ current_state[24] ^ current_state[23] ^ current_state[19];
                27: feedback = current_state[26] ^ current_state[25] ^ current_state[24] ^ current_state[21];
                28: feedback = current_state[27] ^ current_state[24];
                29: feedback = current_state[28] ^ current_state[26];
                30: feedback = current_state[29] ^ current_state[28] ^ current_state[25] ^ current_state[23];
                31: feedback = current_state[30] ^ current_state[27];
                32: feedback = current_state[31] ^ current_state[29] ^ current_state[25] ^ current_state[24];
                default: $error("COUNT is outside of supported range");
            endcase  // N
            return { current_state[N-2:0], feedback };
        endfunction  // get_next_state
        /* verilator lint_on WIDTHTRUNC */
        /* verilator lint_on SELRANGE */

        function automatic logic [N-1:0] calculate_start();
            logic [N-1:0] temp = '1;
            int steps = (2**N) - (COUNT);
            for (int i = 0; i < steps; i++) begin
                temp = get_next_state(temp);
            end  // for
            return temp;
        endfunction  // calculate_start

        logic [N-1:0] lfsr_state;

        always_ff @(posedge clk) begin
            if (en) begin
                if (rst) begin
                    done <= 0;
                    lfsr_state <= (N)'(calculate_start());
                end else begin
                    lfsr_state <= get_next_state(lfsr_state);
                    if (lfsr_state == '1) begin
                        done <= 1;
                    end
                end
            end

        end  // always_ff
    end
endmodule  // lfsr_timer
