onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {Reset and clock} /interlock_tb/reset
add wave -noupdate -group {Reset and clock} /interlock_tb/clock
add wave -noupdate -expand -group Command -radix unsigned -radixshowbase 0 /interlock_tb/charIn
add wave -noupdate -expand -group Command -radix ascii -radixshowbase 0 /interlock_tb/charIn
add wave -noupdate -expand -group Command /interlock_tb/charEn
add wave -noupdate -expand -group Command -radixshowbase 0 /interlock_tb/charReady
add wave -noupdate -expand -group Command -radix unsigned -childformat {{/interlock_tb/command(1) -radix unsigned} {/interlock_tb/command(2) -radix unsigned} {/interlock_tb/command(3) -radix unsigned} {/interlock_tb/command(4) -radix unsigned} {/interlock_tb/command(5) -radix unsigned} {/interlock_tb/command(6) -radix unsigned} {/interlock_tb/command(7) -radix unsigned} {/interlock_tb/command(8) -radix unsigned}} -radixshowbase 0 -expand -subitemconfig {/interlock_tb/command(1) {-radix unsigned -radixshowbase 0} /interlock_tb/command(2) {-radix unsigned -radixshowbase 0} /interlock_tb/command(3) {-radix unsigned -radixshowbase 0} /interlock_tb/command(4) {-radix unsigned -radixshowbase 0} /interlock_tb/command(5) {-radix unsigned -radixshowbase 0} /interlock_tb/command(6) {-radix unsigned -radixshowbase 0} /interlock_tb/command(7) {-radix unsigned -radixshowbase 0} /interlock_tb/command(8) {-radix unsigned -radixshowbase 0}} /interlock_tb/command
add wave -noupdate -radix hexadecimal -childformat {{/interlock_tb/selectEn(1) -radix hexadecimal} {/interlock_tb/selectEn(2) -radix hexadecimal} {/interlock_tb/selectEn(3) -radix hexadecimal} {/interlock_tb/selectEn(4) -radix hexadecimal} {/interlock_tb/selectEn(5) -radix hexadecimal} {/interlock_tb/selectEn(6) -radix hexadecimal} {/interlock_tb/selectEn(7) -radix hexadecimal} {/interlock_tb/selectEn(8) -radix hexadecimal}} -radixshowbase 0 -expand -subitemconfig {/interlock_tb/selectEn(1) {-height 16 -radix hexadecimal -radixshowbase 0} /interlock_tb/selectEn(2) {-height 16 -radix hexadecimal -radixshowbase 0} /interlock_tb/selectEn(3) {-height 16 -radix hexadecimal -radixshowbase 0} /interlock_tb/selectEn(4) {-height 16 -radix hexadecimal -radixshowbase 0} /interlock_tb/selectEn(5) {-height 16 -radix hexadecimal -radixshowbase 0} /interlock_tb/selectEn(6) {-height 16 -radix hexadecimal -radixshowbase 0} /interlock_tb/selectEn(7) {-height 16 -radix hexadecimal -radixshowbase 0} /interlock_tb/selectEn(8) {-height 16 -radix hexadecimal -radixshowbase 0}} /interlock_tb/selectEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 218
configure wave -valuecolwidth 107
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
WaveRestoreZoom {0 ps} {6825 ns}
