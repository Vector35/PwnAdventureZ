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

	lda #1
	sta cur_screen_x
	lda #16
	sta cur_screen_y

	rts
.endproc


PROC prepare_map_gen
	jsr clear_screen
	jsr clear_tiles

	; Use 8x8 sprites on first CHR page
	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_SIZE | PPUCTRL_NAMETABLE_2C00
	sta ppu_settings

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

	lda #$ff
	sta entrance_x
	sta entrance_y

	rts
.endproc


PROC map_viewer
	jsr generate_map

	jsr save

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


PROC read_collision_at
	tya
	asl
	sta temp
	txa
	lsr
	lsr
	lsr
	ora temp
	tay

	txa
	and #7
	tax
	lda #$80
bitloop:
	cpx #0
	beq bitloopend
	lsr
	dex
	bne bitloop
bitloopend:

	and collision, y
	rts
.endproc


PROC read_collision_left
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	dex
	stx arg0

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	sty arg1

	lda player_y
	and #$f
	beq aligned

	iny
	jsr read_collision_at
	beq done

aligned:
	ldx arg0
	ldy arg1
	jsr read_collision_at

done:
	rts
.endproc


PROC read_collision_left_direct
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	dex

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay

	jsr read_collision_at
	rts
.endproc


PROC read_collision_left_bottom
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	dex

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


PROC read_collision_right
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	inx
	stx arg0

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	sty arg1

	lda player_y
	and #$f
	beq aligned

	iny
	jsr read_collision_at
	beq done

aligned:
	ldx arg0
	ldy arg1
	jsr read_collision_at

done:
	rts
.endproc


PROC read_collision_right_direct
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay

	jsr read_collision_at
	rts
.endproc


PROC read_collision_right_bottom
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


PROC read_collision_up
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	stx arg0

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	dey
	sty arg1

	lda player_x
	and #$f
	beq aligned

	inx
	jsr read_collision_at
	beq done

aligned:
	ldx arg0
	ldy arg1
	jsr read_collision_at

done:
	rts
.endproc


PROC read_collision_up_direct
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	dey

	jsr read_collision_at
	rts
.endproc


PROC read_collision_up_right
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	dey

	jsr read_collision_at
	rts
.endproc


PROC read_collision_down
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	stx arg0

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	iny
	sty arg1

	lda player_x
	and #$f
	beq aligned

	inx
	jsr read_collision_at
	beq done

aligned:
	ldx arg0
	ldy arg1
	jsr read_collision_at

done:
	rts
.endproc


PROC read_collision_down_direct
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


PROC read_collision_down_right
	lda player_x
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda player_y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


PROC read_spawnable_at
	tya
	asl
	sta temp
	txa
	lsr
	lsr
	lsr
	ora temp
	tay

	txa
	and #7
	tax
	lda #$80
bitloop:
	cpx #0
	beq bitloopend
	lsr
	dex
	bne bitloop
bitloopend:

	and spawnable, y
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

	; Initialize traversable tile list
	ldx #0
	lda #0
initloop:
	sta traversable_tiles, x
	inx
	cpx #8
	bne initloop

	; Initialize spawnable tile list
	ldx #0
	lda #$ff
initspawnloop:
	sta spawnable_tiles, x
	inx
	cpx #4
	bne initspawnloop
	lda #0
	sta spawn_ready

	; Initialize interactive tile list
	ldx #0
	lda #INTERACT_NONE
interactloop:
	sta interactive_tile_types, x
	inx
	cpx #6
	bne interactloop
	sta interaction_type

	; Clear enemy list
	ldx #0
	lda #ENEMY_NONE
initenemyloop:
	sta enemy_type, x
	inx
	cpx #ENEMY_MAX_COUNT
	bne initenemyloop

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

	; Zero collision data memory
	ldx #0
	lda #0
zeroloop:
	sta collision, x
	inx
	cpx #32
	bne zeroloop

	; Compute collision data
	ldx #0
	stx arg0
	lda #$80
	sta temp + 1
collisionloop:
	ldy arg0
	lda map_gen_buf, y
	and #$fc
	sta temp

	ldy #0
checktraversable:
	lda traversable_tiles, y
	cmp temp
	beq traversable
	iny
	cpy #8
	bne checktraversable
	jmp nextcollision

traversable:
	lda temp + 1
	ora collision, x
	sta collision, x

nextcollision:
	inc arg0
	lda temp + 1
	lsr
	sta temp + 1
	bne collisionloop
	lda #$80
	sta temp + 1
	inx
	cpx #MAP_HEIGHT * 2
	bne collisionloop

	jsr prepare_spawn

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


PROC prepare_spawn
	lda spawn_ready
	beq notready
	rts

notready:
	; Zero spawning data memory
	ldx #0
	lda #0
zerospawnloop:
	sta spawnable, x
	inx
	cpx #32
	bne zerospawnloop

	; Compute spawning data
	ldx #0
	stx arg0
	lda #$80
	sta temp + 1
spawnableloop:
	ldy arg0
	lda map_gen_buf, y
	and #$fc
	sta temp

	ldy #0
checkspawnable:
	lda spawnable_tiles, y
	cmp temp
	beq canspawn
	iny
	cpy #4
	bne checkspawnable
	jmp nextspawn

canspawn:
	lda temp + 1
	ora spawnable, x
	sta spawnable, x

nextspawn:
	inc arg0
	lda temp + 1
	lsr
	sta temp + 1
	bne spawnableloop
	lda #$80
	sta temp + 1
	inx
	cpx #MAP_HEIGHT * 2
	bne spawnableloop

	lda #1
	sta spawn_ready
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


PROC load_game_palette_0
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 0, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


PROC load_game_palette_1
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 4, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


PROC load_game_palette_2
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 8, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


PROC load_game_palette_3
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 12, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


PROC load_sprite_palette_0
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 16, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


PROC load_sprite_palette_1
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 20, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


PROC load_sprite_palette_2
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 24, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


PROC load_sprite_palette_3
	ldy #0
loadloop:
	lda (ptr), y
	sta game_palette + 28, y
	iny
	cpy #4
	bne loadloop
	rts
.endproc


;arg0 = top x
;arg1 = top y
;arg2 = bot x
;arg3 = bot y
;Fill in inclusive 
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


PROC gen_map_opening_locations
	; Pick random locations for the openings to the next map location, which will also
	; be used to choose different widths of the outer border, giving a non-rectangular
	; appearance
	lda #5
	jsr genrange_up
	clc
	adc #6
	sta top_opening_pos

	lda #5
	jsr genrange_down
	clc
	adc #6
	sta bot_opening_pos

	lda #2
	jsr genrange_left
	clc
	adc #5
	sta left_opening_pos

	lda #2
	jsr genrange_right
	clc
	adc #5
	sta right_opening_pos

	; Pick random widths for openings to next map location
	lda #3
	jsr genrange_up
	clc
	adc #3
	sta top_opening_size

	lda #3
	jsr genrange_down
	clc
	adc #3
	sta bot_opening_size

	lda #3
	jsr genrange_left
	clc
	adc #3
	sta left_opening_size

	lda #3
	jsr genrange_right
	clc
	adc #3
	sta right_opening_size

	rts
.endproc


PROC gen_left_wall_small
	sta arg4

	lda #2
	jsr genrange_cur
	sta arg2
	sta left_wall_top_extent
	lda #0
	sta arg0
	sta arg1
	ldx left_opening_pos
	dex
	stx arg3
	lda arg4
	jsr fill_map_box

	lda #2
	jsr genrange_cur
	sta arg2
	sta left_wall_bot_extent
	lda left_opening_pos
	sta arg1
	lda #MAP_HEIGHT - 1
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_left_wall_large
	sta arg4

	lda #3
	jsr genrange_cur
	sta arg2
	sta left_wall_top_extent
	lda #0
	sta arg0
	sta arg1
	ldx left_opening_pos
	dex
	stx arg3
	lda arg4
	jsr fill_map_box

	lda #3
	jsr genrange_cur
	sta arg2
	sta left_wall_bot_extent
	lda left_opening_pos
	sta arg1
	lda #MAP_HEIGHT - 1
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_right_wall_small
	sta arg4

	lda #2
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_WIDTH
	sec
	sbc temp
	sta arg0
	sta right_wall_top_extent
	lda #MAP_WIDTH
	sta arg2
	lda #0
	sta arg1
	ldx right_opening_pos
	stx arg3
	lda arg4
	jsr fill_map_box

	lda #2
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_WIDTH
	sec
	sbc temp
	sta arg0
	sta right_wall_bot_extent
	lda right_opening_pos
	sta arg1
	lda #MAP_HEIGHT - 1
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_right_wall_large
	sta arg4

	lda #3
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_WIDTH
	sec
	sbc temp
	sta arg0
	sta right_wall_top_extent
	lda #MAP_WIDTH
	sta arg2
	lda #0
	sta arg1
	ldx right_opening_pos
	stx arg3
	lda arg4
	jsr fill_map_box

	lda #3
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_WIDTH
	sec
	sbc temp
	sta arg0
	sta right_wall_bot_extent
	lda right_opening_pos
	sta arg1
	lda #MAP_HEIGHT - 1
	sta arg3
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_top_wall_small
	sta arg4

	lda #2
	jsr genrange_cur
	sta arg3
	sta top_wall_left_extent
	lda #0
	sta arg0
	sta arg1
	ldx top_opening_pos
	dex
	stx arg2
	lda arg4
	jsr fill_map_box

	lda #2
	jsr genrange_cur
	sta arg3
	sta top_wall_right_extent
	lda top_opening_pos
	sta arg0
	lda #MAP_WIDTH - 1
	sta arg2
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_top_wall_large
	sta arg4

	lda #3
	jsr genrange_cur
	sta arg3
	sta top_wall_left_extent
	lda #0
	sta arg0
	sta arg1
	ldx top_opening_pos
	dex
	stx arg2
	lda arg4
	jsr fill_map_box

	lda #3
	jsr genrange_cur
	sta arg3
	sta top_wall_right_extent
	lda top_opening_pos
	sta arg0
	lda #MAP_WIDTH - 1
	sta arg2
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_top_wall_always_thick
	sta arg4

	lda #3
	jsr genrange_cur
	sta arg3
	sta top_wall_left_extent
	lda #0
	sta arg0
	sta arg1
	ldx top_opening_pos
	dex
	stx arg2
	lda arg4
	jsr fill_map_box

	lda #2
	jsr genrange_cur
	clc
	adc #1
	sta arg3
	sta top_wall_right_extent
	lda top_opening_pos
	sta arg0
	lda #MAP_WIDTH - 1
	sta arg2
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_bot_wall_small
	sta arg4

	lda #2
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_HEIGHT
	sec
	sbc temp
	sta arg1
	sta bot_wall_left_extent
	lda #MAP_HEIGHT
	sta arg3
	lda #0
	sta arg0
	ldx bot_opening_pos
	stx arg2
	lda arg4
	jsr fill_map_box

	lda #2
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_HEIGHT
	sec
	sbc temp
	sta arg1
	sta bot_wall_right_extent
	lda bot_opening_pos
	sta arg0
	lda #MAP_WIDTH - 1
	sta arg2
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_bot_wall_large
	sta arg4

	lda #3
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_HEIGHT
	sec
	sbc temp
	sta arg1
	sta bot_wall_left_extent
	lda #MAP_HEIGHT
	sta arg3
	lda #0
	sta arg0
	ldx bot_opening_pos
	stx arg2
	lda arg4
	jsr fill_map_box

	lda #3
	jsr genrange_cur
	clc
	adc #1
	sta temp
	lda #MAP_HEIGHT
	sec
	sbc temp
	sta arg1
	sta bot_wall_right_extent
	lda bot_opening_pos
	sta arg0
	lda #MAP_WIDTH - 1
	sta arg2
	lda arg4
	jsr fill_map_box

	rts
.endproc


PROC gen_walkable_path
	sta arg4

	; Generate top opening
	jsr can_travel_up
	bne notravelup

	lda top_opening_size
	lsr
	sta arg0
	lda top_opening_pos
	sec
	sbc arg0
	sta arg0
	clc
	adc top_opening_size
	adc #$ff
	sta arg2
	lda #0
	sta arg1
	lda left_opening_pos
	cmp right_opening_pos
	bcs topextent
	lda right_opening_pos
topextent:
	sta arg3
	lda arg4
	jsr fill_map_box

notravelup:
	jsr can_travel_down
	bne notraveldown

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
	lda left_opening_pos
	cmp right_opening_pos
	bcs botextent
	lda right_opening_pos
botextent:
	sta arg1
	lda arg4
	jsr fill_map_box

notraveldown:
	jsr can_travel_left
	bne notravelleft

	; Generate left opening
	lda left_opening_size
	lsr
	sta arg1
	lda left_opening_pos
	sec
	sbc arg1
	sta arg1
	clc
	adc left_opening_size
	adc #$ff
	sta arg3
	lda #0
	sta arg0
	lda top_opening_pos
	cmp bot_opening_pos
	bcs leftextent
	lda bot_opening_pos
leftextent:
	sta arg2
	lda arg4
	jsr fill_map_box

notravelleft:
	jsr can_travel_right
	bne notravelright

	; Generate right opening
	lda right_opening_size
	lsr
	sta arg1
	lda right_opening_pos
	sec
	sbc arg1
	sta arg1
	clc
	adc right_opening_size
	adc #$ff
	sta arg3
	lda #MAP_WIDTH - 1
	sta arg2
	lda top_opening_pos
	cmp bot_opening_pos
	bcs rightextent
	lda bot_opening_pos
rightextent:
	sta arg0
	lda arg4
	jsr fill_map_box

notravelright:
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

VAR top_opening_pos
	.byte 0
VAR bot_opening_pos
	.byte 0
VAR left_opening_pos
	.byte 0
VAR right_opening_pos
	.byte 0
VAR top_opening_size
	.byte 0
VAR bot_opening_size
	.byte 0
VAR left_opening_size
	.byte 0
VAR right_opening_size
	.byte 0

VAR left_wall_top_extent
	.byte 0
VAR left_wall_bot_extent
	.byte 0
VAR right_wall_top_extent
	.byte 0
VAR right_wall_bot_extent
	.byte 0
VAR top_wall_left_extent
	.byte 0
VAR top_wall_right_extent
	.byte 0
VAR bot_wall_left_extent
	.byte 0
VAR bot_wall_right_extent
	.byte 0

VAR clutter_count
	.byte 0
VAR clutter_size
	.byte 0

VAR border_type
	.byte 0

VAR traversable_tiles
	.byte 0, 0, 0, 0, 0, 0, 0, 0
VAR spawnable_tiles
	.byte 0, 0, 0, 0

VAR collision
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

VAR spawn_ready
	.byte 0
VAR spawnable
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

VAR entrance_x
	.byte 0
VAR entrance_y
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
	.word gen_forest
	.word start;gen_house
	.word start;gen_shop
	.word start;gen_park
	.word game_over
	.word start;gen_boss
	.word start;gen_base_horde
	.word start;gen_base_interior
	.word gen_blocky_treasure 
	.word gen_blocky_puzzle

VAR map
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $4b, $c1, $c1, $c1, $43, $03, $43, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $82, $82, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $4c, $c1, $03, $83, $c3, $43, $83, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $42
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $02, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $82, $42, $43, $03, $83, $c3, $c1, $c1, $c1, $c1, $03, $43, $c1, $c1, $42
	.byte $c1, $c1, $02, $82, $42, $c1, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $03, $83, $c3, $c1, $c1, $c1, $c1, $c1, $03, $83, $83, $03, $03, $03
	.byte $43, $c1, $42, $82, $02, $82, $c2, $02, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $43, $03, $43, $c1, $c1, $c1, $03, $03, $c3, $03, $43, $03, $03, $43
	.byte $43, $c1, $42, $c1, $c2, $c1, $c1, $c2, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $43, $83, $83, $43, $c1, $03, $03, $c3, $c7, $43, $43, $03, $83, $03
	.byte $43, $c1, $82, $82, $82, $02, $02, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $43, $03, $43, $03, $03, $03, $c3, $c7, $c7, $c3, $43, $83, $03, $03
	.byte $43, $c1, $c1, $c1, $c1, $c2, $42, $c1, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $c3, $03, $03, $03, $c3, $43, $c7, $c7, $c7, $83, $03, $43, $03, $03
	.byte $03, $43, $c1, $02, $82, $02, $c2, $02, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $03, $83, $83, $03, $03, $43, $c7, $c7, $c7, $c7, $43, $43, $03, $43
	.byte $03, $43, $c1, $42, $c1, $82, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $43, $03, $04, $44, $83, $03, $03, $43, $c7, $c7, $c7, $03, $43, $03, $03
	.byte $83, $03, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $43, $06, $04, $c6, $83, $03, $03, $43, $03, $03, $c3, $43, $03, $03
	.byte $03, $43, $03, $83, $83, $83, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $83, $43, $84, $84, $04, $84, $04, $03, $43, $43, $83, $03, $43, $03, $43
	.byte $03, $43, $43, $03, $03, $43, $03, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $43, $46, $45, $04, $86, $c4, $03, $03, $03, $43, $83, $c3, $03, $03
	.byte $c3, $43, $c3, $c3, $43, $c5, $03, $83, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $83, $03, $84, $84, $84, $03, $03, $43, $03, $03, $43, $03, $03, $03, $83
	.byte $c3, $83, $83, $83, $c3, $03, $03, $03, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $83, $43, $03, $03, $83, $83, $03, $03, $83, $03, $03, $03, $03, $03
	.byte $03, $03, $03, $83, $83, $03, $03, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $80, $42, $43, $03, $c3, $c7, $c7, $03, $03, $03, $84, $44, $03, $43, $c3
	.byte $43, $83, $c3, $8a, $4a, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $83, $03, $43, $c7, $c7, $c7, $03, $43, $03, $43, $c5, $83, $c3, $03
	.byte $43, $8a, $8a, $0a, $4a, $43, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $83, $43, $c7, $c7, $03, $03, $83, $43, $03, $03, $83, $03, $43
	.byte $43, $0a, $8a, $ca, $4a, $03, $c3, $02, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $03, $43, $03, $83, $03, $03, $03, $83, $43, $c1, $83, $43
	.byte $43, $4a, $88, $89, $ca, $03, $43, $42, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $83, $83, $c3, $c1, $83, $03, $03, $03, $c3, $c1, $c1, $03
	.byte $83, $83, $c3, $03, $83, $83, $c3, $c2, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $83, $83, $c3, $c1, $c1, $c1, $83
	.byte $83, $03, $83, $03, $43, $02, $02, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $83, $83, $83, $83, $c3, $82, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c2
