onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dac1793_tb/rst_n
add wave -noupdate /dac1793_tb/demp
add wave -noupdate /dac1793_tb/fmt
add wave -noupdate /dac1793_tb/mute
add wave -noupdate -divider {Input values}
add wave -noupdate /dac1793_tb/i_tb/signalleftfrequency
add wave -noupdate /dac1793_tb/i_tb/sampleen
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal -subitemconfig {/dac1793_tb/i_tb/signalleftsigned(23) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(22) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(21) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(20) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(19) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(18) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(17) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(16) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(15) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(14) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(13) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(12) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(11) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(10) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(9) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(8) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(7) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(6) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(5) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(4) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(3) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(2) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(1) {-radix decimal} /dac1793_tb/i_tb/signalleftsigned(0) {-radix decimal}} /dac1793_tb/i_tb/signalleftsigned
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /dac1793_tb/i_tb/signalrightsigned
add wave -noupdate -divider {ADC I2S}
add wave -noupdate /dac1793_tb/sck
add wave -noupdate /dac1793_tb/bck
add wave -noupdate /dac1793_tb/lrck
add wave -noupdate -format Analog-Step -height 20 -max 40.000000000000007 -min -8.0 -radix decimal /dac1793_tb/i_tb/bitcounter
add wave -noupdate -radix decimal /dac1793_tb/i_tb/bitcounter
add wave -noupdate /dac1793_tb/data
add wave -noupdate -radix binary -subitemconfig {/dac1793_tb/i_tb/signalleftsigned(23) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(22) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(21) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(20) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(19) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(18) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(17) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(16) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(15) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(14) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(13) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(12) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(11) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(10) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(9) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(8) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(7) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(6) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(5) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(4) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(3) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(2) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(1) {-height 15 -radix decimal} /dac1793_tb/i_tb/signalleftsigned(0) {-height 15 -radix decimal}} /dac1793_tb/i_tb/signalleftsigned
add wave -noupdate -divider DAC
add wave -noupdate /dac1793_tb/i_dut/bitcounter
add wave -noupdate /dac1793_tb/i_dut/signalleft
add wave -noupdate /dac1793_tb/i_dut/signalright
add wave -noupdate -divider {Analog signals}
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /dac1793_tb/voutlp
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /dac1793_tb/voutlm
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /dac1793_tb/voutrp
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 -min -10000000.0 -radix decimal /dac1793_tb/voutrm
add wave -noupdate /dac1793_tb/zerol
add wave -noupdate /dac1793_tb/zeror
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0} {{Cursor 2} {0 fs} 0}
configure wave -namecolwidth 227
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 fs} {105 us}
