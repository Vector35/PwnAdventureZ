;   This file is part of Pwn Adventure Z.

;   Pwn Adventure Z is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.

;   Pwn Adventure Z is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.

;   You should have received a copy of the GNU General Public License
;   along with Pwn Adventure Z.  If not, see <http://www.gnu.org/licenses/>.

.include "defines.inc"

.define TILE_UI    $00
.define TILE_SAVE  $80
.define TILE_BLOCK $f0


.segment "FIXED"

PROC save_select
	lda current_bank
	pha
	lda #^save_select_worker
	jsr bankswitch
	jsr save_select_worker & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC enter_name
	lda current_bank
	pha
	lda #^enter_name_worker
	jsr bankswitch
	jsr enter_name_worker & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "CHR1"

PROC save_select_worker
	jsr clear_screen
	jsr clear_tiles

	LOAD_ALL_TILES TILE_UI, title_tiles
	LOAD_ALL_TILES TILE_SAVE, save_tiles

	; Draw UI box for save select
	lda #3
	sta arg0
	lda #8
	sta arg1
	lda #27
	sta arg2
	lda #19
	sta arg3
	jsr draw_large_box

	LOAD_PTR save_select_title
	ldx #8
	ldy #8
	jsr write_string

	lda #2
	sta arg0
	lda #4
	sta arg1
	lda #14
	sta arg2
	lda #10
	sta arg3
	lda #0
	sta arg4
	jsr set_box_palette

	lda #3
	sta arg0
	lda #5
	sta arg1
	lda #4
	sta arg2
	lda #7
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #5
	sta arg0
	lda #5
	sta arg1
	lda #11
	sta arg2
	lda #7
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	lda #4
	sta arg0
	lda #8
	sta arg1
	lda #11
	sta arg2
	lda #8
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
	adc #10
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
	adc #10
	tay
	jsr write_string

	jmp nextslot & $ffff

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

	lda $6c00 + SAVE_HEADER_DIFFICULTY, y
	sta difficulty
	lda $6c00 + SAVE_HEADER_KEY_COUNT, y
	sta key_count

	tya
	pha

	ldx #0
nameloop:
	lda $6c00 + SAVE_HEADER_NAME, y
	sta name, x
	inx
	iny
	cpx #14
	bne nameloop

	pla
	tay
	ldx #0
timeloop:
	lda $6c00 + SAVE_HEADER_TIME_PLAYED, y
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
	adc #10
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
	adc #11
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
	adc #11
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
	lda arg0
	asl
	asl
	asl
	asl
	asl
	asl
	sta temp
	lda arg0
	lsr
	lsr
	ora #$e
	sta temp + 1
	lda #3
	jsr copy_tiles

	; Show time played text
	lda arg0
	asl
	asl
	ora #$e0
	tax
	stx scratch
	inx
	stx scratch + 1
	inx
	stx scratch + 2
	LOAD_PTR scratch
	ldx #21
	lda arg0
	asl
	clc
	adc #11
	tay
	lda #3
	jsr write_tiles

nextslot:
	ldy arg0
	iny
	sty arg0
	cpy #3
	beq savedone
	jmp gameloop & $ffff

savedone:
	LOAD_PTR delete_str
	ldx #9
	ldy #17
	jsr write_string

	; Use 8x8 sprites on first CHR page
	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_PATTERN | PPUCTRL_NAMETABLE_2C00
	sta ppu_settings

	LOAD_PTR save_select_palette
	jsr fade_in

	lda #0
	sta active_save_slot
	lda #0
	sta delete_mode

	jsr draw_save_arrows & $ffff

selectloop:
	jsr wait_for_vblank

	jsr update_controller
	and #JOY_START
	bne activate
	lda controller
	and #JOY_A
	bne activate
	lda controller
	and #JOY_UP
	bne up
	lda controller
	and #JOY_DOWN
	bne down
	jmp selectloop & $ffff

up:
	PLAY_SOUND_EFFECT effect_uimove

	jsr erase_save_arrows & $ffff

	ldx active_save_slot
	dex
	stx active_save_slot
	cpx #$ff
	bne movedone
	lda #3
	sta active_save_slot
	jmp movedone & $ffff

down:
	PLAY_SOUND_EFFECT effect_uimove

	jsr erase_save_arrows & $ffff

	ldx active_save_slot
	inx
	stx active_save_slot
	cpx #4
	bne movedone
	lda #0
	sta active_save_slot
	jmp movedone & $ffff

movedone:
	jsr draw_save_arrows & $ffff

waitfordepress:
	jsr wait_for_vblank
	jsr update_controller
	and #JOY_UP | JOY_DOWN | JOY_START | JOY_A
	bne waitfordepress
	jmp selectloop & $ffff

activate:
	lda active_save_slot
	cmp #3
	bne activateslot

	; Delete mode was selected, toggle delete mode
	PLAY_SOUND_EFFECT effect_select

	lda delete_mode
	eor #1
	sta delete_mode
	beq exitdeletemode

	; Change the palette to red to indicate delete mode is active
	jsr wait_for_vblank
	LOAD_PTR delete_palette
	lda #1
	jsr load_single_palette
	jsr prepare_for_rendering

	; Change delete mode text to show method of exiting delete mode
	jsr wait_for_vblank
	LOAD_PTR cancel_delete_str
	ldx #9
	ldy #17
	jsr write_string
	jsr prepare_for_rendering
	jmp waitfordepress & $ffff

exitdeletemode:
	; Change the palette to normal to indicate delete mode is inactive
	jsr wait_for_vblank
	LOAD_PTR save_select_palette + 4
	lda #1
	jsr load_single_palette
	jsr prepare_for_rendering

	; Change delete mode text to show method of reentering delete mode
	jsr wait_for_vblank
	LOAD_PTR delete_str
	ldx #9
	ldy #17
	jsr write_string
	jsr prepare_for_rendering
	jmp waitfordepress & $ffff

activateslot:
	lda delete_mode
	beq done

	; Slot activated in delete mode, clear the slot
	lda active_save_slot
	jsr clear_slot

	; Modify slot UI to show new game
	jsr wait_for_vblank
	LOAD_PTR new_game_str
	ldx #10
	lda active_save_slot
	asl
	clc
	adc #10
	tay
	jsr write_string
	jsr prepare_for_rendering

	jsr wait_for_vblank
	LOAD_PTR clear_game_desc_str
	ldx #10
	lda active_save_slot
	asl
	clc
	adc #11
	tay
	jsr write_string
	jsr prepare_for_rendering

	jmp selectloop & $ffff

done:
	; A valid slot has been selected, proceed to start the game
	PLAY_SOUND_EFFECT effect_select

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


PROC get_y_for_save_slot
	lda active_save_slot
	cmp #3
	beq delete
	asl
	clc
	adc #10
	tay
	rts

delete:
	ldy #17
	rts
.endproc


PROC draw_save_arrows
	jsr wait_for_vblank

	jsr get_y_for_save_slot & $ffff
	LOAD_PTR right_arrow_str
	ldx #5
	jsr write_string

	jsr get_y_for_save_slot & $ffff
	LOAD_PTR left_arrow_str
	ldx #25
	jsr write_string

	jsr prepare_for_rendering
	rts
.endproc


PROC erase_save_arrows
	jsr wait_for_vblank

	jsr get_y_for_save_slot & $ffff
	LOAD_PTR space_str
	ldx #5
	jsr write_string

	jsr get_y_for_save_slot & $ffff
	LOAD_PTR space_str
	ldx #25
	jsr write_string

	jsr prepare_for_rendering
	rts
.endproc


PROC enter_name_worker
	; Put a placeholder name in for now until UI is implemented
	jsr clear_screen
	jsr clear_tiles

	; Use 8x8 sprites on first CHR page
	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_PATTERN | PPUCTRL_NAMETABLE_2C00
	sta ppu_settings

	LOAD_ALL_TILES TILE_UI, title_tiles
	LOAD_ALL_TILES TILE_BLOCK, block_tile

	; Draw UI box for name entry
	lda #2
	sta arg0
	lda #8
	sta arg1
	lda #27
	sta arg2
	lda #19
	sta arg3
	jsr draw_large_box

	lda #2
	sta arg0
	lda #5
	sta arg1
	lda #12
	sta arg2
	lda #5
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #2
	sta arg0
	lda #6
	sta arg1
	lda #12
	sta arg2
	lda #8
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	LOAD_PTR name_entry_title
	ldx #8
	ldy #8
	jsr write_string

	; Draw on-screen keyboard
	LOAD_PTR char_line_1_str
	ldx #5
	ldy #12
	jsr write_string
	ldx #5
	ldy #13
	jsr write_string
	ldx #5
	ldy #14
	jsr write_string
	ldx #5
	ldy #15
	jsr write_string
	ldx #5
	ldy #17
	jsr write_string

	LOAD_PTR save_select_palette
	jsr fade_in

	lda #0
	sta name_entry_pos
	sta name_entry_line
	sta name_entry_col
	jsr draw_name_entry_block & $ffff
	jsr draw_name_entry_arrows & $ffff

selectloop:
	jsr wait_for_vblank
	jsr update_controller
	and #JOY_START
	bne startpressed
	lda controller
	and #JOY_A
	bne activate
	lda controller
	and #JOY_B
	bne deletepressed
	lda controller
	and #JOY_LEFT
	bne leftpressed
	lda controller
	and #JOY_RIGHT
	bne rightpressed
	lda controller
	and #JOY_UP
	bne uppressed
	lda controller
	and #JOY_DOWN
	bne downpressed
	jmp selectloop & $ffff

startpressed:
	jmp done & $ffff
deletepressed:
	jmp delete & $ffff
leftpressed:
	jmp left & $ffff
rightpressed:
	jmp right & $ffff
uppressed:
	jmp up & $ffff
downpressed:
	jmp down & $ffff

activate:
	lda name_entry_line
	cmp #4
	beq activatebottom

	; Normal character, get character and add it to string
	lda name_entry_line
	asl
	asl
	asl
	asl
	ora name_entry_col
	tax
	lda name_entry_chars & $ffff, x

addchar:
	; Don't allow overflow
	ldx name_entry_pos
	cpx #14
	bne nottoolong
	jmp waitfordepress & $ffff
nottoolong:
	sta name, x
	inx
	stx name_entry_pos
	jmp updatename & $ffff

activatebottom:
	lda name_entry_col
	cmp #0
	beq delete
	cmp #1
	beq space
	jmp done & $ffff

space:
	lda #' '
	jmp addchar & $ffff

updatename:
	PLAY_SOUND_EFFECT effect_select

	jsr wait_for_vblank
	LOAD_PTR name
	ldx #7
	ldy #10
	jsr write_string
	jsr prepare_for_rendering
	jsr draw_name_entry_block & $ffff
	jmp waitfordepress & $ffff

delete:
	; Don't delete if empty
	lda name_entry_pos
	cmp #0
	bne deleteok
	jmp waitfordepress & $ffff

deleteok:
	ldx name_entry_pos
	dex
	stx name_entry_pos
	lda #0
	sta name, x

	PLAY_SOUND_EFFECT effect_select

	jsr draw_name_entry_block & $ffff
	jmp waitfordepress & $ffff

left:
	PLAY_SOUND_EFFECT effect_uimove

	jsr erase_name_entry_arrows & $ffff
	ldx name_entry_col
	ldy name_entry_line
	cpy #4
	beq leftonbottom
	dex
	stx name_entry_col
	cpx #$ff
	beq leftwrap
	jmp movedone & $ffff
leftwrap:
	ldx #9
	stx name_entry_col
	jmp movedone & $ffff
leftonbottom:
	dex
	stx name_entry_col
	cpx #$ff
	beq leftbottomwrap
	jmp movedone & $ffff
leftbottomwrap:
	ldx #2
	stx name_entry_col
	jmp movedone & $ffff

right:
	PLAY_SOUND_EFFECT effect_uimove

	jsr erase_name_entry_arrows & $ffff
	ldx name_entry_col
	ldy name_entry_line
	cpy #4
	beq rightonbottom
	inx
	stx name_entry_col
	cpx #10
	beq rightwrap
	jmp movedone & $ffff
rightwrap:
	ldx #0
	stx name_entry_col
	jmp movedone & $ffff
rightonbottom:
	inx
	stx name_entry_col
	cpx #3
	beq rightbottomwrap
	jmp movedone & $ffff
rightbottomwrap:
	ldx #0
	stx name_entry_col
	jmp movedone & $ffff

up:
	PLAY_SOUND_EFFECT effect_uimove

	jsr erase_name_entry_arrows & $ffff
	ldy name_entry_line
	cpy #4
	beq upfrombottom
	dey
	sty name_entry_line
	cpy #$ff
	beq upwrap
	jmp movedone & $ffff
upwrap:
	ldy #4
	sty name_entry_line
	jmp movetobottom & $ffff
upfrombottom:
	dey
	sty name_entry_line
	jmp movefrombottom & $ffff

down:
	PLAY_SOUND_EFFECT effect_uimove

	jsr erase_name_entry_arrows & $ffff
	ldy name_entry_line
	cpy #4
	beq downfrombottom
	iny
	sty name_entry_line
	cpy #4
	bne movedone
	sty name_entry_line
	jmp movetobottom & $ffff
downfrombottom:
	ldy #0
	sty name_entry_line
	jmp movefrombottom & $ffff

movetobottom:
	ldx name_entry_col
	cpx #3
	bcs tobottomnotdelete
	ldx #0
	stx name_entry_col
	jmp movedone & $ffff
tobottomnotdelete:
	cpx #8
	bcs tobottomnotspace
	ldx #1
	stx name_entry_col
	jmp movedone & $ffff
tobottomnotspace:
	ldx #2
	stx name_entry_col
	jmp movedone & $ffff

movefrombottom:
	ldx name_entry_col
	cpx #0
	bne frombottomnotdelete
	ldx #1
	stx name_entry_col
	jmp movedone & $ffff
frombottomnotdelete:
	cpx #1
	bne frombottomnotspace
	ldx #5
	stx name_entry_col
	jmp movedone & $ffff
frombottomnotspace:
	ldx #8
	stx name_entry_col
	jmp movedone & $ffff

movedone:
	jsr draw_name_entry_arrows & $ffff
	jmp waitfordepress & $ffff

waitfordepress:
	jsr wait_for_vblank
	jsr update_controller
	bne waitfordepress
	jmp selectloop & $ffff

done:
	; Don't allow empty input
	lda name_entry_pos
	bne notblank
	jmp waitfordepress & $ffff
notblank:

	; Name entry completed, start game
	PLAY_SOUND_EFFECT effect_select

	jsr fade_out
	jsr clear_screen
	rts
.endproc


PROC draw_name_entry_block
	jsr wait_for_vblank

	LOAD_PTR block_str
	lda name_entry_pos
	clc
	adc #7
	tax
	ldy #10
	jsr write_string

	jsr prepare_for_rendering
	rts
.endproc


PROC get_left_pos_for_name_char
	lda name_entry_line
	clc
	adc #12
	tay
	cmp #16
	beq bottom

	lda name_entry_col
	asl
	clc
	adc #4
	tax
	rts

bottom:
	iny
	lda name_entry_col
	cmp #1
	beq space
	cmp #2
	beq done

	ldx #4
	rts

space:
	ldx #12
	rts

done:
	ldx #19
	rts
.endproc


PROC get_right_pos_for_name_char
	lda name_entry_line
	clc
	adc #12
	tay
	cmp #16
	beq bottom

	lda name_entry_col
	asl
	clc
	adc #6
	tax
	rts

bottom:
	iny
	lda name_entry_col
	cmp #1
	beq space
	cmp #2
	beq done

	ldx #11
	rts

space:
	ldx #18
	rts

done:
	ldx #24
	rts
.endproc


PROC draw_name_entry_arrows
	jsr wait_for_vblank

	LOAD_PTR right_arrow_str
	jsr get_left_pos_for_name_char & $ffff
	jsr write_string
	LOAD_PTR left_arrow_str
	jsr get_right_pos_for_name_char & $ffff
	jsr write_string

	jsr prepare_for_rendering
	rts
.endproc


PROC erase_name_entry_arrows
	jsr wait_for_vblank

	LOAD_PTR space_str
	jsr get_left_pos_for_name_char & $ffff
	jsr write_string
	LOAD_PTR space_str
	jsr get_right_pos_for_name_char & $ffff
	jsr write_string

	jsr prepare_for_rendering
	rts
.endproc


.segment "FIXED"

PROC copy_number_tiles_to_temp_area
	lda current_bank
	pha

	lda #1
	jsr bankswitch

	ldx #0
copyloop:
	lda 0 + (save_tiles & $ffff) + (SAVE_TILE_NUMBERS * 16), x
	sta sprites + $40, x
	inx
	cpx #$b0
	bne copyloop

	pla
	jsr bankswitch
	rts
.endproc


.segment "TEMP"
VAR delete_mode
	.byte 0

VAR name_entry_pos
	.byte 0
VAR name_entry_line
	.byte 0
VAR name_entry_col
	.byte 0


.segment "CHR1"

VAR save_select_palette
	.byte $0f, $21, $31, $37
	.byte $0f, $26, $37, $30
	.byte $0f, $21, $31, $26
	.byte $0f, $21, $31, $31
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30

VAR delete_palette
	.byte $0f, $16, $26, $26

VAR save_select_title
	.byte $3b, " SAVE SELECT ", $3d, 0

VAR slot_str
	.byte "1: ", 0
	.byte "2: ", 0
	.byte "3: ", 0

VAR new_game_str
	.byte $2a, $2a, " NEW GAME ", $2a, $2a, 0

VAR clear_game_desc_str
	.byte "              ", 0

VAR delete_str
	.byte "DELETE A GAME", 0
VAR cancel_delete_str
	.byte "STOP DELETING", 0

VAR left_arrow_str
	.byte $23, 0

VAR right_arrow_str
	.byte $25, 0

VAR space_str
	.byte ' ', 0

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

VAR name_entry_title
	.byte $3b, " ENTER NAME ", $3d, 0

VAR block_str
	.byte TILE_BLOCK, ' ', 0

VAR char_line_1_str
	.byte "Q W E R T Y U I O P", 0
VAR char_line_2_str
	.byte "A S D F G H J K L -", 0
VAR char_line_3_str
	.byte "Z X C V B N M , . /", 0
VAR char_line_4_str
	.byte "1 2 3 4 5 6 7 8 9 0", 0
VAR char_line_5_str
	.byte "DELETE  SPACE  DONE", 0

VAR name_entry_chars
	.byte "QWERTYUIOP", 0, 0, 0, 0, 0, 0
	.byte "ASDFGHJKL-", 0, 0, 0, 0, 0, 0
	.byte "ZXCVBNM,./", 0, 0, 0, 0, 0, 0
	.byte "1234567890", 0, 0, 0, 0, 0, 0

TILES save_tiles, 1, "tiles/title/save.chr", 32
TILES block_tile, 1, "tiles/title/block.chr", 1
