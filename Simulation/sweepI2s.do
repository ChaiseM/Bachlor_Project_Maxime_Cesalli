onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tester
add wave -noupdate /leftrightsplitter_tb/I_tester/reset
add wave -noupdate /leftrightsplitter_tb/I_tester/clock
add wave -noupdate -divider {I2s Encoder}
add wave -noupdate /leftrightsplitter_tb/I_tester/CLKI2s
add wave -noupdate /leftrightsplitter_tb/LRCK
add wave -noupdate /leftrightsplitter_tb/DOUT
add wave -noupdate -format Analog-Step -height 74 -max 8388610.0 -min -8388610.0 -radix decimal /leftrightsplitter_tb/I_tester/audioIn
add wave -noupdate -radix hexadecimal /leftrightsplitter_tb/I_tester/audioIn
add wave -noupdate -divider {I2s Decoder}
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/dataValid
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/audioLeft
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/audioRight
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/bitCounter
add wave -noupdate -divider mono
add wave -noupdate -format Analog-Step -height 74 -max 18027900.0 -min -17143900.0 -radix decimal /leftrightsplitter_tb/I_dut/I4/audioOut
add wave -noupdate -format Analog-Step -height 74 -max 2147480000.0000002 -min -2147480000.0 -radix decimal /leftrightsplitter_tb/audioLeftO
add wave -noupdate -format Analog-Step -height 74 -max 16873399.999999996 -min -16938500.0 -radix decimal /leftrightsplitter_tb/audioRightO
add wave -noupdate /leftrightsplitter_tb/audioLeft
add wave -noupdate /leftrightsplitter_tb/audioRight
add wave -noupdate /leftrightsplitter_tb/dataValid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {13061495 ns} 0} {{Cursor 2} {2632867 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {46349421 ns}
