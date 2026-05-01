module change_detector (
    input wire clk,
    input wire rst,
    input wire [7:0] data_a,
    input wire [7:0] data_b,
    input wire clear_mult,
    
    output wire input_changed
);

    reg [7:0] last_a, last_b;
    reg last_clear_mult;
    
    assign input_changed = (data_a != last_a) || (data_b != last_b) || (clear_mult != last_clear_mult);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            last_a <= 8'b0;
            last_b <= 8'b0;
            last_clear_mult <= 1'b0;
        end else begin
            last_a <= data_a;
            last_b <= data_b;
            last_clear_mult <= clear_mult;
        end
    end

endmodule 
