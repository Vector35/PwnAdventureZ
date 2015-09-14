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


PROC prepare_map_gen
	jsr clear_screen
	jsr clear_tiles

	ldy #0
	lda #0
clearloop:
	sta map_gen_buf, y
	iny
	bne clearloop

	sta gen_index

	rts
.endproc


PROC map_viewer
	jsr generate_map

	LOAD_PTR game_palette
	jsr fade_in

loop:
	jsr wait_for_vblank
	jsr update_controller
	lda controller
	and #JOY_START
	beq loop

	jsr fade_out

	ldx gen_base
	inx
	stx gen_base
	jmp map_viewer
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


PROC genrange_cur
	pha
	ldy gen_index
	iny
	sty gen_index

	tya
	ldx cur_screen_x
	ldy cur_screen_y
	jsr gen8
	tay

	pla
	tax
	tya
	jsr mod8
	rts
.endproc


PROC genrange_up
	jmp genrange_cur
.endproc


PROC genrange_left
	jmp genrange_cur
.endproc


PROC genrange_down
	pha
	ldy gen_index
	iny
	sty gen_index

	tya
	ldx cur_screen_x
	ldy cur_screen_y
	iny
	jsr gen8
	tay

	pla
	tax
	tya
	jsr mod8
	rts
.endproc


PROC genrange_right
	pha
	ldy gen_index
	iny
	sty gen_index

	tya
	ldx cur_screen_x
	inx
	ldy cur_screen_y
	jsr gen8
	tay

	pla
	tax
	tya
	jsr mod8
	rts
.endproc


PROC read_overworld_map
	txa
	pha
	tya
	pha

	lsr
	lsr
	lsr
	and #3
	sta ptr + 1

	tya
	ror
	ror
	ror
	ror
	and #$e0
	sta temp
	txa
	ora temp
	clc
	adc #<map
	sta ptr
	lda ptr + 1
	adc #>map
	sta ptr + 1

	ldy #0
	lda (ptr), y
	sta temp

	pla
	tay
	pla
	tax
	lda temp
	rts
.endproc


PROC read_gen_map
	txa
	pha
	tya
	pha

	asl
	asl
	asl
	asl
	sta temp
	txa
	clc
	adc temp
	tay
	lda map_gen_buf, y
	sta temp

	pla
	tay
	pla
	tax
	lda temp
	rts
.endproc


PROC write_gen_map
	pha
	sta temp + 1
	txa
	pha
	tya
	pha

	asl
	asl
	asl
	asl
	sta temp
	txa
	clc
	adc temp
	tay
	lda temp + 1
	sta map_gen_buf, y

	pla
	tay
	pla
	tax
	pla
	rts
.endproc


PROC generate_map
	jsr prepare_map_gen

	ldx cur_screen_x
	ldy cur_screen_y
	jsr read_overworld_map

	; Call map generator function
	asl
	tay
	lda map_screen_generators, y
	sta ptr
	lda map_screen_generators + 1, y
	sta ptr + 1
	jsr call_ptr

	; Write generated tiles to screen
	ldy #0
writeloop:
	tya
	sta arg0

	lda map_gen_buf, y
	sta arg1

	; Set palette for the tile based on the bottom 2 bits of the map data
	lda arg0
	lsr
	lsr
	lsr
	lsr
	tay
	cpy #MAP_HEIGHT
	beq endwrite
	lda arg0
	and #15
	tax
	cpx #MAP_WIDTH
	beq nextwrite
	lda arg1
	and #3
	jsr set_tile_palette

	; Write tile data
	lda arg0
	lsr
	lsr
	lsr
	and #$1e
	tay
	pha
	lda arg0
	asl
	and #$1e
	tax
	pha
	jsr set_ppu_addr_to_coord

	lda arg1
	and #$fc
	sta PPUDATA
	ora #$02
	sta PPUDATA

	pla
	tax
	pla
	tay
	iny
	jsr set_ppu_addr_to_coord

	lda arg1
	and #$fc
	ora #$01
	sta PPUDATA
	ora #$02
	sta PPUDATA

nextwrite:
	ldy arg0
	iny
	bne writeloop

endwrite:
	; Clear sprite memory
	ldy #0
	lda #$ff
clearsprites:
	sta sprites, y
	iny
	bne clearsprites

	rts
.endproc


PROC load_background_game_palette
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette, y
	iny
	cpy #16
	bne loadloop
	rts
.endproc


PROC fill_map_box
	ldy arg1
yloop:
	ldx arg0
xloop:
	jsr write_gen_map
	cpx arg2
	beq nexty
	inx
	jmp xloop

nexty:
	cpy arg3
	beq end
	iny
	jmp yloop

end:
	rts
.endproc


.bss
VAR game_palette
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0

VAR gen_index
	.byte 0


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
	.word gen_cave_start
	.word game_over
	.word gen_cave_interior
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
