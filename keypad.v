module keypad(
    input clk,
    input [3:0] row,               // Row input from keypad
    output reg [3:0] col,          // Column output to keypad
    output reg [3:0] key,          // Key pressed value
    output reg key_pressed         // Signal indicating if the key is new or old
);

    // Counter bits
    localparam BITS = 20;
         
    // Number of clk ticks for 1ms: 100Mhz / 1000
    localparam ONE_MS_TICKS = 100000000 / 1000;
         
    // Settle time of 1 us = 100Mhz / 1000000
    localparam SETTLE_TIME = 100000000 / 1000000;
    
    // Internal 20-bit counter for timing
    reg [BITS-1:0] key_counter = 0;
    reg rst = 1'b0;

    // Key pressed tracking
    reg [3:0] last_key = 4'b0000;  // To store the last pressed key (set to some default)

    // Counter for generating 1ms intervals
    always @ (posedge clk) begin
        if (rst) 
            key_counter <= 0; // Reset the counter
        else 
            key_counter <= key_counter + 1;
    end

    // Keypad scanning logic
    always @ (posedge clk) begin
        // Default value when no key is pressed
        key <= 4'b0000;  // No key pressed (default)
        key_pressed <= 1'b0;  // Assume no key is pressed (old key state)

        case (key_counter)
            0: begin
                rst <= 1'b0;
            end

            ONE_MS_TICKS: begin
                col <= 4'b0111;
            end

            ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key <= 4'b0001; // 1
                    4'b1011: key <= 4'b0100; // 4
                    4'b1101: key <= 4'b0111; // 7
                    4'b1110: key <= 4'b0000; // 0
                endcase
            end

            2 * ONE_MS_TICKS: begin
                col <= 4'b1011;
            end

            2 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key <= 4'b0010; // 2
                    4'b1011: key <= 4'b0101; // 5
                    4'b1101: key <= 4'b1000; // 8
                    4'b1110: key <= 4'b1010; // A (Changed from F to A)
                endcase
            end

            3 * ONE_MS_TICKS: begin
                col <= 4'b1101;
            end

            3 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key <= 4'b0011; // 3
                    4'b1011: key <= 4'b0110; // 6
                    4'b1101: key <= 4'b1001; // 9
                    4'b1110: key <= 4'b1110; // E
                endcase
            end

            4 * ONE_MS_TICKS: begin
                col <= 4'b1110;
            end

            4 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key <= 4'b1010; // A
                    4'b1011: key <= 4'b1011; // B
                    4'b1101: key <= 4'b1100; // C
                    4'b1110: key <= 4'b1101; // D
                endcase

                // Reset the counter                
                rst <= 1'b1;
            end    
        endcase

        // Detect if the key is "new" or "old"
        if (key != last_key) begin
            key_pressed <= 1'b1;  // Mark as new key press if key is changed
            last_key <= key;  // Update last_key with the current key
        end else if (key == 4'b0000) begin
            key_pressed <= 1'b0;  // No key pressed, reset key_pressed
        end
    end
endmodule
