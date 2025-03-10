module memorization_game (
    input  wire        clk,       // System clock
    input  wire        rst,       // Reset signal (active high)

    // Keypad interface
    output wire [3:0]  keypad_row, // Keypad row outputs
    input  wire [3:0]  keypad_col, // Keypad column inputs

    // 7-segment display (common-anode: active-low signals)
    output wire [6:0]  segments,
    output wire [3:0]  digit_sel,

    // VGA interface
    output wire        hsync,     // VGA horizontal sync
    output wire        vsync,     // VGA vertical sync
    output wire [7:0]  rgb        // 8-bit color output to VGA
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
    reg [13:0] score; // 0..9999

    // Example: storing 10 random values (20 bits each, if you’re using 20-bit RNG)
    localparam MAX_SEQUENCE_LENGTH = 10;
    reg [19:0] current_sequence [0:MAX_SEQUENCE_LENGTH-1];
    reg [6:0]  sequence_length;
    reg [6:0]  display_index;
    reg [6:0]  input_index;

    // For capturing user’s 5-digit input
    reg [19:0] input_buffer;  
    reg [2:0]  digit_count; 

    reg [31:0] timer_count;

    //-------------------------------------------------------------------------
    // 3) Keypad Scanner (Placeholder or real module)
    //-------------------------------------------------------------------------
    wire       key_pressed;
    wire [3:0] keypad_value;

    // Example if you have a scanner:
    // keypad_scanner keypad_inst (
    //     .clk         (clk),
    //     .rst         (rst),
    //     .keypad_row  (keypad_row),
    //     .keypad_col  (keypad_col),
    //     .key_pressed (key_pressed),
    //     .key_value   (keypad_value)
    // );

    // Stub signals if scanner is not used:
    assign keypad_row  = 4'b0000;
    assign key_pressed = 1'b0;
    assign keypad_value= 4'hF;

    //-------------------------------------------------------------------------
    // 4) Random Generator (Placeholder or real module)
    //-------------------------------------------------------------------------
    wire [19:0] random_value;
    // random_generator_20bit rng_inst (
    //     .clk       (clk),
    //     .rst       (rst),
    //     .seed      (20'hABCDE),
    //     .random_num(random_value)
    // );
    // For now, stub it:
    assign random_value = 20'd12345;

    //-------------------------------------------------------------------------
    // 5) 7-Segment Display Controller
    //    - You said your display_controller already does the “long if” approach
    //-------------------------------------------------------------------------
    display_controller display_inst (
        .clk      (clk),
        .rst      (rst),
        .value    (score),      // 14-bit score (0..9999)
        .segments (segments),   // active-low segments
        .digit_sel(digit_sel)   // active-low digit selector
    );

    //-------------------------------------------------------------------------
    // 6) VGA Controller + ASCII Display
    //-------------------------------------------------------------------------
    wire video_on;
    wire p_tick;
    wire [9:0] x, y;

    vga_controller vga(
        .clk      (clk),
        .rst      (rst),
        .hsync    (hsync),
        .vsync    (vsync),
        .video_on (video_on),
        .p_tick   (p_tick),
        .x        (x),
        .y        (y)
    );

    wire [7:0] rgb_next;
    reg  [7:0] rgb_reg;

    // We'll display 5 ASCII chars in `num_string`
    reg [39:0] num_string;

    ascii_display ascii_display(
        .clk         (clk),
        .video_on    (video_on),
        .x           (x),
        .y           (y),
        .show_number (1'b1),
        .num_string  (num_string),
        .rgb         (rgb_next)
    );

    // On each pixel tick, latch rgb_next
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rgb_reg <= 8'h00;
        end else if (p_tick) begin
            rgb_reg <= rgb_next;
        end
    end
    assign rgb = rgb_reg;

    //-------------------------------------------------------------------------
    // 7) Convert Score to ASCII (Optional)
    //-------------------------------------------------------------------------
    // If you want to show the score on VGA as well, do a 4-digit + space approach
    reg [3:0] thousands, hundreds, tens, ones;
    reg [7:0] ascii_thousands, ascii_hundreds, ascii_tens, ascii_ones, ascii_space;

    always @(*) begin
        // If no division is allowed, do your “long if” approach here too.
        // For brevity, we'll do division:
        thousands = (score / 1000) % 10;
        hundreds  = (score / 100 ) % 10;
        tens      = (score / 10  ) % 10;
        ones      = (score       ) % 10;

        ascii_thousands = 8'h30 + thousands; // '0' + thousands
        ascii_hundreds  = 8'h30 + hundreds;
        ascii_tens      = 8'h30 + tens;
        ascii_ones      = 8'h30 + ones;
        ascii_space     = 8'h20;            // space

        num_string = { ascii_thousands, ascii_hundreds, ascii_tens, ascii_ones, ascii_space };
    end

    //-------------------------------------------------------------------------
    // 8) Main FSM
    //-------------------------------------------------------------------------
    localparam ST_IDLE             = 2'b00;
    localparam ST_DISPLAY_SEQUENCE = 2'b01;
    localparam ST_WAIT_INPUT       = 2'b10;
    localparam ST_GAME_OVER        = 2'b11;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset
            game_state      <= ST_IDLE;
            difficulty      <= EASY;
            score           <= 14'd0;
            sequence_length <= 7'd0;
            display_index   <= 7'd0;
            input_index     <= 7'd0;
            input_buffer    <= 20'd0;
            digit_count     <= 3'd0;
            timer_count     <= 32'd0;
        end else begin
            case (game_state)

                ST_IDLE: begin
                    if (key_pressed) begin
                        case (keypad_value)
                            4'h1: difficulty <= EASY;
                            4'h2: difficulty <= MEDIUM;
                            4'h3: difficulty <= HARD;
                            4'hF: begin
                                // Start
                                if (difficulty == EASY)
                                    sequence_length <= 5;
                                else if (difficulty == MEDIUM)
                                    sequence_length <= 7;
                                else
                                    sequence_length <= 10;
                                display_index <= 0;
                                game_state    <= ST_DISPLAY_SEQUENCE;
                            end
                        endcase
                    end
                end

                ST_DISPLAY_SEQUENCE: begin
                    if (display_index < sequence_length) begin
                        current_sequence[display_index] <= random_value;
                        display_index <= display_index + 1;
                    end else begin
                        input_index  <= 0;
                        digit_count  <= 0;
                        input_buffer <= 20'd0;
                        game_state   <= ST_WAIT_INPUT;
                    end
                end

                ST_WAIT_INPUT: begin
                    if (key_pressed) begin
                        if (keypad_value <= 4'd9) begin
                            // Shift in 1 nibble
                            input_buffer <= {input_buffer[15:0], keypad_value};
                            if (digit_count < 4) begin
                                digit_count <= digit_count + 1;
                            end else begin
                                // 5 digits read
                                digit_count <= 0;
                                if (input_buffer == current_sequence[input_index]) begin
                                    // Correct
                                    if (input_index == sequence_length-1) begin
                                        // Completed entire sequence
                                        score      <= score + 1;
                                        game_state <= ST_IDLE; // or ST_GAME_OVER
                                    end else begin
                                        input_index  <= input_index + 1;
                                        input_buffer <= 20'd0;
                                    end
                                end else begin
                                    // Wrong
                                    game_state <= ST_GAME_OVER;
                                end
                            end
                        end
                    end
                end

                ST_GAME_OVER: begin
                    // Possibly display final score, wait for user reset
                end

            endcase
        end
    end

endmodule

