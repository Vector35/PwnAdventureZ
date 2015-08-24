.include "defines.inc"

.code

PROC main
	jsr title
	jmp main
.endproc


PROC update_controller
	; Start controller read
	lda #1
	sta JOY1
	lda #0
	sta JOY1

	; Read 8 buttons
	ldx #8
loop:
	pha
	lda JOY1
	and #3 ; Button is pressed if either of the bottom two bits are set
	cmp #1
	pla
	ror

	dex
	bne loop

	sta controller
	rts
.endproc

.zeropage
VAR controller
	.byte 0
