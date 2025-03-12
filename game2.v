module memorization_game (
    input  wire        clk,
    input  wire        rst,

    // Keypad interface
    output wire [3:0]  keypad_row,
    input  wire [3:0]  keypad_col,

    // 7-segment display
    output wire [6:0]  segments,
    output wire [3:0]  digit_sel,

    // VGA interface
    output wire        hsync,
    output wire        vsync,
    output wire [7:0]  rgb
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

    localparam MAX_SEQUENCE_LENGTH = 10;
    reg [19:0] current_sequence [0:MAX_SEQUENCE_LENGTH-1];
    reg [6:0]  sequence_length;
    reg [6:0]  display_index;
    reg [6:0]  input_index;

    reg [19:0] input_buffer;  
    reg [2:0]  digit_count;

    wire key_pressed;
    wire [3:0] keypad_value;

    keypad_controller keypad_inst (
        .clk         (clk),
        .rst         (rst),
        .row         (keypad_row),
        .col         (keypad_col),
        .value       (keypad_value),
        .key_pressed (key_pressed)
    );

    reg [19:0] random_value;
    always @(posedge clk or posedge rst) begin
        if (rst)
            random_value <= 20'd54321;
        else
            random_value <= random_value + 20'd12345;
    end

    display_controller display_inst (
        .clk      (clk),
        .rst      (rst),
        .value    (score),
        .segments (segments),
        .digit_sel(digit_sel)
    );

    assign hsync = 1'b0;
    assign vsync = 1'b0;
    assign rgb   = 8'd0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            game_state      <= ST_IDLE;
            difficulty      <= EASY;
            score           <= 14'd0;
            digit_count     <= 3'd0;
            sequence_length <= 7'd0;
            display_index   <= 7'd0;
            input_index     <= 7'd0;
            input_buffer    <= 20'd0;
        end else begin
            case (game_state)
                ST_IDLE: begin
                    if (key_pressed) begin
                        case (keypad_value)
                            4'd1: difficulty <= EASY;
                            4'd2: difficulty <= MEDIUM;
                            4'd3: difficulty <= HARD;
                            4'd15: begin
                                sequence_length <= (difficulty == EASY) ? 5 : (difficulty == MEDIUM ? 7 : 10);
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
                    if (key_pressed && keypad_value <= 4'd9) begin
                        input_buffer <= {input_buffer[15:0], keypad_value};
                        digit_count <= digit_count + 1;

                        if (digit_count == 3'd4) begin
                            digit_count <= 0;

                            if (input_buffer == current_sequence[input_index]) begin
                                if (input_index == sequence_length - 1) begin
                                    score <= score + 1;
                                    game_state <= ST_IDLE;
                                end else begin
                                    input_index  <= input_index + 1;
                                    input_buffer <= 20'd0;
                                end
                            end else begin
                                game_state <= ST_GAME_OVER;
                            end
                        end
                    end
                end

                ST_GAME_OVER: begin
                    if (key_pressed && keypad_value == 4'd15)
                        game_state <= ST_IDLE;
                end

                default: game_state <= ST_IDLE;
            endcase
        end
    end

endmodule
