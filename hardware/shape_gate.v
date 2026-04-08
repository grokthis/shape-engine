// shape_gate.v -- The minimal persistent structure in hardware.
//
// One shape-gate = one shape. It persists (flip-flop holds state),
// it changes (wave_in triggers transform), and it propagates
// (wave_out signals dependents).
//
// This is the hardware axiom. Everything else derives from connecting
// these gates into a lattice.
//
// Parameters:
//   CONTENT_WIDTH -- bits of character state (default 8)
//   TICK_WIDTH    -- bits for tick counter (default 16)
//   NUM_DEPS      -- number of dependency inputs (default 4)

module shape_gate #(
    parameter CONTENT_WIDTH = 8,
    parameter TICK_WIDTH    = 16,
    parameter NUM_DEPS      = 4
)(
    input  wire                    clk,
    input  wire                    rst,

    // Wave inputs: one per dependency.
    // When any goes high, this gate activates.
    input  wire [NUM_DEPS-1:0]     wave_in,

    // Data from dependencies (one word per dep).
    input  wire [NUM_DEPS*CONTENT_WIDTH-1:0] data_in,

    // Wave output: asserted for one cycle when this gate propagates.
    output reg                     wave_out,

    // Data output: this gate's current content.
    output wire [CONTENT_WIDTH-1:0] data_out,

    // Tick output: structural position.
    output wire [TICK_WIDTH-1:0]    tick_out,

    // Coherence flag: high if gate is in coherent state.
    output wire                    coherent,

    // Transform configuration: loaded at synthesis or runtime.
    // This IS the shape's character -- the LUT truth table.
    input  wire [CONTENT_WIDTH-1:0] transform_cfg
);

    // --- State registers (persistence) ---
    reg [CONTENT_WIDTH-1:0] content;
    reg [TICK_WIDTH-1:0]    tick;
    reg                     has_state;  // Law 2: has structure

    // --- Wave detection ---
    wire any_wave = |wave_in;

    // --- Transform logic ---
    // The transform combines incoming data with current content
    // according to transform_cfg. This is the f in M' = f(C, S).
    //
    // Minimal transform: XOR incoming data with config.
    // Real implementation: content of the LUT truth table.
    wire [CONTENT_WIDTH-1:0] dep_data [0:NUM_DEPS-1];
    wire [CONTENT_WIDTH-1:0] combined;

    // Unpack data_in into per-dep words.
    genvar i;
    generate
        for (i = 0; i < NUM_DEPS; i = i + 1) begin : unpack
            assign dep_data[i] = data_in[(i+1)*CONTENT_WIDTH-1 : i*CONTENT_WIDTH];
        end
    endgenerate

    // Combine: OR all active dependency data, then XOR with transform.
    // This is the simplest non-trivial transform. The shape compiler
    // replaces this with the actual transform logic per gate.
    reg [CONTENT_WIDTH-1:0] active_data;
    integer j;
    always @(*) begin
        active_data = {CONTENT_WIDTH{1'b0}};
        for (j = 0; j < NUM_DEPS; j = j + 1) begin
            if (wave_in[j])
                active_data = active_data | dep_data[j];
        end
    end

    assign combined = active_data ^ transform_cfg;

    // --- State update (change + persistence) ---
    always @(posedge clk) begin
        if (rst) begin
            content   <= {CONTENT_WIDTH{1'b0}};
            tick      <= {TICK_WIDTH{1'b0}};
            has_state <= 1'b0;
            wave_out  <= 1'b0;
        end else if (any_wave) begin
            // Change: apply transform, update content.
            content   <= combined;
            tick      <= tick + 1'b1;
            has_state <= 1'b1;
            wave_out  <= 1'b1;  // Propagate to dependents.
        end else begin
            // Persistence: hold state, no propagation.
            wave_out  <= 1'b0;
        end
    end

    // --- Outputs ---
    assign data_out  = content;
    assign tick_out  = tick;
    assign coherent  = has_state;  // Law 0: persists if has structure.

endmodule
