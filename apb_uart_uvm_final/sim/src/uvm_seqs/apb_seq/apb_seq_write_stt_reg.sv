`ifndef APB_SEQ_WRITE_STT_REG_SV
`define APB_SEQ_WRITE_STT_REG_SV

import uvm_pkg::*;
`include "uvm_macros.svh"

import apb_pkg::*;

class apb_seq_write_stt_reg extends apb_seq_base;
  `uvm_object_utils(apb_seq_write_stt_reg)

  localparam logic [11:0] STT_ADDR = 12'h010;

  rand logic [31:0] stt_wdata;

  logic got_rsp;
  logic rsp_pready;
  logic rsp_pslverr;

  function new(string name="apb_seq_write_stt_reg");
    super.new(name);
    got_rsp    = 1'b0;
    rsp_pready = 1'b0;
    rsp_pslverr= 1'b0;
  endfunction

  task body();
    apb_item tr;

    tr = apb_item::type_id::create("tr_stt_ro");

    start_item(tr);
      tr.pwrite = 1'b1;
      tr.paddr  = STT_ADDR;
      tr.pwdata = stt_wdata;
      tr.pstrb  = 4'hF;
    finish_item(tr);

    rsp_pready  = tr.pready;
    rsp_pslverr = tr.pslverr;
    got_rsp     = (!$isunknown(tr.pready) && !$isunknown(tr.pslverr));

    `uvm_info(get_type_name(),
      $sformatf("FORCE-WR STT(RO) @0x%0h pwdata=0x%08h | pready=%0b pslverr=%0b%s",
                tr.paddr, tr.pwdata, tr.pready, tr.pslverr,
                got_rsp ? "" : " (driver may not sample rsp)"),
      UVM_LOW)
  endtask

endclass

`endif