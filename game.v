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
    localparam MAX_SEQUENCE_LENGTH = 100; // Maximum possible sequence length TODO
    
    // Internal registers and wires
    reg [1:0] game_state;
    reg [1:0] difficulty;
    reg [13:0] score; // 0-9999
    reg [3:0] current_sequence [0:MAX_SEQUENCE_LENGTH-1];
    reg [6:0] sequence_length;
    reg [6:0] display_index;
    reg [6:0] input_index;
    reg [3:0] input_buffer;
    reg [31:0] timer_count;
    
    // Interface with submodules
    wire [3:0] keypad_value;
    wire key_pressed;
    reg [13:0] display_value;
    wire [3:0] random_num;
    reg [15:0] random_seed;
    
    // Submodule instantiations
    keypad_controller keypad_ctrl (
        .clk(clk),
        .rst(rst),
        .row(keypad_row),
        .col(keypad_col),
        .value(keypad_value),
        .key_pressed(key_pressed)
    );
    
    display_controller display_ctrl (
        .clk(clk),
        .rst(rst),
        .value(display_value),
        .segments(segments),
        .digit_sel(digit_sel)
    );
    
    random_generator rand_gen (
        .clk(clk),
        .rst(rst),
        .seed(random_seed),
        .random_num(random_num)
    );
    
    // Random seed generator
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            random_seed <= 16'd0;
        end else begin
            random_seed <= random_seed + 1'b1;
        end
    end
    
    // Main game control process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_state <= IDLE;
            difficulty <= EASY;
            score <= 14'd0;
            sequence_length <= 7'd0;
            display_index <= 7'd0;
            input_index <= 7'd0;
            display_value <= 14'd0;
            timer_count <= 32'd0;
            input_buffer <= 4'd0;
            
            // Initialize sequence array
            for (integer i = 0; i < MAX_SEQUENCE_LENGTH; i = i + 1) begin
                current_sequence[i] <= 4'd0;
            end
        end else begin
            case (game_state)
                IDLE: begin
                    display_value <= 14'd0;
                    
                    // Check for difficulty selection (A, B, or C keys)
                    if (key_pressed) begin
                        if (keypad_value == 4'd10) begin    // A key (Easy)
                            difficulty <= EASY;
                            game_state <= DISPLAY_SEQUENCE;
                            score <= 14'd0;
                            sequence_length <= 7'd1;
                            // Add a random number to start the sequence
                            current_sequence[0] <= random_num;
                        end else if (keypad_value == 4'd11) begin // B key (Medium)
                            difficulty <= MEDIUM;
                            game_state <= DISPLAY_SEQUENCE;
                            score <= 14'd0;
                            sequence_length <= 7'd1;
                            // Add a random number to start the sequence
                            current_sequence[0] <= random_num;
                        end else if (keypad_value == 4'd12) begin // C key (Hard)
                            difficulty <= HARD;
                            game_state <= DISPLAY_SEQUENCE;
                            score <= 14'd0;
                            sequence_length <= 7'd1;
                            // Add a random number to start the sequence
                            current_sequence[0] <= random_num;
                        end
                    end
                end
                
                DISPLAY_SEQUENCE: begin
                    // Display sequence
                    if (timer_count == 32'd0) begin
                        display_value <= {10'd0, current_sequence[display_index]};
                    end
                    
                    timer_count <= timer_count + 1'b1;
                    
                    // Determine delay based on difficulty
                    if ((difficulty == EASY && timer_count >= 32'd50000000) ||    // 1 second at 50MHz
                        (difficulty == MEDIUM && timer_count >= 32'd30000000) ||  // 0.6 seconds
                        (difficulty == HARD && timer_count >= 32'd15000000)) begin // 0.3 seconds
                        
                        timer_count <= 32'd0;
                        display_index <= display_index + 1'b1;
                        
                        if (display_index >= sequence_length - 1'b1) begin
                            display_index <= 7'd0;
                            game_state <= WAIT_INPUT;
                            display_value <= 14'd0; // Clear display
                        end
                    end
                end
                
                WAIT_INPUT: begin
                    if (key_pressed) begin
                        if (keypad_value <= 4'd9) begin
                            // Store input in buffer
                            input_buffer <= keypad_value;
                            // Display the input
                            display_value <= {10'd0, keypad_value};
                        end else if (keypad_value == 4'd13) begin // D key (Submit)
                            // Check if input matches sequence
                            if (input_buffer == current_sequence[input_index]) begin
                                input_index <= input_index + 1'b1;
                                
                                // If completed the entire sequence
                                if (input_index >= sequence_length - 1'b1) begin
                                    // Update score and add a new number to sequence
                                    score <= sequence_length;
                                    sequence_length <= sequence_length + 1'b1;
                                    current_sequence[sequence_length] <= random_num;
                                    input_index <= 7'd0;
                                    display_index <= 7'd0;
                                    game_state <= DISPLAY_SEQUENCE;
                                end
                            end else begin
                                // Wrong input, game over
                                game_state <= GAME_OVER;
                                display_value <= score;
                            end
                        end
                    end
                end
                
                GAME_OVER: begin
                    // Display score
                    display_value <= score;
                    
                    // Check for restart (A, B, or C keys)
                    if (key_pressed) begin
                        if (keypad_value == 4'd10 || keypad_value == 4'd11 || keypad_value == 4'd12) begin
                            game_state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end

endmodule

