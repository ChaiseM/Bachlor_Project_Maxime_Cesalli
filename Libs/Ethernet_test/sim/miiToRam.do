onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Clock and reset} /miitoram_tb/reset
add wave -noupdate -expand -group {Clock and reset} /miitoram_tb/clock
add wave -noupdate -expand -group {Rx MII} /miitoram_tb/mii_rxclk
add wave -noupdate -expand -group {Rx MII} /miitoram_tb/mii_rxdv
add wave -noupdate -expand -group {Rx MII} -radix hexadecimal /miitoram_tb/mii_rxd
add wave -noupdate -expand -group {Rx RAM} /miitoram_tb/i_dut/i_rx/ramwrite
add wave -noupdate -expand -group {Rx RAM} -radix hexadecimal /miitoram_tb/i_dut/i_rx/ramwriteaddress
add wave -noupdate -expand -group {Rx RAM} -radix hexadecimal /miitoram_tb/i_dut/i_rx/ramwritedata
add wave -noupdate -expand -group {Rx RAM} /miitoram_tb/rx_startofframe
add wave -noupdate -expand -group {Rx RAM} -radix hexadecimal /miitoram_tb/rx_baseaddress
add wave -noupdate -expand -group {Rx RAM} -radix hexadecimal /miitoram_tb/rx_address
add wave -noupdate -expand -group {Rx RAM} -radix hexadecimal /miitoram_tb/rx_data
add wave -noupdate -expand -group {Rx error control} /miitoram_tb/i_dut/i_rx/initframe
add wave -noupdate -expand -group {Rx error control} /miitoram_tb/i_dut/i_rx/frameerror
add wave -noupdate -expand -group {Rx error control} /miitoram_tb/i_dut/i_rx/errorcode
add wave -noupdate -expand -group {Rx error control} /miitoram_tb/i_dut/i_rx/frameok
add wave -noupdate -expand -group {Rx error control} /miitoram_tb/mii_rxer
add wave -noupdate -expand -group {Rx error control} /miitoram_tb/i_tb/read_frames
add wave -noupdate -group {Tx RAM} /miitoram_tb/tx_write
add wave -noupdate -group {Tx RAM} -radix hexadecimal /miitoram_tb/tx_baseaddress
add wave -noupdate -group {Tx RAM} -radix hexadecimal /miitoram_tb/tx_address
add wave -noupdate -group {Tx RAM} -radix hexadecimal /miitoram_tb/tx_data
add wave -noupdate -group {Tx RAM} /miitoram_tb/tx_endofframe
add wave -noupdate -group {Tx MII} /miitoram_tb/mii_txclk
add wave -noupdate -group {Tx MII} /miitoram_tb/mii_txen
add wave -noupdate -group {Tx MII} -radix hexadecimal /miitoram_tb/mii_txd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 283
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {378 us}
