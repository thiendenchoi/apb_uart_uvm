`include "uvm_macros.svh"
import uvm_pkg::*;
class apb_reg_adapter extends uvm_reg_adapter;

  `uvm_object_utils(apb_reg_adapter)

  bit use_fixed_pstrb = 0;
  bit [3:0] fixed_pstrb = 4'hF;

  function new(string name = "apb_reg_adapter");
    super.new(name);
  endfunction

  virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
    apb_item req = apb_item::type_id::create("req");
    req.paddr  = rw.addr;
    req.pwdata = rw.data;
    req.pwrite = (rw.kind == UVM_WRITE) ? 1 : 0;
    req.pstrb   = (rw.kind == UVM_WRITE) ? (use_fixed_pstrb ? fixed_pstrb : '1) : '0;
    // add pstrb and pprot
    req.prdata = '0;
    `uvm_info(get_type_name(), $sformatf("Reg2bus: addr=0x%0h data=0x%0h kind%s", req.paddr, req.pwdata, (req.pwrite ? "WRITE" : "READ")),UVM_DEBUG)
    return req;
  endfunction

  // Convert from APB transaction to RAL operation
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_item rsp;
    if(!$cast(rsp, bus_item)) begin
      `uvm_fatal(get_type_name(), "Failed to cast bus_item to apb_item")
    end
    rw.addr = rsp.paddr;
    rw.kind = (rsp.pwrite) ? UVM_WRITE : UVM_READ;
    // Data: read get prdata, write -> pwdata(expected);
    if (rw.kind == UVM_READ) begin
      rw.data = rsp.prdata;
    end else begin
      rw.data = rsp.pwdata;
    end

    // Check pslverr to control the writing to the RAL
    if (rsp.pslverr) begin
      rw.status = UVM_NOT_OK; // ERROR
      `uvm_warning (get_type_name(),$sformatf("APB PSLVERR=1 at addr=0x%0h -> skip RAL update",rsp.paddr))
    end
    else begin
      rw.status = UVM_IS_OK;
    end
    `uvm_info ("adapter", $sformatf("bus2reg : addr=0x%0h data=0x%0h kind=%s status=%s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_DEBUG)
  endfunction
endclass