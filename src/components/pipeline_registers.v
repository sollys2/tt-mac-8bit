module pipeline_registers (
    input wire clk,
    input wire rst,
    input wire [7:0] data_a_in,
    input wire [7:0] data_b_in,
    input wire clear_mult_in,
    input wire valid_in,
    input wire signed_mode_in,
    
    output reg [7:0] data_a_out,
    output reg [7:0] data_b_out,
    output reg clear_mult_out,
    output reg valid_out,
    output reg signed_mode_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_a_out <= 8'b0;
            data_b_out <= 8'b0;
            clear_mult_out <= 1'b0;
            valid_out <= 1'b0;
            signed_mode_out <= 1'b0;
        end else begin
            data_a_out <= data_a_in;
            data_b_out <= data_b_in;
            clear_mult_out <= clear_mult_in;
            valid_out <= valid_in;
            signed_mode_out <= signed_mode_in;
        end
    end

endmodule 
