`include "uvm_macros.svh"
import uvm_pkg::*;

// `include "uart_regs_pkg.sv"
import uart_regs_pkg::*;

// `include "apb_item.sv"
`include "apb_sequencer.sv"
`include "apb_cov.sv"
`include "apb_monitor.sv"
`include "apb_driver.sv"
`include "apb_agent.sv"

`include "uart_param.sv"

`include "uart_tx_intf.sv"
`include "uart_rx_intf.sv"

`include "uart_config.sv"

`include "uart_tx_item.sv"
`include "uart_tx_driver.sv"
`include "uart_tx_monitor.sv"
`include "uart_tx_sequencer.sv"
`include "uart_tx_agent.sv"

`include "uart_rx_item.sv"
`include "uart_rx_driver.sv"
`include "uart_rx_monitor.sv"
`include "uart_rx_sequencer.sv"
`include "uart_rx_agent.sv"

`include "apb_intf.sv"
// `include "apb_reg_adapter.sv"

`include "apb_seq_base.sv"
`include "apb_seq_read_cfg_reg.sv"
`include "apb_seq_read_ctrl_reg.sv"
`include "apb_seq_read_rx_data_reg.sv"
`include "apb_seq_read_stt_reg.sv"
`include "apb_seq_read_tx_data_reg.sv"
`include "apb_seq_write_cfg_reg.sv"
`include "apb_seq_write_ctrl_reg.sv"
`include "apb_seq_write_tx_data_reg.sv"

`include "uart_tx_seq.sv"
`include "uart_rx_seq.sv"

`include "apb_uart_env.sv"
`include "apb_sva.sv"
`include "apb_uart_test_base.sv"
`include "apb_uart_test_normal.sv"