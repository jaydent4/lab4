module memorization_game (
    input  wire        clk,            // System clock
    input  wire        rst,            // Reset signal (active high)
    // Keypad interface
    output wire [3:0]  keypad_row,     // Keypad row outputs
    input  wire [3:0]  keypad_col,     // Keypad column inputs
    // 7-segment display interface
    output wire [6:0]  segments,       // 7-segment display segments
    output wire [3:0]  digit_sel,      // 7-segment display digit selector
    // VGA interface
    input  wire        p_tick,         // Pixel tick from VGA timing generator
    output wire [7:0]  rgb             // 8-bit color output to VGA
);

    //-------------------------------------------------------------------------
    // 1) States & Difficulty
    //-------------------------------------------------------------------------
    localparam IDLE             = 2'b00;
    localparam DISPLAY_SEQUENCE = 2'b01;
    localparam WAIT_INPUT       = 2'b10;
    localparam GAME_OVER        = 2'b11;

    localparam EASY   = 2'b00;
    localparam MEDIUM = 2'b01;
    localparam HARD   = 2'b10;

    //-------------------------------------------------------------------------
    // 2) Internal Registers
    //-------------------------------------------------------------------------
    reg [1:0]  game_state;
    reg [1:0]  difficulty;
    reg [13:0] score;                 // 0..9999
    localparam MAX_SEQUENCE_LENGTH = 10; // Example: up to 10 randoms
    reg [19:0] current_sequence [0:MAX_SEQUENCE_LENGTH-1]; 
    reg [6:0]  sequence_length;
    reg [6:0]  display_index;
    reg [6:0]  input_index;

    // For capturing user’s 5-digit input
    reg [19:0] input_buffer;  
    reg [2:0]  digit_count; // how many digits (0..4) for the current random

    reg [31:0] timer_count;

    // Keypad signals
    wire       key_pressed;
    wire [3:0] keypad_value;

    // 20-bit random value (5 nibbles in [0..9])
    wire [19:0] random_value;

    // 7-Segment & VGA signals
    reg  [13:0] display_value;
    reg  [7:0]  rgb_reg, rgb_next;

    //-------------------------------------------------------------------------
    // 3) Submodules
    //-------------------------------------------------------------------------

    // (A) 20-bit random generator: 5 digits [0..9]
    random_generator_20bit rng_inst (
        .clk       (clk),
        .rst       (rst),
        .seed      (20'hABCDE),   // 20-bit seed
        .random_num(random_value) // each nibble = [0..9]
    );

    // (B) Keypad scanner (not fully shown):
    // keypad_scanner keypad_inst (
    //    .clk         (clk),
    //    .rst         (rst),
    //    .keypad_row  (keypad_row),
    //    .keypad_col  (keypad_col),
    //    .key_pressed (key_pressed),
    //    .key_value   (keypad_value) // 0..9 if user pressed 0..9
    // );

    // (C) 7-segment display for showing `score` or other data:
    // display_controller display_inst (
    //     .clk        (clk),
    //     .rst        (rst),
    //     .value      (display_value),
    //     .segments   (segments),
    //     .digit_sel  (digit_sel)
    // );

    //-------------------------------------------------------------------------
    // 4) Main FSM
    //-------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_state      <= IDLE;
            difficulty      <= EASY;
            score           <= 14'd0;
            sequence_length <= 7'd0;
            display_index   <= 7'd0;
            input_index     <= 7'd0;
            input_buffer    <= 20'd0;
            digit_count     <= 3'd0;
            display_value   <= 14'd0;
            timer_count     <= 32'd0;
        end else begin
            case (game_state)

                //================================================================
                // IDLE: choose difficulty, start game
                //================================================================
                IDLE: begin
                    if (key_pressed) begin
                        case (keypad_value)
                            4'h1: difficulty <= EASY;
                            4'h2: difficulty <= MEDIUM;
                            4'h3: difficulty <= HARD;
                            4'hF: begin
                                // 'F' means start
                                if (difficulty == EASY)
                                    sequence_length <= 5;
                                else if (difficulty == MEDIUM)
                                    sequence_length <= 7;
                                else 
                                    sequence_length <= 10;
                                display_index <= 0;
                                game_state <= DISPLAY_SEQUENCE;
                            end
                        endcase
                    end
                end

                //================================================================
                // DISPLAY_SEQUENCE: generate random_value & store in array
                //================================================================
                DISPLAY_SEQUENCE: begin
                    if (display_index < sequence_length) begin
                        current_sequence[display_index] <= random_value;
                        display_index <= display_index + 1;
                    end else begin
                        // Done filling
                        input_index  <= 0;     // index of the random_value we check
                        digit_count  <= 0;     // user must enter 5 digits
                        input_buffer <= 20'd0; // clear buffer
                        game_state   <= WAIT_INPUT;
                    end
                end

                //================================================================
                // WAIT_INPUT: user must enter 5 digits for each random_value
                //================================================================
                WAIT_INPUT: begin
                    if (key_pressed) begin
                        // We expect keypad_value in [0..9].
                        // If it's greater than 9, maybe ignore or handle error:
                        if (keypad_value <= 4'd9) begin
                            // SHIFT IN the new digit to input_buffer.
                            // We'll place the newest digit in the *least* significant nibble:
                            // e.g. input_buffer = { input_buffer[15:0], keypad_value }
                            // So after 5 presses, input_buffer holds 5 digits.
                            input_buffer <= { input_buffer[15:0], keypad_value };

                            if (digit_count < 4) begin
                                // Not done with 5-digit entry
                                digit_count <= digit_count + 1;
                            end else begin
                                // We just entered the 5th digit:
                                digit_count <= 0; // reset for next random_value

                                // Compare user’s 5-digit input to current_sequence
                                // The random_value is stored as nib4..nib0 in current_sequence[input_index].
                                if (input_buffer == current_sequence[input_index]) begin
                                    // Good match
                                    if (input_index == (sequence_length - 1)) begin
                                        // Completed entire sequence
                                        score <= score + 1;  // or something
                                        game_state <= IDLE;  // or GAME_OVER
                                    end else begin
                                        // Move to next random_value
                                        input_index  <= input_index + 1;
                                        input_buffer <= 20'd0;
                                    end
                                end else begin
                                    // Mismatch => GAME_OVER
                                    game_state <= GAME_OVER;
                                end
                            end
                        end
                    end
                end

                //================================================================
                // GAME_OVER: Display score, wait for reset or something
                //================================================================
                GAME_OVER: begin
                    // Example: show final score
                    display_value <= score;
                    // Wait for user reset or a special key to go back to IDLE
                    // if (key_pressed && keypad_value==4'hE) game_state <= IDLE; 
                end

            endcase
        end
    end

    //-------------------------------------------------------------------------
    // 5) VGA Color Update
    //-------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rgb_reg <= 8'h00;
        end else if (p_tick) begin
            rgb_reg <= rgb_next;
        end
    end

    assign rgb = rgb_reg;

endmodule

