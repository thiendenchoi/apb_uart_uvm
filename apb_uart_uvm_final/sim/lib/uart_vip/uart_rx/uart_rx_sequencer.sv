class uart_rx_sequencer extends uvm_sequencer #(uart_rx_item);

  // UART rx configuration object.
  uart_config rx_config;

  `uvm_component_utils(uart_rx_sequencer)

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
endclass

// Function: new
// Constructor of object.
function uart_rx_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction


// Function: build_phase
// UVM built-in method.
function void uart_rx_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Get the cfg object
  if (!uvm_config_db #(uart_config)::get(this, "", "rx_config", rx_config) && rx_config == null)
    `uvm_fatal("build_phase", "Cannot get UART RX configuration in sequencer")
endfunction
