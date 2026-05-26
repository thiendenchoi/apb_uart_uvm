class uart_tx_sequencer extends uvm_sequencer #(uart_tx_item);

  // UART TX configuration object.
  uart_config tx_config;

  `uvm_component_utils(uart_tx_sequencer)

  extern                   function      new(string name, uvm_component parent);
  extern           virtual function void build_phase(uvm_phase phase);
endclass

// Function: new
// Constructor of object.
function uart_tx_sequencer::new(string name, uvm_component parent);
  super.new(name, parent);
endfunction


// Function: build_phase
// UVM built-in method.
function void uart_tx_sequencer::build_phase(uvm_phase phase);
  super.build_phase(phase);

  // Get the cfg object
  if (!uvm_config_db #(uart_config)::get(this, "", "tx_config", tx_config) && tx_config == null)
    `uvm_fatal("build_phase", "Cannot get UART TX configuration in sequencer")
endfunction