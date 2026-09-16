// ============================================================================
// Project      : FPGA-Based Digital Lock
// Module       : debounce
// Description  : Synchronizes asynchronous active-low push buttons and
//                generates a single clean pulse for each valid button press.
// Clock        : 100 MHz
// Debounce     : 20 ms
// Author       : Akshit Mathur & Team
// HDL          : Verilog
// ============================================================================

module debounce(
    input        clk,
    input        reset,
    input  [3:0] buttons_in,
    output reg   debounced_press
);

    // ------------------------------------------------------------------------
    // Debounce Counter
    //
    // 100 MHz clock:
    //      Clock period = 10 ns
    //
    // 20 ms debounce time:
    //      20 ms / 10 ns = 2,000,000 clock cycles
    //
    // Therefore:
    //      COUNTER_MAX = 1,999,999
    // ------------------------------------------------------------------------

    parameter COUNTER_MAX = 21'd1999999;

    reg [20:0] counter;

    // ------------------------------------------------------------------------
    // Two-Stage Synchronizer
    // ------------------------------------------------------------------------

    reg [3:0] buttons_synced1;
    reg [3:0] buttons_synced2;

    // Tracks whether a button was already recognized as pressed
    reg prev_buttons_state;

    // Indicates that at least one active-low button is pressed
    wire any_button_pressed;

    // ------------------------------------------------------------------------
    // Synchronize Asynchronous Button Inputs
    // ------------------------------------------------------------------------

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            buttons_synced1 <= 4'b1111;
            buttons_synced2 <= 4'b1111;

        end

        else begin

            buttons_synced1 <= buttons_in;
            buttons_synced2 <= buttons_synced1;

        end

    end

    // ------------------------------------------------------------------------
    // Active-Low Button Detection
    //
    // A button is considered pressed when its input becomes 0.
    // 1111 means that no button is pressed.
    // ------------------------------------------------------------------------

    assign any_button_pressed =
            (buttons_synced2 != 4'b1111);

    // ------------------------------------------------------------------------
    // Debounce Logic
    // ------------------------------------------------------------------------

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            counter            <= 21'd0;
            prev_buttons_state <= 1'b0;
            debounced_press    <= 1'b0;

        end

        else begin

            // ---------------------------------------------------------------
            // A new button press has been detected
            // ---------------------------------------------------------------

            if ((prev_buttons_state == 1'b0) &&
                (any_button_pressed == 1'b1)) begin

                // -----------------------------------------------------------
                // Wait until the button remains stable for 20 ms
                // -----------------------------------------------------------

                if (counter < COUNTER_MAX) begin

                    counter <= counter + 1'b1;

                end

                else begin

                    // Valid and debounced button press
                    debounced_press <= 1'b1;

                    // Prevent repeated pulses while button is held
                    prev_buttons_state <= 1'b1;

                end

            end

            // ---------------------------------------------------------------
            // No button is pressed
            // ---------------------------------------------------------------

            else if (any_button_pressed == 1'b0) begin

                counter            <= 21'd0;
                prev_buttons_state <= 1'b0;
                debounced_press    <= 1'b0;

            end

            // ---------------------------------------------------------------
            // Button remains pressed
            // ---------------------------------------------------------------

            else begin

                debounced_press <= 1'b0;

            end

        end

    end

endmodule
