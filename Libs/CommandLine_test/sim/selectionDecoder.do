onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Reset and clock} /selectiondecoder_tb/reset
add wave -noupdate -expand -group {Reset and clock} /selectiondecoder_tb/clock
add wave -noupdate -expand -group Command -radix hexadecimal -radixshowbase 0 /selectiondecoder_tb/charIn
add wave -noupdate -expand -group Command /selectiondecoder_tb/charEn
add wave -noupdate -expand -group Command -radix ascii -radixshowbase 0 /selectiondecoder_tb/I_DUT/charReg
add wave -noupdate -group {Command decoder} -radix unsigned -childformat {{/selectiondecoder_tb/I_DUT/characterCounter(3) -radix unsigned} {/selectiondecoder_tb/I_DUT/characterCounter(2) -radix unsigned} {/selectiondecoder_tb/I_DUT/characterCounter(1) -radix unsigned} {/selectiondecoder_tb/I_DUT/characterCounter(0) -radix unsigned}} -radixshowbase 0 -subitemconfig {/selectiondecoder_tb/I_DUT/characterCounter(3) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/characterCounter(2) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/characterCounter(1) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/characterCounter(0) {-height 16 -radix unsigned -radixshowbase 0}} /selectiondecoder_tb/I_DUT/characterCounter
add wave -noupdate -group {Command decoder} -radix unsigned -childformat {{/selectiondecoder_tb/I_DUT/commandId(3) -radix unsigned} {/selectiondecoder_tb/I_DUT/commandId(2) -radix unsigned} {/selectiondecoder_tb/I_DUT/commandId(1) -radix unsigned} {/selectiondecoder_tb/I_DUT/commandId(0) -radix unsigned}} -radixshowbase 0 -subitemconfig {/selectiondecoder_tb/I_DUT/commandId(3) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandId(2) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandId(1) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandId(0) {-height 16 -radix unsigned -radixshowbase 0}} /selectiondecoder_tb/I_DUT/commandId
add wave -noupdate -group {Command decoder} -radix unsigned -childformat {{/selectiondecoder_tb/I_DUT/ramAddress(6) -radix unsigned} {/selectiondecoder_tb/I_DUT/ramAddress(5) -radix unsigned} {/selectiondecoder_tb/I_DUT/ramAddress(4) -radix unsigned} {/selectiondecoder_tb/I_DUT/ramAddress(3) -radix unsigned} {/selectiondecoder_tb/I_DUT/ramAddress(2) -radix unsigned} {/selectiondecoder_tb/I_DUT/ramAddress(1) -radix unsigned} {/selectiondecoder_tb/I_DUT/ramAddress(0) -radix unsigned}} -radixshowbase 0 -subitemconfig {/selectiondecoder_tb/I_DUT/ramAddress(6) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/ramAddress(5) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/ramAddress(4) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/ramAddress(3) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/ramAddress(2) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/ramAddress(1) {-height 16 -radix unsigned -radixshowbase 0} /selectiondecoder_tb/I_DUT/ramAddress(0) {-height 16 -radix unsigned -radixshowbase 0}} /selectiondecoder_tb/I_DUT/ramAddress
add wave -noupdate -group {Command decoder} /selectiondecoder_tb/I_DUT/ramEn
add wave -noupdate -group {Command decoder} -radix ascii -radixshowbase 0 /selectiondecoder_tb/I_DUT/ramData
add wave -noupdate -group {Command decoder} -radix unsigned -radixshowbase 0 /selectiondecoder_tb/I_DUT/commandIdDelayed
add wave -noupdate -group {Command decoder} -radix hexadecimal -childformat {{/selectiondecoder_tb/I_DUT/commandMatches(1) -radix hexadecimal} {/selectiondecoder_tb/I_DUT/commandMatches(2) -radix hexadecimal} {/selectiondecoder_tb/I_DUT/commandMatches(3) -radix hexadecimal} {/selectiondecoder_tb/I_DUT/commandMatches(4) -radix hexadecimal} {/selectiondecoder_tb/I_DUT/commandMatches(5) -radix hexadecimal} {/selectiondecoder_tb/I_DUT/commandMatches(6) -radix hexadecimal} {/selectiondecoder_tb/I_DUT/commandMatches(7) -radix hexadecimal} {/selectiondecoder_tb/I_DUT/commandMatches(8) -radix hexadecimal}} -radixshowbase 0 -expand -subitemconfig {/selectiondecoder_tb/I_DUT/commandMatches(1) {-height 16 -radix hexadecimal -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandMatches(2) {-height 16 -radix hexadecimal -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandMatches(3) {-height 16 -radix hexadecimal -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandMatches(4) {-height 16 -radix hexadecimal -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandMatches(5) {-height 16 -radix hexadecimal -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandMatches(6) {-height 16 -radix hexadecimal -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandMatches(7) {-height 16 -radix hexadecimal -radixshowbase 0} /selectiondecoder_tb/I_DUT/commandMatches(8) {-height 16 -radix hexadecimal -radixshowbase 0}} /selectiondecoder_tb/I_DUT/commandMatches
add wave -noupdate /selectiondecoder_tb/charReady
add wave -noupdate -expand /selectiondecoder_tb/command
add wave -noupdate -group {Number decoder} /selectiondecoder_tb/I_DUT/isHexDigit
add wave -noupdate -group {Number decoder} -radix unsigned -radixshowbase 0 /selectiondecoder_tb/I_DUT/hexDigit
add wave -noupdate -group {Number decoder} /selectiondecoder_tb/I_DUT/isNumber
add wave -noupdate -radix hexadecimal -radixshowbase 0 /selectiondecoder_tb/value
add wave -noupdate /selectiondecoder_tb/valueEn
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 336
configure wave -valuecolwidth 68
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
