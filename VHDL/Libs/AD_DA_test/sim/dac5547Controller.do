onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dac5547controller_tb/reset
add wave -noupdate /dac5547controller_tb/clock
add wave -noupdate -divider Controls
add wave -noupdate -radix unsigned /dac5547controller_tb/amplitude1
add wave -noupdate -radix unsigned /dac5547controller_tb/amplitude2
add wave -noupdate /dac5547controller_tb/newsample
add wave -noupdate -divider Internals
add wave -noupdate /dac5547controller_tb/i_dut/timingsenable
add wave -noupdate /dac5547controller_tb/i_dut/writeshiftreg
add wave -noupdate -divider {DAC inputs}
add wave -noupdate /dac5547controller_tb/msb
add wave -noupdate /dac5547controller_tb/rs_n
add wave -noupdate -radix binary -subitemconfig {/dac5547controller_tb/a(1) {-radix binary} /dac5547controller_tb/a(0) {-radix binary}} /dac5547controller_tb/a
add wave -noupdate -radix unsigned /dac5547controller_tb/d
add wave -noupdate /dac5547controller_tb/wr_n
add wave -noupdate /dac5547controller_tb/ldac
add wave -noupdate -divider {DAC outputs}
add wave -noupdate /dac5547controller_tb/outa
add wave -noupdate /dac5547controller_tb/outb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
