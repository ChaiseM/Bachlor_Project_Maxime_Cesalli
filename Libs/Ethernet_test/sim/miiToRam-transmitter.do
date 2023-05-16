onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /miitoram_tb/reset
add wave -noupdate /miitoram_tb/clock
add wave -noupdate -divider {RAM - Tx}
add wave -noupdate -radix hexadecimal /miitoram_tb/tx_baseaddress
add wave -noupdate -radix hexadecimal /miitoram_tb/tx_address
add wave -noupdate -radix hexadecimal /miitoram_tb/tx_data
add wave -noupdate /miitoram_tb/tx_write
add wave -noupdate /miitoram_tb/tx_endofframe
add wave -noupdate -divider Transmitter
add wave -noupdate /miitoram_tb/u_0/i1/i2/current_state
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/ramreadaddress
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/ramreaddata
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/i3/datashiftregister
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/i3/miidatalow
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/i3/miidatahigh
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/miidata
add wave -noupdate -format Analog-Step -height 20 -max 16.0 -radix unsigned /miitoram_tb/u_0/i1/i3/interframecounter
add wave -noupdate /miitoram_tb/u_0/i1/i3/txenable
add wave -noupdate -format Analog-Step -height 20 -max 18.0 -radix unsigned /miitoram_tb/u_0/i1/i3/preamblecounter
add wave -noupdate /miitoram_tb/u_0/i1/i3/preambleend
add wave -noupdate /miitoram_tb/u_0/i1/incrmiiaddress
add wave -noupdate -format Analog-Step -height 20 -max 4.0 -radix unsigned /miitoram_tb/u_0/i1/i3/ramtomiicounter
add wave -noupdate /miitoram_tb/u_0/i1/incrramaddress
add wave -noupdate -format Analog-Step -height 40 -max 50.0 -radix unsigned /miitoram_tb/u_0/i1/i3/remainingframelength
add wave -noupdate /miitoram_tb/u_0/i1/frameavailable
add wave -noupdate /miitoram_tb/u_0/i1/endofframe_int
add wave -noupdate /miitoram_tb/u_0/i1/sendcrc
add wave -noupdate /miitoram_tb/u_0/i1/endofcrc
add wave -noupdate -divider CRC
add wave -noupdate /miitoram_tb/u_0/i1/crcinit
add wave -noupdate /miitoram_tb/u_0/i1/crccalculate
add wave -noupdate /miitoram_tb/u_0/i1/crcdatavalid
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/crcdata
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/crc
add wave -noupdate -radix hexadecimal /miitoram_tb/u_0/i1/miicrc
add wave -noupdate -divider {MII - Tx}
add wave -noupdate /miitoram_tb/mii_txclk
add wave -noupdate /miitoram_tb/u_0/i1/sendcrc
add wave -noupdate -radix hexadecimal /miitoram_tb/mii_txd
add wave -noupdate /miitoram_tb/mii_txen
add wave -noupdate /miitoram_tb/mii_txer
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 272
configure wave -valuecolwidth 73
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
WaveRestoreZoom {0 ps} {10500 ns}
