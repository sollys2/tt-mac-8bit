`timescale 1ns / 1ps


module tb_mac_simple;
    reg clk;
    reg rst_n;
    
    reg [7:0] ui_in;
    wire [7:0] uo_out;
    reg [7:0] uio_in;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    reg ena;

    // TinyTapeout top module with 4-bit serial interface
    tt_um_SollysLe_mac_8bits dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    // Clock generation - let cocotb control this
    always #5 clk = ~clk;

    initial begin
        // Initialize signals only
        clk = 0;
        rst_n = 1;
        ena = 1;
        ui_in = 0;
        uio_in = 0;
        
        // Generate VCD for waveform viewing
        $dumpfile("mac_nibble_test.vcd");
        $dumpvars(0, tb_mac_simple);
        
        // Let cocotb control the rest of the simulation
    end

endmodule
