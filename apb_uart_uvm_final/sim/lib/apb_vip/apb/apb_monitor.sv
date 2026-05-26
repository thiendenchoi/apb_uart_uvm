class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)
    virtual apb_intf vif;
    uvm_analysis_port #(apb_item) item_collected_port;
    apb_item trans_collected;
    
    extern function new(string name="apb_monitor", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task collect_transaction();
endclass

function apb_monitor::new(string name="apb_monitor", uvm_component parent);
    super.new(name, parent);
endfunction

function void apb_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
        `uvm_fatal(get_type_name(), "Virtual interface not found in config_db")
    item_collected_port = new("item_collected_port", this);
    trans_collected = apb_item::type_id::create("trans_collected");
endfunction

task apb_monitor::run_phase(uvm_phase phase);
    wait(vif.reset_n);
    forever begin
        collect_transaction();
    end
endtask


task apb_monitor::collect_transaction();
    apb_item item;

    do @(posedge vif.clk);
    while (!(vif.psel && !vif.penable));

    // setup
    item = apb_item::type_id::create("item");
    item.pwrite = vif.pwrite;
    item.paddr  = vif.paddr;
    item.pstrb  = vif.pstrb;
    if (item.pwrite)
        item.pwdata = vif.pwdata;

    // access
    do @(posedge vif.clk);
    while (!(vif.psel && vif.penable && vif.pready));

    item.pready  = vif.pready;
    item.pslverr = vif.pslverr;
    if (!item.pwrite)
        item.prdata = vif.prdata;

    item_collected_port.write(item);
    `uvm_info(get_type_name(), $sformatf("Transaction collected:\n%s", item.sprint()), UVM_MEDIUM)
endtask