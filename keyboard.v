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

    // Internal 20-bit counter (integrated instead of using counter_n)
    wire [BITS-1:0] key_counter;
    reg rst = 1'b0;
    
    
    counter_n #(.BITS(BITS)) counter(
        .clk(clk),
        .rst(rst),
        .q(key_counter)
    );
    // Main always block: counter, scanning, and positive edge detection
    always @(posedge clk) begin
        // --- Scanning and Key Assignment ---
        key_detected <= 0;
        case (key_counter)
            // --- First scan (approx. 1 ms period) ---
            ONE_MS_TICKS: begin
                col <= 4'b0111;
            end
            ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: begin key <= 4'b0001; key_detected <= 1; end // Key 1
                    4'b1011: begin key <= 4'b0100; key_detected <= 1; end // Key 4
                    4'b1101: begin key <= 4'b0111; key_detected <= 1; end // Key 7
                    4'b1110: begin key <= 4'b0000; key_detected <= 1; end // Key 0
                endcase
            end

            // --- Second scan (approx. 2 ms period) ---
            2 * ONE_MS_TICKS: begin
                col <= 4'b1011;
            end
            2 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: begin key <= 4'b0010; key_detected <= 1; end // Key 2
                    4'b1011: begin key <= 4'b0101; key_detected <= 1; end // Key 5
                    4'b1101: begin key <= 4'b1000; key_detected <= 1; end // Key 8
                    4'b1110: begin key <= 4'b1111; key_detected <= 1; end // Key F
                endcase
            end

            // --- Third scan (approx. 3 ms period) ---
            3 * ONE_MS_TICKS: begin
                col <= 4'b1101;
            end
            3 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: begin key <= 4'b0011; key_detected <= 1; end // Key 3
                    4'b1011: begin key <= 4'b0110; key_detected <= 1; end // Key 6
                    4'b1101: begin key <= 4'b1001; key_detected <= 1; end // Key 9
                    4'b1110: begin key <= 4'b1110; key_detected <= 1; end // Key E
                endcase
            end

            // --- Fourth scan (approx. 4 ms period) ---
            4 * ONE_MS_TICKS: begin
                col <= 4'b1110;
            end
            4 * ONE_MS_TICKS + SETTLE_TIME: begin
                case (row)
                    4'b0111: begin key <= 4'b1010; key_detected <= 1; end // Key A
                    4'b1011: begin key <= 4'b1011; key_detected <= 1; end // Key B
                    4'b1101: begin key <= 4'b1100; key_detected <= 1; end // Key C
                    4'b1110: begin key <= 4'b1101; key_detected <= 1; end // Key D
                endcase
                
                rst <= 0; 
            end
        endcase

    end

endmodule