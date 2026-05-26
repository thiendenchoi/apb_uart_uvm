module uart_tx_sva #(
  parameter int CLK_HZ       = 50_000_000,
  parameter int BAUD         = 115_200,
  parameter int BIT_CYCLES   = (CLK_HZ + (BAUD/2)) / BAUD, // ~434

  parameter int FRAME_CYCLES = 10 * BIT_CYCLES,

  parameter int MAX_FRAME_CYCLES = 1_000_000
)(
  uart_tx_intf intf
);

  logic clk, reset_n, tx, cts_n;
  assign clk     = intf.clk;
  assign reset_n = intf.reset_n;
  assign tx      = intf.tx;
  assign cts_n   = intf.cts_n;

  function automatic bit known(input logic [127:0] v);
    return !$isunknown(v);
  endfunction

  wire tx_high = (tx == 1'b1);
  wire tx_low  = (tx == 1'b0);

  logic tx_q;
  wire  tx_fell = (tx_q == 1'b1) && (tx == 1'b0);

  logic in_frame;
  int unsigned frame_cnt;

  wire start_evt = (!in_frame) && tx_fell;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      tx_q      <= 1'b1;
      in_frame  <= 1'b0;
      frame_cnt <= 0;
    end else begin
      tx_q <= tx;

      if (!in_frame) begin
        frame_cnt <= 0;
        if (start_evt) begin
          in_frame  <= 1'b1;
          frame_cnt <= 1;
        end
      end else begin
        frame_cnt <= frame_cnt + 1;

        if (frame_cnt >= FRAME_CYCLES) begin
          in_frame  <= 1'b0;
          frame_cnt <= 0;
        end

        if (frame_cnt >= MAX_FRAME_CYCLES) begin
          in_frame  <= 1'b0;
          frame_cnt <= 0;
        end
      end
    end
  end

  property p_reset_idle_high;
    @(posedge clk) (!reset_n) |-> (tx_high && known(tx));
  endproperty

  property p_no_xz_on_pins;
    @(posedge clk) disable iff(!reset_n)
      known({tx, cts_n});
  endproperty

  property p_cts_blocks_new_start;
    @(posedge clk) disable iff(!reset_n)
      (cts_n && !in_frame) |-> !start_evt;
  endproperty

  property p_start_not_glitch;
    @(posedge clk) disable iff(!reset_n)
      start_evt |=> tx_low;
  endproperty

    property TX_NO_1CYCLE_PULSE;
    @(posedge clk) disable iff (!reset_n)
      (tx != $past(tx)) |-> ##1 (tx == $past(tx));
  endproperty

  ASSERT_TX_NO_1CYCLE_PULSE: assert property (TX_NO_1CYCLE_PULSE)
    else $error("TX glitch: toggled for 1 cycle then returned at time %0t", $time);

  UART_TX_RESET_IDLE_HIGH : assert property(p_reset_idle_high)
    else $error("[UART_TX_SVA] reset asserted but tx not idle-high/known");

  UART_TX_NO_XZ_PINS : assert property(p_no_xz_on_pins)
    else $error("[UART_TX_SVA] X/Z detected on {tx, cts_n}");

  UART_TX_CTS_BLOCKS_START : assert property(p_cts_blocks_new_start)
    else $error("[UART_TX_SVA] start-bit observed while cts_n=1 (blocked)");

  UART_TX_START_NOT_GLITCH : assert property(p_start_not_glitch)
    else $error("[UART_TX_SVA] start detected but tx did not stay low for 1 cycle (glitch?)");

endmodule