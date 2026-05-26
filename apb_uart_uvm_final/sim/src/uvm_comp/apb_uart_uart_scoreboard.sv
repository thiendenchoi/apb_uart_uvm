`uvm_analysis_imp_decl(_uart_tx)
`uvm_analysis_imp_decl(_uart_rx)

class apb_uart_uart_scoreboard extends uvm_component;
  `uvm_component_utils(apb_uart_uart_scoreboard)

  uvm_analysis_imp_uart_tx #(uart_tx_item, apb_uart_uart_scoreboard) tx_imp;
  uvm_analysis_imp_uart_rx #(uart_rx_item, apb_uart_uart_scoreboard) rx_imp;

  // forward to E2E
  uvm_analysis_port #(uart_tx_item) tx_ap;
  uvm_analysis_port #(uart_rx_item) rx_ap;

  int unsigned tx_seen, rx_seen, rx_parity_err, rx_stop_err;

  extern function new(string name="apb_uart_uart_scoreboard", uvm_component parent=null);
  extern virtual function void write_uart_tx(uart_tx_item t);
  extern virtual function void write_uart_rx(uart_rx_item t);
  extern virtual function void report_phase(uvm_phase phase);
endclass

function apb_uart_uart_scoreboard::new(string name="apb_uart_uart_scoreboard", uvm_component parent=null);
  super.new(name, parent);
  tx_imp = new("tx_imp", this);
  rx_imp = new("rx_imp", this);
  tx_ap  = new("tx_ap",  this);
  rx_ap  = new("rx_ap",  this);
endfunction

function void apb_uart_uart_scoreboard::write_uart_tx(uart_tx_item t);
  tx_seen++;
  tx_ap.write(t);
  `uvm_info("UART_SB", $sformatf("TX observed: 0x%02h", t.data_in), UVM_MEDIUM)
endfunction

function void apb_uart_uart_scoreboard::write_uart_rx(uart_rx_item t);
  rx_seen++;
  rx_ap.write(t);

  if (t.parity_error) begin
    rx_parity_err++;
    `uvm_warning("UART_SB", $sformatf("RX parity_error on 0x%02h", t.data_reg))
  end
  if (t.stop_error) begin
    rx_stop_err++;
    `uvm_warning("UART_SB", $sformatf("RX stop_error on 0x%02h", t.data_reg))
  end

  `uvm_info("UART_SB", $sformatf("RX observed: 0x%02h", t.data_reg), UVM_MEDIUM)
endfunction

function void apb_uart_uart_scoreboard::report_phase(uvm_phase phase);
  `uvm_info("UART_SB",
    $sformatf("tx=%0d rx=%0d parity_err=%0d stop_err=%0d",
              tx_seen, rx_seen, rx_parity_err, rx_stop_err),
    UVM_LOW)
endfunction