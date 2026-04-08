// shape_gate_tb.v -- Testbench for the minimal shape-gate.
//
// Verifies:
//   1. Persistence: content holds without wave input
//   2. Change: wave_in triggers transform, updates content
//   3. Propagation: wave_out asserts for one cycle after change
//   4. Tick: increments on every wave
//   5. Coherence: flag set after first wave

`timescale 1ns / 1ps

module shape_gate_tb;

    parameter CW = 8;
    parameter TW = 16;
    parameter ND = 4;

    reg                clk;
    reg                rst;
    reg  [ND-1:0]      wave_in;
    reg  [ND*CW-1:0]   data_in;
    wire               wave_out;
    wire [CW-1:0]      data_out;
    wire [TW-1:0]      tick_out;
    wire               coherent;
    reg  [CW-1:0]      transform_cfg;

    shape_gate #(
        .CONTENT_WIDTH(CW),
        .TICK_WIDTH(TW),
        .NUM_DEPS(ND)
    ) uut (
        .clk(clk),
        .rst(rst),
        .wave_in(wave_in),
        .data_in(data_in),
        .wave_out(wave_out),
        .data_out(data_out),
        .tick_out(tick_out),
        .coherent(coherent),
        .transform_cfg(transform_cfg)
    );

    // Clock: 10ns period.
    initial clk = 0;
    always #5 clk = ~clk;

    integer errors = 0;

    task check(input [255:0] name, input condition);
        if (!condition) begin
            $display("FAIL: %0s", name);
            errors = errors + 1;
        end else begin
            $display("PASS: %0s", name);
        end
    endtask

    initial begin
        // Reset.
        rst = 1;
        wave_in = 0;
        data_in = 0;
        transform_cfg = 8'hAA;
        #20;
        rst = 0;
        #10;

        // 1. Persistence: no wave, content holds at 0.
        check("persistence: content is 0 after reset", data_out == 8'h00);
        check("persistence: tick is 0 after reset", tick_out == 16'h0000);
        check("persistence: not coherent yet", coherent == 1'b0);
        check("persistence: no wave_out", wave_out == 1'b0);

        // Wait a few cycles. Nothing should change.
        #50;
        check("persistence: content still 0", data_out == 8'h00);
        check("persistence: tick still 0", tick_out == 16'h0000);

        // 2. Change: send wave on dep 0 with data 0x55.
        //    Transform: 0x55 XOR 0xAA = 0xFF.
        data_in = {24'h0, 8'h55};  // dep 0 = 0x55, others = 0
        wave_in = 4'b0001;         // dep 0 active
        #10;
        wave_in = 4'b0000;
        data_in = 0;
        #10;

        // 3. Verify change + propagation.
        check("change: content is 0xFF (0x55 XOR 0xAA)", data_out == 8'hFF);
        check("change: tick is 1", tick_out == 16'h0001);
        check("change: coherent", coherent == 1'b1);

        // 4. Wave_out should have been high for one cycle.
        //    (It was high on the clock edge after wave_in, now low.)
        check("propagation: wave_out deasserted", wave_out == 1'b0);

        // 5. Second wave: dep 0 sends 0xFF.
        //    Transform: 0xFF XOR 0xAA = 0x55.
        data_in = {24'h0, 8'hFF};
        wave_in = 4'b0001;
        #10;
        wave_in = 4'b0000;
        data_in = 0;
        #10;

        check("second wave: content is 0x55", data_out == 8'h55);
        check("second wave: tick is 2", tick_out == 16'h0002);

        // 6. Multiple deps active simultaneously.
        //    dep 0 = 0x0F, dep 1 = 0xF0. OR = 0xFF. XOR cfg = 0x55.
        data_in = {16'h0, 8'hF0, 8'h0F};
        wave_in = 4'b0011;
        #10;
        wave_in = 4'b0000;
        data_in = 0;
        #10;

        check("multi-dep: content is 0x55 (OR then XOR)", data_out == 8'h55);
        check("multi-dep: tick is 3", tick_out == 16'h0003);

        // Summary.
        #10;
        if (errors == 0)
            $display("\nAll tests passed.");
        else
            $display("\n%0d test(s) FAILED.", errors);

        $finish;
    end

endmodule
