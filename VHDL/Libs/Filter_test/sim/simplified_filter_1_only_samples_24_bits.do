onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {sample generator}
add wave -noupdate -format Literal -radix decimal /highpass_50_tb/i1/sine_frequency_s
add wave -noupdate -format Logic /highpass_50_tb/i0/enable_i
add wave -noupdate -divider {Biquad 1 (input)}
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/i0/sample_i
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/i0/i0/w2_s
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/i0/i0/x1_s
add wave -noupdate -format Literal -offset 8388610.0 -radix hexadecimal -scale 1.1682507590649702e-005 /highpass_50_tb/i0/sample_i
add wave -noupdate -format Literal -offset 8388610.0 -radix hexadecimal /highpass_50_tb/i0/i0/w2_s
add wave -noupdate -format Literal -radix hexadecimal /highpass_50_tb/i0/i0/x1_s
add wave -noupdate -format Literal -radix hexadecimal /highpass_50_tb/i0/i0/w5_s
add wave -noupdate -format Literal -radix hexadecimal /highpass_50_tb/i0/i0/w6_s
add wave -noupdate -format Literal -radix hexadecimal /highpass_50_tb/i0/i0/w9_s
add wave -noupdate -format Literal -offset 8388610.0 -radix hexadecimal /highpass_50_tb/i0/i0/x1_s
add wave -noupdate -divider {Biquad 2 (input)}
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/i0/sample_out_biquad_1_s
add wave -noupdate -divider {Amplifier (input)}
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/i0/sample_out_biquad_2_s
add wave -noupdate -divider {Filter (output)}
add wave -noupdate -format Analog-Step -height 200 -offset 8388610.0 -radix decimal -scale 1.1682507590649702e-005 /highpass_50_tb/i0/sample_o
add wave -noupdate -divider <NULL>
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1799789473134 ps} 0} {{Cursor 2} {52696841274 ps} 0}
configure wave -namecolwidth 230
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
configure wave -timelineunits ms
update
WaveRestoreZoom {48022102314 ps} {55404914826 ps}
