module keypad_controller (
    input  wire       clk,
    input  wire       rst,
    output reg [3:0]  row,
    input  wire [3:0]  col,
    output reg [3:0]  value,
    output reg        key_pressed
);

    // Parameters for timing (assuming a 100MHz clock)
    localparam BITS           = 20;
    localparam ONE_MS_TICKS   = 100_000;  // 1ms delay
    localparam SETTLE_TIME    = 100;      // 1us settle time

    // 20-bit counter for scanning each row period
    reg [BITS-1:0] key_counter;
    // Which row is currently being scanned (0-3)
    reg [1:0] row_scan;
    // Used for positive edge detection of a key press
    reg key_state;
    reg key_last;

    // Counter and scan state process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_counter <= 0;
            row_scan    <= 0;
            key_state   <= 0;
            key_last    <= 0;
            key_pressed <= 0;
            row         <= 4'b1111;
            value       <= 4'd0;
        end else begin
            // Increment the counter until the end of the row scan period
            if (key_counter < ONE_MS_TICKS - 1)
                key_counter <= key_counter + 1;
            else begin
                key_counter <= 0;
                // Move to the next row (wrap around after row 3)
                row_scan <= (row_scan == 2'd3) ? 2'd0 : row_scan + 1'b1;
            end

            // At the start of the scan period, drive the proper row signal
            if (key_counter == 0) begin
                case (row_scan)
                    2'd0: row <= 4'b0111;
                    2'd1: row <= 4'b1011;
                    2'd2: row <= 4'b1101;
                    2'd3: row <= 4'b1110;
                    default: row <= 4'b1111;
                endcase
            end

            // After a short settle time, sample the column inputs
            if (key_counter == SETTLE_TIME) begin
                if (col != 4'b1111) begin
                    key_state <= 1;
                    // Determine key value based on the current row_scan and col
                    case (row_scan)
                        2'd0: begin
                            if (!col[0]) value <= 4'd1;      // Key 1
                            else if (!col[1]) value <= 4'd2; // Key 2
                            else if (!col[2]) value <= 4'd3; // Key 3
                            else if (!col[3]) value <= 4'd10; // Key A
                        end
                        2'd1: begin
                            if (!col[0]) value <= 4'd4;      // Key 4
                            else if (!col[1]) value <= 4'd5; // Key 5
                            else if (!col[2]) value <= 4'd6; // Key 6
                            else if (!col[3]) value <= 4'd11; // Key B
                        end
                        2'd2: begin
                            if (!col[0]) value <= 4'd7;      // Key 7
                            else if (!col[1]) value <= 4'd8; // Key 8
                            else if (!col[2]) value <= 4'd9; // Key 9
                            else if (!col[3]) value <= 4'd12; // Key C
                        end
                        2'd3: begin
                            if (!col[0]) value <= 4'd14;     // Key *
                            else if (!col[1]) value <= 4'd0; // Key 0
                            else if (!col[2]) value <= 4'd15; // Key #
                            else if (!col[3]) value <= 4'd13; // Key D
                        end
                        default: value <= 4'd0;
                    endcase
                end else begin
                    key_state <= 0;
                end
            end

            // At the end of each scan period, generate a one-clock pulse on rising edge
            if (key_counter == ONE_MS_TICKS - 1) begin
                if (key_state && !key_last)
                    key_pressed <= 1;
                else
                    key_pressed <= 0;
                key_last <= key_state;
            end
        end
    end

endmodule
