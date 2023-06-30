onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testder data}
add wave -noupdate /leftrightsplitter_tb/reset
add wave -noupdate /leftrightsplitter_tb/clock
add wave -noupdate -format Analog-Step -height 75 -max 2500000000.0 -min -2500000000.0 /leftrightsplitter_tb/audioIn
add wave -noupdate /leftrightsplitter_tb/en
add wave -noupdate -divider {i2s encodeur Tester}
add wave -noupdate /leftrightsplitter_tb/DOUT_in
add wave -noupdate /leftrightsplitter_tb/LRCK_in
add wave -noupdate /leftrightsplitter_tb/SCK_in
add wave -noupdate -divider {i2s decoder DUT}
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/lrCounter
add wave -noupdate /leftrightsplitter_tb/I_dut/Data_Valid
add wave -noupdate /leftrightsplitter_tb/I_dut/audioLeft
add wave -noupdate /leftrightsplitter_tb/I_dut/audioRight
add wave -noupdate -divider {reguster DUT}
add wave -noupdate -format Analog-Step -height 75 -max 2500000000.0 -min -2500000000.0 -radix decimal /leftrightsplitter_tb/I_dut/audio_R_out
add wave -noupdate -divider {Xover DUT}
add wave -noupdate /leftrightsplitter_tb/I_dut/end_Calc
add wave -noupdate /leftrightsplitter_tb/I_dut/I3/cnt
add wave -noupdate /leftrightsplitter_tb/I_dut/highPass
add wave -noupdate /leftrightsplitter_tb/I_dut/lowPass
add wave -noupdate -format Analog-Step -height 75 -max 2500000000.0 -min -2500000000.0 -radix decimal /leftrightsplitter_tb/I_dut/highPass
add wave -noupdate -format Analog-Step -height 75 -max 2500000000.0 -min -2500000000.0 -radix decimal /leftrightsplitter_tb/I_dut/lowPass
add wave -noupdate -divider {Rgegister 2 dut}
add wave -noupdate /leftrightsplitter_tb/I_dut/Next_data
add wave -noupdate /leftrightsplitter_tb/I_dut/audioLeft1
add wave -noupdate /leftrightsplitter_tb/I_dut/audioRight1
add wave -noupdate -divider {i2s encoder DUT}
add wave -noupdate /leftrightsplitter_tb/I_dut/I2/frameCounter
add wave -noupdate /leftrightsplitter_tb/I_dut/DOUT
add wave -noupdate /leftrightsplitter_tb/I_dut/LRCK
add wave -noupdate /leftrightsplitter_tb/I_dut/SCK
add wave -noupdate -divider {Final Data}
add wave -noupdate -format Analog-Step -height 75 -max 2500000000.0 -min -2500000000.0 -radix decimal /leftrightsplitter_tb/audio_L_out
add wave -noupdate -format Analog-Step -height 75 -max 2500000000.0 -min -2500000000.0 -radix decimal /leftrightsplitter_tb/audio_R_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {95527735 ns} 0} {{Cursor 2} {21837802 ns} 0}
quietly wave cursor active 2
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
WaveRestoreZoom {0 ns} {105 ms}
