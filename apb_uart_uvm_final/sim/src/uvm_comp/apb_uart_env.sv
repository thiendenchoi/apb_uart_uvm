`include "uvm_macros.svh"
import uvm_pkg::*;
import apb_pkg::*;  
import uart_pkg::*;
import uart_regs_pkg::*;
`include "apb_uart_sb_common.sv"
`include "apb_uart_apb_scoreboard.sv"
`include "apb_uart_uart_scoreboard.sv"
`include "apb_uart_e2e_scoreboard.sv"

class apb_uart_env extends uvm_env;
    `uvm_component_utils(apb_uart_env)

    // agents
    apb_agent m_apb_agent;
    uart_tx_agent m_uart_tx_agent;
    uart_rx_agent m_uart_rx_agent;

    // config
    uart_config m_uart_config;

    // RAL
    apb_reg_adapter m_apb_reg_adapter;
    uvm_reg_predictor#(apb_item) apb_reg_predictor;
    uart_regs apb_uart_regs;
    apb_uart_apb_scoreboard apb_sb;
    apb_uart_uart_scoreboard uart_sb;
    apb_uart_e2e_scoreboard  e2e_sb;


    extern function new(string name="apb_uart_env", uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual function void connect_phase(uvm_phase phase);
    extern function void end_of_elaboration_phase(uvm_phase phase);
endclass

function apb_uart_env::new(string name="apb_uart_env", uvm_component parent);
    super.new(name, parent);
endfunction

function void apb_uart_env::build_phase(uvm_phase phase);
    super.build_phase(phase);



    if (!uvm_config_db#(uart_config)::get(this, "", "uart_config", m_uart_config) || (m_uart_config == null)) begin
        `uvm_fatal("NOCFG", "apb_uart_env: cannot get m_uart_config")
    end

    m_apb_reg_adapter = apb_reg_adapter::type_id::create("m_apb_reg_adapter");

    apb_reg_predictor = uvm_reg_predictor#(apb_item)::type_id::create("apb_reg_predictor", this);

    apb_uart_regs = uart_regs::type_id::create("apb_uart_regs", this);
    apb_uart_regs.build();
    apb_uart_regs.lock_model();

    apb_uart_regs.default_map.set_auto_predict(0);
    apb_uart_regs.reset();

    uvm_config_db#(uart_regs)::set(this, "*", "apb_uart_regs", apb_uart_regs);

    uvm_config_db#(uart_config)::set(this, "m_uart_tx_agent", "tx_config", m_uart_config);
    uvm_config_db#(uart_config)::set(this, "m_uart_rx_agent", "rx_config", m_uart_config);

    m_apb_agent     = apb_agent::type_id::create("m_apb_agent", this);
    m_uart_tx_agent = uart_tx_agent::type_id::create("m_uart_tx_agent", this);
    m_uart_rx_agent = uart_rx_agent::type_id::create("m_uart_rx_agent", this);

    apb_sb  = apb_uart_apb_scoreboard::type_id::create("apb_sb", this);
    uart_sb = apb_uart_uart_scoreboard::type_id::create("uart_sb", this);
    e2e_sb  = apb_uart_e2e_scoreboard::type_id::create("e2e_sb", this);
endfunction

function void apb_uart_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    m_apb_agent.monitor.item_collected_port.connect(apb_reg_predictor.bus_in);

    apb_reg_predictor.map     = apb_uart_regs.default_map;
    apb_reg_predictor.adapter = m_apb_reg_adapter;

    apb_uart_regs.default_map.set_sequencer(m_apb_agent.sequencer, m_apb_reg_adapter);

    // APB -> apb_sb + e2e_sb
    m_apb_agent.monitor.item_collected_port.connect(apb_sb.apb_imp);
    m_apb_agent.monitor.item_collected_port.connect(e2e_sb.apb_imp);

    // UART -> uart_sb + e2e_sb
    m_uart_tx_agent.tx_monitor.ap.connect(uart_sb.tx_imp);
    m_uart_rx_agent.rx_monitor.ap.connect(uart_sb.rx_imp);
    m_uart_rx_agent.rx_monitor.ap.connect(e2e_sb.tx_imp);
    m_uart_tx_agent.tx_monitor.ap.connect(e2e_sb.rx_imp);


endfunction

function void apb_uart_env::end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
endfunction
