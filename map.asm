.include "defines.inc"

.code

PROC init_map
	; Initialize map generators
	ldy #0
genloop:
	lda initial_map_generators, y
	sta map_screen_generators, y
	iny
	cpy #MAP_TYPE_COUNT * 2
	bne genloop

	lda #15
	sta cur_screen_x
	lda #2
	sta cur_screen_y

	rts
.endproc


.segment "FIXED"

PROC get_flag
	jsr disable_rendering
	jsr clear_screen

	; Draw text
	LOAD_PTR flag_strings
	ldx #8
	ldy #11
	jsr write_string
	ldx #1
	ldy #12
	jsr write_string
	ldx #1
	ldy #17
	jsr write_string
	ldx #3
	ldy #18
	jsr write_string

	LOAD_PTR flag_palette
	jsr fade_in

end:
	jmp end
.endproc


.data

VAR flag_palette
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30
	.byte $02, $30, $30, $30


VAR initial_map_generators
	.word start;gen_cave_start
	.word game_over
	.word start;gen_cave_interior
	.word start;gen_forest
	.word start;gen_house
	.word start;gen_shop
	.word start;gen_park
	.word game_over
	.word start;gen_boss
	.word start;gen_base_horde
	.word start;gen_base_interior
	.word game_over
	.word get_flag

VAR map
	.byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 2, 1, 1, 2, 2, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 3, 3, 1, 1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 1, 2, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 3, 3, 1, 1, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 3, 3, 3, 3, 3, 1, 3, 3, 7, 7, 3, 3, 3, 3, 3, 3, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 3, 3, 3, 3, 3, 3, 3, 3, 7, 7, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 3, 3, 3, 3, 3, 3, 3, 7, 7, 7, 3, 3, 3, 3, 3, 3, 3, 1, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 3, 3, 4, 3, 3, 3, 3, 7, 7, 7, 7, 3, 3, 3, 3, 3, 3, 1, 2, 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 4, 4, 3, 3, 3, 3, 7, 7, 7, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 6, 4, 6, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 6, 5, 4, 6, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 3, 3, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,11,11,11, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 3, 3, 4, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,11,10,11, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 3, 3, 3, 7, 7, 3, 3, 3, 3, 4, 3, 3, 3, 3, 3,11,11,11,10,11, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 3, 3, 3, 7, 7, 7, 3, 3, 3, 4, 5, 3, 3, 3, 3, 3,10,10,10,10,11, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 3, 3, 7, 7, 7, 3, 3, 3, 3, 3, 3, 3, 3,11,11,11,10,11,11,11, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 3, 3,11,10,10,10, 9, 8,11, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 3,11,11,11,11,11,11,11, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
	.byte  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,12
