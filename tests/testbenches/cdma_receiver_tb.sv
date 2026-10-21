/**
 * @file cdma_receiver_tb.sv
 * @author Geeoon Chung
 * @brief testbench for the cdma_receiver module
 */

module cdma_receiver_tb #(
    parameter CLOCK_PERIOD=100,
    parameter int PRN=1,
    parameter int CODE_LENGTH=1023,
    parameter int OVERSAMPLING=2,
    parameter int CLOCK_FREQ=4,
    parameter int CHIP_FREQ=1,
    parameter int N=20,
    parameter int TEST_LENGTH=100,

    localparam int DIV_FREQ=CLOCK_FREQ/(CHIP_FREQ*OVERSAMPLING),
    localparam int LAYERS=1+$clog2(CODE_LENGTH*OVERSAMPLING)
) ();
    // inputs
    logic clk;
    logic rst;
    logic signal;

    // outputs
    logic out;
    logic acquired;
    logic valid;


    logic tx_rst;
    logic data;
    logic tx_done;
    cdma_transmitter #(
        .PRN(PRN),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ),
        .N(N)
    ) signal_generator (
        .clk,
        .rst(tx_rst),
        .data,
        
        .code(signal),
        .done(tx_done)
    );

    cdma_receiver #(
        .PRN(PRN),
        .CODE_LENGTH(CODE_LENGTH),
        .OVERSAMPLING(OVERSAMPLING),
        .CLOCK_FREQ(CLOCK_FREQ),
        .CHIP_FREQ(CHIP_FREQ)
    ) dut (
        .clk,
        .rst,
        .signal,

        .out,
        .acquired,
        .valid
    );

    initial begin
        clk = 0;
        forever begin
            #(CLOCK_PERIOD/2) clk = ~clk;
        end  // forever
    end  // initial

    bit bit_samples [0:N-1];
    initial begin
        $urandom('hCAFEBABE);
        // dump waveforms
        // $dumpfile("waveforms/cdma_receiver_tb.vcd");  // waveform is too large
        // $dumpvars;
        $display(" -- Starting cdma_receiver test -- ");
        // reset
        rst = 1;
        tx_rst = 1;
        data = 1;
        @(posedge clk); #5;
        rst = 0;
        repeat(89) begin
            @(posedge clk); #5;
        end
        tx_rst = 0;
        
        repeat(TEST_LENGTH) begin
            data = 1'($urandom());
            @(posedge tx_done); #5;
            // we better have acquired the signal by now
            if (~acquired) $fatal("Failed to acquire signal in time.");
            @(posedge clk); #5;
            
            for (int i = 0;; i++) begin
                @(posedge valid, posedge tx_done); #5;
                if (tx_done) break;
                assert(i != N);
                bit_samples[i] = out;
                if (tx_done & ~valid) $fatal("The transmitter and receiver were left in a bad state.  tx_done=%b valid=%b", tx_done, valid);
            end

            // there should be no bit errors since there's no noise
            foreach (bit_samples[i]) assert(bit_samples[i] == data);
            $display("Passed test with sending and receiving %b", data);
            @(negedge tx_done); #5;
        end

        $display(" -- FINISHED TESTS -- ");
        $finish;
    end
endmodule  // cdma_receiver_tb
