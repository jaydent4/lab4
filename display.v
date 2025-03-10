module display_controller (
    input wire clk,
    input wire rst,
    input wire [13:0] value,    // 0-9999 value to display
    output reg [6:0] segments,  // 7-segment display segments (active low)
    output reg [3:0] digit_sel  // 7-segment display digit selector (active low)
);

    // Internal registers
    reg [15:0] refresh_counter;
    reg [1:0] active_digit;      // Current active digit (0..3)
    reg [3:0] digit_value;       // BCD value for the current digit

    // BCD "digits"
    reg [3:0] thousands;
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;

    // We'll use this to carry the leftover after subtracting out thousands,
    // hundreds, etc.
    reg [13:0] remainder;

    //-------------------------------------------------------------------------
    // 1) Extract thousands, hundreds, tens, and ones with NO division/modulus.
    //    We do this by checking thresholds and subtracting constants directly.
    //-------------------------------------------------------------------------
    always @(*) begin

        // ---------------------
        // Thousands Digit
        // ---------------------
        if (value >= 9000) begin
            thousands = 9;
            remainder = value - 9000;
        end else if (value >= 8000) begin
            thousands = 8;
            remainder = value - 8000;
        end else if (value >= 7000) begin
            thousands = 7;
            remainder = value - 7000;
        end else if (value >= 6000) begin
            thousands = 6;
            remainder = value - 6000;
        end else if (value >= 5000) begin
            thousands = 5;
            remainder = value - 5000;
        end else if (value >= 4000) begin
            thousands = 4;
            remainder = value - 4000;
        end else if (value >= 3000) begin
            thousands = 3;
            remainder = value - 3000;
        end else if (value >= 2000) begin
            thousands = 2;
            remainder = value - 2000;
        end else if (value >= 1000) begin
            thousands = 1;
            remainder = value - 1000;
        end else begin
            thousands = 0;
            remainder = value;  // no thousands to subtract
        end

        // ---------------------
        // Hundreds Digit
        // ---------------------
        if (remainder >= 900) begin
            hundreds  = 9;
            remainder = remainder - 900;
        end else if (remainder >= 800) begin
            hundreds  = 8;
            remainder = remainder - 800;
        end else if (remainder >= 700) begin
            hundreds  = 7;
            remainder = remainder - 700;
        end else if (remainder >= 600) begin
            hundreds  = 6;
            remainder = remainder - 600;
        end else if (remainder >= 500) begin
            hundreds  = 5;
            remainder = remainder - 500;
        end else if (remainder >= 400) begin
            hundreds  = 4;
            remainder = remainder - 400;
        end else if (remainder >= 300) begin
            hundreds  = 3;
            remainder = remainder - 300;
        end else if (remainder >= 200) begin
            hundreds  = 2;
            remainder = remainder - 200;
        end else if (remainder >= 100) begin
            hundreds  = 1;
            remainder = remainder - 100;
        end else begin
            hundreds  = 0;
        end

        // ---------------------
        // Tens Digit
        // ---------------------
        if (remainder >= 90) begin
            tens      = 9;
            remainder = remainder - 90;
        end else if (remainder >= 80) begin
            tens      = 8;
            remainder = remainder - 80;
        end else if (remainder >= 70) begin
            tens      = 7;
            remainder = remainder - 70;
        end else if (remainder >= 60) begin
            tens      = 6;
            remainder = remainder - 60;
        end else if (remainder >= 50) begin
            tens      = 5;
            remainder = remainder - 50;
        end else if (remainder >= 40) begin
            tens      = 4;
            remainder = remainder - 40;
        end else if (remainder >= 30) begin
            tens      = 3;
            remainder = remainder - 30;
        end else if (remainder >= 20) begin
            tens      = 2;
            remainder = remainder - 20;
        end else if (remainder >= 10) begin
            tens      = 1;
            remainder = remainder - 10;
        end else begin
            tens      = 0;
        end

        // ---------------------
        // Ones Digit
        // ---------------------
        // At this point, remainder is between 0 and 9 inclusive
        ones = remainder[3:0];
    end

    //-------------------------------------------------------------------------
    // 2) 7-Segment Lookup Table (Active-Low, for Common-Anode)
    //-------------------------------------------------------------------------
    wire [6:0] segment_lut [0:9];
    assign segment_lut[0] = 7'b1000000; // 0 
    assign segment_lut[1] = 7'b1111001; // 1
    assign segment_lut[2] = 7'b0100100; // 2
    assign segment_lut[3] = 7'b0110000; // 3
    assign segment_lut[4] = 7'b0011001; // 4
    assign segment_lut[5] = 7'b0010010; // 5
    assign segment_lut[6] = 7'b0000010; // 6
    assign segment_lut[7] = 7'b1111000; // 7
    assign segment_lut[8] = 7'b0000000; // 8
    assign segment_lut[9] = 7'b0010000; // 9

    //-------------------------------------------------------------------------
    // 3) Display Multiplexing (Refresh ~1 kHz)
    //-------------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 16'd0;
            active_digit    <= 2'd0;
            digit_value     <= 4'd0;
            digit_sel       <= 4'b1111;     // disable all digits (active low)
            segments        <= 7'b1111111;  // all segments off
        end else begin
            // ~1 kHz refresh (for 50MHz clock)
            if (refresh_counter < 16'd50000) begin
                refresh_counter <= refresh_counter + 1;
            end else begin
                refresh_counter <= 16'd0;

                // Move to next digit (0->1->2->3->0->...)
                active_digit <= active_digit + 1;

                // Pick which BCD digit to display
                case (active_digit)
                    2'b00: digit_value <= thousands;
                    2'b01: digit_value <= hundreds;
                    2'b10: digit_value <= tens;
                    2'b11: digit_value <= ones;
                endcase

                // Activate exactly one digit (active low)
                case (active_digit)
                    2'b00: digit_sel <= 4'b1110; // thousands
                    2'b01: digit_sel <= 4'b1101; // hundreds
                    2'b10: digit_sel <= 4'b1011; // tens
                    2'b11: digit_sel <= 4'b0111; // ones
                endcase

                // Update segments (active low)
                segments <= segment_lut[digit_value];
            end
        end
    end

endmodule

