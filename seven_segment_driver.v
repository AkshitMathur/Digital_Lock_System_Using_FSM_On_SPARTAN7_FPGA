// ============================================================================
// Project      : FPGA-Based Digital Lock
// Module       : seven_segment_driver
// Description  : Multiplexed four-digit common-anode 7-segment display
//                driver for displaying lock status.
// Clock        : 100 MHz
// Display      : 4-digit common-anode 7-segment
// Author       : Akshit Mathur & Team
// HDL          : Verilog
// ============================================================================

module seven_segment_driver(
    input        clk,
    input        reset,

    input  [3:0] char1,
    input  [3:0] char2,
    input  [3:0] char3,
    input  [3:0] char4,

    output reg [6:0] segments,
    output reg [3:0] anodes
);

    // ------------------------------------------------------------------------
    // Display Refresh Counter
    //
    // 100 MHz / 204800 = approximately 488 Hz
    //
    // The upper two bits are used to select the four display digits.
    // ------------------------------------------------------------------------

    reg [17:0] refresh_counter;

    // ------------------------------------------------------------------------
    // Refresh Counter
    // ------------------------------------------------------------------------

    always @(posedge clk or posedge reset) begin

        if (reset)
            refresh_counter <= 18'd0;

        else
            refresh_counter <= refresh_counter + 1'b1;

    end

    // ------------------------------------------------------------------------
    // Digit Selection
    // ------------------------------------------------------------------------

    wire [1:0] digit_select = refresh_counter[17:16];

    // Character currently being displayed
    reg [3:0] char_to_display;

    // ------------------------------------------------------------------------
    // Character Multiplexing
    //
    // The physical display wiring requires the following mapping.
    // ------------------------------------------------------------------------

    always @(*) begin

        case (digit_select)

            // Physical digit 1
            2'b10:
                char_to_display = char1;

            // Physical digit 2
            2'b11:
                char_to_display = char2;

            // Physical digit 3
            2'b00:
                char_to_display = char3;

            // Physical digit 4
            2'b01:
                char_to_display = char4;

            default:
                char_to_display = 4'hF;

        endcase

    end

    // ------------------------------------------------------------------------
    // 7-Segment Character Decoder
    //
    // Segment order:
    // {g, f, e, d, c, b, a}
    //
    // Common-anode display:
    // Logic 0 = Segment ON
    // Logic 1 = Segment OFF
    // ------------------------------------------------------------------------

    always @(*) begin

        case (char_to_display)

            // U
            4'h0:
                segments = 7'b1000001;

            // n
            4'h1:
                segments = 7'b0101011;

            // L
            4'h2:
                segments = 7'b1000111;

            // c
            4'h3:
                segments = 7'b0100111;

            // o
            4'h4:
                segments = 7'b0100011;

            // Blank
            default:
                segments = 7'b1111111;

        endcase

    end

    // ------------------------------------------------------------------------
    // 7-Segment Anode Control
    //
    // Common-anode display:
    // Logic 0 = Digit ON
    // Logic 1 = Digit OFF
    // ------------------------------------------------------------------------

    always @(*) begin

        case (digit_select)

            // Activate physical display 3
            2'b00:
                anodes = 4'b1110;

            // Activate physical display 4
            2'b01:
                anodes = 4'b1101;

            // Activate physical display 1
            2'b10:
                anodes = 4'b1011;

            // Activate physical display 2
            2'b11:
                anodes = 4'b0111;

            default:
                anodes = 4'b1111;

        endcase

    end

endmodule
