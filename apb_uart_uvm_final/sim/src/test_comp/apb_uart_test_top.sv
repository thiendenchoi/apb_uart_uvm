`include "apb_intf.sv"
`include "uart_tx_intf.sv"
`include "uart_rx_intf.sv"
`include "apb_sva.sv"
`include "uart_tx_sva.sv"
`include "uart_rx_sva.sv"
`include "apb_uart_test_base.sv"
`include "apb_uart_testcase_include.svh"

module apb_uart_test_top;

  /** Import UVM Package */
  import uvm_pkg::*;
  /** Import uart_regs Package */
  import uart_regs_pkg::*;
  /** Import APB VIP Package */
  import apb_pkg::*;
  /** Import UART VIP Package */
  import uart_pkg::*;
  /** Import APB SEQ Package */
  import apb_seq_pkg::*;
  /** Import UART SEQ Package */
  import uart_seq_pkg::*;

  logic        clk;
  logic        reset_n;

  apb_intf     apb_intf();
  uart_tx_intf tx_intf();
  uart_rx_intf rx_intf();

  apb_sva apb_sva(.intf(apb_intf));
  uart_tx_sva tx_sva(.intf(tx_intf));
  uart_rx_sva rx_sva(.intf(rx_intf));

  uart dut(
    .clk      (clk),
    .reset_n  (reset_n),
    .pclk     (apb_intf.clk),
    .preset_n (apb_intf.reset_n),
    .psel     (apb_intf.psel),
    .penable  (apb_intf.penable),
    .pwrite   (apb_intf.pwrite),
    .pstrb    (apb_intf.pstrb),
    .paddr    (apb_intf.paddr),
    .pwdata   (apb_intf.pwdata),
    .rx       (tx_intf.tx),
    .cts_n    (rx_intf.rts_n),
    .pready   (apb_intf.pready),
    .pslverr  (apb_intf.pslverr),
    .prdata   (apb_intf.prdata),
    .tx       (rx_intf.rx),
    .rts_n    (tx_intf.cts_n)
    );

  assign apb_intf.clk = clk;
  assign apb_intf.reset_n = reset_n;
  assign rx_intf.clk = clk;
  assign tx_intf.clk = clk;
  assign tx_intf.reset_n = reset_n;
  assign rx_intf.reset_n = reset_n;

  initial begin
    clk = 0;
    forever #10ns clk = ~clk;
  end

  initial begin
    reset_n = 1;
    #10ns;
    reset_n = 0;
    #10ns;
    reset_n = 1;
  end

  initial begin
    uvm_config_db#(virtual apb_intf    )::set(null, "*", "apb_intf", apb_intf);
    uvm_config_db#(virtual uart_tx_intf)::set(null, "*", "tx_intf",  tx_intf);
    uvm_config_db#(virtual uart_rx_intf)::set(null, "*", "rx_intf",  rx_intf);
  
    uvm_reg::include_coverage("*", UVM_CVR_ALL);
    run_test();
  end

endmodule