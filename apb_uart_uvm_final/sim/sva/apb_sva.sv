module apb_sva #(
  parameter int ADDR_W = 12,
  parameter int DATA_W = 32,
  parameter int STRB_W = DATA_W/8,
  parameter int TIMEOUT_CYCLES = 100,
  parameter bit ENABLE_XCHECK = 1,
  parameter bit ENABLE_TIMEOUT = 1,
  parameter bit ENABLE_BACK2BACK = 1
)(
  apb_intf intf
);

  logic                apb_clk;
  logic                apb_resetn;
  logic [ADDR_W-1:0]   apb_addr;
  logic [DATA_W-1:0]   apb_rdata;
  logic [DATA_W-1:0]   apb_wdata;
  logic [STRB_W-1:0]   apb_strb;
  logic                apb_sel;
  logic                apb_enable;
  logic                apb_write;
  logic                apb_ready;
  logic                apb_slverr;

  assign apb_clk    = intf.clk;
  assign apb_resetn = intf.reset_n;
  assign apb_addr   = intf.paddr;
  assign apb_rdata  = intf.prdata;
  assign apb_wdata  = intf.pwdata;
  assign apb_strb   = intf.pstrb;
  assign apb_sel    = intf.psel;
  assign apb_enable = intf.penable;
  assign apb_write  = intf.pwrite;
  assign apb_ready  = intf.pready;
  assign apb_slverr = intf.pslverr;

  wire in_setup  = apb_sel && !apb_enable;
  wire in_access = apb_sel &&  apb_enable;
  wire handshake = in_access && apb_ready;

  property p_reset_idle;
    @(posedge apb_clk)
      $fell(apb_resetn) |=> (!apb_sel && !apb_enable);
  endproperty

  property p_idle_psel_penable;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (!apb_sel) |-> (!apb_enable);
  endproperty

  property p_idle_slverr_low;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (!apb_sel) |-> (!apb_slverr);
  endproperty

  property p_setup_to_access;
    @(posedge apb_clk) disable iff(!apb_resetn)
      in_setup |=> (apb_sel && apb_enable);
  endproperty

  property p_no_enable_without_setup;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (apb_sel && apb_enable) |-> $past(apb_sel && !apb_enable);
  endproperty

  property p_enable_drop_rules;
    @(posedge apb_clk) disable iff(!apb_resetn)
      $fell(apb_enable) |-> $past(handshake) || (!apb_sel);
  endproperty

  property p_stable_addr_ctrl_strb_during_wait;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (in_access && !apb_ready) |-> $stable(apb_addr) && $stable(apb_write) && $stable(apb_strb);
  endproperty

  property p_stable_wdata_during_wait;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (in_access && !apb_ready && apb_write) |-> $stable(apb_wdata);
  endproperty

  property p_stable_through_access_if_extended;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (in_access && $past(in_access) && !$past(handshake)) |-> // continued access due to wait previously
        $stable(apb_addr) && $stable(apb_write) && $stable(apb_strb) &&
        (apb_write -> $stable(apb_wdata));
  endproperty

  property p_strb_zero_on_read;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (apb_sel && !apb_write) |-> (apb_strb == '0);
  endproperty

  property p_strb_nonzero_on_write;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (apb_sel && apb_write) |-> (apb_strb != '0);
  endproperty

  property p_rdata_stable_during_wait_read;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (in_access && !apb_ready && !apb_write) |-> $stable(apb_rdata);
  endproperty

  property p_psel_drop_only_after_handshake;
    @(posedge apb_clk) disable iff(!apb_resetn)
      $fell(apb_sel) |-> $past(handshake);
  endproperty

  property p_hold_enable_until_ready;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (in_access && !apb_ready) |=> (apb_enable); 
  endproperty

  property p_after_handshake_next_state;
    @(posedge apb_clk) disable iff(!apb_resetn)
      handshake |=> ((!apb_sel && !apb_enable) || (apb_sel && !apb_enable));
  endproperty

  property p_pready_timeout;
    @(posedge apb_clk) disable iff(!apb_resetn)
      in_access |-> ##[0:TIMEOUT_CYCLES] apb_ready;
  endproperty

  property p_slverr_only_with_handshake;
    @(posedge apb_clk) disable iff(!apb_resetn)
      apb_slverr |-> handshake;
  endproperty

  property p_no_x_on_controls_when_active;
    @(posedge apb_clk) disable iff(!apb_resetn)
      apb_sel |-> (!$isunknown({apb_sel, apb_enable, apb_write, apb_ready}));
  endproperty

  property p_no_x_on_addr_when_active;
    @(posedge apb_clk) disable iff(!apb_resetn)
      apb_sel |-> (!$isunknown(apb_addr));
  endproperty

  property p_no_x_on_wdata_when_write;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (apb_sel && apb_write) |-> (!$isunknown(apb_wdata) && !$isunknown(apb_strb));
  endproperty

  property p_no_x_on_rdata_when_read_handshake;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (handshake && !apb_write) |-> (!$isunknown(apb_rdata));
  endproperty

  property p_back2back_requires_setup;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (handshake && $rose(apb_sel)) |=> 1'b1; // not meaningful, ignore
  endproperty

  property p_if_psel_stays_high_after_handshake_then_setup;
    @(posedge apb_clk) disable iff(!apb_resetn)
      (handshake && $past(apb_sel) && apb_sel) |=> (!apb_enable);
  endproperty

  APB_RESET_IDLE        : assert property(p_reset_idle);

  APB_IDLE_PENABLE      : assert property(p_idle_psel_penable)
    else $error("APB_SVA","PENABLE must be low when PSEL is low");

  APB_SETUP_TO_ACCESS   : assert property(p_setup_to_access)
    else $error("APB_SVA","SETUP must go to ACCESS in 1 cycle (PSEL held, PENABLE rises)");

  APB_NO_ENABLE_NO_SETUP: assert property(p_no_enable_without_setup)
    else $error("APB_SVA","ACCESS seen without prior SETUP");

  APB_ENABLE_DROP_RULES : assert property(p_enable_drop_rules)
    else $error("APB_SVA","PENABLE dropped illegally (not after handshake / not idle)");

  APB_STABLE_CTRL_ADDR  : assert property(p_stable_addr_ctrl_strb_during_wait)
    else $error("APB_SVA","PADDR/PWRITE/PSTRB changed during wait-state (ACCESS & PREADY=0)");

  APB_STABLE_WDATA      : assert property(p_stable_wdata_during_wait)
    else $error("APB_SVA","PWDATA changed during wait-state write");

  APB_STABLE_EXTENDED   : assert property(p_stable_through_access_if_extended)
    else $error("APB_SVA","Signals not stable across extended ACCESS");

  APB_STRB_READ_ZERO    : assert property(p_strb_zero_on_read)
    else $error("APB_SVA","PSTRB must be 0 on reads");

  APB_PSEL_DROP_OK      : assert property(p_psel_drop_only_after_handshake)
    else $error("APB_SVA","PSEL deasserted without completing handshake in previous cycle");

  APB_HOLD_ENABLE_WAIT  : assert property(p_hold_enable_until_ready)
    else $error("APB_SVA","PENABLE must remain asserted until PREADY=1 in ACCESS");

  APB_AFTER_HANDSHAKE   : assert property(p_after_handshake_next_state)
    else $error("APB_SVA","After handshake, next cycle must be IDLE or SETUP (PENABLE low)");

  if (ENABLE_TIMEOUT) begin
    APB_TIMEOUT          : assert property(p_pready_timeout)
      else $error("APB_SVA","Slave timeout: PREADY not asserted within TIMEOUT_CYCLES");
  end

  APB_SLVERR_VALID      : assert property(p_slverr_only_with_handshake)
    else $error("APB_SVA","PSLVERR asserted outside of valid handshake");

  if (ENABLE_XCHECK) begin
    APB_NOX_CTRL         : assert property(p_no_x_on_controls_when_active)
      else $error("APB_SVA","X/Z detected on APB control signals while PSEL=1");
    APB_NOX_ADDR         : assert property(p_no_x_on_addr_when_active)
      else $error("APB_SVA","X/Z detected on PADDR while PSEL=1");
    APB_NOX_WDATA        : assert property(p_no_x_on_wdata_when_write)
      else $error("APB_SVA","X/Z detected on PWDATA/PSTRB during write");
  end

  if (ENABLE_BACK2BACK) begin
    APB_B2B_SETUP        : assert property(p_if_psel_stays_high_after_handshake_then_setup)
      else $error("APB_SVA","Back-to-back transfer must insert SETUP (PENABLE low) after handshake");
  end

endmodule
