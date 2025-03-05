// Keypad Controller Module - keypad_controller.v
module keypad_controller (
    input wire clk,
    input wire rst,
    output reg [3:0] row,
    input wire [3:0] col,
    output reg [3:0] value,
    output reg key_pressed
);

    // Internal registers
    reg [15:0] scan_timer;       // Debouncing timer
    reg [1:0] row_scan;          // Current row being scanned
    reg key_state;               // Current key state
    reg key_last;                // Previous key state
    
    // Keypad scanning and debouncing
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            row <= 4'b1111;
            value <= 4'd0;
            row_scan <= 2'd0;
            key_pressed <= 1'b0;
            key_state <= 1'b0;
            key_last <= 1'b0;
            scan_timer <= 16'd0;
        end else begin
            key_pressed <= 1'b0; // Default state
            
            // Debouncing and scanning logic
            if (scan_timer < 16'd50000) begin
                scan_timer <= scan_timer + 1'b1;
            end else begin
                scan_timer <= 16'd0;
                
                // Scan rows sequentially
                case (row_scan)
                    2'd0: row <= 4'b0111;
                    2'd1: row <= 4'b1011;
                    2'd2: row <= 4'b1101;
                    2'd3: row <= 4'b1110;
                endcase
                
                // Detect key press
                if (col != 4'b1111) begin
                    key_state <= 1'b1;
                    
                    // Determine key value based on row and column
                    case (row_scan)
                        2'd0: begin
                            if (col[0] == 1'b0) value <= 4'd1;      // Key 1
                            else if (col[1] == 1'b0) value <= 4'd2; // Key 2
                            else if (col[2] == 1'b0) value <= 4'd3; // Key 3
                            else if (col[3] == 1'b0) value <= 4'd10; // Key A
                        end
                        2'd1: begin
                            if (col[0] == 1'b0) value <= 4'd4;      // Key 4
                            else if (col[1] == 1'b0) value <= 4'd5; // Key 5
                            else if (col[2] == 1'b0) value <= 4'd6; // Key 6
                            else if (col[3] == 1'b0) value <= 4'd11; // Key B
                        end
                        2'd2: begin
                            if (col[0] == 1'b0) value <= 4'd7;      // Key 7
                            else if (col[1] == 1'b0) value <= 4'd8; // Key 8
                            else if (col[2] == 1'b0) value <= 4'd9; // Key 9
                            else if (col[3] == 1'b0) value <= 4'd12; // Key C
                        end
                        2'd3: begin
                            if (col[0] == 1'b0) value <= 4'd14;     // Key *
                            else if (col[1] == 1'b0) value <= 4'd0; // Key 0
                            else if (col[2] == 1'b0) value <= 4'd15; // Key #
                            else if (col[3] == 1'b0) value <= 4'd13; // Key D
                        end
                    endcase
                end else begin
                    key_state <= 1'b0;
                end
                
                // Detect rising edge of key press
                if (key_state == 1'b1 && key_last == 1'b0) begin
                    key_pressed <= 1'b1;
                end
                
                key_last <= key_state;
                
                // Move to next row
                if (row_scan == 2'd3) begin
                    row_scan <= 2'd0;
                end else begin
                    row_scan <= row_scan + 1'b1;
                end
            end
        end
    end

endmodule

