`include "uvm_macros.svh"
import uvm_pkg::*;
import uart_pkg::*; 

class uart_tx_seq extends uvm_sequence #(uart_tx_item);

  `uvm_object_utils(uart_tx_seq)
  `uvm_declare_p_sequencer(uart_tx_sequencer)

  uart_config tx_config;

  rand bit [7:0] data_in;

  uart_tx_item tx_item;

  extern function new(string name = "uart_tx_seq");
  extern function void pre_randomize();
  extern virtual task body();

endclass

function uart_tx_seq::new(string name = "uart_tx_seq");
  super.new(name);
endfunction


function void uart_tx_seq::pre_randomize();
  super.pre_randomize();

  if (tx_config == null) begin
    if (p_sequencer == null) begin
      `uvm_fatal(get_type_name(), "p_sequencer is null - cannot get tx_config")
    end
    tx_config = p_sequencer.tx_config;
  end
endfunction


task uart_tx_seq::body();
  tx_item = uart_tx_item::type_id::create("tx_item");

  `uvm_do_with(tx_item, { data_in == local::data_in; })

  `uvm_info(get_type_name(),
            $sformatf("UART_TX item data=0x%02h", tx_item.data_in),
            UVM_LOW)
endtask : body
