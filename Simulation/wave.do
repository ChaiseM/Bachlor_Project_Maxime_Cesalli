onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {test bench}
add wave -noupdate /leftrightsplitter_tb/clock
add wave -noupdate /leftrightsplitter_tb/reset
add wave -noupdate /leftrightsplitter_tb/CLK_I
add wave -noupdate /leftrightsplitter_tb/Data_I
add wave -noupdate /leftrightsplitter_tb/LR_I
add wave -noupdate -divider I2SDecoder
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/dataValid
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/audioLeft
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/audioRight
add wave -noupdate -divider Resizer
add wave -noupdate /leftrightsplitter_tb/I_dut/I1/dataValidI
add wave -noupdate /leftrightsplitter_tb/I_dut/I1/audioLeftI
add wave -noupdate /leftrightsplitter_tb/I_dut/I1/audioRightI
add wave -noupdate /leftrightsplitter_tb/I_dut/I1/ShiftData
add wave -noupdate /leftrightsplitter_tb/I_dut/I1/audioLeftO
add wave -noupdate /leftrightsplitter_tb/I_dut/I1/audioRightO
add wave -noupdate -divider StoM
add wave -noupdate /leftrightsplitter_tb/I_dut/I3/audioLeft
add wave -noupdate /leftrightsplitter_tb/I_dut/I3/audioRight
add wave -noupdate /leftrightsplitter_tb/I_dut/I3/audioMono
add wave -noupdate -divider I2Sencoder
add wave -noupdate /leftrightsplitter_tb/I_dut/I2/SCK
add wave -noupdate /leftrightsplitter_tb/I_dut/I2/DOUT
add wave -noupdate /leftrightsplitter_tb/I_dut/I2/ShiftData
add wave -noupdate /leftrightsplitter_tb/I_dut/I2/LRCK
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {380 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 415
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
WaveRestoreZoom {0 ns} {79641 ns}
