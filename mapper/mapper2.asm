.include "../defines.inc"

.segment "FIXED"

PROC reset_mapper
	lda #0
	sta bankswitch_table
	rts
.endproc


PROC bankswitch
	; Must write to a memory location that contains the same value being written due to bus conflicts.
	tay
	sta bankswitch_table, y
	rts
.endproc


PROC has_save_ram
	lda #0
	rts
.endproc


PROC clear_slot
	rts
.endproc


PROC save_ram_to_slot
	rts
.endproc


PROC restore_ram_from_slot
	rts
.endproc


PROC is_save_slot_valid
	lda #0
	rts
.endproc


.data
VAR bankswitch_table
	.byte 0, 1, 2, 3, 4, 5, 6, 7


.segment "HEADER"
	.byte "NES", $1a
	.byte 8 ; 128kb program ROM
	.byte 0 ; CHR-RAM
	.byte $20 ; Mapper 2 (UNROM)
	.byte 0
	.byte 0
	.byte 0 ; NTSC
	.byte $10 ; No program RAM (internal RAM only)
