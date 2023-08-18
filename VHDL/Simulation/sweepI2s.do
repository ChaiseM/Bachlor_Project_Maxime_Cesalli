onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Testder data}
add wave -noupdate /leftrightsplitter_tb/reset
add wave -noupdate /leftrightsplitter_tb/clock
add wave -noupdate -format Analog-Step -height 74 -max 8388610.0 -min -8388610.0 -radix decimal /leftrightsplitter_tb/audioIn
add wave -noupdate /leftrightsplitter_tb/en
add wave -noupdate -divider {i2s encodeur Tester}
add wave -noupdate /leftrightsplitter_tb/DOUT_in
add wave -noupdate /leftrightsplitter_tb/LRCK_in
add wave -noupdate /leftrightsplitter_tb/SCK_in
add wave -noupdate -divider {i2s decoder DUT}
add wave -noupdate /leftrightsplitter_tb/I_dut/I0/lrCounter
add wave -noupdate /leftrightsplitter_tb/I_dut/audioLeft
add wave -noupdate /leftrightsplitter_tb/I_dut/audioRight
add wave -noupdate -divider {reguster DUT}
add wave -noupdate -format Analog-Step -height 75 -max 2500000000.0 -min -2500000000.0 -radix decimal /leftrightsplitter_tb/I_dut/audio_R_out
add wave -noupdate -divider write
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/wraddr
add wave -noupdate /leftrightsplitter_tb/I_dut/we
add wave -noupdate /leftrightsplitter_tb/I_dut/din
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/I11/initialRAddress
add wave -noupdate -divider Read
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/re
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/debug1
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/debug0
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/I11/rAddrCnt_Plus
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/I11/rAddrCnt_Minus
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/I11/cntNooffset
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/RAMfull
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/I11/RAMLength
add wave -noupdate -divider CoeffReading
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/I11/coeffAddr
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/LCoeff
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/HCoeff
add wave -noupdate -divider {Xover DUT}
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/convertsionPoint
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/sample1
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/sample2
add wave -noupdate /leftrightsplitter_tb/I_dut/highPass
add wave -noupdate /leftrightsplitter_tb/I_dut/end_Calc
add wave -noupdate /leftrightsplitter_tb/I_dut/lowPass
add wave -noupdate /leftrightsplitter_tb/I_dut/I11/calculate
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
add wave -noupdate -radix unsigned /leftrightsplitter_tb/I_dut/addressB
add wave -noupdate /leftrightsplitter_tb/I_dut/dataInB
add wave -noupdate /leftrightsplitter_tb/I_dut/enB
add wave -noupdate /leftrightsplitter_tb/I_dut/writeEnB
add wave -noupdate /leftrightsplitter_tb/I_dut/I10/firstWrite
add wave -noupdate /leftrightsplitter_tb/I_dut/I10/wAddrCnt
add wave -noupdate /leftrightsplitter_tb/I_dut/I10/arrayCnt
add wave -noupdate -divider UART
add wave -noupdate -radix binary /leftrightsplitter_tb/I_dut/RS232Data
add wave -noupdate /leftrightsplitter_tb/I_dut/RS232Valid
add wave -noupdate /leftrightsplitter_tb/I_dut/RxD_synch
add wave -noupdate /leftrightsplitter_tb/I_dut/I13/rxRising
add wave -noupdate /leftrightsplitter_tb/I_dut/I13/cnt
add wave -noupdate /leftrightsplitter_tb/I_dut/I13/cnt2
add wave -noupdate /leftrightsplitter_tb/I_dut/I13/RS232Register
add wave -noupdate /leftrightsplitter_tb/I_dut/I13/currentState
add wave -noupdate /leftrightsplitter_tb/I_dut/I14/currentState
add wave -noupdate /leftrightsplitter_tb/I_dut/I14/coeffCnt
add wave -noupdate /leftrightsplitter_tb/I_dut/I14/coeff0
add wave -noupdate /leftrightsplitter_tb/I_dut/I14/coeffNb
add wave -noupdate /leftrightsplitter_tb/I_dut/I14/cnt
add wave -noupdate /leftrightsplitter_tb/I_dut/NewCoeff
add wave -noupdate /leftrightsplitter_tb/I_dut/RS232Coeff
add wave -noupdate -divider {RAM input outout}
add wave -noupdate /leftrightsplitter_tb/I_dut/addressB1
add wave -noupdate /leftrightsplitter_tb/I_dut/dataInB1
add wave -noupdate /leftrightsplitter_tb/I_dut/dataOutA
add wave -noupdate /leftrightsplitter_tb/I_dut/dataOutB
add wave -noupdate /leftrightsplitter_tb/I_dut/din
add wave -noupdate /leftrightsplitter_tb/I_dut/enB
add wave -noupdate /leftrightsplitter_tb/I_dut/we
add wave -noupdate /leftrightsplitter_tb/I_dut/wraddr
add wave -noupdate /leftrightsplitter_tb/I_dut/writeEnA
add wave -noupdate /leftrightsplitter_tb/I_dut/writeEnB1
add wave -noupdate /leftrightsplitter_tb/I_dut/enB1
add wave -noupdate /leftrightsplitter_tb/I_dut/outputEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {37644290 ns} 0} {{Cursor 2} {1365854 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 302
configure wave -valuecolwidth 94
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