.include "defines.inc"

.define TILE_UI     $00
.define TILE_VECTOR $01
.define TILE_Z      $01

.code

PROC title
	; Get the developer logo screen ready
	jsr clear_screen
	jsr clear_tiles

	; Copy tiles into video memory
	LOAD_ALL_TILES $100 + TILE_VECTOR, vector35_tiles

	; Use 8x8 sprites on first CHR page
	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_PATTERN | PPUCTRL_NAMETABLE_2C00
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
	ldy #180
vectorwait:
	jsr wait_for_vblank
	jsr update_controller
	and #JOY_START
	bne vectordone
	dey
	bne vectorwait
vectordone:

	jsr fade_out

	; Start drawing title screen
	jsr clear_screen

	; Copy tiles into video memory
	LOAD_ALL_TILES $000 + TILE_UI, title_tiles
	LOAD_ALL_TILES $100 + TILE_Z, z_tiles

	; Draw UI box around logo
	lda #6
	sta arg0
	lda #5
	sta arg1
	lda #24
	sta arg2
	lda #14
	sta arg3
	jsr draw_large_box

	; Draw Pwn Adventure logo
	LOAD_PTR pwn_logo
	ldy #7

pwn_logo_loop:
	tya
	pha

	ldx #8
	lda #9
	jsr write_tiles

	pla
	tay
	iny
	cpy #11
	bne pwn_logo_loop

	; Copy Z logo sprite data to OAM
	LOAD_PTR z_logo
	ldy #0
zloop:
	lda (ptr), y
	sta sprites, y
	iny
	cpy #28 * 4
	bne zloop

	; Set palette for logo
	lda #4
	sta arg0
	lda #3
	sta arg1
	lda #8
	sta arg2
	lda #5
	sta arg3
	lda #1
	sta arg4
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
	ldy #12
	jsr write_string
	LOAD_PTR retro_str
	ldx #4
	ldy #16
	jsr write_string
	ldx #10
	ldy #22
	jsr write_string

	; Fade in to the palette and start displaying the title screen
	LOAD_PTR title_palette
	jsr fade_in

	lda #0
	sta arg0
	sta arg1
menuloop:
	jsr update_controller
	and #JOY_START
	bne start

	lda controller
	beq nopress

	ldx #0
buttonmoveloop:
	lda button_presses + 1, x
	sta button_presses, x
	inx
	cpx #9
	bne buttonmoveloop
	lda controller
	sta button_presses + 9

	lda button_presses
	cmp #JOY_UP
	bne waitfordepress
	lda button_presses + 1
	cmp #JOY_UP
	bne waitfordepress
	lda button_presses + 2
	cmp #JOY_DOWN
	bne waitfordepress
	lda button_presses + 3
	cmp #JOY_DOWN
	bne waitfordepress
	lda button_presses + 4
	cmp #JOY_LEFT
	bne waitfordepress
	lda button_presses + 5
	cmp #JOY_RIGHT
	bne waitfordepress
	lda button_presses + 6
	cmp #JOY_LEFT
	bne waitfordepress
	lda button_presses + 7
	cmp #JOY_RIGHT
	bne waitfordepress
	lda button_presses + 8
	cmp #JOY_B
	bne waitfordepress
	lda button_presses + 9
	cmp #JOY_A
	bne waitfordepress

	lda #1
	sta secret_code

waitfordepress:
	jsr wait_for_vblank
	jsr title_palette_anim
	jsr update_controller
	lda controller
	bne waitfordepress

nopress:
	jsr wait_for_vblank
	jsr title_palette_anim
	jmp menuloop

start:
	jsr fade_out

	rts

.endproc


PROC title_palette_anim
	ldx arg0
	ldy arg1

	inx
	cpx #8
	bne done
	ldx #0

	LOAD_PTR flashing_text_palette_anim
	lda #3
	sta arg0
	jsr animate_palette
	jsr prepare_for_rendering

done:
	stx arg0
	sty arg1
	rts
.endproc


.segment "TEMP"

VAR button_presses
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


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
	.byte $0f, $10, $2a, $3a
	.byte $0f, $10, $2a, $3a
	.byte $0f, $10, $2a, $3a
	.byte $0f, $10, $2a, $3a
	.byte $0f, $10, $2a, $3a
	.byte $0f, $10, $2a, $30
	.byte $0f, $30, $3a, $2a
	.byte $0f, $10, $2a, $3a

VAR pwn_logo
	.byte $02, $01, $04, $0c, $20, $0c, $0e, $10, $0c
	.byte $2b, $20, $2b, $2b, $20, $2b, $0f, $11, $2b
	.byte $03, $01, $05, $06, $08, $0a, $2b, $12, $14
	.byte $0d, $20, $20, $07, $09, $0b, $0d, $13, $15
VAR z_logo
	.byte 63, TILE_Z + $00, 0, 152
	.byte 63, TILE_Z + $01, 0, 160
	.byte 63, TILE_Z + $01, 0, 168
	.byte 63, TILE_Z + $01, 0, 176
	.byte 63, TILE_Z + $02, 0, 184
	.byte 71, TILE_Z + $03, 0, 152
	.byte 71, TILE_Z + $04, 0, 160
	.byte 71, TILE_Z + $05, 0, 168
	.byte 71, TILE_Z + $06, 0, 176
	.byte 71, TILE_Z + $07, 0, 184
	.byte 79, TILE_Z + $08, 0, 160
	.byte 79, TILE_Z + $09, 0, 168
	.byte 79, TILE_Z + $0a, 0, 176
	.byte 79, TILE_Z + $0b, 0, 184
	.byte 87, TILE_Z + $08, 0, 152
	.byte 87, TILE_Z + $09, 0, 160
	.byte 87, TILE_Z + $0a, 0, 168
	.byte 87, TILE_Z + $0b, 0, 176
	.byte 95, TILE_Z + $0c, 0, 152
	.byte 95, TILE_Z + $0d, 0, 160
	.byte 95, TILE_Z + $0e, 0, 168
	.byte 95, TILE_Z + $0f, 0, 176
	.byte 95, TILE_Z + $10, 0, 184
	.byte 103, TILE_Z + $11, 0, 152
	.byte 103, TILE_Z + $12, 0, 160
	.byte 103, TILE_Z + $12, 0, 168
	.byte 103, TILE_Z + $12, 0, 176
	.byte 103, TILE_Z + $13, 0, 184

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

VAR title_palette
	.byte $0f, $21, $31, $37
	.byte $0f, $16, $26, $36
	.byte $0f, $31, $31, $31
normal_str_palette:
	.byte $0f, $30, $30, $30
	.byte $0f, $16, $26, $36
	.byte $0f, $16, $26, $36
	.byte $0f, $16, $26, $36
	.byte $0f, $16, $26, $36
alt_str_palettes:
	.byte $0f, $10, $10, $10
	.byte $0f, $00, $00, $00
	.byte $0f, $0f, $0f, $0f


TILES ui_tiles, 1, "tiles/ui.chr", 92
TILES title_tiles, 1, "tiles/title/title.chr", 92
TILES vector35_tiles, 1, "tiles/title/vector35.chr", 14
TILES z_tiles, 1, "tiles/title/z.chr", 20
