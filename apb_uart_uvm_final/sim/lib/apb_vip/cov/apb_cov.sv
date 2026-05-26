`ifndef APB_COV_SV
`define APB_COV_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

class apb_cov extends uvm_subscriber #(apb_item);
  `uvm_component_utils(apb_cov)

  localparam bit [11:0] UART_TX_DATA_ADDR = 12'h000;
  localparam bit [11:0] UART_RX_DATA_ADDR = 12'h004;
  localparam bit [11:0] UART_CFG_ADDR     = 12'h008;
  localparam bit [11:0] UART_CTRL_ADDR    = 12'h00C;
  localparam bit [11:0] UART_STT_ADDR     = 12'h010;

  apb_item tr_last;
  apb_item tr_shadow;

  covergroup apb_cg;

    cp_dir : coverpoint tr_shadow.pwrite {
      bins READ  = {1'b0};
      bins WRITE = {1'b1};
    }

    // NOTE: Do NOT use default bins when you want to reference them in binsof()
    //       (Questa will complain in cross bin select expressions).
    cp_addr : coverpoint tr_shadow.paddr[11:0] {
      bins TX_DATA = {UART_TX_DATA_ADDR};
      bins RX_DATA = {UART_RX_DATA_ADDR};
      bins CFG     = {UART_CFG_ADDR};
      bins CTRL    = {UART_CTRL_ADDR};
      bins STT     = {UART_STT_ADDR};

      // OTHER = all addresses except the known ones above
      bins OTHER = {[12'h000:12'hFFF]} with
                   (!(item inside {UART_TX_DATA_ADDR, UART_RX_DATA_ADDR, UART_CFG_ADDR,
                                   UART_CTRL_ADDR, UART_STT_ADDR}));
    }

    cp_strb : coverpoint tr_shadow.pstrb {
      bins B0    = {4'b0001};
      bins B01   = {4'b0011};
      bins B012  = {4'b0111};
      bins B0123 = {4'b1111};
      bins OTH   = default;
    }

    // cp_err : coverpoint tr_shadow.pslverr {
    //   bins OK  = {1'b0};
    //   bins ERR = {1'b1};
    // }

    cross_dir_addr : cross cp_dir, cp_addr {
      ignore_bins wr_ro  = binsof(cp_dir.WRITE) && (binsof(cp_addr.RX_DATA) || binsof(cp_addr.STT));
      ignore_bins rd_wo  = binsof(cp_dir.READ)  && binsof(cp_addr.OTHER);
      ignore_bins wr_oth = binsof(cp_dir.WRITE) && binsof(cp_addr.OTHER);
    }

    cp_cfg_data_bits : coverpoint tr_shadow.pwdata[1:0]
      iff (tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_CFG_ADDR)) {
        bins DB5 = {2'b00};
        bins DB6 = {2'b01};
        bins DB7 = {2'b10};
        bins DB8 = {2'b11};
      }

    cp_cfg_stop_bits : coverpoint tr_shadow.pwdata[2]
      iff (tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_CFG_ADDR)) {
        bins STOP_1 = {1'b0};
        bins STOP_2 = {1'b1};
      }

    cp_cfg_parity_en : coverpoint tr_shadow.pwdata[3]
      iff (tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_CFG_ADDR)) {
        bins PAR_OFF = {1'b0};
        bins PAR_ON  = {1'b1};
      }

    cp_cfg_parity_type : coverpoint tr_shadow.pwdata[4]
      iff (tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_CFG_ADDR)) {
        bins ODD  = {1'b0};
        bins EVEN = {1'b1};
      }

    cross_parity : cross cp_cfg_parity_en, cp_cfg_parity_type {
      ignore_bins type_when_off = binsof(cp_cfg_parity_en.PAR_OFF) && binsof(cp_cfg_parity_type);
    }

    cp_ctrl_start_tx : coverpoint tr_shadow.pwdata[0]
      iff (tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_CTRL_ADDR)) {
        bins START_0 = {1'b0};
        bins START_1 = {1'b1};
      }

    cp_tx_data_byte : coverpoint tr_shadow.pwdata[7:0]
      iff (tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_TX_DATA_ADDR)) {
        bins ZERO = {8'h00};
        bins MAX  = {8'hFF};
        bins OTH  = default;
      }

    cp_rx_data_byte : coverpoint tr_shadow.prdata[7:0]
      iff (!tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_RX_DATA_ADDR)) {
        bins ZERO = {8'h00};
        bins MAX  = {8'hFF};
        bins OTH  = default;
      }

    // cp_stt_tx_done : coverpoint tr_shadow.prdata[0]
    //   iff (!tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_STT_ADDR)) {
    //     bins TXD_0 = {1'b0};
    //     bins TXD_1 = {1'b1};
    //   }

    // cp_stt_rx_done : coverpoint tr_shadow.prdata[1]
    //   iff (!tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_STT_ADDR)) {
    //     bins RXD_0 = {1'b0};
    //     bins RXD_1 = {1'b1};
    //   }

    // cp_stt_parity_err : coverpoint tr_shadow.prdata[2]
    //   iff (!tr_shadow.pwrite && (tr_shadow.paddr[11:0] == UART_STT_ADDR)) {
    //     bins PE_0 = {1'b0};
    //     bins PE_1 = {1'b1};
    //   }

    // cross_err_addr : cross cp_err, cp_addr;

  endgroup

  // constructor
  function new(string name="apb_cov", uvm_component parent=null);
    super.new(name, parent);
    tr_shadow = new();
    apb_cg    = new();
  endfunction

  virtual function void write(apb_item t);
    tr_last = t;

    tr_shadow.pwrite  = t.pwrite;
    tr_shadow.paddr   = t.paddr;
    tr_shadow.pwdata  = t.pwdata;
    tr_shadow.prdata  = t.prdata;
    tr_shadow.pstrb   = t.pstrb;
    tr_shadow.pslverr = t.pslverr;

    apb_cg.sample();

    `uvm_info(get_type_name(),
      $sformatf("APB_UART_COV sample: %s @0x%0h strb=%0b W=0x%0h R=0x%0h err=%0b",
                t.pwrite ? "WR" : "RD",
                t.paddr, t.pstrb, t.pwdata, t.prdata, t.pslverr),
      UVM_DEBUG)
  endfunction

endclass

`endif
