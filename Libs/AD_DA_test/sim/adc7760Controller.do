onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adc7760controller_tb/reset
add wave -noupdate /adc7760controller_tb/clock
add wave -noupdate -divider {ADC inputs}
add wave -noupdate /adc7760controller_tb/vin1
add wave -noupdate /adc7760controller_tb/vin2
add wave -noupdate -divider Controls
add wave -noupdate /adc7760controller_tb/newsample
add wave -noupdate -divider Internals
add wave -noupdate /adc7760controller_tb/i_dut/readshiftreg
add wave -noupdate /adc7760controller_tb/i_dut/samplewait
add wave -noupdate /adc7760controller_tb/i_dut/sampledone
add wave -noupdate -radix decimal -subitemconfig {/adc7760controller_tb/i_dut/amplitudereg(1) {-radix decimal} /adc7760controller_tb/i_dut/amplitudereg(0) {-radix decimal}} -subitemconfig {/adc7760controller_tb/i_dut/amplitudereg(1) {-height 15 -radix decimal} /adc7760controller_tb/i_dut/amplitudereg(0) {-height 15 -radix decimal}} /adc7760controller_tb/i_dut/amplitudereg
add wave -noupdate -divider {ADC controls}
add wave -noupdate /adc7760controller_tb/reset_n
add wave -noupdate /adc7760controller_tb/mclk
add wave -noupdate /adc7760controller_tb/sync_n
add wave -noupdate /adc7760controller_tb/drdy_n
add wave -noupdate -expand /adc7760controller_tb/cs_n
add wave -noupdate /adc7760controller_tb/wr_rd_n
add wave -noupdate -radix hexadecimal /adc7760controller_tb/db
add wave -noupdate -divider {ADC value}
add wave -noupdate -radix decimal /adc7760controller_tb/amplitude1
add wave -noupdate -radix decimal /adc7760controller_tb/amplitude2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0} {{Cursor 2} {0 ps} 0}
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
