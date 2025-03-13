module pmod_keypad(
    input         clk,
    input  [3:0]  row,
    output reg [3:0] col,
    output reg [3:0] key,
    output reg    key_detected  // One-clock pulse when a new key press is detected
);
    // Parameters for a 100 MHz clock
    localparam BITS           = 20;
    localparam ONE_MS_TICKS   = 100000000 / 1000;   // 100,000 cycles ≈ 1 ms
    localparam SETTLE_TIME    = 100000000 / 1000000;  // 100 cycles ≈ 1 µs
    
    // Internal 20-bit counter
    reg [BITS-1:0] key_counter;
    
    // Add debounce and key state tracking
    reg [15:0] key_state;     // Current state of all 16 keys
    reg [15:0] last_key_state; // Previous state of all 16 keys
    reg [3:0] current_key;    // Currently detected key
    reg key_valid;            // Whether a valid key has been detected
    
    // Main always block: counter, scanning, and key assignment
    always @(posedge clk) begin
        // Default values
        key_detected <= 1'b0;
        key_valid <= 1'b0;
        
        // Increment counter until the end of a full scan cycle, then reset it.
        if (key_counter < (4 * ONE_MS_TICKS + SETTLE_TIME))
            key_counter <= key_counter + 1;
        else begin
            key_counter <= 0;
            
            // Only update key states at the end of a full scan cycle
            last_key_state <= key_state;
            
            // Check if any new key was pressed 
            if (key_state != 16'h0000 && last_key_state == 16'h0000) begin
                // Find the position of the first '1' bit in key_state
                if (key_state[0]) current_key <= 4'h0;        // Key 0
                else if (key_state[1]) current_key <= 4'h1;   // Key 1
                else if (key_state[2]) current_key <= 4'h2;   // Key 2
                else if (key_state[3]) current_key <= 4'h3;   // Key 3
                else if (key_state[4]) current_key <= 4'h4;   // Key 4
                else if (key_state[5]) current_key <= 4'h5;   // Key 5
                else if (key_state[6]) current_key <= 4'h6;   // Key 6
                else if (key_state[7]) current_key <= 4'h7;   // Key 7
                else if (key_state[8]) current_key <= 4'h8;   // Key 8
                else if (key_state[9]) current_key <= 4'h9;   // Key 9
                else if (key_state[10]) current_key <= 4'hA;  // Key A
                else if (key_state[11]) current_key <= 4'hB;  // Key B
                else if (key_state[12]) current_key <= 4'hC;  // Key C
                else if (key_state[13]) current_key <= 4'hD;  // Key D
                else if (key_state[14]) current_key <= 4'hE;  // Key E
                else if (key_state[15]) current_key <= 4'hF;  // Key F
                
                key <= current_key;
                key_detected <= 1'b1;  // Generate a single-cycle pulse
            end
        end
        
        // Scanning and key determination logic
        case (key_counter)
            // First scan (approx. 1 ms period)
            ONE_MS_TICKS: begin
                col <= 4'b0111;
            end
            ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key_state[1] <= 1;  // Key 1
                    4'b1011: key_state[4] <= 1;  // Key 4
                    4'b1101: key_state[7] <= 1;  // Key 7
                    4'b1110: key_state[0] <= 1;  // Key 0
                    default: begin
                        key_state[1] <= 0;
                        key_state[4] <= 0;
                        key_state[7] <= 0;
                        key_state[0] <= 0;
                    end
                endcase
            end
            
            // Second scan (approx. 2 ms period)
            2 * ONE_MS_TICKS: begin
                col <= 4'b1011;
            end
            2 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key_state[2] <= 1;  // Key 2
                    4'b1011: key_state[5] <= 1;  // Key 5
                    4'b1101: key_state[8] <= 1;  // Key 8
                    4'b1110: key_state[15] <= 1; // Key F
                    default: begin
                        key_state[2] <= 0;
                        key_state[5] <= 0;
                        key_state[8] <= 0;
                        key_state[15] <= 0;
                    end
                endcase
            end
            
            // Third scan (approx. 3 ms period)
            3 * ONE_MS_TICKS: begin
                col <= 4'b1101;
            end
            3 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key_state[3] <= 1;  // Key 3
                    4'b1011: key_state[6] <= 1;  // Key 6
                    4'b1101: key_state[9] <= 1;  // Key 9
                    4'b1110: key_state[14] <= 1; // Key E
                    default: begin
                        key_state[3] <= 0;
                        key_state[6] <= 0;
                        key_state[9] <= 0;
                        key_state[14] <= 0;
                    end
                endcase
            end
            
            // Fourth scan (approx. 4 ms period)
            4 * ONE_MS_TICKS: begin
                col <= 4'b1110;
            end
            4 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: key_state[10] <= 1; // Key A
                    4'b1011: key_state[11] <= 1; // Key B
                    4'b1101: key_state[12] <= 1; // Key C
                    4'b1110: key_state[13] <= 1; // Key D
                    default: begin
                        key_state[10] <= 0;
                        key_state[11] <= 0;
                        key_state[12] <= 0;
                        key_state[13] <= 0;
                    end
                endcase
            end
            
            // Default: do nothing
            default: ;
        endcase
    end
endmodule
