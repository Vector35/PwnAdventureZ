.include "defines.inc"

.code

PROC gen_blocky_puzzle
	LOAD_ALL_TILES $080, cave_border_tiles
	LOAD_ALL_TILES $0c0, bigdoor_tiles

	; Load cave palette
	LOAD_PTR cave_palette
	jsr load_background_game_palette

	lsr gen_map_opening_locations
	; Generate the sides of the cave wall
	lda #$80 + BORDER_CENTER
	jsr gen_left_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_right_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_top_wall_bigdoor
	lda #$80 + BORDER_CENTER
	jsr gen_bot_wall_1

	lda #0
	jsr gen_walkable_bot_path


	lda #$80
	jsr process_border_sides
	rts
.endproc

PROC gen_blocky_treasure
	LOAD_ALL_TILES $080, cave_border_tiles
	LOAD_ALL_TILES $0c0, treasure_tiles
	; Load cave palette
	LOAD_PTR cave_palette
	jsr load_background_game_palette

	lsr gen_map_opening_locations
	; Generate the sides of the cave wall
	lda #$80 + BORDER_CENTER
	jsr gen_left_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_right_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_top_wall_1
	lda #$80 + BORDER_CENTER
	jsr gen_bot_wall_bigdoor

	lda #$80
	jsr process_border_sides


	; Now place the treasure chest

	ldx #7
	ldy #2
	lda #$c0
	jsr write_gen_map

	rts
.endproc

PROC gen_left_wall_1
	sta arg4

	lda #0
	sta left_wall_top_extent
	sta left_wall_bot_extent
	sta arg0
	lda #0
	sta arg1
	lda #0
	sta arg2
	lda #MAP_HEIGHT-1
	sta arg3

	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_right_wall_1
	sta arg4

	lda #MAP_WIDTH-1
	sta left_wall_top_extent
	sta left_wall_bot_extent
	sta arg0
	lda #0
	sta arg1
	lda #MAP_WIDTH-1
	sta arg2
	lda #MAP_HEIGHT-1
	sta arg3

	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_top_wall_1
	sta arg4

	lda #1
	sta top_wall_left_extent
	sta top_wall_right_extent

	lda #0
	sta arg1
	lda #0
	sta arg3
	lda #0
	sta arg0
	lda #MAP_WIDTH-1
	sta arg2
	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_top_wall_bigdoor
	sta arg4

	lda #1
	sta top_wall_left_extent
	sta top_wall_right_extent

	lda #0
	sta arg1
	lda #0
	sta arg3
	lda #0
	sta arg0
	lda #5
	sta arg2
	lda arg4
	jsr fill_map_box

	; Write our door here
	ldx #6
	ldy #0
	lda #$c0
	jsr write_gen_map
	
	ldx #7
	ldy #0
	lda #$c4
	jsr write_gen_map

	ldx #8
	ldy #0
	lda #$c8
	jsr write_gen_map

	lda #9
	sta arg0
	lda #0
	sta arg1
	lda #MAP_WIDTH-1
	sta arg2
	lda #0
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc

PROC gen_bot_wall_bigdoor
	sta arg4

	lda #MAP_HEIGHT-1
	sta arg1

	sta bot_wall_left_extent
	sta bot_wall_right_extent
	lda #MAP_HEIGHT
	sta arg3
	lda #0
	sta arg0
	lda #5
	sta arg2
	lda arg4
	jsr fill_map_box

	lda #9
	sta arg0
	lda #MAP_HEIGHT-1
	sta arg1
	lda #MAP_WIDTH-1
	sta arg2
	lda #MAP_HEIGHT-1
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc

PROC gen_bot_wall_1
	sta arg4

	lda #MAP_HEIGHT-1
	sta arg1

	sta bot_wall_left_extent
	sta bot_wall_right_extent
	lda #MAP_HEIGHT
	sta arg3
	lda #0
	sta arg0
	lda #MAP_WIDTH-1
	sta arg2
	lda arg4
	jsr fill_map_box
	rts
.endproc

PROC gen_walkable_bot_path
	sta arg4

	; Generate bottom opening
	lda bot_opening_size
	lsr
	sta arg0
	lda bot_opening_pos
	sec
	sbc arg0
	sta arg0
	clc
	adc bot_opening_size
	adc #$ff
	sta arg2
	lda #MAP_HEIGHT - 1
	sta arg3
	sta arg1
	lda arg4
	jsr fill_map_box

	rts
.endproc

TILES bigdoor_tiles, 2, "tiles/cave/bigdoor.chr", 48
TILES treasure_tiles, 2, "tiles/cave/chest.chr", 8
