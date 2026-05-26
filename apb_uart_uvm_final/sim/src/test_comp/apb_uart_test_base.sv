`include "uvm_macros.svh"
import uvm_pkg::*;

import apb_seq_pkg::*;
import uart_seq_pkg::*;

`include "apb_uart_env.sv"

class apb_uart_test_base extends uvm_test;
  `uvm_component_utils(apb_uart_test_base)

  apb_uart_env           m_apb_uart_env;

  uart_config            m_uart_config;
  virtual uart_tx_intf   tx_intf;
  virtual uart_rx_intf   rx_intf;
  virtual apb_intf       apb_vif;

  function new(string name="apb_uart_test_base", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_apb_uart_env = apb_uart_env::type_id::create("m_apb_uart_env", this);
    m_uart_config  = uart_config::type_id::create("m_uart_config");

    // m_uart_config.data_bit_num    = DATA_8_BIT;
    // m_uart_config.parity_bit_en   = PARITY_EN;
    // m_uart_config.parity_bit_type = PARITY_EVEN;
    // m_uart_config.stop_bit_num    = STOP_1_BIT;
    // m_uart_config.baudrate        = 115200;

    // GET interfaces from config_db
    // IMPORTANT: get from 'this' and "" so it matches values set at uvm_test_top or "*"
    if (!uvm_config_db#(virtual uart_tx_intf)::get(this, "", "tx_intf", tx_intf) || (tx_intf == null))
      `uvm_fatal("GET_INTF", "apb_uart_test_base: cannot get tx_intf (key='tx_intf')")

    if (!uvm_config_db#(virtual uart_rx_intf)::get(this, "", "rx_intf", rx_intf) || (rx_intf == null))
      `uvm_fatal("GET_INTF", "apb_uart_test_base: cannot get rx_intf (key='rx_intf')")

    if (!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", apb_vif) || (apb_vif == null))
      `uvm_fatal("GET_INTF", "apb_uart_test_base: cannot get apb_intf (key='apb_intf')")

    // Put vifs into config object (driver takes from config in connect_phase)
    m_uart_config.tx_intf = tx_intf;
    m_uart_config.rx_intf = rx_intf;

    // Pass uart_config to env using the key env expects: "uart_config"
    uvm_config_db#(uart_config)::set(this, "m_apb_uart_env", "uart_config", m_uart_config);

    // Pass APB interface to APB agent/driver (cover both possible instance names)
    uvm_config_db#(virtual apb_intf)::set(this, "m_apb_uart_env.apb_agent.*",   "apb_intf", apb_vif);
    uvm_config_db#(virtual apb_intf)::set(this, "m_apb_uart_env.m_apb_agent.*", "apb_intf", apb_vif);

    // Pass UART interfaces to UART agents (cover both possible instance names)
    uvm_config_db#(virtual uart_tx_intf)::set(this, "m_apb_uart_env.uart_tx_agent.*",   "tx_intf", tx_intf);
    uvm_config_db#(virtual uart_tx_intf)::set(this, "m_apb_uart_env.m_uart_tx_agent.*", "tx_intf", tx_intf);

    uvm_config_db#(virtual uart_rx_intf)::set(this, "m_apb_uart_env.uart_rx_agent.*",   "rx_intf", rx_intf);
    uvm_config_db#(virtual uart_rx_intf)::set(this, "m_apb_uart_env.m_uart_rx_agent.*", "rx_intf", rx_intf);

  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    // If your env member name is different, adjust here.
    // (Also: key name had a typo in your original: "apb_apb_uart_regs")
    if (m_apb_uart_env != null && m_apb_uart_env.apb_uart_regs != null) begin
      uvm_config_db#(uart_regs)::set(null, "*", "apb_uart_regs", m_apb_uart_env.apb_uart_regs);
    end
    else begin
      `uvm_warning("NORAL", "apb_uart_test_base: apb_uart_regs is null; reg sequences may fatal")
    end
  endfunction
  task wait_tx_done_0_then_e2e_then_1(
    apb_seq_read_stt_reg seq_r_stt,
    int unsigned drop_timeout = 2000,
    int unsigned e2e_timeout_cycles = 500000
  );
    int unsigned timeout;

    // A) wait tx_done drop to 0
    timeout = drop_timeout;
    do begin
      seq_r_stt.start(m_apb_uart_env.m_apb_agent.sequencer);
      if (timeout-- == 0) begin
        `uvm_fatal("TX_DONE",
          $sformatf("Timeout waiting tx_done drop to 0, stt=%h", seq_r_stt.value))
      end
    end while (seq_r_stt.value[0] !== 1'b0);

    // B) wait end-of-frame from E2E (with timeout)
    fork
      begin : WAIT_E2E_DONE
        m_apb_uart_env.e2e_sb.tx_frame_done = 1'b0;
        m_apb_uart_env.e2e_sb.tx_frame_ok   = 1'b0;

        m_apb_uart_env.e2e_sb.ev_dut_tx_byte.wait_trigger();

        if (m_apb_uart_env.e2e_sb.tx_frame_ok) begin
          `uvm_info("E2E_SB", "TX frame matched expected byte", UVM_LOW)
        end else begin
          `uvm_info("E2E_SB", "TX frame observed but byte mismatch/unexpected (already reported in E2E_SB)", UVM_LOW)
        end
      end

      begin : TIMEOUT_E2E
        int unsigned cyc;
        for (cyc = 0; cyc < e2e_timeout_cycles; cyc++) begin
          @(posedge $root.apb_uart_test_top.clk);
        end
        `uvm_fatal("E2E_WAIT", "Timeout waiting E2E end-of-frame event (DUT_TX observed)")
      end
    join_any
    disable fork;

    // C) immediately after end-of-frame: tx_done must be 1
    seq_r_stt.start(m_apb_uart_env.m_apb_agent.sequencer);
    if (seq_r_stt.value[0] !== 1'b1) begin
      `uvm_error("TX_DONE",
        $sformatf("Expected tx_done=1 immediately after end-of-frame, stt=%h", seq_r_stt.value))
    end else begin
      `uvm_info("TX_DONE", "PASS: tx_done=1 immediately after end-of-frame", UVM_LOW)
    end
  endtask
endclass