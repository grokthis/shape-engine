// shape_lattice.v -- A grid of shape-gates with configurable routing.
//
// The lattice IS the shape graph. Each gate is one shape.
// Routing connections between gates ARE the dependency graph.
// Wave propagation through the lattice IS computation.
//
// Parameters:
//   ROWS, COLS     -- lattice dimensions
//   CONTENT_WIDTH  -- bits per shape character
//   TICK_WIDTH     -- bits per tick counter
//   MAX_DEPS       -- max dependencies per gate
//
// The connection matrix is loaded at configuration time.
// It maps: for each gate, which other gates are its dependencies.
// This is the shape graph projected onto hardware.

module shape_lattice #(
    parameter ROWS          = 8,
    parameter COLS          = 8,
    parameter CONTENT_WIDTH = 8,
    parameter TICK_WIDTH    = 16,
    parameter MAX_DEPS      = 4,
    parameter NUM_GATES     = ROWS * COLS
)(
    input  wire clk,
    input  wire rst,

    // External wave injection: trigger a specific gate (edit).
    input  wire                     ext_wave,
    input  wire [$clog2(NUM_GATES)-1:0] ext_target,
    input  wire [CONTENT_WIDTH-1:0] ext_data,

    // Transform configuration: one per gate, loaded at config time.
    input  wire [NUM_GATES*CONTENT_WIDTH-1:0] transform_cfgs,

    // Connection matrix: for each gate, MAX_DEPS source gate indices.
    // Index NUM_GATES means "no connection" (unconnected dep).
    input  wire [NUM_GATES*MAX_DEPS*$clog2(NUM_GATES+1)-1:0] connections,

    // Status outputs.
    output wire [NUM_GATES*CONTENT_WIDTH-1:0] all_content,
    output wire [NUM_GATES*TICK_WIDTH-1:0]    all_ticks,
    output wire [NUM_GATES-1:0]               all_coherent,
    output wire [NUM_GATES-1:0]               all_wave_out
);

    // --- Internal wires ---
    wire [NUM_GATES-1:0] gate_wave_out;
    wire [NUM_GATES*CONTENT_WIDTH-1:0] gate_data_out;

    // Gate index width for connection lookups.
    localparam IDX_WIDTH = $clog2(NUM_GATES + 1);

    // --- Generate shape-gate instances ---
    genvar g;
    generate
        for (g = 0; g < NUM_GATES; g = g + 1) begin : gates

            // Build wave_in for this gate from connection matrix.
            wire [MAX_DEPS-1:0] wave_in;
            wire [MAX_DEPS*CONTENT_WIDTH-1:0] data_in;

            genvar d;
            for (d = 0; d < MAX_DEPS; d = d + 1) begin : deps
                // Extract source gate index from connection matrix.
                wire [IDX_WIDTH-1:0] src_idx =
                    connections[(g*MAX_DEPS+d+1)*IDX_WIDTH-1 : (g*MAX_DEPS+d)*IDX_WIDTH];

                // Connection is valid if src_idx < NUM_GATES.
                wire valid = (src_idx < NUM_GATES);

                // Wave comes from source gate's wave_out, or from external if targeted.
                wire src_wave = valid ? gate_wave_out[src_idx] : 1'b0;
                wire ext_match = (ext_wave && ext_target == g);

                assign wave_in[d] = src_wave | (d == 0 ? ext_match : 1'b0);

                // Data comes from source gate's data_out, or external data.
                assign data_in[(d+1)*CONTENT_WIDTH-1 : d*CONTENT_WIDTH] =
                    (d == 0 && ext_match) ? ext_data :
                    (valid ? gate_data_out[(src_idx+1)*CONTENT_WIDTH-1 : src_idx*CONTENT_WIDTH] :
                     {CONTENT_WIDTH{1'b0}});
            end

            // Transform config for this gate.
            wire [CONTENT_WIDTH-1:0] cfg =
                transform_cfgs[(g+1)*CONTENT_WIDTH-1 : g*CONTENT_WIDTH];

            // Instantiate shape-gate.
            shape_gate #(
                .CONTENT_WIDTH(CONTENT_WIDTH),
                .TICK_WIDTH(TICK_WIDTH),
                .NUM_DEPS(MAX_DEPS)
            ) gate_inst (
                .clk(clk),
                .rst(rst),
                .wave_in(wave_in),
                .data_in(data_in),
                .wave_out(gate_wave_out[g]),
                .data_out(gate_data_out[(g+1)*CONTENT_WIDTH-1 : g*CONTENT_WIDTH]),
                .tick_out(all_ticks[(g+1)*TICK_WIDTH-1 : g*TICK_WIDTH]),
                .coherent(all_coherent[g]),
                .transform_cfg(cfg)
            );
        end
    endgenerate

    // --- Outputs ---
    assign all_content  = gate_data_out;
    assign all_wave_out = gate_wave_out;

endmodule
