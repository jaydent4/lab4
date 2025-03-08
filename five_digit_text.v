module five_digit_text(
    input clk,
    input [3:0] key,               // Key input from keypad module
    input key_pressed,
    output reg [19:0] num_string   // 5-digit number in 20-bit register
);

    // To store digits, with space for 5 digits
    reg [3:0] digit_counter;       // To count which digit we're on (0 to 4)
    reg [3:0] digit_0;
    reg [3:0] digit_1;
    reg [3:0] digit_2;
    reg [3:0] digit_3;
    reg [3:0] digit_4;
    
    // Previous key state for edge detection
    reg [3:0] key_prev;            // Previous value of the key
    
    // Initialize registers
    initial begin
        digit_0 = 4'b0000;  // Initial value of digit_0
        digit_1 = 4'b0000;  // Initial value of digit_1
        digit_2 = 4'b0000;  // Initial value of digit_2
        digit_3 = 4'b0000;  // Initial value of digit_3
        digit_4 = 4'b0000;  // Initial value of digit_4
        digit_counter = 0;  // Start with the first digit
        num_string = 20'b0; // Initialize num_string to 0
        key_prev = 4'b1110;  // Set key_prev to 4'b1111 (no key pressed initially)
    end
    
    // Store key when valid, with edge detection
    always @(posedge clk) begin
        // Edge detection: detect when key goes from 4'b1111 to any other key
        if (key_pressed && key != 4'b1110 && key_prev == 4'b1110) begin
            // If the key is a number key (not 'F' or 'B')
            if (key != 4'b1011 && key != 4'b1101 && key != 4'b1111) begin
                case (digit_counter)
                    0: digit_0 = key;
                    1: digit_1 = key;
                    2: digit_2 = key;
                    3: digit_3 = key;
                    4: digit_4 = key;
                endcase
            end
            // If the 'F' button (4'b1110) is pressed, move to the next digit
            else if (key_pressed && key == 4'b1111 && key_prev != 4'b1111) begin
                if (digit_counter < 4) begin
                    digit_counter = digit_counter + 1; // Move forward a digit
                end
            end
            // If the 'B' button (4'b1011) is pressed, move to the previous digit
            else if (key_pressed && key == 4'b1011 && key_prev != 4'b1011) begin
                if (digit_counter > 0) begin
                    digit_counter = digit_counter - 1; // Move back a digit
                end
            end
            // If the 'Clear' button (4'b1101) is pressed, reset everything
            else if (key_pressed && key == 4'b1101 && key_prev != 4'b1101) begin
                digit_counter <= 0;
                digit_0 = 4'b0000;
                digit_1 = 4'b0000;
                digit_2 = 4'b0000;
                digit_3 = 4'b0000;
                digit_4 = 4'b0000;
            end
        end

        // Update the previous key state for next clock cycle
        key_prev <= key;
        
        // Update num_string to represent the 5 digits stored
        num_string <= {digit_4, digit_3, digit_2, digit_1, digit_0};
    end
endmodule
