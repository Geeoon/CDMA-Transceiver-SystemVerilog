/**
 * @file popcount.sv
 * @author Geeoon Chung
 * @brief counts the 1 bits in a packed array (popcount) using a tree
 * @param IN_LENGTH     the number of 1-bit samples on the input
 * @param LUT_SIZE      the size of the LUTs on the target system. you can set
 *                          this to 2 for a binary tree structure.
 * @param ADDER_SIZE    the size of the adders on the target system. you can
 *                          set this to 2 for a binary tree structure.
 * @param[in] clk       the clock driving the sequential logic
 * @param[in] start     whether the inputs are valid or not
 * @param[in] in_arr    the input array to count
 * @param[out] out_arr  the solution
 * @param[out] valid    whether the output is valid or not
 */

// Constant function to compute ceil(log_base(value))
function automatic int clogb_n;
    input int base;
    input int value;
    int temp;
    begin
        clogb_n = 0;
        temp = 1;
        while (temp < value) begin
            temp = temp * base;
            clogb_n = clogb_n + 1;
        end  // while
    end
endfunction  // clogb_n

module popcount #(
    parameter int IN_LENGTH,
    parameter int LUT_SIZE=6,
    parameter int ADDER_SIZE=3,

    localparam int DEPTH=clogb_n(ADDER_SIZE, IN_LENGTH / LUT_SIZE),  // TODO: this is doing integer division, so it messes up sometimes
    localparam int TOTAL_SIZE=LUT_SIZE * (ADDER_SIZE**DEPTH),
    localparam int OUTPUT_BITS=$clog2(IN_LENGTH+1),
    localparam int SUBSECTION_SIZE=TOTAL_SIZE/ADDER_SIZE
)(
    input logic clk,
    input logic start,
    input logic [IN_LENGTH-1:0] in_arr,

    output logic [OUTPUT_BITS-1:0] out_arr,
    output logic valid
);
    if (IN_LENGTH < LUT_SIZE) begin
        $error("Invalid popcount input length.  Input length must be greater than or equal to LUT size.");
    end

    logic [TOTAL_SIZE-1:0] padded;  // compiler should optimize the dead parts of the tree
    assign padded = (TOTAL_SIZE)'(in_arr);  // pads to expected lengths
    if (DEPTH == 0)  // base case
        begin : DEPTH_eq_0
            // LUT compressor logic
            logic [OUTPUT_BITS-1:0] compressor;
            always_comb begin
                compressor = '0;
                for (int i = 0; i < LUT_SIZE; i++) begin
                    compressor = compressor + (OUTPUT_BITS)'(padded[i]);
                end  // for
            end  // always_comb
            // pipeline DFF
            always_ff @(posedge clk) begin
                valid <= start;
                out_arr <= compressor;
            end  // always_ff
        end  // DEPTH_eq_0
    else
        begin : DEPTH_gt_0  // recursive case
            logic [($clog2(SUBSECTION_SIZE+1))-1:0] outs [0:ADDER_SIZE-1];
            logic [ADDER_SIZE-1:0] valids;

            // submodules
            for (genvar i = 0; i < ADDER_SIZE; i++) begin
                popcount #(
                    .IN_LENGTH(SUBSECTION_SIZE),
                    .LUT_SIZE(LUT_SIZE),
                    .ADDER_SIZE(ADDER_SIZE)
                ) popcount_section (
                    .clk,
                    .start,
                    .in_arr(padded[((i+1)*SUBSECTION_SIZE)-1:i*SUBSECTION_SIZE]),
                    .out_arr(outs[i]),
                    .valid(valids[i])
                );
            end  // for

            // Adder optimization
            logic [OUTPUT_BITS-1:0] sum;
            always_comb begin
                sum = 0;
                for (int i = 0; i < ADDER_SIZE; i++) begin
                    sum = sum + (OUTPUT_BITS)'(outs[i]);
                end  // for
            end  // always_comb
            
            // pipeline
            always_ff @(posedge clk) begin
                valid <= &valids;
                out_arr <= sum;
            end  // always_ff
        end  // DEPTH_gt_0
endmodule  // popcount
