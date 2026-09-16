// ============================================================================
// Project      : FPGA-Based Digital Lock
// Module       : digital_lock
// Description  : Six-state synchronous FSM for four-key password
//                verification.
// Password     : KEY1 -> KEY0 -> KEY2 -> KEY3
// Input Type   : Active-low buttons
// Author       : Akshit Mathur & Team
// HDL          : Verilog
// ============================================================================

module digital_lock(
    input        clk,
    input        reset,
    input  [3:0] keys_in,
    output reg   unlocked,
    output reg   failed
);

    // ------------------------------------------------------------------------
    // FSM State Encoding
    // ------------------------------------------------------------------------

    localparam IDLE     = 3'b000;
    localparam GOT_1    = 3'b001;
    localparam GOT_2    = 3'b010;
    localparam GOT_3    = 3'b011;
    localparam UNLOCKED = 3'b100;
    localparam FAILED   = 3'b101;

    // ------------------------------------------------------------------------
    // State Registers
    // ------------------------------------------------------------------------

    reg [2:0] current_state;
    reg [2:0] next_state;

    // Tracks whether all previously entered keys were correct
    reg correct_so_far;

    // ------------------------------------------------------------------------
    // Password Sequence
    //
    // Inputs are active-low.
    //
    // KEY1 -> KEY0 -> KEY2 -> KEY3
    // ------------------------------------------------------------------------

    localparam PASS_1 = 4'b1101;
    localparam PASS_2 = 4'b1110;
    localparam PASS_3 = 4'b1011;
    localparam PASS_4 = 4'b0111;

    // ------------------------------------------------------------------------
    // Debounced Button Pulse
    // ------------------------------------------------------------------------

    wire debounced_press;

    debounce uut_debounce (
        .clk             (clk),
        .reset           (reset),
        .buttons_in      (keys_in),
        .debounced_press (debounced_press)
    );

    // ------------------------------------------------------------------------
    // Sequential State and Password Tracking Logic
    // ------------------------------------------------------------------------

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            current_state  <= IDLE;
            correct_so_far <= 1'b1;

        end

        else begin

            current_state <= next_state;

            // ---------------------------------------------------------------
            // Check the entered key only when a debounced press occurs
            // ---------------------------------------------------------------

            if (debounced_press) begin

                case (current_state)

                    IDLE: begin

                        if (keys_in != PASS_1)
                            correct_so_far <= 1'b0;

                    end

                    GOT_1: begin

                        if (keys_in != PASS_2)
                            correct_so_far <= 1'b0;

                    end

                    GOT_2: begin

                        if (keys_in != PASS_3)
                            correct_so_far <= 1'b0;

                    end

                    // Final key is checked in the next-state logic

                    default: begin
                        // No action
                    end

                endcase

            end

            // Reset correctness tracking when returning to IDLE
            if (next_state == IDLE)
                correct_so_far <= 1'b1;

        end

    end

    // ------------------------------------------------------------------------
    // FSM Next-State and Output Logic
    // ------------------------------------------------------------------------

    always @(*) begin

        // Default values
        next_state = current_state;

        unlocked = 1'b0;
        failed   = 1'b0;

        case (current_state)

            // ----------------------------------------------------------------
            // IDLE
            // ----------------------------------------------------------------

            IDLE: begin

                if (debounced_press)
                    next_state = GOT_1;

            end

            // ----------------------------------------------------------------
            // GOT_1
            // ----------------------------------------------------------------

            GOT_1: begin

                if (debounced_press)
                    next_state = GOT_2;

            end

            // ----------------------------------------------------------------
            // GOT_2
            // ----------------------------------------------------------------

            GOT_2: begin

                if (debounced_press)
                    next_state = GOT_3;

            end

            // ----------------------------------------------------------------
            // GOT_3
            // ----------------------------------------------------------------

            GOT_3: begin

                if (debounced_press) begin

                    // Final key verification
                    if (correct_so_far && (keys_in == PASS_4))
                        next_state = UNLOCKED;

                    else
                        next_state = FAILED;

                end

            end

            // ----------------------------------------------------------------
            // UNLOCKED
            // ----------------------------------------------------------------

            UNLOCKED: begin

                unlocked = 1'b1;

                // Remain unlocked until reset

            end

            // ----------------------------------------------------------------
            // FAILED
            // ----------------------------------------------------------------

            FAILED: begin

                failed = 1'b1;

                // Remain failed until reset

            end

            // ----------------------------------------------------------------
            // Default
            // ----------------------------------------------------------------

            default: begin

                next_state = IDLE;

            end

        endcase

    end

endmodule
