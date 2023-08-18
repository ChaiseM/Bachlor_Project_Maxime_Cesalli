onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /adc8782controller_tb/clock
add wave -noupdate /adc8782controller_tb/reset
add wave -noupdate -divider {ADC inputs}
add wave -noupdate /adc8782controller_tb/ainr
add wave -noupdate /adc8782controller_tb/ainl
add wave -noupdate -divider {ADC controls}
add wave -noupdate /adc8782controller_tb/format
add wave -noupdate /adc8782controller_tb/fsampen
add wave -noupdate /adc8782controller_tb/iwl
add wave -noupdate /adc8782controller_tb/m_s
add wave -noupdate /adc8782controller_tb/mclk
add wave -noupdate /adc8782controller_tb/bclk
add wave -noupdate /adc8782controller_tb/lrclk
add wave -noupdate /adc8782controller_tb/dout
add wave -noupdate -divider {Controller Outputs}
add wave -noupdate /adc8782controller_tb/newsample
add wave -noupdate -radix decimal /adc8782controller_tb/amplituder
add wave -noupdate -radix decimal /adc8782controller_tb/amplitudel
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 223
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
WaveRestoreZoom {0 ps} {21 us}
