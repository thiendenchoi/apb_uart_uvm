class apb_driver extends uvm_driver #(apb_item);
    `uvm_component_utils(apb_driver)

    virtual apb_intf vif;
    extern function new(string name="apb_driver", uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern task reset_signal();
    extern task write(apb_item apb_item);
    extern task read(apb_item apb_item);
    extern task select_drive(apb_item apb_item);

endclass

function apb_driver::new(string name="apb_driver", uvm_component parent);
    super.new(name, parent);
endfunction

function void apb_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_intf)::get(this, "", "apb_intf", vif))
        `uvm_fatal(get_type_name(), "Virtual interface not found in config_db")
endfunction

function void apb_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

task apb_driver::run_phase(uvm_phase phase);
    reset_signal();
    wait(vif.reset_n);
    @(posedge vif.clk);
    forever begin
        seq_item_port.get_next_item(req);
        select_drive(req);
        seq_item_port.item_done();
    end
endtask

task apb_driver::reset_signal();
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwrite  <= 1'b0;
    vif.paddr   <= 12'h0;
    vif.pstrb   <= 4'h0;
    vif.pwdata  <= 32'h0;
endtask

task apb_driver::write(apb_item apb_item);
    int unsigned timeout_cnt;
    int unsigned TIMEOUT_CYCLES = 1000;
    // setup
    @(posedge vif.clk);
    vif.psel    <= 1'b1;
    vif.penable <= 1'b0;
    vif.pwrite  <= 1'b1;
    vif.paddr   <= apb_item.paddr;
    vif.pwdata  <= apb_item.pwdata;
    vif.pstrb   <= apb_item.pstrb;
    
    // access
    @(posedge vif.clk);
    vif.penable <= 1'b1;

    timeout_cnt = 0;
    while (!vif.pready && timeout_cnt < TIMEOUT_CYCLES) begin
        @(posedge vif.clk);
        timeout_cnt++;
    end

    if (!vif.pready) begin
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite  <= 1'b0;
        vif.pstrb   <= 4'h0;

        `uvm_fatal(get_type_name(),
        $sformatf("APB WRITE TIMEOUT waiting PREADY. paddr=0x%0h pwdata=0x%0h waited=%0d cycles",
                    apb_item.paddr, apb_item.pwdata, TIMEOUT_CYCLES))
    end

    apb_item.pslverr = vif.pslverr;
    
    // @(posedge vif.clk);
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0;
    vif.pwrite  <= 1'b0;
    vif.pstrb   <= 4'h0;
endtask

task apb_driver::read(apb_item apb_item);
    int unsigned timeout_cnt;
    int unsigned TIMEOUT_CYCLES = 1000;
    // setup
    @(posedge vif.clk);
    vif.psel    <= 1'b1;
    vif.penable <= 1'b0;
    vif.pwrite  <= 1'b0;
    vif.paddr   <= apb_item.paddr;
    vif.pstrb   <= 4'h0;  
    
    // access
    @(posedge vif.clk);
    vif.penable <= 1'b1;

    timeout_cnt = 0;
    while (!vif.pready && timeout_cnt < TIMEOUT_CYCLES) begin
        @(posedge vif.clk);
        timeout_cnt++;
    end

    if (!vif.pready) begin
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
        vif.pwrite  <= 1'b0;
        vif.pstrb   <= 4'h0;

        `uvm_fatal(get_type_name(),
        $sformatf("APB WRITE TIMEOUT waiting PREADY. paddr=0x%0h pwdata=0x%0h waited=%0d cycles",
                    apb_item.paddr, apb_item.pwdata, TIMEOUT_CYCLES))
    end
    
    // @(posedge vif.clk);
    apb_item.prdata  = vif.prdata;
    apb_item.pslverr = vif.pslverr;
    
    // @(posedge vif.clk);
    vif.psel    <= 1'b0;
    vif.penable <= 1'b0; 
endtask

task apb_driver::select_drive(apb_item apb_item);
    if(apb_item.pwrite)
        write(apb_item);
    else
        read(apb_item);
endtask

