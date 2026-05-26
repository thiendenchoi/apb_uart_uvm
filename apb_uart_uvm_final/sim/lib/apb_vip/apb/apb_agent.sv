class apb_agent extends uvm_agent;
     
    `uvm_component_utils(apb_agent)
    
    apb_driver    driver;
    apb_sequencer sequencer;
    apb_monitor   monitor;
    apb_cov       cov;
    
    extern function new(string name="apb_agent", uvm_component parent);
    
    extern function void build_phase(uvm_phase phase);
    
    extern function void connect_phase(uvm_phase phase);
    
endclass

function apb_agent::new(string name="apb_agent", uvm_component parent);
    super.new(name, parent);
endfunction

function void apb_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);
    monitor = apb_monitor::type_id::create("monitor", this);
    cov = apb_cov::type_id::create("cov", this);
    if(is_active == UVM_ACTIVE) begin
        driver    = apb_driver::type_id::create("driver", this);
        sequencer = apb_sequencer::type_id::create("sequencer", this);
    end
endfunction

function void apb_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(is_active == UVM_ACTIVE) begin
        driver.seq_item_port.connect(sequencer.seq_item_export);
    end
    monitor.item_collected_port.connect(cov.analysis_export);
endfunction