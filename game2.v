module memorization_game (
    input  wire        clk,
    input  wire        rst,

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
    output wire [3:0]  led  // Added LED output for game state
);

    // Game state definitions
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
    reg key_pulse;          // Synchronized one-clock pulse for key press
    reg [2:0]  digit_count;
    
    wire [3:0] keypad_value;
    
    reg [23:0] video_timer;
    reg show_number;
    reg [1:0] sequence_index;
    wire key_detected;
    wire [19:0] sequence_out;
    
    // Double flip-flop synchronizer for key_detected
    reg key_detected_sync, key_detected_sync_d;
    always @(posedge clk) begin
        key_detected_sync   <= key_detected;
        key_detected_sync_d <= key_detected_sync;
    end

    // Synchronous rising-edge detection for key press
    always @(posedge clk) begin
        if (~key_detected_sync_d & key_detected_sync) begin
            // On a rising edge, update key_buffer and digit_count
            key_buffer  <= { key_buffer[15:0], keypad_value };
            digit_count <= digit_count + 1;
            key_pulse   <= 1'b1;
        end else begin
            key_pulse   <= 1'b0;
        end
    end

    pmod_keypad keypad_inst (
        .clk         (clk),
        .row         (JA[7:4]),
        .col         (JA[3:0]),
        .key         (keypad_value),
        .key_detected(key_detected)
    );

    sequence_provider sequence_inst (
        .clk(clk),
        .rst(rst),
        .next_sequence(game_state == ST_DISPLAY_SEQUENCE),
        .sequence_out(sequence_out)
    );

    wire [9:0] x, y;          // VGA coordinates
    wire video_on, p_tick;    // Video signal and pixel tick

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
    
    ascii_display ascii_display_inst(
        .clk(clk),
        .video_on(video_on),
        .x(x),
        .y(y),
        .show_number(show_number),     
        .num_string(current_sequence),
        .rgb(rgb)       
    );

    display_controller display_inst (
        .clk      (clk),
        .rst      (rst),
        .value    (score),
        .segments (segments),
        .digit_sel(digit_sel)
    );
  
    // Main game state machine using synchronized key_pulse
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
            key_pulse       <= 1'b0;
        end else begin
            // Update input_buffer when a key press pulse occurs
            if (key_pulse) begin
                input_buffer <= key_buffer;
            end

            case (game_state)
                ST_IDLE: begin
                    if (key_pulse) begin
                        case (keypad_value)
                            4'd1: difficulty <= EASY;
                            4'd2: difficulty <= MEDIUM;
                            4'd3: difficulty <= HARD;
                            4'd15: begin
                                current_sequence <= sequence_out;
                                game_state       <= ST_DISPLAY_SEQUENCE;
                                case (difficulty)
                                    EASY:   video_timer <= 24'd7000000;
                                    MEDIUM: video_timer <= 24'd5000000;
                                    HARD:   video_timer <= 24'd3000000;
                                endcase
                                show_number <= 1'b1;
                            end
                        endcase
                    end
                end

                ST_DISPLAY_SEQUENCE: begin
                    if (video_timer > 0)
                        video_timer <= video_timer - 1;
                    else begin
                        show_number <= 1'b0;
                        game_state  <= ST_WAIT_INPUT;
                    end
                end

                ST_WAIT_INPUT: begin
                    if (digit_count == 4) begin
                        if (input_buffer == current_sequence) begin
                            score      <= score + 1;
                            game_state <= ST_DISPLAY_SEQUENCE;
                            current_sequence <= sequence_out;
                            case (difficulty)
                                EASY:   video_timer <= 24'd7000000;
                                MEDIUM: video_timer <= 24'd5000000;
                                HARD:   video_timer <= 24'd3000000;
                            endcase
                            show_number <= 1'b1;
                        end else begin
                            game_state <= ST_GAME_OVER;
                        end
                    end
                end

                ST_GAME_OVER: begin
                    if (key_pulse && (keypad_value == 4'd15))
                        game_state <= ST_IDLE;
                end

                default: game_state <= ST_IDLE;
            endcase
        end
    end

    // LED assignment to display game state (here using digit_count; adjust if needed)
    assign led = digit_count;

endmodule
