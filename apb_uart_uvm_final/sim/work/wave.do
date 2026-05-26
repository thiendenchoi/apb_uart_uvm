onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/clk
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/reset_n
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/pclk
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/psel
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/penable
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/pwrite
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/pstrb
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/paddr
add wave -noupdate -expand -group dut -radix binary /apb_uart_test_top/dut/pwdata
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/rx
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/cts_n
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/pready
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/pslverr
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/prdata
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/tx
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/rts_n
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/tx_data
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/rx_data
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/data_bit_num
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/stop_bit_num
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/parity_en
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/parity_type
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/start_tx
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/tx_done
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/rx_done
add wave -noupdate -expand -group dut /apb_uart_test_top/dut/parity_error
add wave -noupdate -expand -group tx_intf /apb_uart_test_top/tx_intf/clk
add wave -noupdate -expand -group tx_intf /apb_uart_test_top/tx_intf/reset_n
add wave -noupdate -expand -group tx_intf /apb_uart_test_top/tx_intf/tx
add wave -noupdate -expand -group tx_intf /apb_uart_test_top/tx_intf/cts_n
add wave -noupdate -expand -group tx_intf /apb_uart_test_top/tx_intf/data_in
add wave -noupdate -expand -group rx_intf /apb_uart_test_top/rx_intf/clk
add wave -noupdate -expand -group rx_intf /apb_uart_test_top/rx_intf/reset_n
add wave -noupdate -expand -group rx_intf /apb_uart_test_top/rx_intf/rx
add wave -noupdate -expand -group rx_intf /apb_uart_test_top/rx_intf/rts_n
add wave -noupdate -expand -group rx_intf /apb_uart_test_top/rx_intf/data_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25230 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {220805 ns}
