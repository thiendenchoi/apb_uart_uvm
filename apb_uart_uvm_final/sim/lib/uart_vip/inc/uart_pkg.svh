package uart_pkg;
  import  uvm_pkg::*;
  `include "uvm_macros.svh"
  
  `include "uart_param.sv"

    // `include "uart_tx_intf.sv"
    // `include "uart_rx_intf.sv"

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

endpackage