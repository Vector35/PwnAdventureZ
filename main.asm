.include "defines.inc"

.code

PROC main
	jsr title

	jsr init_game_state

	rts
.endproc


PROC init_game_state
	jsr init_map

	rts
.endproc


PROC game_over
	lda rendering_enabled
	beq already_disabled
	jsr fade_out
already_disabled:

	jsr clear_screen

	; Draw text
	LOAD_PTR game_over_strings
	ldx #7
	ldy #13
	jsr write_string
	ldx #8
	ldy #14
	jsr write_string
	ldx #7
	ldy #17
	jsr write_string

	; Set palette for game over text
	lda #3
	sta arg0
	lda #8
	sta arg1
	sta arg3
	lda #12
	sta arg2
	lda #1
	sta arg4
	jsr set_box_palette

	LOAD_PTR game_over_palette
	jsr fade_in

	ldx #180
	jsr wait_for_frame_count

	ldy #0
	LOAD_PTR game_over_palette + 8
game_over_fade:
	tya
	pha

	lda #1
	jsr load_single_palette
	jsr prepare_for_rendering

	ldx #15
	jsr wait_for_frame_count

	pla
	tay
	iny
	cpy #4
	bne game_over_fade

end:
	jsr wait_for_vblank
	jsr update_controller
	lda controller
	and #JOY_START
	beq end
	jmp start
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


.data
VAR game_over_strings
	.byte "THE ZOMBIES HAVE", 0
	.byte "OVERTAKEN YOU.", 0
	.byte $3b, $3b, " GAME  OVER ", $3d, $3d, 0

VAR game_over_palette
	.byte $0f, $26, $26, $26
	.byte $0f, $0f, $0f, $0f
	.byte $0f, $07, $07, $07
	.byte $0f, $17, $17, $17
	.byte $0f, $27, $27, $27
	.byte $0f, $37, $37, $37
	.byte $0f, $26, $26, $26
	.byte $0f, $26, $26, $26


.bss
VAR inventory

VAR map_screen_generators
	.word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

VAR cur_screen_x
	.byte 0
VAR cur_screen_y
	.byte 0


.zeropage
VAR controller
	.byte 0
