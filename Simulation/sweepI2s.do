onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tester
add wave -noupdate /leftrightsplitter_tb/I_tester/reset
add wave -noupdate /leftrightsplitter_tb/I_tester/clock
add wave -noupdate -format Analog-Step -height 74 -max 10000000.0 -min -10000000.0 -radix decimal -childformat {{/leftrightsplitter_tb/I_tester/audioIn(23) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(22) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(21) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(20) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(19) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(18) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(17) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(16) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(15) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(14) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(13) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(12) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(11) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(10) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(9) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(8) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(7) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(6) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(5) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(4) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(3) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(2) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(1) -radix decimal} {/leftrightsplitter_tb/I_tester/audioIn(0) -radix decimal}} -subitemconfig {/leftrightsplitter_tb/I_tester/audioIn(23) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(22) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(21) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(20) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(19) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(18) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(17) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(16) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(15) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(14) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(13) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(12) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(11) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(10) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(9) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(8) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(7) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(6) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(5) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(4) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(3) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(2) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(1) {-height 15 -radix decimal} /leftrightsplitter_tb/I_tester/audioIn(0) {-height 15 -radix decimal}} /leftrightsplitter_tb/I_tester/audioIn
add wave -noupdate -divider {I2s Encoder TESTER}
add wave -noupdate /leftrightsplitter_tb/DOUT_in
add wave -noupdate /leftrightsplitter_tb/LRCK_in
add wave -noupdate /leftrightsplitter_tb/SCK_in
add wave -noupdate -divider {I2s Decoder CIRCUT}
add wave -noupdate /leftrightsplitter_tb/I_dut/dataValid
add wave -noupdate /leftrightsplitter_tb/I_dut/en
add wave -noupdate /leftrightsplitter_tb/I_dut/audioLeft
add wave -noupdate /leftrightsplitter_tb/I_dut/audioRight
add wave -noupdate -divider Bascule
add wave -noupdate -format Analog-Step -height 75 -max 2000000000.0 -min -2000000000.0 -radix decimal /leftrightsplitter_tb/I_dut/audioLeftO
add wave -noupdate -format Analog-Step -height 75 -max 2000000000.0 -min -2000000000.0 -radix decimal /leftrightsplitter_tb/I_dut/audioRightO
add wave -noupdate -divider mono
add wave -noupdate -format Analog-Step -height 74 -max 1999999999.9999998 -min -2000000000.0 -radix decimal /leftrightsplitter_tb/I_dut/audioMono
add wave -noupdate -divider Lowpass
add wave -noupdate -format Analog-Step -height 74 -max 2500000000.0 -min -2500000000.0 -radix decimal /leftrightsplitter_tb/I_dut/lowpassOut
add wave -noupdate -divider {I2S encoder CIRCUT}
add wave -noupdate /leftrightsplitter_tb/I_dut/DOUT
add wave -noupdate /leftrightsplitter_tb/I_dut/LRCK
add wave -noupdate /leftrightsplitter_tb/I_dut/SCK
add wave -noupdate -divider {I2s decoder TESTER}
add wave -noupdate /leftrightsplitter_tb/audioLeft
add wave -noupdate /leftrightsplitter_tb/audioRight
add wave -noupdate /leftrightsplitter_tb/dataValid
add wave -noupdate -divider {Final data Out}
add wave -noupdate -format Analog-Step -height 70 -max 2000000000.0000002 -min -2000000000.0 -radix decimal /leftrightsplitter_tb/audioRightO
add wave -noupdate -format Analog-Step -height 70 -max 2000000000.0000002 -min -2000000000.0 -radix decimal /leftrightsplitter_tb/audioLeftO
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {35224501 ns} 0} {{Cursor 2} {5072101 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 243
configure wave -valuecolwidth 100
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ns} {172359 ns}
