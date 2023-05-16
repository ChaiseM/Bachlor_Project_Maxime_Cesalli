onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {reset and clock} /ethernetfifo_tb/reset
add wave -noupdate -expand -group {reset and clock} /ethernetfifo_tb/clock
add wave -noupdate -expand -group Rx -expand -group {Rx MII} /ethernetfifo_tb/mii_rxclk
add wave -noupdate -expand -group Rx -expand -group {Rx MII} -radix hexadecimal -subitemconfig {/ethernetfifo_tb/mii_rxd(3) {-radix hexadecimal} /ethernetfifo_tb/mii_rxd(2) {-radix hexadecimal} /ethernetfifo_tb/mii_rxd(1) {-radix hexadecimal} /ethernetfifo_tb/mii_rxd(0) {-radix hexadecimal}} /ethernetfifo_tb/mii_rxd
add wave -noupdate -expand -group Rx -expand -group {Rx MII} /ethernetfifo_tb/mii_rxdv
add wave -noupdate -expand -group Rx -expand -group {Rx MII} /ethernetfifo_tb/i_send/frameinfo
add wave -noupdate -expand -group Rx -group {Rx RAM} -radix unsigned /ethernetfifo_tb/rx_baseaddress
add wave -noupdate -expand -group Rx -group {Rx RAM} -radix unsigned /ethernetfifo_tb/rx_address
add wave -noupdate -expand -group Rx -group {Rx RAM} -format Analog-Step -height 74 -max 1023.0000000000001 -radix unsigned /ethernetfifo_tb/rx_address
add wave -noupdate -expand -group Rx -group {Rx RAM} -radix hexadecimal /ethernetfifo_tb/rx_data
add wave -noupdate -expand -group Rx -group {Rx RAM} /ethernetfifo_tb/i_mii/i_rx/errorcode
add wave -noupdate -expand -group Rx -group {Rx RAM} /ethernetfifo_tb/i_mii/i_rx/frameerror
add wave -noupdate -expand -group Rx -group {Rx RAM} /ethernetfifo_tb/i_mii/i_rx/frameok
add wave -noupdate -expand -group Rx -group {Rx RAM} /ethernetfifo_tb/i_mii/i_rx/initframe
add wave -noupdate -expand -group Rx -group {Rx Fifo} /ethernetfifo_tb/rx_fifoempty
add wave -noupdate -expand -group Rx -group {Rx Fifo} /ethernetfifo_tb/rx_fiforead
add wave -noupdate -expand -group Rx -group {Rx Fifo} /ethernetfifo_tb/rx_fiforead1
add wave -noupdate -expand -group Rx -group {Rx Fifo} -radix hexadecimal /ethernetfifo_tb/rx_fifodata
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/miistate
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/bytecounter
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal -radix unsigned /ethernetfifo_tb/i_fifo/i_rx/readframelength
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/byteenable
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/readaddress
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/readbaseaddress
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/fifostate
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/fifodata
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal /ethernetfifo_tb/i_fifo/i_rx/fifodatasampled
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal -radix unsigned /ethernetfifo_tb/i_fifo/i_rx/readbaseaddress
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal -radix unsigned /ethernetfifo_tb/i_fifo/i_rx/readaddress
add wave -noupdate -expand -group Rx -group {Rx Fifo} -expand -group internal -radix unsigned /ethernetfifo_tb/i_fifo/i_rx/readbaseaddressplusone
add wave -noupdate -group fifoBridge -radix hexadecimal /ethernetfifo_tb/i_fifobridge/data1
add wave -noupdate -group fifoBridge -radix hexadecimal /ethernetfifo_tb/i_fifobridge/data2
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/databitnb
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/empty1
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/fifodepth
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/full2
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/rd1
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/read
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/read1
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/read2
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/reset
add wave -noupdate -group fifoBridge -radix hexadecimal /ethernetfifo_tb/i_fifobridge/storeddata
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/wr2
add wave -noupdate -group fifoBridge /ethernetfifo_tb/i_fifobridge/write
add wave -noupdate -group fifoBridge /ethernetfifo_tb/clock
add wave -noupdate -expand -group Tx -group {Tx Fifo} -radix hexadecimal /ethernetfifo_tb/tx_fifodata
add wave -noupdate -expand -group Tx -group {Tx Fifo} /ethernetfifo_tb/tx_fifofull
add wave -noupdate -expand -group Tx -group {Tx Fifo} /ethernetfifo_tb/tx_fifowrite
add wave -noupdate -expand -group Tx -group {Tx Fifo} -group internal /ethernetfifo_tb/i_fifo/i_tx/current_state
add wave -noupdate -expand -group Tx -group {Tx Fifo} -group internal /ethernetfifo_tb/i_fifo/i_tx/fifofull_l
add wave -noupdate -expand -group Tx -group {Tx Fifo} -group internal -radix hexadecimal /ethernetfifo_tb/i_fifo/i_tx/data_l
add wave -noupdate -expand -group Tx -group {Tx Fifo} -group internal -radix unsigned /ethernetfifo_tb/i_fifo/i_tx/fifowordcounter_l
add wave -noupdate -expand -group Tx -group {Tx Fifo} -group internal /ethernetfifo_tb/i_fifo/i_tx/tx_write_cld
add wave -noupdate -expand -group Tx -group {Tx Fifo} -group internal -radix unsigned /ethernetfifo_tb/i_fifo/i_tx/ramaddress_l
add wave -noupdate -expand -group Tx -group {Tx Fifo} -group internal -radix unsigned /ethernetfifo_tb/i_fifo/i_tx/baseaddress_l
add wave -noupdate -expand -group Tx -group {Tx RAM} -radix unsigned /ethernetfifo_tb/tx_baseaddress
add wave -noupdate -expand -group Tx -group {Tx RAM} -radix unsigned /ethernetfifo_tb/tx_address
add wave -noupdate -expand -group Tx -group {Tx RAM} -format Analog-Step -height 74 -max 1023.0000000000001 -radix unsigned /ethernetfifo_tb/tx_address
add wave -noupdate -expand -group Tx -group {Tx RAM} -radix hexadecimal /ethernetfifo_tb/tx_data
add wave -noupdate -expand -group Tx -group {Tx RAM} /ethernetfifo_tb/tx_write
add wave -noupdate -expand -group Tx -expand -group {Tx MII} /ethernetfifo_tb/mii_txclk
add wave -noupdate -expand -group Tx -expand -group {Tx MII} -radix hexadecimal /ethernetfifo_tb/mii_txd
add wave -noupdate -expand -group Tx -expand -group {Tx MII} /ethernetfifo_tb/mii_txen
add wave -noupdate -expand -group Tx -expand -group {Tx MII} /ethernetfifo_tb/mii_txer
TreeUpdate [SetDefaultTree]
configure wave -namecolwidth 395
configure wave -valuecolwidth 68
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {525 us}
