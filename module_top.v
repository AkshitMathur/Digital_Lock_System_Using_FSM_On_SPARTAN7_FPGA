// ============================================================================
// Project      : FPGA-Based Digital Lock
// Module       : top_module
// Description  : Top-level module integrating the digital lock FSM,
//                debounce circuit, and 4-digit 7-segment display driver.
// Author       : Akshit Mathur & Team
// Device       : Xilinx Spartan-7 FPGA
// HDL          : Verilog
// ============================================================================

module top_module(
    input        clk,
    input        reset_sw,
    input  [3:0] keys_in,
    output [6:0] segments_out,
    output [3:0] anodes_out
);

    // ------------------------------------------------------------------------
    // Internal status signals
    // ------------------------------------------------------------------------

    wire unlocked_status;
    wire failed_status;

    // ------------------------------------------------------------------------
    // Digital Lock FSM
    // ------------------------------------------------------------------------

    digital_lock uut_lock (
        .clk      (clk),
        .reset    (reset_sw),
        .keys_in  (keys_in),
        .unlocked (unlocked_status),
        .failed   (failed_status)
    );

    // ------------------------------------------------------------------------
    // 7-Segment Character Selection
    // ------------------------------------------------------------------------

    reg [3:0] d1;
    reg [3:0] d2;
    reg [3:0] d3;
    reg [3:0] d4;

    // Character codes
    localparam CHAR_U = 4'h0;
    localparam CHAR_N = 4'h1;
    localparam CHAR_L = 4'h2;
    localparam CHAR_C = 4'h3;
    localparam CHAR_O = 4'h4;
    localparam BLANK  = 4'hF;

    // ------------------------------------------------------------------------
    // Display Status Selection
    // ------------------------------------------------------------------------

    always @(*) begin

        if (unlocked_status) begin

            // Display: "UNLC"
            d1 = CHAR_U;
            d2 = CHAR_N;
            d3 = CHAR_L;
            d4 = CHAR_C;

        end

        else if (failed_status) begin

            // Display: " LOC"
            d1 = BLANK;
            d2 = CHAR_L;
            d3 = CHAR_O;
            d4 = CHAR_C;

        end

        else begin

            // Blank display during standby / password entry
            d1 = BLANK;
            d2 = BLANK;
            d3 = BLANK;
            d4 = BLANK;

        end

    end

    // ------------------------------------------------------------------------
    // 4-Digit 7-Segment Display Driver
    // ------------------------------------------------------------------------

    seven_segment_driver uut_display (
        .clk      (clk),
        .reset    (reset_sw),
        .char1    (d1),
        .char2    (d2),
        .char3    (d3),
        .char4    (d4),
        .segments (segments_out),
        .anodes   (anodes_out)
    );

endmodule
