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

	sta gen_cur_index
	sta gen_left_index
	sta gen_right_index
	lda #$80
	sta gen_up_index
	sta gen_down_index

	rts
.endproc


PROC map_viewer
	jsr generate_map

	LOAD_PTR game_palette
	jsr fade_in

loop:
	jsr wait_for_vblank
	jsr update_controller
	and #JOY_A
	bne change_base
	lda controller
	and #JOY_LEFT
	bne left
	lda controller
	and #JOY_RIGHT
	bne right
	lda controller
	and #JOY_UP
	bne up
	lda controller
	and #JOY_DOWN
	bne down
	jmp loop

left:
	jsr can_travel_left
	bne loop
	jsr fade_out
	ldx cur_screen_x
	dex
	stx cur_screen_x
	jmp map_viewer

right:
	jsr can_travel_right
	bne loop
	jsr fade_out
	ldx cur_screen_x
	inx
	stx cur_screen_x
	jmp map_viewer

up:
	jsr can_travel_up
	bne loop
	jsr fade_out
	ldy cur_screen_y
	dey
	sty cur_screen_y
	jmp map_viewer

down:
	jsr can_travel_down
	bne loop
	jsr fade_out
	ldy cur_screen_y
	iny
	sty cur_screen_y
	jmp map_viewer

change_base:
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
	ldy gen_cur_index
	iny
	sty gen_cur_index

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
	pha
	ldy gen_up_index
	iny
	sty gen_up_index

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


PROC genrange_left
	pha
	ldy gen_left_index
	iny
	sty gen_left_index

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


PROC genrange_down
	pha
	ldy gen_down_index
	iny
	sty gen_down_index

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
	ldy gen_right_index
	iny
	sty gen_right_index

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


PROC read_overworld_cur
	ldx cur_screen_x
	ldy cur_screen_y
	jsr read_overworld_map
	rts
.endproc


PROC read_overworld_left
	ldx cur_screen_x
	dex
	ldy cur_screen_y
	jsr read_overworld_map
	rts
.endproc


PROC read_overworld_right
	ldx cur_screen_x
	inx
	ldy cur_screen_y
	jsr read_overworld_map
	rts
.endproc


PROC read_overworld_up
	ldx cur_screen_x
	ldy cur_screen_y
	dey
	jsr read_overworld_map
	rts
.endproc


PROC read_overworld_down
	ldx cur_screen_x
	ldy cur_screen_y
	iny
	jsr read_overworld_map
	rts
.endproc


PROC can_travel_up
	jsr read_overworld_up
	and #$80
	rts
.endproc


PROC can_travel_down
	jsr read_overworld_cur
	and #$80
	rts
.endproc


PROC can_travel_left
	jsr read_overworld_left
	and #$40
	rts
.endproc


PROC can_travel_right
	jsr read_overworld_cur
	and #$40
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
	and #$3f
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

VAR gen_cur_index
	.byte 0
VAR gen_left_index
	.byte 0
VAR gen_right_index
	.byte 0
VAR gen_up_index
	.byte 0
VAR gen_down_index
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
	.word gen_cave_interior;gen_forest
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
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $43, $03, $43, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $82, $82, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $03, $83, $c3, $43, $83, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $40
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $02, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $43, $03, $83, $c3, $c1, $c1, $c1, $c1, $03, $43, $c1, $c1, $42
	.byte $c1, $c1, $02, $82, $42, $c1, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $03, $83, $c3, $c1, $c1, $c1, $c1, $c1, $03, $83, $83, $03, $03, $03
	.byte $43, $c1, $42, $82, $02, $82, $c2, $02, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $43, $03, $43, $c1, $c1, $c1, $03, $83, $c3, $03, $43, $03, $03, $43
	.byte $43, $c1, $42, $c1, $c2, $c1, $c1, $c2, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $43, $83, $83, $43, $c1, $03, $43, $c7, $c7, $43, $43, $03, $83, $03
	.byte $43, $c1, $82, $82, $82, $02, $02, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $c3, $03, $43, $03, $03, $03, $c3, $c7, $c7, $c3, $43, $83, $03, $03
	.byte $43, $c1, $c1, $c1, $c1, $c2, $42, $c1, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $03, $03, $03, $03, $c3, $43, $c7, $c7, $c7, $83, $03, $43, $03, $03
	.byte $03, $43, $c1, $02, $82, $02, $c2, $02, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $83, $03, $83, $83, $03, $03, $43, $c7, $c7, $c7, $c7, $43, $43, $03, $43
	.byte $03, $43, $c1, $42, $c1, $82, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $03, $04, $44, $83, $03, $03, $43, $c7, $c7, $c7, $03, $43, $03, $03
	.byte $83, $03, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $43, $06, $04, $c6, $83, $03, $03, $43, $03, $03, $c3, $43, $03, $03
	.byte $03, $43, $03, $83, $83, $83, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $43, $84, $84, $04, $84, $04, $03, $43, $43, $83, $03, $43, $03, $43
	.byte $03, $43, $43, $03, $83, $c5, $03, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $43, $46, $45, $04, $86, $c4, $03, $03, $03, $43, $83, $c3, $03, $03
	.byte $c3, $43, $c3, $83, $03, $c3, $03, $83, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $03, $84, $84, $84, $03, $03, $43, $03, $03, $43, $03, $03, $03, $83
	.byte $c3, $83, $83, $83, $c3, $03, $03, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $83, $03, $03, $03, $03, $83, $83, $03, $03, $83, $03, $03, $03, $03, $03
	.byte $43, $03, $03, $03, $83, $83, $03, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $03, $43, $03, $83, $c7, $c7, $03, $03, $03, $84, $44, $03, $43, $c3
	.byte $43, $03, $83, $c3, $8a, $4a, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $83, $03, $43, $c7, $c7, $c7, $03, $43, $03, $43, $c5, $83, $c3, $03
	.byte $c3, $03, $8a, $8a, $0a, $4a, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $83, $43, $c7, $c7, $c7, $03, $83, $43, $03, $03, $83, $03, $43
	.byte $43, $43, $0a, $8a, $ca, $ca, $43, $02, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $03, $43, $03, $83, $03, $03, $03, $83, $43, $c1, $83, $43
	.byte $03, $43, $8a, $8a, $89, $c8, $43, $42, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $83, $83, $c3, $c1, $83, $03, $03, $03, $c3, $c1, $c1, $03
	.byte $c3, $83, $c3, $03, $83, $83, $c3, $c2, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $83, $83, $c3, $c1, $c1, $c1, $83
	.byte $83, $03, $83, $03, $82, $02, $82, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $83, $83, $c3, $c1, $82, $82, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c2
