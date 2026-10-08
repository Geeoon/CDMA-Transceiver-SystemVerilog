/**
 * @file gold_code.sv
 * @see https://www.navcen.uscg.gov/sites/default/files/pdf/gps/IS-GPS-200N.pdf
 * @author Geeoon Chung
 * @brief Gold code generation, used in GPS C/A
 * @param PRN           the PRN signal number
 * @param[in] clk       the clock driving the sequential logic
 * @param[in] rst       the synchronous reset
 * @param[in] en        the enable signal to generate the next code
 * @param[out] code     the output code
 * @param[out] cycled   whether \p code is the start of the cycle
 */

module gold_code #(
    parameter int PRN=1
) (
    input logic clk,
    input logic rst,
    input logic en,

    output logic code,
    output logic cycled
);
    function automatic logic get_g2_taps(logic [10:1] g2_state);
        unique case (PRN)
            1: return g2_state[2] ^ g2_state[6];
            2: return g2_state[3] ^ g2_state[7];
            3: return g2_state[4] ^ g2_state[8];
            4: return g2_state[5] ^ g2_state[9];
            5: return g2_state[1] ^ g2_state[9];
            6: return g2_state[2] ^ g2_state[10];
            7: return g2_state[1] ^ g2_state[8];
            8: return g2_state[2] ^ g2_state[9];
            9: return g2_state[3] ^ g2_state[10];
            10: return g2_state[2] ^ g2_state[3];
            11: return g2_state[3] ^ g2_state[4];
            12: return g2_state[5] ^ g2_state[6];
            13: return g2_state[6] ^ g2_state[7];
            14: return g2_state[7] ^ g2_state[8];
            15: return g2_state[8] ^ g2_state[9];
            16: return g2_state[9] ^ g2_state[10];
            17: return g2_state[1] ^ g2_state[4];
            18: return g2_state[2] ^ g2_state[5];
            19: return g2_state[3] ^ g2_state[6];
            20: return g2_state[4] ^ g2_state[7];
            21: return g2_state[5] ^ g2_state[8];
            22: return g2_state[6] ^ g2_state[9];
            23: return g2_state[1] ^ g2_state[3];
            24: return g2_state[4] ^ g2_state[6];
            25: return g2_state[5] ^ g2_state[7];
            26: return g2_state[6] ^ g2_state[8];
            27: return g2_state[7] ^ g2_state[9];
            28: return g2_state[8] ^ g2_state[10];
            29: return g2_state[1] ^ g2_state[6];
            30: return g2_state[2] ^ g2_state[7];
            31: return g2_state[3] ^ g2_state[8];
            32: return g2_state[4] ^ g2_state[9];
            33: return g2_state[5] ^ g2_state[10];
            34: return g2_state[4] ^ g2_state[10];
            35: return g2_state[1] ^ g2_state[7];
            36: return g2_state[2] ^ g2_state[8];
            37: return g2_state[4] ^ g2_state[10];
            default: $error("Unsupported PRN");
        endcase
                
    endfunction  // get_g2_taps

    logic [9:0] g1_state, g2_state;

    always_ff @(posedge clk) begin
        if (rst) begin
            g1_state <= '1;
            g2_state <= '1;
        end else if (en) begin
            g1_state <= { g1_state[8:0], g1_state[2] ^ g1_state[9] };
            g2_state <= { g2_state[8:0], g2_state[1] ^ g2_state[2] ^ g2_state[5] ^ g2_state[7] ^ g2_state[8] ^ g2_state[9] };
        end
    end  // always_ff
    assign code = get_g2_taps(g2_state) ^ g1_state[9];
    assign cycled = (g1_state == '1);
endmodule  // lfsr_code
