module memorization_game (
    input  wire        clk,
    input  wire        rst,
    input  wire        submit,

    // Keypad interface
    inout [7:0] JA,
    
    // 7-segment display
    output wire [6:0]  segments,
    output wire [3:0]  digit_sel,

    // VGA interface
    output wire        hsync,
    output wire        vsync,
    output wire [11:0] rgb,

    // LED output to show game state
    output wire [7:0]  led,
    output wire [3:0] current_key
);

    localparam ST_IDLE             = 2'b00;
    localparam ST_DISPLAY_SEQUENCE = 2'b01;
    localparam ST_WAIT_INPUT       = 2'b10;
    localparam ST_GAME_OVER        = 2'b11;

    localparam EASY   = 2'b00;
    localparam MEDIUM = 2'b01;
    localparam HARD   = 2'b10;
    
    reg [1:0]  game_state;
    reg [1:0]  difficulty;
    reg [13:0] score;

    reg [6:0]  input_index;
    reg [19:0] current_sequence;
    reg [19:0] input_buffer;
    reg [19:0] key_buffer;
    reg key_pulse;
    reg [2:0]  digit_count;
    
    wire key_pressed;
    wire [3:0] keypad_value;
    
    reg [23:0] video_timer;
    reg show_number;
    reg [1:0] sequence_index;
    wire key_detected;
    wire [19:0] sequence_out;
    
    // Keypad module
    pmod_keypad keypad_inst (
        .clk         (clk),
        .row         (JA[7:4]),
        .col         (JA[3:0]),
        .key         (keypad_value),
        .key_detected(key_detected)
    );

    // Sequence provider module
//    sequence_provider sequence_inst (
//        .clk(clk),
//        .rst(rst),
//        .next_sequence(game_state == ST_DISPLAY_SEQUENCE),
//        .sequence_out(sequence_out)
//    );

    // VGA controller
    wire [9:0] x, y;          
    wire video_on, p_tick;    
    wire [11:0] rgb_next;     

    vga_controller vga(
        .clk(clk),
        .rst(rst),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .p_tick(p_tick),
        .x(x),
        .y(y)
    );
    
    // ASCII display
    ascii_display ascii_display_inst(
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .show_number(show_number),     
        .num_string(current_sequence),
        .rgb(rgb)       
    );

    // 7-segment display controller
    display_controller display_inst (
        .clk      (clk),
        .rst      (rst),
        .value    (score),
        .segments (segments),
        .digit_sel(digit_sel)
    );
   
     // wire [19:0] random_value;
     random_generator_20bit rng_inst (
         .clk       (clk),
         .rst       (rst),
         .seed      (20'hABCDE),
         .random_num(sequence_out)
     );
   
    
    // Debounce signals for key detection
    wire db_key_detected, db_rst, db_submit;
    
    debouncer debouncer_inst (
        .button(key_detected),
        .clk(clk),
        .button_state(db_key_detected)
    );

    debouncer db_rst_inst (.clk(clk), .button(rst), .button_state(db_rst));
    debouncer db_submit_inst (.clk(clk), .button(submit), .button_state(db_submit));

    // Register to store previous state of submit button for edge detection
    reg db_submit_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            db_submit_prev <= 0;
        end else begin
            db_submit_prev <= db_submit; // Update previous state
        end
    end

    initial begin
        digit_count <= 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_state      <= ST_IDLE;
            difficulty      <= EASY;
            score           <= 14'd0;
            input_index     <= 7'd0;
            input_buffer    <= 20'd0;
            key_buffer      <= 20'd0;
            digit_count     <= 3'd0;
            video_timer     <= 24'd0;
            show_number     <= 1'b0;
            sequence_index  <= 2'd0;
        end else begin
            // Edge detection: Only register input when submit transitions from 1 -> 0
            if (!db_submit && db_submit_prev) begin
                input_buffer <= {keypad_value, input_buffer[19:4]};
                digit_count <= digit_count + 1;
            end

            // Game state logic (uncommented for clarity)
            case (game_state)
                ST_IDLE: begin
                    if (key_detected) begin
                        case (keypad_value)
                            4'd1: difficulty <= EASY;
                            4'd2: difficulty <= MEDIUM;
                            4'd3: difficulty <= HARD;
                            4'd15: begin
                                current_sequence <= sequence_out;
                                game_state      <= ST_DISPLAY_SEQUENCE;
                                case (difficulty)
                                    EASY:   video_timer <= 24'd16000000;
                                    MEDIUM: video_timer <= 24'd5000000;
                                    HARD:   video_timer <= 24'd3000000;
                                endcase
                                show_number     <= 1'b1;
                            end
                        endcase
                    end
                end

                ST_DISPLAY_SEQUENCE: begin
                    if (video_timer > 0) begin
                        video_timer <= video_timer - 1;
                    end else begin
                        show_number <= 1'b0;
                        game_state  <= ST_WAIT_INPUT;
                    end
                end

                ST_WAIT_INPUT: begin
                    if (digit_count == 5) begin
                        if (input_buffer == current_sequence) begin
                            if (score == 14'd9999)
                                score <= 0;
                            else
                                score <= score + 1;
                            game_state <= ST_DISPLAY_SEQUENCE;
                            current_sequence <= sequence_out;
                            case (difficulty)
                                EASY:   video_timer <= 24'd16000000;
                                MEDIUM: video_timer <= 24'd5000000;
                                HARD:   video_timer <= 24'd3000000;
                            endcase
                            show_number     <= 1'b1;
                            digit_count <= 0;
                        end else begin
                            game_state <= ST_GAME_OVER;
                        end
                    end
                end

                ST_GAME_OVER: begin
                    if (keypad_value == 4'b1110) begin
                        game_state <= ST_IDLE;
                        digit_count <= 0;
                    end
                end

                default: game_state <= ST_IDLE;
            endcase
        end
    end

    // LED logic to show game state
    assign led[7:6] = game_state;
    assign led[3:0] = input_buffer[19:16]; 
    assign led[5:4] = 2'b00;
    assign current_key = keypad_value;

endmodule
