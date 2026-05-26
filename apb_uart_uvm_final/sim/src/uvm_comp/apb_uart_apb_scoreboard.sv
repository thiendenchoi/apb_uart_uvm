class apb_uart_apb_scoreboard extends uvm_component;
  `uvm_component_utils(apb_uart_apb_scoreboard)

  uvm_analysis_imp #(apb_item, apb_uart_apb_scoreboard) apb_imp;

  uvm_analysis_port #(apb_item) apb_item_ap;

  int unsigned n_seen, n_slverr;

  extern function new(string name="apb_uart_apb_scoreboard", uvm_component parent=null);
  extern virtual function void write(apb_item t);
  extern virtual function void report_phase(uvm_phase phase);
endclass

function apb_uart_apb_scoreboard::new(string name="apb_uart_apb_scoreboard", uvm_component parent=null);
  super.new(name, parent);
  apb_imp     = new("apb_imp", this);
  apb_item_ap = new("apb_item_ap", this);
endfunction

function void apb_uart_apb_scoreboard::write(apb_item t);
  n_seen++;

  apb_item_ap.write(t);

  if (t.pslverr) begin
    n_slverr++;
    `uvm_warning("APB_SB", $sformatf("PSLVERR on access addr=0x%0h write=%0b", t.paddr, t.pwrite))
  end

  if (t.pwrite) begin
    if (t.pstrb == 4'b0000)
      `uvm_error("APB_SB", $sformatf("WRITE but PSTRB==0 at addr=0x%0h", t.paddr))
  end
  else begin
    if (t.pstrb != 4'b0000)
      `uvm_error("APB_SB", $sformatf("READ but PSTRB!=0 at addr=0x%0h (pstrb=%b)", t.paddr, t.pstrb))
  end

  unique case (t.paddr)

    TX_DATA_ADDR: begin
    end

    // RO
    RX_DATA_ADDR: begin
      if (t.pwrite)
        `uvm_error("APB_SB", "RX_DATA (0x4) is RO but got WRITE")
    end

    // RW
    CFG_ADDR: begin
    end

    // RW
    CTRL_ADDR: begin
    end

    // RO (Status)
    SS_ADDR: begin
      if (t.pwrite)
        `uvm_error("APB_SB", "SS (0x10) is RO but got WRITE")
    end

    default: begin
      `uvm_warning("APB_SB", $sformatf("Committed access to unknown addr 0x%0h", t.paddr))
    end

  endcase
endfunction

function void apb_uart_apb_scoreboard::report_phase(uvm_phase phase);
  `uvm_info("APB_SB", $sformatf("seen=%0d slverr=%0d", n_seen, n_slverr), UVM_LOW)
endfunction
