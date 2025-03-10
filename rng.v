// Random Number Generator Module - random_generator.v
module random_generator (
    input wire clk,
    input wire rst,
    input wire [15:0] seed,
    output reg [4:0] random_num // Changed to 5-bit output
);

    // Linear Feedback Shift Register (LFSR)
    reg [15:0] lfsr;
    wire feedback;

    // Feedback polynomial: x^16 + x^14 + x^13 + x^11 + 1
    assign feedback = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];

    // LFSR process
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            lfsr <= seed; // Initialize with seed value
            random_num <= 5'd0; // 5-bit output
        end else begin
            // Shift and apply feedback
            lfsr <= {lfsr[14:0], feedback};

            // Take the lower 5 bits for randomness
            random_num <= lfsr[4:0];
        end
    end

endmodule

