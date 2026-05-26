`uvm_analysis_imp_decl(_e2e_apb)
`uvm_analysis_imp_decl(_e2e_tx)
`uvm_analysis_imp_decl(_e2e_rx)

class apb_uart_e2e_scoreboard extends uvm_component;
  `uvm_component_utils(apb_uart_e2e_scoreboard)

  uvm_analysis_imp_e2e_apb #(apb_item, apb_uart_e2e_scoreboard) apb_imp;

  uvm_analysis_imp_e2e_tx  #(uart_rx_item, apb_uart_e2e_scoreboard) tx_imp;
  uvm_analysis_imp_e2e_rx  #(uart_tx_item, apb_uart_e2e_scoreboard) rx_imp;

  uvm_event ev_dut_tx_byte; 
  bit tx_frame_done;
  bit tx_frame_ok;  
  byte unsigned exp_tx_q[$]; 
  byte unsigned exp_rx_q[$]; 

  int unsigned tx_match, tx_mismatch, tx_unexpected;
  int unsigned rx_match, rx_mismatch, rx_underflow;

  extern function new(string name="apb_uart_e2e_scoreboard", uvm_component parent=null);
  extern virtual function void write_e2e_apb(apb_item t);
  extern virtual function void write_e2e_tx(uart_rx_item t); 
  extern virtual function void write_e2e_rx(uart_tx_item t); 
  extern virtual function void report_phase(uvm_phase phase);
endclass

function apb_uart_e2e_scoreboard::new(string name="apb_uart_e2e_scoreboard", uvm_component parent=null);
  super.new(name, parent);
  apb_imp = new("apb_imp", this);
  tx_imp  = new("tx_imp",  this);
  rx_imp  = new("rx_imp",  this);
  ev_dut_tx_byte = new("ev_dut_tx_byte");

endfunction

function void apb_uart_e2e_scoreboard::write_e2e_apb(apb_item t);
  if (t.pslverr) return; 

  if ((t.paddr == TX_DATA_ADDR) && t.pwrite) begin
    byte unsigned b = apb_get_byte_from_wdata(t);
    exp_tx_q.push_back(b);
    `uvm_info("E2E_SB", $sformatf("APB->TXDATA queued(expect DUT_TX): 0x%02h", b), UVM_MEDIUM)
  end

  if ((t.paddr == RX_DATA_ADDR) && !t.pwrite) begin
    byte unsigned got = apb_get_byte_from_rdata(t);
    if (exp_rx_q.size() == 0) begin
      rx_underflow++;
      `uvm_error("E2E_SB", $sformatf("APB read RXDATA=0x%02h but no DUT_RX(stimulus) queued", got))
    end else begin
      byte unsigned exp = exp_rx_q.pop_front();
      if (got !== exp) begin
        rx_mismatch++;
        `uvm_error("E2E_SB", $sformatf("RX MISMATCH: APB_RXDATA=0x%02h expected DUT_RX(stimulus)=0x%02h", got, exp))
      end else begin
        rx_match++;
        `uvm_info("E2E_SB", $sformatf("RX MATCH: 0x%02h", got), UVM_LOW)
      end
    end
  end
endfunction

function void apb_uart_e2e_scoreboard::write_e2e_tx(uart_rx_item t);
  byte unsigned got = t.data_reg; 
  bit ok;
  ok =0;

  if (exp_tx_q.size() == 0) begin
    tx_unexpected++;
    `uvm_error("E2E_SB", $sformatf("DUT_TX observed 0x%02h but no APB TXDATA queued", got))
  end else begin
    byte unsigned exp = exp_tx_q.pop_front();
    if (got !== exp) begin
      tx_mismatch++;
      `uvm_error("E2E_SB", $sformatf("TX MISMATCH: DUT_TX=0x%02h expected APB_TXDATA=0x%02h", got, exp))
    end else begin
      tx_match++;
      ok = 1;
      `uvm_info("E2E_SB", $sformatf("TX MATCH: 0x%02h", got), UVM_LOW)
    end
  end
  tx_frame_ok   = ok;
  tx_frame_done = 1'b1;
  ev_dut_tx_byte.trigger();
endfunction

function void apb_uart_e2e_scoreboard::write_e2e_rx(uart_tx_item t); 
  byte unsigned b = t.data_in; 
  exp_rx_q.push_back(b);
  `uvm_info("E2E_SB", $sformatf("DUT_RX(stimulus) queued(expect APB_RXDATA): 0x%02h", b), UVM_MEDIUM)

  if (exp_rx_q.size() > 1) begin
    `uvm_warning("E2E_SB",
      $sformatf("No-FIFO warning: %0d RX bytes queued. DUT should hold rx_valid until CPU reads.",
                exp_rx_q.size()))
  end
endfunction

function void apb_uart_e2e_scoreboard::report_phase(uvm_phase phase);
  `uvm_info("E2E_SB",
    $sformatf("TX match=%0d mismatch=%0d unexpected=%0d | RX match=%0d mismatch=%0d underflow=%0d | pending_tx=%0d pending_rx=%0d",
              tx_match, tx_mismatch, tx_unexpected,
              rx_match, rx_mismatch, rx_underflow,
              exp_tx_q.size(), exp_rx_q.size()),
    UVM_LOW)
endfunction