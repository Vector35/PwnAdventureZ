.include "defines.inc"

.code

PROC title
	; Get the developer logo screen ready
	jsr clear_screen

	; Use 8x8 sprites on second CHR page
	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_PATTERN | PPUCTRL_NAMETABLE_2400
	sta ppu_settings

	; Copy sprite data to OAM
	LOAD_PTR vector35_logo
	ldy #0
vectorloop:
	lda (ptr), y
	sta sprites, y
	iny
	cpy #19 * 4
	bne vectorloop

	LOAD_PTR vector35_palette
	jsr fade_in

	; Show developer logo for 3 seconds then fade out
	ldx #180
	jsr wait_for_frame_count
	jsr fade_out

	; Start drawing title screen
	jsr clear_screen

	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_SIZE | PPUCTRL_NAMETABLE_2400
	sta ppu_settings

	; Draw UI box around logo
	lda #6
	sta arg0
	lda #6
	sta arg1
	lda #24
	sta arg2
	lda #15
	sta arg3
	jsr draw_large_box

	; Draw Pwn Adventure logo
	LOAD_PTR pwn_logo
	ldy #8

pwn_logo_loop:
	tya
	pha

	ldx #8
	lda #9
	jsr write_tiles

	pla
	tay
	iny
	cpy #12
	bne pwn_logo_loop

	; Draw Z logo
	LOAD_PTR z_logo
	ldy #8

z_logo_loop:
	tya
	pha

	ldx #18
	lda #5
	jsr write_tiles

	pla
	tay
	iny
	cpy #14
	bne z_logo_loop

	; Set palette for logo
	lda #4
	sta arg0
	sta arg1
	lda #8
	sta arg2
	lda #5
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	lda #9
	sta arg0
	lda #4
	sta arg1
	lda #11
	sta arg2
	lda #6
	sta arg3
	jsr set_box_palette

	lda #2
	sta arg0
	sta arg4
	lda #8
	sta arg1
	sta arg3
	lda #13
	sta arg2
	jsr set_box_palette

	lda #11
	sta arg1
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	; Draw text
	LOAD_PTR adventure_str
	ldx #8
	ldy #13
	jsr write_string
	ldx #4
	ldy #17
	jsr write_string
	ldx #10
	ldy #23
	jsr write_string

	; Fade in to the palette and start displaying the title screen
	LOAD_PTR title_palette
	jsr fade_in

	ldx #0
	ldy #0
menuloop:
	txa
	pha
	tya
	pha

	jsr update_controller
	lda controller
	and #JOY_START
	bne start

	jsr wait_for_vblank

	; Perform palette animation
	pla
	tay
	pla
	tax

	inx
	cpx #8
	bne menuloop
	ldx #0

	LOAD_PTR flashing_text_palette_anim
	lda #3
	sta arg0
	jsr animate_palette
	jsr prepare_for_rendering

	jmp menuloop

start:
	pla
	pla

	jsr fade_out

	rts

.endproc


.data

VAR vector35_logo
	.byte 99, TILE_VECTOR, 0, 108
	.byte 99, TILE_VECTOR + $1, 1, 116
	.byte 99, TILE_VECTOR + $1, 1 | SPRITE_FLIP_HORIZ, 132
	.byte 99, TILE_VECTOR + $0, 0 | SPRITE_FLIP_HORIZ, 140
	.byte 107, TILE_VECTOR + $2, 0, 108
	.byte 107, TILE_VECTOR + $3, 0, 116
	.byte 107, TILE_VECTOR + $4, 1, 124
	.byte 107, TILE_VECTOR + $3, 0 | SPRITE_FLIP_HORIZ, 132
	.byte 107, TILE_VECTOR + $2, 0 | SPRITE_FLIP_HORIZ, 140
	.byte 115, TILE_VECTOR + $2, 0, 116
	.byte 115, TILE_VECTOR + $5, 0, 124
	.byte 115, TILE_VECTOR + $2, 0 | SPRITE_FLIP_HORIZ, 132
	.byte 131, TILE_VECTOR + $6, 2, 100
	.byte 131, TILE_VECTOR + $7, 2, 108
	.byte 131, TILE_VECTOR + $8, 2, 116
	.byte 131, TILE_VECTOR + $9, 2, 124
	.byte 131, TILE_VECTOR + $a, 2, 132
	.byte 131, TILE_VECTOR + $b, 2, 140
	.byte 131, TILE_VECTOR + $c, 2, 148

VAR vector35_palette
	.byte $0f, $3d, $2a, $3a
	.byte $0f, $3d, $2a, $3a
	.byte $0f, $3d, $2a, $3a
	.byte $0f, $3d, $2a, $3a
	.byte $0f, $3d, $2a, $3a
	.byte $0f, $3d, $2a, $30
	.byte $0f, $30, $3a, $3a
	.byte $0f, $3d, $2a, $3a

VAR pwn_logo
	.byte $02, $01, $04, $0c, $20, $0c, $0e, $10, $0c
	.byte $2b, $20, $2b, $2b, $20, $2b, $0f, $11, $2b
	.byte $03, $01, $05, $06, $08, $0a, $2b, $12, $14
	.byte $0d, $20, $20, $07, $09, $0b, $0d, $13, $15
VAR z_logo
	.byte TILE_Z + $00, TILE_Z + $01, TILE_Z + $01, TILE_Z + $01, TILE_Z + $02
	.byte TILE_Z + $03, TILE_Z + $04, TILE_Z + $05, TILE_Z + $06, TILE_Z + $07
	.byte $00,          TILE_Z + $08, TILE_Z + $09, TILE_Z + $0a, TILE_Z + $0b
	.byte TILE_Z + $08, TILE_Z + $09, TILE_Z + $0a, TILE_Z + $0b, $00
	.byte TILE_Z + $0c, TILE_Z + $0d, TILE_Z + $0e, TILE_Z + $0f, TILE_Z + $10
	.byte TILE_Z + $11, TILE_Z + $12, TILE_Z + $12, TILE_Z + $12, TILE_Z + $13

VAR adventure_str
	.byte "ADVENTURE", 0
VAR retro_str
	.byte $3b, " SUPER RETRO EDITION ", $3d, 0
VAR press_start_str
	.byte "PRESS START", 0


VAR flashing_text_palette_anim
	.word normal_str_palette
	.word normal_str_palette
	.word normal_str_palette
	.word alt_str_palettes
	.word alt_str_palettes + 4
	.word alt_str_palettes + 8
	.word alt_str_palettes + 4
	.word alt_str_palettes

title_palette:
	.byte $0f, $21, $31, $37
	.byte $0f, $16, $26, $36
	.byte $0f, $31, $31, $31
normal_str_palette:
	.byte $0f, $30, $30, $30
	.byte $0f, $27, $37, $30
	.byte $0f, $27, $37, $30
	.byte $0f, $27, $37, $30
	.byte $0f, $27, $37, $30
alt_str_palettes:
	.byte $0f, $10, $10, $10
	.byte $0f, $00, $00, $00
	.byte $0f, $0f, $0f, $0f
