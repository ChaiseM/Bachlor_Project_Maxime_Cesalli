onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Signal values}
add wave -noupdate -radix unsigned /dac5543_tb/i_tb/amplitude_int
add wave -noupdate /dac5543_tb/i_tb/sendnewvalue
add wave -noupdate -divider {DAC controls}
add wave -noupdate /dac5543_tb/cs_n
add wave -noupdate /dac5543_tb/clk
add wave -noupdate /dac5543_tb/sdi
add wave -noupdate -divider {DAC out}
add wave -noupdate -radix unsigned /dac5543_tb/iout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 257
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
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {31500 ns}
