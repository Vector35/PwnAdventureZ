.include "defines.inc"


.segment "FIXED"

PROC activate_overworld_map
	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #^normal_overworld_map
	sta map_bank
	lda #<normal_overworld_map
	sta map_ptr
	lda #>normal_overworld_map
	sta map_ptr + 1
	rts

hard:
veryhard:
	lda #^hard_overworld_map
	sta map_bank
	lda #<hard_overworld_map
	sta map_ptr
	lda #>hard_overworld_map
	sta map_ptr + 1
	rts
.endproc


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

	jsr activate_overworld_map

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #1
	sta cur_screen_x
	sta spawn_screen_x
	lda #17
	sta cur_screen_y
	sta spawn_screen_y
	lda #0
	sta spawn_inside

	jmp initvisited

hard:
veryhard:
	lda #7
	sta cur_screen_x
	sta spawn_screen_x
	lda #11
	sta cur_screen_y
	sta spawn_screen_y
	lda #0
	sta spawn_inside

	jmp initvisited

initvisited:
	lda #<overworld_visited
	sta map_visited_ptr
	lda #>overworld_visited
	sta map_visited_ptr + 1

	lda secret_code
	beq nocode

	lda #$ff
	ldx #0
revealmaploop:
	sta overworld_visited, x
	inx
	cpx #88
	bne revealmaploop

nocode:
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
	lda #0
	sta entrance_down

	rts
.endproc


PROC map_viewer
	jsr generate_map

	lda #$0f
	ldy #16
spritepalloop:
	sta game_palette, y
	iny
	cpy #32
	bne spritepalloop

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


PROC read_projectile_collision_at
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

	and projectile_collision, y
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


PROC read_enemy_collision_left
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	dex
	stx arg0

	lda enemy_y, y
	pha
	lsr
	lsr
	lsr
	lsr
	tay
	sty arg1

	pla
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


PROC read_enemy_collision_left_direct
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	dex

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay

	jsr read_collision_at
	rts
.endproc


PROC read_enemy_collision_left_bottom
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	dex

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


PROC read_enemy_collision_right
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	inx
	stx arg0

	lda enemy_y, y
	pha
	lsr
	lsr
	lsr
	lsr
	tay
	sty arg1

	pla
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


PROC read_enemy_collision_right_direct
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay

	jsr read_collision_at
	rts
.endproc


PROC read_enemy_collision_right_bottom
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


PROC read_enemy_collision_up
	ldy cur_enemy
	lda enemy_x, y
	pha
	lsr
	lsr
	lsr
	lsr
	tax
	stx arg0

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	dey
	sty arg1

	pla
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


PROC read_enemy_collision_up_direct
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	dey

	jsr read_collision_at
	rts
.endproc


PROC read_enemy_collision_up_right
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	dey

	jsr read_collision_at
	rts
.endproc


PROC read_enemy_collision_down
	ldy cur_enemy
	lda enemy_x, y
	pha
	lsr
	lsr
	lsr
	lsr
	tax
	stx arg0

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	iny
	sty arg1

	pla
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


PROC read_enemy_collision_down_direct
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


PROC read_enemy_collision_down_right
	ldy cur_enemy
	lda enemy_x, y
	lsr
	lsr
	lsr
	lsr
	tax
	inx

	lda enemy_y, y
	lsr
	lsr
	lsr
	lsr
	tay
	iny

	jsr read_collision_at
	rts
.endproc


.segment "FIXED"

PROC read_water_collision_at
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

	and water_collision, y
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


PROC get_flag
	jsr disable_rendering
	jsr clear_screen

	LOAD_ALL_TILES $0, inventory_ui_tiles

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
	jsr wait_for_vblank
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
	sta temp

	lda current_bank
	pha
	lda map_bank
	jsr bankswitch

	lda temp
	tay
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
	adc map_ptr
	sta ptr
	lda ptr + 1
	adc map_ptr + 1
	sta ptr + 1

	ldy #0
	lda (ptr), y
	sta temp

	pla
	jsr bankswitch

	pla
	tay
	pla
	tax
	lda temp
	rts
.endproc


PROC read_overworld_map_known_bank
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
	adc map_ptr
	sta ptr
	lda ptr + 1
	adc map_ptr + 1
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


PROC mark_visited
	tya
	asl
	asl
	sta temp
	txa
	lsr
	lsr
	lsr
	clc
	adc temp
	tay

	txa
	and #7
	tax

	lda (map_visited_ptr), y
	ora toggle_mask, x
	sta (map_visited_ptr), y
	rts
.endproc


PROC generate_map
	jsr prepare_map_gen
	jsr init_player_sprites

	ldx cur_screen_x
	dex
	ldy cur_screen_y
	dey
	jsr mark_visited

	ldx cur_screen_x
	ldy cur_screen_y
	dey
	jsr mark_visited

	ldx cur_screen_x
	inx
	ldy cur_screen_y
	dey
	jsr mark_visited

	ldx cur_screen_x
	dex
	ldy cur_screen_y
	jsr mark_visited

	ldx cur_screen_x
	ldy cur_screen_y
	jsr mark_visited

	ldx cur_screen_x
	inx
	ldy cur_screen_y
	jsr mark_visited

	ldx cur_screen_x
	dex
	ldy cur_screen_y
	iny
	jsr mark_visited

	ldx cur_screen_x
	ldy cur_screen_y
	iny
	jsr mark_visited

	ldx cur_screen_x
	inx
	ldy cur_screen_y
	iny
	jsr mark_visited

	lda #0
	sta horde_active
	sta horde_complete

	lda #0
	sta warp_to_new_screen

	; Initialize traversable tile list
	ldx #0
	lda #0
initloop:
	sta traversable_tiles, x
	inx
	cpx #8
	bne initloop

	lda #$ff
	sta traversable_range_min
	lda #0
	sta traversable_range_max

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

	lda #$ff
	sta spawnable_range_min
	lda #0
	sta spawnable_range_max

	; Initialize interactive tile list
	ldx #0
	lda #INTERACT_NONE
interactloop:
	sta interactive_tile_types, x
	inx
	cpx #6
	bne interactloop
	sta interaction_type

	lda #$ff
	sta water_tile_start
	sta water_tile_end

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
	sta projectile_collision, x
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

	lda temp
	cmp traversable_range_min
	bcc nottraversablerange
	cmp traversable_range_max
	bcc traversable
nottraversablerange:

	ldy #0
checktraversable:
	lda traversable_tiles, y
	cmp temp
	beq traversable
	iny
	cpy #8
	bne checktraversable
	jmp nottraversable

traversable:
	lda temp + 1
	ora collision, x
	sta collision, x
	lda temp + 1
	ora projectile_collision, x
	sta projectile_collision, x
	jmp nextcollision

nottraversable:
	lda temp
	cmp water_tile_start
	bcc nextcollision
	cmp water_tile_end
	bcs nextcollision

	lda temp + 1
	ora projectile_collision, x
	sta projectile_collision, x

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

	; Ensure column 15 (which is not visible) is never marked as traversable
	ldy #0
lastcolloop:
	lda collision + 1, y
	and #$fe
	sta collision + 1, y
	lda projectile_collision + 1, y
	and #$fe
	sta projectile_collision + 1, y
	iny
	iny
	cpy #MAP_HEIGHT * 2
	bne lastcolloop

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

	lda temp
	cmp spawnable_range_min
	bcc notspawnablerange
	cmp spawnable_range_max
	bcc canspawn
notspawnablerange:

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

	; Zero water collision memory
	ldx #0
	lda #0
zerowaterloop:
	sta water_collision, x
	inx
	cpx #32
	bne zerowaterloop

	; Compute water data
	ldx #0
	stx arg0
	lda #$80
	sta temp
waterloop:
	ldy arg0
	lda map_gen_buf, y
	and #$fc
	cmp water_tile_start
	bcc nextwater
	cmp water_tile_end
	bcs nextwater

	lda temp
	ora water_collision, x
	sta water_collision, x

nextwater:
	inc arg0
	lda temp
	lsr
	sta temp
	bne waterloop
	lda #$80
	sta temp
	inx
	cpx #MAP_HEIGHT * 2
	bne waterloop

	; Ensure column 15 (which is not visible) is never marked as valid
	ldy #0
lastcolloop:
	lda spawnable + 1, y
	and #$fe
	sta spawnable + 1, y
	lda water_collision + 1, y
	and #$fe
	sta water_collision + 1, y
	iny
	iny
	cpy #MAP_HEIGHT * 2
	bne lastcolloop

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


PROC gen_left_wall_very_large
	sta arg4

	lda #2
	jsr genrange_cur
	clc
	adc #1
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
	clc
	adc #1
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


PROC gen_right_wall_very_large
	sta arg4

	lda #2
	jsr genrange_cur
	clc
	adc #2
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
	adc #2
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


PROC gen_top_wall_very_large
	sta arg4

	lda #2
	jsr genrange_cur
	clc
	adc #1
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


PROC gen_top_wall_single
	sta arg4

	lda #0
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

	lda #0
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


PROC gen_bot_wall_very_large
	sta arg4

	lda #2
	jsr genrange_cur
	clc
	adc #2
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
	adc #2
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


.segment "TEMP"
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
VAR water_tile_start
	.byte 0
VAR water_tile_end
	.byte 0
VAR traversable_range_min
	.byte 0
VAR traversable_range_max
	.byte 0
VAR spawnable_range_min
	.byte 0
VAR spawnable_range_max
	.byte 0

VAR collision
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
VAR projectile_collision
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
VAR water_collision
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
VAR entrance_down
	.byte 0


.bss
VAR overworld_visited
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0

VAR mine_visited
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0

VAR sewer_visited
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0


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
	.word gen_cave_interior
	.word gen_cave_interior
	.word gen_forest
	.word gen_house
	.word gen_shop
	.word gen_park
	.word gen_cave_interior
	.word start;gen_boss
	.word start;gen_base_horde
	.word start;gen_base_interior
	.word gen_blocky_treasure 
	.word gen_blocky_puzzle
	.word gen_blocky_cave_interior
	.word gen_starting_cave
	.word gen_cave_interior
	.word gen_cave_interior
	.word gen_cave_interior
	.word gen_dead_wood
	.word gen_forest
	.word gen_forest
	.word gen_forest
	.word gen_forest_boss
	.word gen_boarded_house
	.word gen_cave_interior
	.word gen_cave_interior
	.word gen_forest
	.word gen_cave_interior
	.word gen_cave_interior
	.word gen_sewer
	.word gen_sewer
	.word gen_sewer_boss
	.word gen_forest
	.word gen_dead_wood_boss
	.word gen_forest
	.word gen_forest
	.word gen_cave_interior
	.word gen_cave_interior
	.word gen_cave_interior
	.word gen_shop
	.word gen_shop
	.word gen_sewer_down
	.word gen_house
	.word gen_sewer_up
	.word gen_cave_interior
	.word gen_cave_interior


VAR normal_overworld_map
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $4b, $c1, $c1, $c1, $13, $13, $53, $63, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $99, $82, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $4c, $c1, $c1, $a2, $d3, $53, $93, $d3, $c1, $c1, $c1, $c1, $c1, $c1, $51
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $02, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $8d, $4d, $c1, $13, $93, $d3, $c1, $c1, $c1, $c1, $03, $5a, $c1, $c1, $50
	.byte $c1, $c1, $02, $82, $42, $c1, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $93, $13, $93, $d3, $c1, $c1, $c1, $c1, $c1, $03, $83, $83, $03, $03, $03
	.byte $43, $c1, $42, $82, $02, $82, $c2, $02, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $53, $1a, $43, $c1, $c1, $c1, $03, $03, $c3, $12, $52, $03, $03, $43
	.byte $43, $c1, $42, $c1, $c2, $c1, $c1, $d8, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $53, $83, $83, $43, $c1, $03, $03, $c3, $c7, $52, $52, $03, $83, $03
	.byte $43, $c1, $82, $02, $82, $82, $82, $82, $c2, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $13, $53, $03, $43, $03, $03, $03, $c3, $c7, $c7, $e1, $52, $83, $03, $03
	.byte $43, $c1, $c1, $42, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $13, $d3, $03, $03, $03, $c3, $43, $c7, $c7, $c7, $92, $12, $52, $03, $03
	.byte $03, $03, $03, $03, $03, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $03, $83, $83, $03, $03, $43, $c7, $c7, $c7, $c7, $52, $52, $03, $43
	.byte $1a, $03, $03, $83, $83, $83, $03, $03, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $43, $03, $04, $44, $a9, $03, $03, $43, $c7, $c7, $c7, $12, $52, $03, $03
	.byte $03, $03, $43, $03, $03, $43, $03, $03, $03, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $03, $43, $06, $04, $c6, $83, $03, $03, $43, $12, $12, $d2, $60, $03, $03
	.byte $c3, $43, $c3, $c3, $43, $e7, $03, $43, $03, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $83, $43, $84, $84, $04, $84, $04, $03, $43, $52, $92, $12, $52, $03, $83
	.byte $c3, $83, $83, $83, $c3, $03, $03, $03, $43, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $14, $54, $46, $45, $04, $86, $c4, $03, $03, $03, $43, $92, $d2, $03, $03
	.byte $83, $c3, $8a, $4a, $03, $43, $03, $9a, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $94, $14, $84, $84, $84, $03, $03, $43, $03, $03, $43, $03, $03, $03, $43
	.byte $8a, $8a, $0a, $4a, $03, $c3, $03, $03, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $94, $94, $54, $03, $83, $83, $03, $03, $83, $03, $03, $03, $43, $43
	.byte $0a, $8a, $ca, $4a, $03, $83, $03, $c3, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $54, $c3, $c7, $c7, $03, $03, $03, $97, $6a, $03, $43, $43
	.byte $4a, $88, $89, $ca, $03, $03, $43, $0f, $4f, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $80, $4e, $c1, $54, $c7, $c7, $c7, $03, $43, $03, $43, $e8, $83, $03, $03
	.byte $03, $83, $03, $83, $83, $c3, $da, $4f, $4f, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $94, $94, $54, $c7, $c7, $03, $03, $83, $43, $03, $03, $83, $03, $03
	.byte $83, $03, $43, $c1, $c1, $c1, $c1, $e6, $4f, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $94, $14, $14, $54, $83, $03, $03, $03, $83, $43, $c1, $83, $43
	.byte $03, $c3, $43, $c1, $0f, $8f, $0f, $a4, $cf, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $94, $d4, $d5, $c1, $83, $83, $83, $d6, $c1, $c1, $c1, $83
	.byte $83, $83, $83, $83, $83, $c3, $8f, $8f, $e5, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1

; Maps other than main overworld are stored in extra bank
.segment "EXTRA"

VAR normal_sewer_map
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $1d, $9d, $eb, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $1d, $9d, $9d, $5d, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $5d, $c1, $c1, $5d, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $5d, $c1, $c1, $5d, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $9d, $9d, $9d, $1d, $9d, $9d, $9d, $9d, $9d, $9d, $9d, $5d, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $de, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $5d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $9d, $9d, $9d, $df, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1

VAR normal_mine_map
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $6c
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $6d
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $2d, $ad, $ad, $ad, $2d
	.byte $ad, $ad, $ad, $ad, $6d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $6d, $c1, $c1, $c1, $6d
	.byte $c1, $c1, $c1, $c1, $6d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $6d, $c1, $2d, $ad, $ed
	.byte $c1, $c1, $c1, $c1, $6d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $6d, $c1, $6d, $c1, $c1
	.byte $c1, $2d, $ad, $2d, $ed, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $ad, $2d, $ad, $ed, $c1, $c1
	.byte $c1, $6d, $c1, $6d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $6d, $c1, $c1, $c1, $c1
	.byte $c1, $6d, $c1, $2d, $ad, $ed, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $ad, $ad, $db, $c1, $c1
	.byte $c1, $2d, $ad, $6d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $6d, $c1, $6d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $5c, $c1
	.byte $c1, $6d, $c1, $6d, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $ad, $ad
	.byte $ad, $ad, $ad, $ed, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1
	.byte $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1, $c1

VAR hard_overworld_map
	.byte $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $c7, $c7, $c7, $03, $03, $03, $43, $03, $43, $c7, $c7, $c7
	.byte $03, $03, $03, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $c7, $03, $03, $83, $c3, $03, $03, $83, $83, $03, $03, $c3
	.byte $83, $83, $03, $03, $03, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $03, $03, $03, $c3, $c1, $c1, $03, $43, $85, $46, $03, $03, $03
	.byte $83, $83, $83, $83, $03, $83, $03, $c3, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $03, $83, $c3, $c1, $42, $c1, $83, $03, $84, $c4, $83, $43, $43
	.byte $0a, $0a, $8a, $4a, $83, $43, $43, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $03, $03, $03, $43, $c1, $42, $c1, $03, $03, $83, $03, $03, $43, $43
	.byte $4a, $4a, $09, $8a, $ca, $43, $03, $c3, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $03, $03, $03, $c3, $03, $03, $03, $03, $03, $83, $83, $83, $03, $c3, $43
	.byte $ca, $4a, $8a, $89, $c8, $43, $83, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $03, $83, $03, $03, $03, $83, $03, $83, $c3, $02, $82, $42, $83, $83, $03
	.byte $03, $03, $03, $03, $c3, $43, $83, $83, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $03, $03, $43, $03, $03, $03, $c3, $c1, $c1, $42, $02, $82, $82, $c2, $03
	.byte $03, $43, $03, $43, $43, $03, $43, $45, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $03, $03, $43, $03, $83, $c3, $c1, $c1, $82, $c2, $42, $82, $82, $42, $03
	.byte $83, $03, $03, $c3, $83, $c3, $83, $c3, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $03, $83, $03, $43, $c1, $c1, $82, $82, $42, $82, $82, $42, $02, $42, $83
	.byte $03, $43, $03, $83, $83, $83, $43, $43, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $03, $43, $03, $43, $c1, $0e, $c0, $82, $02, $42, $02, $42, $c2, $82, $42
	.byte $03, $03, $c3, $03, $03, $43, $c3, $03, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $43, $03, $03, $03, $03, $03, $43, $c1, $42, $42, $42, $02, $82, $02, $c2
	.byte $03, $c3, $03, $83, $83, $03, $03, $43, $c3, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $83, $03, $83, $03, $03, $83, $03, $43, $c2, $42, $02, $c2, $02, $c2, $03
	.byte $43, $83, $03, $83, $83, $43, $43, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $03, $03, $43, $44, $46, $83, $03, $43, $82, $82, $c2, $42, $c1, $83
	.byte $03, $43, $c3, $c7, $c7, $c3, $83, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $03, $43, $43, $44, $04, $c4, $03, $43, $03, $03, $03, $03, $83, $03
	.byte $03, $83, $c3, $c7, $c7, $83, $83, $c3, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $83, $83, $43, $86, $04, $c5, $44, $03, $43, $83, $03, $43, $03, $03
	.byte $c3, $43, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $03, $03, $84, $84, $c6, $03, $03, $83, $43, $03, $03, $43
	.byte $03, $03, $83, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $83, $03, $03, $03, $83, $03, $43, $03, $03, $03, $83, $c3
	.byte $43, $43, $03, $83, $03, $83, $43, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $c7, $83, $03, $43, $03, $03, $03, $83, $83, $83, $83, $03
	.byte $83, $83, $c3, $03, $83, $c3, $c3, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $c7, $c7, $83, $83, $83, $83, $c3, $c7, $c7, $c7, $c7, $83
	.byte $83, $83, $83, $83, $83, $c3, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
	.byte $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7
