import uvm_pkg::*;
`include "uvm_macros.svh"

import uart_pkg::*;
import apb_pkg::*;
import uart_regs_pkg::*;

class apb_uart_test_write_reg_error extends apb_uart_test_base;
  `uvm_component_utils(apb_uart_test_write_reg_error)

  uart_tx_seq               tx_seq;
  uart_rx_seq               rx_seq;

  apb_seq_write_stt_reg     seq_w_stt;
  apb_seq_write_rx_data_reg seq_w_rx_data;

  function new(string name="apb_uart_test_write_reg_error", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  virtual task run_phase(uvm_phase phase);
    tx_seq        = uart_tx_seq::type_id::create("tx_seq", this);
    rx_seq        = uart_rx_seq::type_id::create("rx_seq", this);
    seq_w_stt     = apb_seq_write_stt_reg::type_id::create("seq_w_stt", this);
    seq_w_rx_data = apb_seq_write_rx_data_reg::type_id::create("seq_w_rx_data", this);

    phase.raise_objection(this);
    `uvm_info("run_phase", "Starting apb_uart_test_write_reg_error", UVM_LOW)

    if (!seq_w_stt.randomize() with { stt_wdata inside {32'hDEAD_BEEF,32'hCAFE_BABE,32'h1234_5678}; })
      `uvm_fatal("RAND", "seq_w_stt randomize failed")

    if (!seq_w_rx_data.randomize() with { rx_data inside {[8'h00:8'hFF]}; })
      `uvm_fatal("RAND", "seq_w_rx_data randomize failed")

    seq_w_stt.start(m_apb_uart_env.m_apb_agent.sequencer);
    seq_w_rx_data.start(m_apb_uart_env.m_apb_agent.sequencer);

    if (seq_w_stt.got_rsp && (seq_w_stt.rsp_pready !== 1'b1))
      `uvm_error("APB_RO_WRITE", "STT(RO): PREADY not seen as 1 (or driver didn't sample correctly)")

    if (seq_w_rx_data.got_rsp && (seq_w_rx_data.rsp_pready !== 1'b1))
      `uvm_error("APB_RO_WRITE", "RX_DATA(RO): PREADY not seen as 1 (or driver didn't sample correctly)")

    #1000ns;
    `uvm_info("run_phase", "Ending apb_uart_test_write_reg_error", UVM_LOW)
    phase.drop_objection(this);
  endtask

endclass