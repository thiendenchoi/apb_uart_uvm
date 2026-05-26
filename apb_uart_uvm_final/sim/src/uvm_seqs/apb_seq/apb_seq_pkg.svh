package apb_seq_pkg;
  import  uart_regs_pkg::*;
  import  uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "apb_seq_base.sv"
  `include "apb_seq_read_cfg_reg.sv"
  `include "apb_seq_read_ctrl_reg.sv"
  `include "apb_seq_read_rx_data_reg.sv"
  `include "apb_seq_read_stt_reg.sv"
  `include "apb_seq_read_tx_data_reg.sv"
  `include "apb_seq_write_cfg_reg.sv"
  `include "apb_seq_write_ctrl_reg.sv"
  `include "apb_seq_write_tx_data_reg.sv"
  `include "apb_seq_write_rx_data_reg.sv"
  `include "apb_seq_write_stt_reg.sv"

endpackage