// TOP memorization_game.v
module memorization_game (
    input wire clk,            // System clock
    input wire rst,            // Reset signal (active high)
    output wire [3:0] keypad_row,  // Keypad row outputs
    input wire [3:0] keypad_col,   // Keypad column inputs
    output wire [6:0] segments,    // 7-segment display segments
    output wire [3:0] digit_sel    // 7-segment display digit selector
);

    // Game states
    localparam IDLE = 2'b00;             // Waiting for difficulty selection
    localparam DISPLAY_SEQUENCE = 2'b01; // Displaying the sequence
    localparam WAIT_INPUT = 2'b10;       // Waiting for player input
    localparam GAME_OVER = 2'b11;        // Game over, displaying score

    // Difficulty levels
    localparam EASY = 2'b00;
    localparam MEDIUM = 2'b01;
    localparam HARD = 2'b10;

    // Constants
    localparam MAX_SEQUENCE_LENGTH = 100; // Maximum possible sequence length

    // Internal registers and wires
    reg [1:0] game_state;
    reg [1:0] difficulty;
    reg [13:0] score; // 0-9999
    reg [4:0] current_sequence [0:MAX_SEQUENCE_LENGTH-1]; // Updated to 5-bit
    reg [6:0] sequence_length;
    reg [6:0] display_index;
    reg [6:0] input_index;
    reg [4:0] input_buffer; // Updated to 5-bit
    reg [31:0] timer_count;

    // Interface with submodules
    wire [4:0] random_value; // Updated to 5-bit
    wire key_pressed;
    reg [13:0] display_value;

    // Instantiate the random number generator (5-bit version)
    random_generator rng_inst (
        .clk(clk),
        .rst(rst),
        .seed(16'hACE1), // Example seed
        .random_num(random_value) // Updated to 5-bit output
    );

    // Game logic (example: generating a random sequence)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_state <= IDLE;
            sequence_length <= 7'd0;
            input_index <= 7'd0;
            display_index <= 7'd0;
            score <= 14'd0;
        end else begin
            case (game_state)
                IDLE: begin
                    // Initialize game state
                    if (/* Start game condition */) begin
                        game_state <= DISPLAY_SEQUENCE;
                        sequence_length <= (difficulty == EASY) ? 10 :
                                           (difficulty == MEDIUM) ? 20 : 30;
                        display_index <= 0;
                    end
                end

                DISPLAY_SEQUENCE: begin
                    if (display_index < sequence_length) begin
                        current_sequence[display_index] <= random_value; // Store 5-bit random value
                        display_index <= display_index + 1;
                    end else begin
                        game_state <= WAIT_INPUT;
                        input_index <= 0;
                    end
                end

                WAIT_INPUT: begin
                    if (key_pressed) begin
                        input_buffer <= keypad_value; // Store player input
                        if (input_buffer != current_sequence[input_index]) begin
                            game_state <= GAME_OVER; // Incorrect input
                        end else if (input_index == sequence_length - 1) begin
                            game_state <= IDLE; // Sequence completed
                            score <= score + 1; // Increase score
                        end else begin
                            input_index <= input_index + 1;
                        end
                    end
                end

                GAME_OVER: begin
                    // Handle game over state
                end

            endcase
        end
    end

endmodule

