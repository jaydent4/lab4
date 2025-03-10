// Display Controller Module - display_controller.v
module display_controller (
    input wire clk,
    input wire rst,
    input wire [13:0] value,    // 0-9999 value to display
    output reg [6:0] segments,  // 7-segment display segments (active low)
    output reg [3:0] digit_sel  // 7-segment display digit selector (active low)
);

    // Internal registers
    reg [15:0] refresh_counter;
    reg [1:0] active_digit;     // Current active digit
    reg [3:0] digit_value;      // Value to display on current digit
    
    // BCD conversion registers
    reg [3:0] thousands;
    reg [3:0] hundreds;
    reg [3:0] tens;
    reg [3:0] ones;
    
    // BCD conversion process
    always @(value) begin
        
    end
    
    // Display multiplexing process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_counter <= 16'd0;
            active_digit <= 2'd0;
            digit_value <= 4'd0;
            digit_sel <= 4'b1111;
        end else begin
            // Refresh at ~1kHz (50MHz / 50000)
            if (refresh_counter < 16'd50000) begin
                refresh_counter <= refresh_counter + 1'b1;
            end else begin
                refresh_counter <= 16'd0;
                
                // Rotate through digits
                if (active_digit == 2'd3) begin
                    active_digit <= 2'd0;
                end else begin
                    active_digit <= active_digit + 1'b1;
                end
                
                // Set active digit and value
                case (active_digit)
                    2'd0: begin
                        digit_sel <= 4'b0111;
                        digit_value <= thousands;
                    end
                    2'd1: begin
                        digit_sel <= 4'b1011;
                        digit_value <= hundreds;
                    end
                    2'd2: begin
                        digit_sel <= 4'b1101;
                        digit_value <= tens;
                    end
                    2'd3: begin
                        digit_sel <= 4'b1110;
                        digit_value <= ones;
                    end
                endcase
            end
        end
    end
    
    // 7-segment decoder (active low)
    always @(digit_value) begin
        case (digit_value)
            //                   abcdefg
            4'd0: segments <= 7'b0000001; // 0
            4'd1: segments <= 7'b1001111; // 1
            4'd2: segments <= 7'b0010010; // 2
            4'd3: segments <= 7'b0000110; // 3
            4'd4: segments <= 7'b1001100; // 4
            4'd5: segments <= 7'b0100100; // 5
            4'd6: segments <= 7'b0100000; // 6
            4'd7: segments <= 7'b0001111; // 7
            4'd8: segments <= 7'b0000000; // 8
            4'd9: segments <= 7'b0000100; // 9
            default: segments <= 7'b1111111; // all off
        endcase
    end

endmodule