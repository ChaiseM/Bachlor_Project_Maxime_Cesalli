onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider System
add wave -noupdate -format Logic /highpass_50_tb/sys_clk_o
add wave -noupdate -format Logic /highpass_50_tb/sys_rst_o
add wave -noupdate -divider input
add wave -noupdate -format Literal -radix decimal /highpass_50_tb/i1/sine_frequency_s
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/sample_o
add wave -noupdate -format Logic /highpass_50_tb/enable_o
add wave -noupdate -divider output
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/sample_i
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2805 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 1
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1890 ms}
