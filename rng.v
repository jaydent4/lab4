// Random Number Generator Module - random_generator.v TODO: set seed??
module random_generator (
    input wire clk,
    input wire rst,
    input wire [15:0] seed,
    output reg [3:0] random_num
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
            random_num <= 4'd0;
        end else begin
            // Shift and apply feedback
            lfsr <= {lfsr[14:0], feedback};
            
            // Map to range 0-9
            random_num <= (lfsr[3:0] % 10);
        end
    end

endmodule

