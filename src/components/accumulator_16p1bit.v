module accumulator_16p1bit (
    input wire clk,
    input wire rst,
    input wire [15:0] mult_result,
    input wire clear_mode,
    input wire valid,
    input wire signed_mode,

    output reg [16:0] accumulator_value,
    output reg [15:0] result_out,
    output reg overflow_out
);

    wire [16:0] add_result;
    wire signed_overflow;
    wire unsigned_overflow;

    // Unsigned addition
    assign add_result = accumulator_value + {1'b0, mult_result};
    assign unsigned_overflow = add_result[16];

    // Signed overflow detection: overflow when signs are same but result sign differs
    wire [16:0] signed_accumulator = {{1{accumulator_value[15]}}, accumulator_value[15:0]};
    wire [16:0] signed_mult = {{1{mult_result[15]}}, mult_result};
    wire [16:0] signed_add_result = signed_accumulator + signed_mult;

    assign signed_overflow = (signed_accumulator[15] == signed_mult[15]) &&
                             (signed_add_result[15] != signed_accumulator[15]);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            accumulator_value <= 17'b0;
            result_out <= 16'b0;
            overflow_out <= 1'b0;
        end else if (valid) begin
            if (clear_mode) begin
                accumulator_value <= {1'b0, mult_result};
                result_out <= mult_result;
                overflow_out <= 1'b0;
            end else begin
                if (signed_mode) begin
                    accumulator_value <= signed_add_result;
                    result_out <= signed_add_result[15:0];
                    overflow_out <= signed_overflow;
                end else begin
                    accumulator_value <= add_result;
                    result_out <= add_result[15:0];
                    overflow_out <= unsigned_overflow;
                end
            end
        end
    end
endmodule
