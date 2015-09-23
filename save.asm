.include "defines.inc"

.define TILE_UI   $00
.define TILE_SAVE $80

.code

PROC save_select
	jsr clear_screen
	jsr clear_tiles

	LOAD_ALL_TILES TILE_UI, ui_tiles
	LOAD_ALL_TILES TILE_SAVE, save_tiles

	; Draw UI box for save select
	lda #3
	sta arg0
	lda #6
	sta arg1
	lda #27
	sta arg2
	lda #21
	sta arg3
	jsr draw_large_box

	LOAD_PTR save_select_title
	ldx #8
	ldy #6
	jsr write_string

	lda #2
	sta arg0
	lda #3
	sta arg1
	lda #14
	sta arg2
	lda #11
	sta arg3
	lda #0
	sta arg4
	jsr set_box_palette

	lda #3
	sta arg0
	lda #4
	sta arg1
	lda #4
	sta arg2
	lda #8
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #5
	sta arg0
	lda #4
	sta arg1
	lda #11
	sta arg2
	lda #8
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	lda #4
	sta arg0
	lda #9
	sta arg1
	lda #11
	sta arg2
	lda #9
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	; Fill in game details for each save
	ldy #0
gameloop:
	sty arg0

	LOAD_PTR slot_str
	lda arg0
	asl
	asl
	tay
	jsr add_y_to_ptr
	ldx #7
	lda arg0
	asl
	clc
	adc #8
	tay
	jsr write_string

	; Determine if the save slot is valid
	lda arg0
	jsr is_save_slot_valid
	beq validsave

	; Save slot is invalid, show new game text
	LOAD_PTR new_game_str
	ldx #10
	lda arg0
	asl
	clc
	adc #8
	tay
	jsr write_string

	jmp nextslot

validsave:
	; Pull the save data out of the save slot
	jsr enable_save_ram

	lda arg0
	asl
	asl
	asl
	asl
	asl
	tay

	lda $6000 + SAVE_HEADER_DIFFICULTY
	sta difficulty
	lda $6000 + SAVE_HEADER_KEY_COUNT
	sta key_count

	tya
	pha

	ldx #0
nameloop:
	lda $6000 + SAVE_HEADER_NAME, y
	sta name, x
	inx
	iny
	cpx #12
	bne nameloop

	pla
	tay
	ldx #0
timeloop:
	lda $6000 + SAVE_HEADER_TIME_PLAYED, y
	sta time_played, x
	inx
	iny
	cpx #6
	bne timeloop

	jsr disable_save_ram

	; Show save slot name
	LOAD_PTR name
	ldx #10
	lda arg0
	asl
	clc
	adc #8
	tay
	jsr write_string	

	; Show game difficulty
	LOAD_PTR difficulty_tiles
	lda difficulty
	asl
	asl
	asl
	tay
	jsr add_y_to_ptr
	ldx #10
	lda arg0
	asl
	clc
	adc #9
	tay
	lda #7
	jsr write_tiles

	; Show number of keys retrieved
	LOAD_PTR scratch
	lda key_count
	clc
	adc #TILE_SAVE + SAVE_TILE_KEY_COUNT
	sta scratch
	lda #TILE_SAVE + SAVE_TILE_NUMBERS + FINAL_KEY_COUNT
	sta scratch + 1
	ldx #18
	lda arg0
	asl
	clc
	adc #9
	tay
	lda #2
	jsr write_tiles

	; Need to show time played, procedurally generate tiles with non-8-width font to show this
	jsr copy_number_tiles_to_temp_area

	lda #0
	ldx #0
cleartileloop:
	sta sprites, x
	inx
	cpx #48
	bne cleartileloop

	lda time_played
	beq no_hour_tens

	asl
	asl
	asl
	asl
	tay
	ldx #0
tenhourloop:
	lda sprites + $40, y
	lsr
	sta sprites, x
	sta sprites + 8, x
	iny
	inx
	cpx #8
	bne tenhourloop

no_hour_tens:
	lda time_played + 1
	asl
	asl
	asl
	asl
	tay
	ldx #0
hourloop:
	lda sprites + $40, y
	lsr
	lsr
	lsr
	lsr
	lsr
	lsr
	sta temp
	lda sprites, x
	ora temp
	sta sprites, x
	sta sprites + 8, x
	lda sprites + $40, y
	asl
	asl
	sta sprites + $10, x
	sta sprites + $18, x
	iny
	inx
	cpx #8
	bne hourloop

	ldy #$a0
	ldx #0
colonloop:
	lda sprites + $40, y
	clc
	lsr
	lsr
	lsr
	sta temp
	lda sprites + $10, x
	ora temp
	sta sprites + $10, x
	sta sprites + $18, x
	iny
	inx
	cpx #8
	bne colonloop

	lda time_played + 2
	asl
	asl
	asl
	asl
	tay
	ldx #0
tenminuteloop:
	lda sprites + $40, y
	lsr
	lsr
	lsr
	lsr
	lsr
	sta temp
	lda sprites + $10, x
	ora temp
	sta sprites + $10, x
	sta sprites + $18, x
	lda sprites + $40, y
	asl
	asl
	asl
	sta sprites + $20, x
	sta sprites + $28, x
	iny
	inx
	cpx #8
	bne tenminuteloop

	lda time_played + 3
	asl
	asl
	asl
	asl
	tay
	ldx #0
minuteloop:
	lda sprites + $40, y
	lsr
	lsr
	sta temp
	lda sprites + $20, x
	ora temp
	sta sprites + $20, x
	sta sprites + $28, x
	iny
	inx
	cpx #8
	bne minuteloop

	; Copy generated tiles to CHR RAM
	LOAD_PTR sprites
	ldy #0
	lda #0
	sta temp
	lda #$f
	sta temp + 1
	lda #3
	jsr copy_tiles

	; Show time played text
	LOAD_PTR time_tiles
	ldx #21
	lda arg0
	asl
	clc
	adc #9
	tay
	lda #3
	jsr write_tiles

nextslot:
	ldy arg0
	iny
	sty arg0
	cpy #5
	beq savedone
	jmp gameloop

savedone:
	LOAD_PTR delete_str
	ldx #9
	ldy #19
	jsr write_string

	; Use 8x8 sprites on first CHR page
	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_PATTERN | PPUCTRL_NAMETABLE_2C00
	sta ppu_settings

	LOAD_PTR save_select_palette
	jsr fade_in

	lda #0
	sta active_save_slot

selectloop:
	jsr update_controller
	and #JOY_START
	bne done
	jmp selectloop

done:
	jsr fade_out
	jsr clear_screen

	; If a valid existing save state was selected, load the state
	lda active_save_slot
	jsr is_save_slot_valid
	bne newgame

	lda active_save_slot
	sta scratch
	jsr restore_ram_from_slot
	lda scratch
	sta active_save_slot

	lda #0
	sta start_new_game
	rts

newgame:
	lda #1
	sta start_new_game
	rts
.endproc


PROC enter_name
	; Put a placeholder name in for now until UI is implemented
	lda #'P'
	sta name
	lda #'L'
	sta name + 1
	lda #'A'
	sta name + 2
	lda #'Y'
	sta name + 3
	lda #'E'
	sta name + 4
	lda #'R'
	sta name + 5
	lda #' '
	sta name + 6
	lda #'O'
	sta name + 7
	lda #'N'
	sta name + 8
	lda #'E'
	sta name + 9
	rts
.endproc


.segment "FIXED"

PROC copy_number_tiles_to_temp_area
	lda #1
	jsr bankswitch

	ldx #0
copyloop:
	lda save_tiles + (SAVE_TILE_NUMBERS * 16), x
	sta sprites + $40, x
	inx
	cpx #$b0
	bne copyloop

	lda #0
	jsr bankswitch
	rts
.endproc


.data

VAR save_select_palette
	.byte $0f, $21, $31, $37
	.byte $0f, $26, $37, $30
	.byte $0f, $21, $31, $26
	.byte $0f, $21, $31, $31
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30

VAR save_select_title
	.byte $3b, " SAVE SELECT ", $3d, 0

VAR slot_str
	.byte "1: ", 0
	.byte "2: ", 0
	.byte "3: ", 0
	.byte "4: ", 0
	.byte "5: ", 0

VAR new_game_str
	.byte $2a, $2a, " NEW GAME ", $2a, $2a, 0

VAR delete_str
	.byte "DELETE A GAME", 0

VAR difficulty_tiles
	.byte TILE_SAVE + SAVE_TILE_NORMAL + 0
	.byte TILE_SAVE + SAVE_TILE_NORMAL + 1
	.byte TILE_SAVE + SAVE_TILE_NORMAL + 2
	.byte TILE_SAVE + SAVE_TILE_NORMAL + 3
	.byte 0, 0, 0, 0

	.byte TILE_SAVE + SAVE_TILE_HARD + 0
	.byte TILE_SAVE + SAVE_TILE_HARD + 1
	.byte TILE_SAVE + SAVE_TILE_HARD + 2
	.byte 0, 0, 0, 0, 0

	.byte TILE_SAVE + SAVE_TILE_APOCALYPSE + 0
	.byte TILE_SAVE + SAVE_TILE_APOCALYPSE + 1
	.byte TILE_SAVE + SAVE_TILE_APOCALYPSE + 2
	.byte TILE_SAVE + SAVE_TILE_APOCALYPSE + 3
	.byte TILE_SAVE + SAVE_TILE_APOCALYPSE + 4
	.byte TILE_SAVE + SAVE_TILE_APOCALYPSE + 5
	.byte TILE_SAVE + SAVE_TILE_APOCALYPSE + 6
	.byte 0

VAR time_tiles
	.byte $f0, $f1, $f2

TILES save_tiles, 1, "tiles/title/save.chr", 32
