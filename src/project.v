/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none

module tt_um_BryanKuang_mac_peripheral (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // 2-cycle 8-bit serial interface pin mapping
  wire [7:0] data_input = ui_in[7:0];                // 8-bit data input (Data A in cycle 1, Data B in cycle 2)
  wire clear_and_mult = uio_in[0];                   // Clear and multiply control (valid in cycle 1)
  wire enable_interface = uio_in[1];                 // Enable interface
  wire signed_mode = uio_in[2];                      // Signed mode control (when 1, treat inputs/outputs as signed)
  
  // 2-cycle 8-bit serial interface outputs
  wire [7:0] data_output;                            // 8-bit data output (low 8 bits in cycle 1, high 8 bits in cycle 2)
  wire overflow_flag;
  wire data_ready;
  wire frame_valid;                                   // One-cycle pulse when a 2-cycle frame completes
  
  // MAC interface signals
  wire [7:0] mac_data_a, mac_data_b;
  wire mac_clear_and_mult, mac_signed_mode;
  wire [15:0] mac_result;
  wire mac_overflow;
  
  // Internal MAC signals
  wire [7:0] reg_A, reg_B;
  wire reg_Clear_and_Mult, reg_signed_mode;
  wire reg_valid;
  wire [7:0] pipe_A, pipe_B;
  wire pipe_Clear_and_Mult, pipe_signed_mode;
  wire pipe_valid;
  wire [15:0] mult_result;
  wire [16:0] accumulator_value;
  
  // 2-cycle 8-bit serial interface module
  nibble_interface serial_if (
    .clk(clk),
    .rst(~rst_n),
    .enable(enable_interface),
    .data_in(data_input),
    .clear_and_mult_in(clear_and_mult),
    .signed_mode(signed_mode),
    .data_out(data_output),
    .overflow_out(overflow_flag),
    .data_ready(data_ready),
    .mac_data_a(mac_data_a),
    .mac_data_b(mac_data_b),
    .mac_clear_and_mult(mac_clear_and_mult),
    .mac_signed_mode(mac_signed_mode),
    .mac_result(mac_result),
    .mac_overflow(mac_overflow),
    .frame_valid(frame_valid)
  );
  
  // Stage 1: Input registers
  input_registers input_regs (
    .clk(clk),
    .rst(~rst_n),
    .data_a_in(mac_data_a),
    .data_b_in(mac_data_b),
    .clear_mult_in(mac_clear_and_mult),
    .valid_in(frame_valid),
    .signed_mode_in(mac_signed_mode),
    .data_a_out(reg_A),
    .data_b_out(reg_B),
    .clear_mult_out(reg_Clear_and_Mult),
    .valid_out(reg_valid),
    .signed_mode_out(reg_signed_mode)
  );
  
  // Stage 2: Pipeline registers
  pipeline_registers pipe_regs (
    .clk(clk),
    .rst(~rst_n),
    .data_a_in(reg_A),
    .data_b_in(reg_B),
    .clear_mult_in(reg_Clear_and_Mult),
    .valid_in(reg_valid),
    .signed_mode_in(reg_signed_mode),
    .data_a_out(pipe_A),
    .data_b_out(pipe_B),
    .clear_mult_out(pipe_Clear_and_Mult),
    .valid_out(pipe_valid),
    .signed_mode_out(pipe_signed_mode)
  );
  
  // Configurable 8x8 Multiplier (signed/unsigned)
  configurable_multiplier multiplier (
    .in0(pipe_A),
    .in1(pipe_B),
    .signed_mode(pipe_signed_mode),
    .result(mult_result)
  );
  
  // 16+1-bit accumulator (17-bit internal)
  accumulator_16p1bit accumulator (
    .clk(clk),
    .rst(~rst_n),
    .mult_result(mult_result),
    .clear_mode(pipe_Clear_and_Mult),
    .valid(pipe_valid),
    .signed_mode(pipe_signed_mode),
    .accumulator_value(accumulator_value),
    .result_out(mac_result),
    .overflow_out(mac_overflow)
  );
  
  // Output mapping - 2-cycle 8-bit serial interface
  assign uo_out[7:0] = data_output;                  // 8-bit data output (cycles between low/high 8 bits)
  assign uio_oe[7:0] = 8'b11111100;                  // uio[7:2] as outputs, uio[1:0] as inputs
  assign uio_out[0] = overflow_flag;                 // Overflow flag output
  assign uio_out[1] = data_ready;                    // Data ready flag output
  assign uio_out[7:2] = 6'b0;                        // Unused outputs

  // Suppress unused signal warnings
  wire _unused = &{ena, uio_in[7:3], accumulator_value, 1'b0};

endmodule
