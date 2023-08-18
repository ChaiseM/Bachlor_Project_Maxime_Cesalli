onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 100 -max 4095.0 -radix unsigned -radixshowbase 0 /adc7886_tb/VIN
add wave -noupdate /adc7886_tb/CS_n
add wave -noupdate /adc7886_tb/SCLK
add wave -noupdate /adc7886_tb/SDO
add wave -noupdate -format Analog-Step -height 50 -max 4095.0 -radix unsigned -radixshowbase 0 /adc7886_tb/I_tb/sample
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 163
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ps} {31500 ns}
