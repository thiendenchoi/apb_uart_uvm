module uart_rx_sva #(
  parameter int CLK_HZ       = 50_000_000,
  parameter int BAUD         = 115_200,
  parameter int BIT_CYCLES   = (CLK_HZ + (BAUD/2)) / BAUD, // ~434

  parameter int FRAME_CYCLES = 10 * BIT_CYCLES,

  parameter int MAX_FRAME_CYCLES = 1_000_000
)(
  uart_rx_intf intf
);

  logic clk, reset_n, rx, rts_n;
  assign clk     = intf.clk;
  assign reset_n = intf.reset_n;
  assign rx      = intf.rx;
  assign rts_n   = intf.rts_n;

  function automatic bit known(input logic [127:0] v);
    return !$isunknown(v);
  endfunction

  wire rx_high = (rx == 1'b1);
  wire rx_low  = (rx == 1'b0);

  logic rx_q;
  wire  rx_fell = (rx_q == 1'b1) && (rx == 1'b0);

  logic in_frame;
  int unsigned frame_cnt;

  wire start_evt = (!in_frame) && rx_fell;

  always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      rx_q      <= 1'b1;
      in_frame  <= 1'b0;
      frame_cnt <= 0;
    end else begin
      rx_q <= rx;

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
    @(posedge clk) (!reset_n) |-> (rx_high && known(rx));
  endproperty

  property p_no_xz_on_pins;
    @(posedge clk) disable iff(!reset_n)
      known({rx, rts_n});
  endproperty

  property p_rts_blocks_new_start;
    @(posedge clk) disable iff(!reset_n)
      ($past(rts_n) && !in_frame) |-> !start_evt;
  endproperty

  property p_start_not_glitch;
    @(posedge clk) disable iff(!reset_n)
      start_evt |=> rx_low;
  endproperty

  UART_RX_RESET_IDLE_HIGH : assert property(p_reset_idle_high)
    else $error("[UART_RX_SVA] reset asserted but rx not idle-high/known");

  UART_RX_NO_XZ_PINS : assert property(p_no_xz_on_pins)
    else $error("[UART_RX_SVA] X/Z detected on {rx, rts_n}");

  UART_RX_RTS_BLOCKS_START : assert property(p_rts_blocks_new_start)
    else $error("[UART_RX_SVA] start-bit observed while rts_n=1 (blocked)");

  UART_RX_START_NOT_GLITCH : assert property(p_start_not_glitch)
    else $error("[UART_RX_SVA] start detected but rx did not stay low for 1 cycle (glitch?)");

endmodule
