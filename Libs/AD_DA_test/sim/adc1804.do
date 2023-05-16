onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Controls
add wave -noupdate /adc1804_tb/rst_n
add wave -noupdate /adc1804_tb/bypas
add wave -noupdate /adc1804_tb/fmt
add wave -noupdate /adc1804_tb/ovfl
add wave -noupdate /adc1804_tb/ovfr
add wave -noupdate /adc1804_tb/s_m
add wave -noupdate /adc1804_tb/osr
add wave -noupdate -divider {Analog inputs}
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 /adc1804_tb/vinlp
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 /adc1804_tb/vinlm
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 /adc1804_tb/vinrp
add wave -noupdate -format Analog-Step -height 30 -max 10000000.0 /adc1804_tb/vinrm
add wave -noupdate -divider Clocks
add wave -noupdate /adc1804_tb/scki
add wave -noupdate /adc1804_tb/bck_dsdl
add wave -noupdate /adc1804_tb/lrck_dsdbck
add wave -noupdate -divider {Serial Output}
add wave -noupdate /adc1804_tb/data_dsdr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7813936600 fs} 0} {{Cursor 2} {13264225260 fs} 0}
configure wave -namecolwidth 189
configure wave -valuecolwidth 100
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 fs} {105 us}
