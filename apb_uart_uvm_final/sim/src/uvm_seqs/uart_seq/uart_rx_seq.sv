class uart_rx_seq extends uvm_sequence #(uart_rx_item);

  `uvm_object_utils(uart_rx_seq)
  `uvm_declare_p_sequencer(uart_rx_sequencer)

  uart_config rx_config;

  rand bit [7:0] data_reg;

  uart_rx_item rx_item;

  extern function new(string name = "uart_rx_seq");
  extern function void pre_randomize();
  extern virtual task body();

endclass : uart_rx_seq

function uart_rx_seq::new(string name = "uart_rx_seq");
  super.new(name);
endfunction : new

function void uart_rx_seq::pre_randomize();
  super.pre_randomize();

  if (rx_config == null) begin
    if (p_sequencer == null) begin
      `uvm_fatal(get_type_name(), "p_sequencer is null - cannot get rx_config")
    end
    rx_config = p_sequencer.rx_config;
  end
endfunction


task uart_rx_seq::body();
  rx_item = uart_rx_item::type_id::create("rx_item");

  `uvm_do_with(rx_item, { data_reg == local::data_reg; })

  `uvm_info(get_type_name(),
            $sformatf("UART_RX item data=0x%02h", rx_item.data_reg),
            UVM_LOW)
endtask 
