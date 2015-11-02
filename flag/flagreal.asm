.include "../defines.inc"

.data

VAR flag_strings
	.byte "THE FLAG IS:", 0
	.byte "ZOMBIESHELLCODE4DEADSYSTEMZ", 0
	.byte "CONGRATULATIONS ON DEFEATING", 0
	.byte "A REAL ZOMBIE, THE 6502", 0


.segment "UI"

VAR blocky_flag_text
	.byte "THE FLAG IS:", 0
	.byte "LINKNEVERHADITTHISHARD", 0
	.byte "                      ", 0
	.byte "                      ", 0

VAR boarded_house_flag_text
	.byte "THE FLAG IS:", 0
	.byte "KNOCKEDITOUTOFTHEPARK ", 0
	.byte "                      ", 0
	.byte "                      ", 0
