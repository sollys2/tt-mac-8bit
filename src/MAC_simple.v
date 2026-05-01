// Configurable 8x8 multiplier wrapper for signed/unsigned operations
module configurable_multiplier (
    input wire [7:0] in0,
    input wire [7:0] in1,
    input wire signed_mode,
    output wire [15:0] result
);

    wire [15:0] unsigned_result;
    wire signed [15:0] signed_result;
    
    // Unsigned multiplication
    assign unsigned_result = in0 * in1;
    
    // Signed multiplication - convert inputs to signed first
    wire signed [7:0] signed_in0 = $signed(in0);
    wire signed [7:0] signed_in1 = $signed(in1);
    assign signed_result = signed_in0 * signed_in1;
    
    // Select result based on mode - convert signed result back to unsigned for output
    assign result = signed_mode ? $unsigned(signed_result) : unsigned_result;

endmodule 
