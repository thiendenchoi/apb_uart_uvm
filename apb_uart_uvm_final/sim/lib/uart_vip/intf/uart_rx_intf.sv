interface uart_rx_intf;
    logic clk;
    logic reset_n;
    logic rx;
    logic rts_n;

    //debug
    logic[7:0] data_reg;

    modport driver_mp (
    output rts_n,
    input  rx
    );

endinterface