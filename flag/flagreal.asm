.include "../defines.inc"

.data

VAR flag_strings
	.byte "THE FLAG IS:", 0
	.byte "WASEASIERTHANSMWCREDITSWARP", 0
	.byte "CONGRATULATIONS ON DEFEATING", 0
	.byte "A REAL ZOMBIE, THE 6502", 0
	.byte 0

VAR memory_disclosure_flag
	.byte "LEAK THIS FLAG FOR MAXIMUM POINTS.", 0
	.byte "THE FLAG IS:", 0
	.byte "ZOMBIESHELLCODE4DEADSYSTEMZ", 0
	.byte 0


.segment "UI"

VAR blocky_flag_text
	.byte "THE FLAG IS:", 0
	.byte "LINKNEVERHADITTHISHARD", 0
	.byte "                      ", 0
	.byte "                      ", 0
	.byte 0

VAR boarded_house_flag_text
	.byte "THE FLAG IS:", 0
	.byte "KNOCKEDITOUTOFTHEPARK ", 0
	.byte "                      ", 0
	.byte "                      ", 0
	.byte 0

VAR lost_cave_flag_text
	.byte "THE FLAG IS:", 0
	.byte "ONCEWASLOSTNOWISFOUND ", 0
	.byte "                      ", 0
	.byte "                      ", 0
	.byte 0

.segment "CHR1"

VAR credit_flag
	.byte "THE FLAG IS:               ", 0
	.byte " PATIENTZERODAYNEARLYGOTME  ", 0
