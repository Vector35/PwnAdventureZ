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

.segment "FIXED"

PROC get_player_tile
	lda player_x
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	tax

	lda player_y
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	tay

	rts
.endproc

PROC player_melee_tick
	lda current_bank
	pha
	lda #^do_player_melee_tick
	jsr bankswitch
	jsr do_player_melee_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC get_player_direction_bits
	lda controller
	and #JOY_LEFT | JOY_RIGHT | JOY_UP | JOY_DOWN
	beq nodir
	sta temp

	lda controller
	and #JOY_LEFT | JOY_RIGHT
	cmp #JOY_LEFT | JOY_RIGHT
	bne notbothhoriz

	lda temp
	and #JOY_LEFT | JOY_UP | JOY_DOWN
	sta temp

notbothhoriz:
	lda controller
	and #JOY_UP | JOY_DOWN
	cmp #JOY_UP | JOY_DOWN
	bne notbothvert

	lda temp
	and #JOY_LEFT | JOY_RIGHT | JOY_UP
	sta temp

notbothvert:
	lda temp
	rts

nodir:
	lda player_direction
	and #3
	cmp #DIR_LEFT
	bne notleft

	lda #JOY_LEFT
	rts

notleft:
	cmp #DIR_RIGHT
	bne notright

	lda #JOY_RIGHT
	rts

notright:
	cmp #DIR_UP
	bne notup

	lda #JOY_UP
	rts

notup:
	lda #JOY_DOWN
	rts
.endproc


PROC init_player_sprites
	lda current_bank
	pha
	lda #^do_init_player_sprites
	jsr bankswitch
	jsr do_init_player_sprites & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC update_player_sprite
	lda current_bank
	pha
	lda #^do_update_player_sprite
	jsr bankswitch
	jsr do_update_player_sprite & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_init_player_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_INTERACT, interact_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_CAMPFIRE, campfire_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_POWERUP, powerup_tiles

	lda equipped_armor
	cmp #ITEM_GHILLIE_SUIT
	beq ghillie
	cmp #ITEM_WIZARD_HAT
	beq wizard

	LOAD_ALL_TILES $100 + SPRITE_TILE_PLAYER, unarmed_player_tiles
	jmp setpalette & $ffff

ghillie:
	LOAD_ALL_TILES $100 + SPRITE_TILE_PLAYER, ghillie_player_tiles
	jmp setpalette & $ffff

wizard:
	LOAD_ALL_TILES $100 + SPRITE_TILE_PLAYER, wizard_player_tiles

setpalette:
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_START
	beq dark
	cmp #MAP_CAVE_INTERIOR
	beq dark
	cmp #MAP_CAVE_CHEST
	beq dark
	cmp #MAP_CAVE_BOSS
	beq dark
	cmp #MAP_STARTING_CAVE
	beq dark
	cmp #MAP_BLOCKY_PUZZLE
	beq dark
	cmp #MAP_BLOCKY_TREASURE
	beq dark
	cmp #MAP_BLOCKY_CAVE
	beq dark
	cmp #MAP_LOST_CAVE
	beq dark
	cmp #MAP_LOST_CAVE_WALL
	beq dark
	cmp #MAP_LOST_CAVE_CHEST
	beq dark
	cmp #MAP_LOST_CAVE_END
	beq dark
	cmp #MAP_MINE_ENTRANCE
	beq dark
	cmp #MAP_MINE_DOWN
	beq dark
	cmp #MAP_MINE_UP
	beq dark
	cmp #MAP_MINE
	beq dark
	cmp #MAP_MINE_BOSS
	beq dark
	cmp #MAP_MINE_CHEST
	beq dark

	lda equipped_armor
	cmp #ITEM_GHILLIE_SUIT
	beq ghillielightpalette

	LOAD_PTR light_player_palette
	jmp loadpal & $ffff

ghillielightpalette:
	LOAD_PTR light_ghillie_player_palette
	jmp loadpal & $ffff

dark:
	lda equipped_armor
	cmp #ITEM_GHILLIE_SUIT
	beq ghilliedarkpalette

	LOAD_PTR dark_player_palette
	jmp loadpal & $ffff

ghilliedarkpalette:
	LOAD_PTR dark_ghillie_player_palette

loadpal:
	lda ptr
	sta player_palette
	lda ptr + 1
	sta player_palette + 1
	jsr load_sprite_palette_0

	LOAD_PTR gun_palette
	jsr load_sprite_palette_2
	LOAD_PTR fire_palette
	jsr load_sprite_palette_3
	rts
.endproc


PROC do_update_player_sprite
	lda rendering_enabled
	beq palettedone

	lda player_damage_flash_time
	beq normalpalette

	and #4
	bne flashoff

	LOAD_PTR player_damage_palette
	lda #4
	jsr load_single_palette

	dec player_damage_flash_time
	jmp palettedone & $ffff

flashoff:
	dec player_damage_flash_time

normalpalette:
	lda player_palette
	sta ptr
	lda player_palette + 1
	sta ptr + 1
	lda #4
	jsr load_single_palette

palettedone:
	lda player_anim_frame
	lsr
	lsr
	lsr
	and #1
	sta temp

	lda player_direction
	asl
	ora temp
	asl
	asl
	tax

	lda player_y
	clc
	adc #7
	sta sprites + SPRITE_OAM_PLAYER
	sta sprites + SPRITE_OAM_PLAYER + 4

	lda walking_sprites_for_state, x
	sta sprites + SPRITE_OAM_PLAYER + 1
	lda walking_sprites_for_state + 1, x
	sta sprites + SPRITE_OAM_PLAYER + 2
	lda walking_sprites_for_state + 2, x
	sta sprites + SPRITE_OAM_PLAYER + 5
	lda walking_sprites_for_state + 3, x
	sta sprites + SPRITE_OAM_PLAYER + 6

	lda player_x
	clc
	adc #8
	sta sprites + SPRITE_OAM_PLAYER + 3
	adc #8
	sta sprites + SPRITE_OAM_PLAYER + 7

	lda inside
	bne nocampfire

	ldx #0
campfireloop:
	lda cur_screen_x
	cmp campfire_screen_x, x
	bne nextcampfire
	lda cur_screen_y
	cmp campfire_screen_y, x
	bne nextcampfire

	lda campfire_y, x
	clc
	adc #7
	sta sprites + SPRITE_OAM_CAMPFIRE
	sta sprites + SPRITE_OAM_CAMPFIRE + 4
	lda #SPRITE_TILE_CAMPFIRE + 1
	sta sprites + SPRITE_OAM_CAMPFIRE + 1
	lda #SPRITE_TILE_CAMPFIRE + 3
	sta sprites + SPRITE_OAM_CAMPFIRE + 5
	lda #3
	sta sprites + SPRITE_OAM_CAMPFIRE + 2
	sta sprites + SPRITE_OAM_CAMPFIRE + 6
	lda campfire_x, x
	clc
	adc #8
	sta sprites + SPRITE_OAM_CAMPFIRE + 3
	adc #8
	sta sprites + SPRITE_OAM_CAMPFIRE + 7

	jmp campfiredone & $ffff

nextcampfire:
	inx
	cpx #3
	bne campfireloop

nocampfire:
	lda #$ff
	sta sprites + SPRITE_OAM_CAMPFIRE
	sta sprites + SPRITE_OAM_CAMPFIRE + 4

campfiredone:
	lda wine_time
	bne drunk
	lda wine_time + 1
	bne drunk

	lda #$ff
	sta sprites + SPRITE_OAM_POWERUP

	jmp winedone & $ffff

drunk:
	lda #206
	sta sprites + SPRITE_OAM_POWERUP
	lda #SPRITE_TILE_POWERUP + 1
	sta sprites + SPRITE_OAM_POWERUP + 1
	lda #2
	sta sprites + SPRITE_OAM_POWERUP + 2
	lda #126
	sta sprites + SPRITE_OAM_POWERUP + 3

winedone:
	lda coffee_time
	bne oncoffee
	lda coffee_time + 1
	bne oncoffee

	lda #$ff
	sta sprites + SPRITE_OAM_POWERUP + 4

	jmp coffeedone & $ffff

oncoffee:
	lda #216
	sta sprites + SPRITE_OAM_POWERUP + 4
	lda #SPRITE_TILE_POWERUP + 3
	sta sprites + SPRITE_OAM_POWERUP + 5
	lda #2
	sta sprites + SPRITE_OAM_POWERUP + 6
	lda #126
	sta sprites + SPRITE_OAM_POWERUP + 7

coffeedone:
	lda interaction_type
	cmp #INTERACT_NONE
	beq nointeract

	lda interaction_sprite_y
	clc
	adc #7
	sta sprites + SPRITE_OAM_INTERACT
	sta sprites + SPRITE_OAM_INTERACT + 4
	lda #$f9
	sta sprites + SPRITE_OAM_INTERACT + 1
	lda #$fb
	sta sprites + SPRITE_OAM_INTERACT + 5
	lda #3
	sta sprites + SPRITE_OAM_INTERACT + 2
	sta sprites + SPRITE_OAM_INTERACT + 6
	lda interaction_sprite_x
	clc
	adc #8
	sta sprites + SPRITE_OAM_INTERACT + 3
	adc #8
	sta sprites + SPRITE_OAM_INTERACT + 7
	rts

nointeract:
	lda #$ff
	sta sprites + SPRITE_OAM_INTERACT
	sta sprites + SPRITE_OAM_INTERACT + 4
	rts
.endproc


.code

PROC place_player_at_entrance
	lda entrance_x
	asl
	asl
	asl
	asl
	sta player_x
	lda entrance_y
	asl
	asl
	asl
	asl
	sta player_y
	rts
.endproc


PROC check_for_entrance
	lda entrance_x
	asl
	asl
	asl
	asl
	cmp player_x
	bne done
	lda entrance_y
	asl
	asl
	asl
	asl
	cmp player_y
done:
	rts
.endproc


PROC perform_player_move
	lda #0
	sta arg4

	lda player_direction
	sta temp_direction

	lda knockback_time
	beq normalmove

	lda extra_player_move
	beq knockback
	lda #0
	rts

knockback:
	lda knockback_control
	sta temp_controller
	jmp noactivate

normalmove:
	lda controller
	sta temp_controller

	lda melee_active
	beq nomelee

	lda #0
	sta temp_controller

nomelee:
	lda temp_controller
	and #JOY_A
	beq noactivate

	lda interaction_type
	cmp #INTERACT_NONE
	beq nointeract

	lda attack_held
	bne startmove

	jsr activate_interaction

	lda #1
	sta attack_held
	jmp startmove

nointeract:
	jsr player_attack
	jmp startmove

noactivate:
	lda #0
	sta attack_held

startmove:
	lda extra_player_move
	bne nocooldown
	lda attack_cooldown
	beq nocooldown
	dec attack_cooldown
nocooldown:
	lda temp_controller
	and #JOY_UP
	bne up
	lda temp_controller
	and #JOY_DOWN
	bne downpressed
	jmp checkhoriz

downpressed:
	jmp down

up:
	; Check for cave/house entrance
	lda entrance_down
	bne notentranceup
	jsr check_for_entrance
	bne notentranceup
	jmp transitionenterup
notentranceup:
	; Check for top of map
	ldy player_y
	bne nottopbounds
	jmp transitionup
nottopbounds:
	lda #DIR_UP
	sta temp_direction
	; Collision detection
	tya
	and #15
	bne noupcollide
	jsr read_collision_up
	bne noupcollide
	ldx player_x
	txa
	and #15
	cmp #8
	bcc upsnapleft
	jmp upsnapright
upmoveinvalid:
	jsr get_player_tile
	stx possible_interaction_tile_x
	dey
	sty possible_interaction_tile_y
	lda player_up_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq upnotinteract
	sta interaction_type
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	beq interactionattop
	dey
interactionattop:
	jsr set_interaction_pos
upnotinteract:
	jmp checkhoriz
upsnapleft:
	lda temp_controller
	and #JOY_LEFT | JOY_RIGHT
	bne upmoveinvalid
	jsr read_collision_up_direct
	beq upmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp left
upsnapright:
	lda controller
	and #JOY_LEFT | JOY_RIGHT
	bne upmoveinvalid
	jsr read_collision_right
	beq upmoveinvalid
	jsr read_collision_up_right
	beq upmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp right
noupcollide:
	; Move OK
	ldy player_y
	dey
	sty player_y
	lda knockback_time
	bne noupdirchange
	lda #DIR_RUN_UP
	sta player_direction
noupdirchange:
	lda #1
	sta arg4
	jmp checkhoriz

down:
	; Check for cave/house entrance
	lda entrance_down
	beq notentrancedown
	jsr check_for_entrance
	bne notentrancedown
	jmp transitionenterdown
notentrancedown:
	; Check for bottom of map
	ldy player_y
	cpy #(MAP_HEIGHT - 1) * 16
	bcc notbotbounds
	jmp transitiondown
notbotbounds:
	lda #DIR_DOWN
	sta temp_direction
	; Collision detection
	tya
	and #15
	bne nodowncollide
	jsr read_collision_down
	bne nodowncollide
	ldx player_x
	txa
	and #15
	cmp #8
	bcc downsnapleft
	jmp downsnapright
downmoveinvalid:
	jsr get_player_tile
	stx possible_interaction_tile_x
	iny
	sty possible_interaction_tile_y
	lda player_down_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq downnotinteract
	sta interaction_type
	jsr get_player_tile
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	iny
	jsr set_interaction_pos
downnotinteract:
	jmp checkhoriz
downsnapleft:
	lda temp_controller
	and #JOY_LEFT | JOY_RIGHT
	bne downmoveinvalid
	jsr read_collision_down_direct
	beq downmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp left
downsnapright:
	lda controller
	and #JOY_LEFT | JOY_RIGHT
	bne downmoveinvalid
	jsr read_collision_right
	beq downmoveinvalid
	jsr read_collision_down_right
	beq downmoveinvalid
	lda temp_controller
	and #(~JOY_UP) & $ff
	sta temp_controller
	jmp right
nodowncollide:
	; Move OK
	ldy player_y
	iny
	sty player_y
	lda knockback_time
	bne nodowndirchange
	lda #DIR_RUN_DOWN
	sta player_direction
nodowndirchange:
	lda #1
	sta arg4
	jmp checkhoriz

checkhoriz:
	lda temp_controller
	and #JOY_LEFT
	bne left
	lda temp_controller
	and #JOY_RIGHT
	bne rightpressed
	jmp movedone

rightpressed:
	jmp right

left:
	; Check for left of map
	ldx player_x
	bne notleftbounds
	jmp transitionleft
notleftbounds:
	lda #DIR_LEFT
	sta temp_direction
	; Collision detection
	txa
	and #15
	bne noleftcollide
	jsr read_collision_left
	bne noleftcollide
	ldx player_y
	txa
	and #15
	cmp #8
	bcc leftsnaptop
	jmp leftsnapbot
leftmoveinvalid:
	jsr get_player_tile
	dex
	stx possible_interaction_tile_x
	sty possible_interaction_tile_y
	lda player_left_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq leftnotinteract
	sta interaction_type
	jsr get_player_tile
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	dex
	jsr set_interaction_pos
leftnotinteract:
	jmp movedone
leftsnaptop:
	lda temp_controller
	and #JOY_UP | JOY_DOWN
	bne leftmoveinvalid
	jsr read_collision_left_direct
	beq leftmoveinvalid
	lda temp_controller
	and #(~JOY_LEFT) & $ff
	sta temp_controller
	jmp up
leftsnapbot:
	lda controller
	and #JOY_UP | JOY_DOWN
	bne leftmoveinvalid
	jsr read_collision_down
	beq leftmoveinvalid
	jsr read_collision_left_bottom
	beq leftmoveinvalid
	lda temp_controller
	and #(~JOY_LEFT) & $ff
	sta temp_controller
	jmp down
noleftcollide:
	; Move OK
	ldx player_x
	dex
	stx player_x
	lda knockback_time
	bne noleftdirchange
	lda #DIR_RUN_LEFT
	sta player_direction
noleftdirchange:
	lda #1
	sta arg4
	jmp movedone

right:
	; Check for right of map
	ldx player_x
	cpx #(MAP_WIDTH - 1) * 16
	bcc notrightbounds
	jmp transitionright
notrightbounds:
	lda #DIR_RIGHT
	sta temp_direction
	; Collision detection
	txa
	and #15
	bne norightcollide
	jsr read_collision_right
	bne norightcollide
	ldx player_y
	txa
	and #15
	cmp #8
	bcc rightsnaptop
	jmp rightsnapbot
rightmoveinvalid:
	jsr get_player_tile
	inx
	stx possible_interaction_tile_x
	sty possible_interaction_tile_y
	lda player_right_tile
	jsr check_for_interactive_tile
	cmp #INTERACT_NONE
	beq rightnotinteract
	sta interaction_type
	jsr get_player_tile
	ldx possible_interaction_tile_x
	stx interaction_tile_x
	ldy possible_interaction_tile_y
	sty interaction_tile_y
	inx
	jsr set_interaction_pos
rightnotinteract:
	jmp movedone
rightsnaptop:
	lda temp_controller
	and #JOY_UP | JOY_DOWN
	bne rightmoveinvalid
	jsr read_collision_right_direct
	beq rightmoveinvalid
	lda temp_controller
	and #(~JOY_RIGHT) & $ff
	sta temp_controller
	jmp up
rightsnapbot:
	lda controller
	and #JOY_UP | JOY_DOWN
	bne rightmoveinvalid
	jsr read_collision_down
	beq rightmoveinvalid
	jsr read_collision_right_bottom
	beq rightmoveinvalid
	lda temp_controller
	and #(~JOY_RIGHT) & $ff
	sta temp_controller
	jmp down
norightcollide:
	; Move OK
	ldx player_x
	inx
	stx player_x
	lda knockback_time
	bne norightdirchange
	lda #DIR_RUN_RIGHT
	sta player_direction
norightdirchange:
	lda #1
	sta arg4
	jmp movedone

movedone:
	; Animate player if moving
	lda arg4
	beq notmoving

	lda #INTERACT_NONE
	sta interaction_type

	inc player_anim_frame
	jmp moveanimdone

notmoving:
	lda #7
	sta player_anim_frame

	lda knockback_time
	bne moveanimdone

	lda temp_direction
	and #3
	sta player_direction

moveanimdone:
	lda #0
	rts

transitionleft:
	lda knockback_time
	bne moveanimdone
	lda horde_active
	bne moveanimdone
	jsr fade_out
	dec cur_screen_x
	lda #(MAP_WIDTH - 1) * 16
	sta player_x
	lda #DIR_LEFT
	sta player_direction
	lda #1
	rts

transitionright:
	lda knockback_time
	bne moveanimdone
	lda horde_active
	bne moveanimdone
	jsr fade_out
	inc cur_screen_x
	lda #0
	sta player_x
	lda #DIR_RIGHT
	sta player_direction
	lda #1
	rts

transitionenterup:
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_HOUSE
	beq transitionhouseinside
	cmp #MAP_BOARDED_HOUSE
	beq transitionhouseinside
	cmp #MAP_OUTPOST_HOUSE
	beq transitionhouseinside
	cmp #MAP_SHOP
	beq transitionshopinside
	cmp #MAP_OUTPOST_SHOP
	beq transitionshopinside
	cmp #MAP_SECRET_SHOP
	beq transitionshopinside
	jmp transitionup

transitionhouseinside:
	jsr fade_out
	lda #1
	sta inside

	; Entering house, place player at entrance
	jsr prepare_map_gen
	jsr gen_house
	jsr place_player_at_entrance
	lda #DIR_UP
	sta player_direction
	lda #1
	rts

transitionshopinside:
	jsr fade_out
	lda #1
	sta inside

	; Entering house, place player at entrance
	jsr prepare_map_gen
	jsr gen_shop
	jsr place_player_at_entrance
	lda #DIR_UP
	sta player_direction
	lda #1
	rts

transitionup:
	lda horde_active
	beq nohordeup
	jmp moveanimdone
nohordeup:
	lda knockback_time
	beq dotransitionup
	jmp moveanimdone
dotransitionup:
	jsr fade_out
	dec cur_screen_y
	lda #(MAP_HEIGHT - 1) * 16
	sta player_y
	lda #DIR_UP
	sta player_direction
	lda #1
	rts

transitionenterdown:
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_HOUSE
	beq transitionhouseoutside
	cmp #MAP_BOARDED_HOUSE
	beq transitionhouseoutside
	cmp #MAP_OUTPOST_HOUSE
	beq transitionhouseoutside
	cmp #MAP_SHOP
	beq transitionshopoutside
	cmp #MAP_OUTPOST_SHOP
	beq transitionshopoutside
	cmp #MAP_SECRET_SHOP
	beq transitionshopoutside
	jmp transitiondown

transitionhouseoutside:
	jsr fade_out
	lda #0
	sta inside

	; Exiting house, place player at entrance
	jsr prepare_map_gen
	jsr gen_house
	jsr place_player_at_entrance
	lda #DIR_DOWN
	sta player_direction
	lda #1
	rts

transitionshopoutside:
	jsr fade_out
	lda #0
	sta inside

	; Exiting shop, place player at entrance
	jsr prepare_map_gen
	jsr gen_shop
	jsr place_player_at_entrance
	lda #DIR_DOWN
	sta player_direction
	lda #1
	rts

transitiondown:
	lda horde_active
	beq nohordedown
	jmp moveanimdone
nohordedown:
	lda knockback_time
	beq dotransitiondown
	jmp moveanimdone
dotransitiondown:
	jsr fade_out

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_INTERIOR
	beq possiblecaveexit
	cmp #MAP_STARTING_CAVE
	beq possiblecaveexit
	cmp #MAP_LOST_CAVE
	beq possiblecaveexit
	cmp #MAP_MINE_ENTRANCE
	beq possiblecaveexit
	cmp #MAP_BLOCKY_CAVE
	bne notcaveexit

possiblecaveexit:
	jsr read_overworld_down
	and #$3f
	jsr is_map_type_forest
	beq notcaveexit

	; Exiting cave, place player at cave entrance
	inc cur_screen_y
	jsr prepare_map_gen
	jsr gen_forest
	lda top_wall_right_extent
	asl
	asl
	asl
	asl
	sta player_y
	lda top_opening_pos
	clc
	adc #1
	asl
	asl
	asl
	asl
	sta player_x
	lda #DIR_DOWN
	sta player_direction
	lda #1
	rts

notcaveexit:
	; Normal exit down
	inc cur_screen_y
	lda #0
	sta player_y
	lda #DIR_DOWN
	sta player_direction
	lda #1
	rts
.endproc


PROC update_player_surroundings
	lda player_x
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	asl
	sta arg0

	lda player_y
	lsr
	lsr
	lsr
	lsr
	adc #0 ; Round to nearest
	asl
	sta arg1

	ldx arg0
	dex
	ldy arg1
	jsr set_ppu_addr_to_coord
	lda PPUDATA
	lda PPUDATA
	sta player_left_tile
	lda PPUDATA
	lda PPUDATA
	lda PPUDATA
	sta player_right_tile

	ldx arg0
	ldy arg1
	dey
	jsr set_ppu_addr_to_coord
	lda PPUDATA
	lda PPUDATA
	sta player_up_tile

	ldx arg0
	ldy arg1
	iny
	iny
	jsr set_ppu_addr_to_coord
	lda PPUDATA
	lda PPUDATA
	sta player_down_tile

	rts
.endproc


PROC check_for_interactive_tile
	and #$fc
	sta temp
	ldx #0
loop:
	lda interactive_tile_values, x
	cmp temp
	beq found
	inx
	cpx #6
	bne loop

	lda #INTERACT_NONE
	rts

found:
	lda interactive_tile_types, x
	cmp #INTERACT_NONE
	bne ok
	rts
ok:
	sta arg0
	pha

	asl
	tax
	lda interaction_descriptors, x
	sta ptr
	lda interaction_descriptors + 1, x
	sta ptr + 1
	ldy #INTERACT_DESC_IS_VALID
	lda (ptr), y
	sta temp
	ldy #INTERACT_DESC_IS_VALID + 1
	lda (ptr), y
	sta temp + 1

	lda arg0
	ldx possible_interaction_tile_x
	ldy possible_interaction_tile_y
	jsr call_temp
	bne invalid

	pla
	rts

invalid:
	pla
	lda #INTERACT_NONE
	rts
.endproc


PROC set_interaction_pos
	txa
	asl
	asl
	asl
	asl
	sta interaction_sprite_x

	tya
	asl
	asl
	asl
	asl
	sta interaction_sprite_y

	rts
.endproc


PROC player_attack
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_SHOP
	beq shop
	cmp #MAP_OUTPOST_SHOP
	beq shop
	cmp #MAP_SECRET_SHOP
	bne notshop
shop:
	rts

notshop:
	lda attack_cooldown
	beq nocooldown
	rts

nocooldown:
	lda attack_held
	beq notheld
	rts

notheld:
	; Get equipped weapon type
	lda equipped_weapon
	cmp #ITEM_NONE
	beq noweapon
	jsr get_item_type

	; Melee weapons do not use ammo
	cmp #ITEM_TYPE_MELEE
	beq ammook

	; Check ammo count for weapon
	lda equipped_weapon_slot
	asl
	tax
	lda inventory, x
	beq failed

ammook:
	lda equipped_weapon
	jsr use_item
	rts

noweapon:
	lda equipped_armor
	cmp #ITEM_WIZARD_HAT
	bne failed

	jsr cast_fireball

failed:
	rts
.endproc


PROC activate_interaction
	lda interaction_type
	cmp #INTERACT_NONE
	bne ok
	rts

ok:
	asl
	tax
	lda interaction_descriptors, x
	sta ptr
	lda interaction_descriptors + 1, x
	sta ptr + 1
	ldy #INTERACT_DESC_ACTIVATE
	lda (ptr), y
	sta temp
	ldy #INTERACT_DESC_ACTIVATE + 1
	lda (ptr), y
	sta temp + 1

	jsr get_player_tile
	lda interaction_type
	ldx interaction_tile_x
	ldy interaction_tile_y
	jsr call_temp

	lda #INTERACT_NONE
	sta interaction_type
	rts
.endproc


PROC always_interactable
	lda #0
	rts
.endproc


PROC take_damage
	sta temp

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard
	jmp ok

hard:
	lda temp
	lsr
	clc
	adc temp
	sta temp
	jmp ok

veryhard:
	lda temp
	asl
	sta temp

ok:
	lda equipped_armor
	cmp #ITEM_ARMOR
	bne noarmor

	lda temp
	lsr
	sta temp

noarmor:
	lda wine_time
	bne drunk
	lda wine_time + 1
	bne drunk
	jmp sober

drunk:
	lda temp
	lsr
	sta temp

sober:
	lda player_health
	sec
	sbc temp
	bcc dead
	sta player_health

	PLAY_SOUND_EFFECT effect_playerhit

	lda #30
	sta player_damage_flash_time
	rts

dead:
	lda #0
	sta player_health
	rts
.endproc


PROC show_bullet_damage_effect
	ldx cur_effect
	dec effect_x, x
	dec effect_x, x
	dec effect_x, x
	dec effect_y, x
	dec effect_y, x
	dec effect_y, x
	lda #EFFECT_PLAYER_BULLET_DAMAGE
	sta effect_type, x
	lda #SPRITE_TILE_BULLET_DAMAGE
	sta effect_tile, x
	lda #0
	sta effect_time, x
	rts
.endproc


PROC bullet_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #10
	jsr enemy_damage

	jsr player_bullet_tick
	jsr show_bullet_damage_effect
	rts
.endproc


PROC hand_cannon_bullet_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #40
	jsr enemy_damage

	jsr player_bullet_tick
	jsr show_bullet_damage_effect
	rts
.endproc


PROC lmg_bullet_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #20
	jsr enemy_damage

	jsr player_bullet_tick

	ldx cur_effect
	dec effect_x, x
	dec effect_x, x
	dec effect_x, x
	dec effect_y, x
	dec effect_y, x
	dec effect_y, x
	lda #EFFECT_PLAYER_BULLET_DAMAGE
	sta effect_type, x
	lda #SPRITE_TILE_BULLET_DAMAGE
	sta effect_tile, x
	lda #0
	sta effect_time, x

	rts
.endproc


PROC ak_bullet_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #15
	jsr enemy_damage

	jsr player_bullet_tick
	jsr show_bullet_damage_effect
	rts
.endproc


PROC sniper_bullet_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #80
	jsr enemy_damage

	jsr player_bullet_tick
	jsr show_bullet_damage_effect
	rts
.endproc


PROC shotgun_bullet_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #15
	jsr enemy_damage

	jsr player_bullet_tick
	jsr show_bullet_damage_effect
	rts
.endproc


PROC bullet_hit_world
	ldx cur_effect
	dec effect_x, x
	dec effect_y, x
	lda #EFFECT_PLAYER_BULLET_HIT
	sta effect_type, x
	lda #SPRITE_TILE_BULLET_HIT
	sta effect_tile, x
	lda #0
	sta effect_time, x
	rts
.endproc


PROC sniper_bullet_hit_world
	ldx cur_effect

	lda effect_x, x
	cmp #16
	bcc collide
	cmp #$e0
	bcs collide
	lda effect_y, x
	cmp #16
	bcc collide
	cmp #$b0
	bcc nocollide

collide:
	dec effect_x, x
	dec effect_y, x
	lda #EFFECT_PLAYER_BULLET_HIT
	sta effect_type, x
	lda #SPRITE_TILE_BULLET_HIT
	sta effect_tile, x
	lda #0
	sta effect_time, x

nocollide:
	rts
.endproc


PROC melee_attack_knockback
	ldx cur_enemy
	lda #4
	sta enemy_knockback_time, x
	lda player_direction
	and #3
	sta enemy_walk_direction, x
	lda #1
	sta enemy_idle_time, x
	rts
.endproc


PROC axe_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #10
	jsr enemy_damage

	ldx cur_effect
	lda #EFFECT_PLAYER_AXE_HIT
	sta effect_type, x

	jsr melee_attack_knockback
	rts
.endproc

PROC sword_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #20
	jsr enemy_damage

	ldx cur_effect
	lda #EFFECT_PLAYER_SWORD_HIT
	sta effect_type, x

	jsr melee_attack_knockback
	rts
.endproc

.segment "EXTRA"

PROC do_player_melee_tick
	ldx cur_effect
	lda #0
	dec effect_data_0, x
	cmp effect_data_0, x
	beq remove
	jsr get_player_direction_bits
	sta effect_direction, x
	
	lda player_direction
	and #3
	cmp #DIR_LEFT
	bne notleft

	lda #SPRITE_TILE_MELEE + 12
	sta effect_tile, x
	lda player_x
	sec
	sbc #12
	sta effect_x, x
	lda player_y
	clc
	adc #4
	sta effect_y, x
	jmp done & $ffff

notleft:
	cmp #DIR_RIGHT
	bne notright

	lda #SPRITE_TILE_MELEE + 4
	sta effect_tile, x
	lda player_x
	clc
	adc #12
	sta effect_x, x
	lda player_y
	clc
	adc #4
	sta effect_y, x
	jmp done & $ffff
notright:
	cmp #DIR_UP
	bne notup

	lda #SPRITE_TILE_MELEE + 0
	sta effect_tile, x
	lda player_y
	sec
	sbc #12
	sta effect_y, x
	lda player_x
	clc
	adc #0
	sta effect_x, x

	jmp done & $ffff
notup:
	lda #SPRITE_TILE_MELEE + 8
	sta effect_tile, x
	lda player_y
	clc
	adc #12
	sta effect_y, x
	lda player_x
	clc
	adc #2
	sta effect_x, x
done:
	rts
remove:
	lda #0
	sta melee_active
	jsr remove_effect & $ffff
	rts
.endproc

PROC do_player_bullet_tick
	ldx cur_effect
	lda effect_direction, x
	and #JOY_LEFT
	beq notleft

	dec effect_x, x
	dec effect_x, x
	dec effect_x, x

notleft:
	lda effect_direction, x
	and #JOY_RIGHT
	beq notright

	inc effect_x, x
	inc effect_x, x
	inc effect_x, x

notright:
	lda effect_direction, x
	and #JOY_UP
	beq notup

	dec effect_y, x
	dec effect_y, x
	dec effect_y, x

notup:
	lda effect_direction, x
	and #JOY_DOWN
	beq notdown

	inc effect_y, x
	inc effect_y, x
	inc effect_y, x

notdown:
	rts
.endproc


PROC do_player_rocket_horizontal_tick
	jsr player_bullet_tick

	ldx cur_effect
	inc effect_time, x
	lda effect_time, x

	cmp #8
	beq secondframe
	cmp #16
	beq firstframe
	rts

secondframe:
	lda effect_tile, x
	clc
	adc #4
	sta effect_tile, x
	rts

firstframe:
	lda effect_tile, x
	sec
	sbc #4
	sta effect_tile, x
	lda #0
	sta effect_time, x
	rts
.endproc


PROC do_player_rocket_vertical_tick
	jsr player_bullet_tick

	ldx cur_effect
	inc effect_time, x
	lda effect_time, x

	cmp #8
	beq secondframe
	cmp #16
	beq firstframe
	rts

secondframe:
	lda effect_tile, x
	clc
	adc #2
	sta effect_tile, x
	rts

firstframe:
	lda effect_tile, x
	sec
	sbc #2
	sta effect_tile, x
	lda #0
	sta effect_time, x
	rts
.endproc


PROC do_player_ak_bullet_tick
	jsr player_bullet_tick
	jsr player_bullet_tick
	rts
.endproc


PROC do_player_shotgun_bullet_tick
	ldx cur_effect
	lda effect_direction, x
	and #JOY_LEFT
	beq notleft

	dec effect_x, x
	dec effect_x, x
	dec effect_x, x
	dec effect_x, x

notleft:
	lda effect_direction, x
	and #JOY_RIGHT
	beq notright

	inc effect_x, x
	inc effect_x, x
	inc effect_x, x
	inc effect_x, x

notright:
	lda effect_direction, x
	and #JOY_UP
	beq notup

	dec effect_y, x
	dec effect_y, x
	dec effect_y, x
	dec effect_y, x

notup:
	lda effect_direction, x
	and #JOY_DOWN
	beq notdown

	inc effect_y, x
	inc effect_y, x
	inc effect_y, x
	inc effect_y, x

notdown:
	rts
.endproc


PROC do_player_left_bullet_tick
	jsr player_shotgun_bullet_tick

	ldx cur_effect
	lda effect_direction, x
	and #JOY_LEFT
	beq notleft

	inc effect_y, x

notleft:
	lda effect_direction, x
	and #JOY_RIGHT
	beq notright

	dec effect_y, x

notright:
	lda effect_direction, x
	and #JOY_UP
	beq notup

	dec effect_x, x

notup:
	lda effect_direction, x
	and #JOY_DOWN
	beq notdown

	inc effect_x, x

notdown:
	rts
.endproc


PROC do_player_right_bullet_tick
	jsr player_shotgun_bullet_tick

	ldx cur_effect
	lda effect_direction, x
	and #JOY_LEFT
	beq notleft

	dec effect_y, x

notleft:
	lda effect_direction, x
	and #JOY_RIGHT
	beq notright

	inc effect_y, x

notright:
	lda effect_direction, x
	and #JOY_UP
	beq notup

	inc effect_x, x

notup:
	lda effect_direction, x
	and #JOY_DOWN
	beq notdown

	dec effect_x, x

notdown:
	rts
.endproc


PROC do_explosion_stage_1_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #3
	beq secondframe
	cmp #6
	bne done

	lda effect_direction, x
	cmp #DIR_LEFT
	beq left
	cmp #DIR_RIGHT
	beq right
	cmp #DIR_UP
	beq up

	lda effect_y, x
	clc
	adc #12
	sta effect_y, x
	jmp nextstage & $ffff

left:
	lda effect_x, x
	sec
	sbc #12
	sta effect_x, x
	jmp nextstage & $ffff

right:
	lda effect_x, x
	clc
	adc #12
	sta effect_x, x
	jmp nextstage & $ffff

up:
	lda effect_y, x
	sec
	sbc #12
	sta effect_y, x

nextstage:
	lda #0
	sta effect_time, x
	lda #SPRITE_TILE_FIREBALL
	sta effect_tile, x
	lda #EFFECT_EXPLOSION_STAGE_2
	sta effect_type, x
	rts

secondframe:
	lda #SPRITE_TILE_FIREBALL + 4
	sta effect_tile, x

done:
	rts
.endproc


PROC do_explosion_stage_2_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #3
	beq secondframe
	cmp #6
	bne done

	jsr remove_effect
	rts

secondframe:
	lda #SPRITE_TILE_FIREBALL + 4
	sta effect_tile, x

done:
	rts
.endproc


PROC do_create_explosion_effect
	lda #EFFECT_EXPLOSION_STAGE_2
	sta arg2
	lda #0
	sta arg3
	jsr create_effect

	lda #EFFECT_EXPLOSION_STAGE_1
	sta arg2
	lda arg0
	sec
	sbc #12
	sta arg0
	lda #DIR_UP
	sta arg3
	jsr create_effect

	lda #EFFECT_EXPLOSION_STAGE_1
	sta arg2
	lda arg0
	clc
	adc #12
	sta arg0
	lda arg1
	sec
	sbc #12
	sta arg1
	lda #DIR_RIGHT
	sta arg3
	jsr create_effect

	lda #EFFECT_EXPLOSION_STAGE_1
	sta arg2
	lda arg1
	clc
	adc #24
	sta arg1
	lda #DIR_LEFT
	sta arg3
	jsr create_effect

	lda #EFFECT_EXPLOSION_STAGE_1
	sta arg2
	lda arg0
	clc
	adc #12
	sta arg0
	lda arg1
	sec
	sbc #12
	sta arg1
	lda #DIR_DOWN
	sta arg3
	jsr create_effect

	rts
.endproc


.segment "FIXED"

PROC player_bullet_tick
	lda current_bank
	pha
	lda #^do_player_bullet_tick
	jsr bankswitch
	jsr do_player_bullet_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC player_ak_bullet_tick
	lda current_bank
	pha
	lda #^do_player_ak_bullet_tick
	jsr bankswitch
	jsr do_player_ak_bullet_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC player_left_bullet_tick
	lda current_bank
	pha
	lda #^do_player_left_bullet_tick
	jsr bankswitch
	jsr do_player_left_bullet_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC player_right_bullet_tick
	lda current_bank
	pha
	lda #^do_player_right_bullet_tick
	jsr bankswitch
	jsr do_player_right_bullet_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC player_rocket_horizontal_tick
	lda current_bank
	pha
	lda #^do_player_rocket_horizontal_tick
	jsr bankswitch
	jsr do_player_rocket_horizontal_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC player_rocket_vertical_tick
	lda current_bank
	pha
	lda #^do_player_rocket_vertical_tick
	jsr bankswitch
	jsr do_player_rocket_vertical_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC player_shotgun_bullet_tick
	lda current_bank
	pha
	lda #^do_player_shotgun_bullet_tick
	jsr bankswitch
	jsr do_player_shotgun_bullet_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC explosion_stage_1_tick
	lda current_bank
	pha
	lda #^do_explosion_stage_1_tick
	jsr bankswitch
	jsr do_explosion_stage_1_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC explosion_stage_2_tick
	lda current_bank
	pha
	lda #^do_explosion_stage_2_tick
	jsr bankswitch
	jsr do_explosion_stage_2_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC create_explosion_effect
	lda current_bank
	pha
	lda #^do_create_explosion_effect
	jsr bankswitch
	jsr do_create_explosion_effect & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.code

PROC rocket_hit
	ldx cur_effect
	lda effect_x, x
	sta arg0
	lda effect_y, x
	sta arg1
	jsr explode

	jsr remove_effect
	rts
.endproc


PROC player_bullet_hit_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #8
	bne done
	jsr remove_effect
done:
	rts
.endproc


PROC explode
	lda cur_enemy
	sta saved_enemy

	ldx #0
enemyloop:
	lda enemy_type, x
	cmp #ENEMY_NONE
	beq nextenemy

	lda enemy_x, x
	sec
	sbc arg0

	cmp #$18
	bcc enemyxoverlap
	cmp #$d8
	bcs enemyxoverlap
	jmp nextenemy & $ffff

enemyxoverlap:
	lda enemy_y, x
	sec
	sbc arg1

	cmp #$18
	bcc enemyhit
	cmp #$d8
	bcc nextenemy

enemyhit:
	txa
	pha
	tya
	pha
	lda arg0
	pha
	lda arg1
	pha

	stx cur_enemy
	lda #60
	jsr enemy_damage

	pla
	sta arg1
	pla
	sta arg0
	pla
	tay
	pla
	tax

nextenemy:
	inx
	cpx #8
	bne enemyloop

	lda saved_enemy
	sta cur_enemy

	lda player_x
	sec
	sbc arg0

	cmp #$18
	bcc playerxoverlap
	cmp #$d8
	bcs playerxoverlap
	jmp noplayerdamage & $ffff

playerxoverlap:
	lda player_y
	sec
	sbc arg1

	cmp #$18
	bcc playerhit
	cmp #$d8
	bcc noplayerdamage

playerhit:
	lda arg0
	pha
	lda arg1
	pha

	lda #20
	jsr take_damage
	jsr explosion_knockback

	pla
	sta arg1
	pla
	sta arg0

noplayerdamage:
	lda arg0
	sec
	sbc #4
	sta arg0
	lda arg1
	sec
	sbc #4
	sta arg1

	jsr check_lost_cave_wall_explosion

	jsr create_explosion_effect
	PLAY_SOUND_EFFECT effect_boom
	rts
.endproc


PROC grenade_tick
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #12
	bcc fast
	cmp #24
	bcc slow
	cmp #90
	bne done

	lda effect_x, x
	sta arg0
	lda effect_y, x
	sta arg1
	jsr explode
	jsr remove_effect
	rts

slow:
	and #1
	beq done
fast:
	jsr player_bullet_tick
done:
	rts
.endproc


PROC grenade_hit
	ldx cur_effect
	lda #0
	sta effect_direction, x
	rts
.endproc


PROC player_fireball_animate
	ldx cur_effect
	inc effect_time, x
	lda effect_time, x
	cmp #60
	beq done

	and #8
	beq secondframe

	lda #SPRITE_TILE_FIREBALL
	sta effect_tile, x
	rts

secondframe:
	lda #SPRITE_TILE_FIREBALL + 4
	sta effect_tile, x
	rts

done:
	jsr remove_effect
	rts
.endproc


PROC player_fireball_tick
	jsr player_bullet_tick
	jmp player_fireball_animate
.endproc


PROC player_fireball_hit_tick
	ldx cur_effect
	lda effect_direction, x
	and #JOY_LEFT
	beq notleft

	dec effect_x, x

notleft:
	lda effect_direction, x
	and #JOY_RIGHT
	beq notright

	inc effect_x, x

notright:
	lda effect_direction, x
	and #JOY_UP
	beq notup

	dec effect_y, x

notup:
	lda effect_direction, x
	and #JOY_DOWN
	beq notdown

	inc effect_y, x

notdown:
	jmp player_fireball_animate
.endproc


PROC fireball_hit_enemy
	PLAY_SOUND_EFFECT effect_enemyhit

	lda #25
	jsr enemy_damage
	jsr melee_attack_knockback

	ldx cur_effect
	lda #EFFECT_FIREBALL_HIT
	sta effect_type, x
	lda #45
	sta effect_time, x
	rts
.endproc


PROC fireball_hit_world
	ldx cur_effect
	lda #0
	sta effect_direction, x
	rts
.endproc


.zeropage
VAR player_x
	.byte 0
VAR player_y
	.byte 0
VAR player_entry_x
	.byte 0
VAR player_entry_y
	.byte 0

VAR player_health
	.byte 0


.segment "TEMP"
VAR temp_direction
	.byte 0
VAR temp_controller
	.byte 0

VAR interactive_tile_types
	.byte 0, 0, 0, 0, 0, 0
VAR interactive_tile_values
	.byte 0, 0, 0, 0, 0, 0

VAR player_direction
	.byte 0
VAR player_anim_frame
	.byte 0

VAR player_damage_flash_time
	.byte 0
VAR player_palette
	.word 0

VAR player_left_tile
	.byte 0
VAR player_right_tile
	.byte 0
VAR player_up_tile
	.byte 0
VAR player_down_tile
	.byte 0

VAR interaction_type
	.byte 0
VAR interaction_sprite_x
	.byte 0
VAR interaction_sprite_y
	.byte 0
VAR interaction_tile_x
	.byte 0
VAR interaction_tile_y
	.byte 0

VAR possible_interaction_tile_x
	.byte 0
VAR possible_interaction_tile_y
	.byte 0

VAR attack_held
	.byte 0
VAR attack_cooldown
	.byte 0

VAR extra_player_move
	.byte 0

VAR saved_enemy
	.byte 0


.data
VAR walking_sprites_for_state
	; Up
	.byte $1c + 1, $00
	.byte $1e + 1, $00
	.byte $1c + 1, $00
	.byte $1e + 1, $00
	; Left
	.byte $0a + 1, $40
	.byte $08 + 1, $40
	.byte $0a + 1, $40
	.byte $08 + 1, $40
	; Right
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	; Down
	.byte $18 + 1, $00
	.byte $1a + 1, $00
	.byte $18 + 1, $00
	.byte $1a + 1, $00
	; Run Up
	.byte $10 + 1, $00
	.byte $12 + 1, $00
	.byte $14 + 1, $00
	.byte $16 + 1, $00
	; Run Left
	.byte $0a + 1, $40
	.byte $08 + 1, $40
	.byte $0e + 1, $40
	.byte $0c + 1, $40
	; Run Right
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00
	; Run Down
	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $04 + 1, $00
	.byte $06 + 1, $00

VAR dark_player_palette
	.byte $0f, $2d, $37, $07
VAR light_player_palette
	.byte $0f, $0f, $37, $07

VAR dark_ghillie_player_palette
	.byte $0f, $2d, $09, $07
VAR light_ghillie_player_palette
	.byte $0f, $0f, $09, $07

VAR player_damage_palette
	.byte $0f, $20, $10, $2d

VAR gun_palette
	.byte $0f, $00, $10, $20
VAR fire_palette
	.byte $0f, $06, $16, $37

VAR interaction_descriptors
	.word starting_chest_descriptor
	.word blocky_urn 
	.word blocky_bigdoor
	.word blocky_chest
	.word shop_npc_descriptor
	.word starting_note_descriptor
	.word blocky_note_descriptor
	.word boarded_house_note_descriptor
	.word boarded_house_npc_descriptor
	.word sewer_entrance_descriptor
	.word sewer_exit_descriptor
	.word mine_entrance_descriptor
	.word mine_exit_descriptor
	.word key_chest_1_descriptor
	.word key_chest_2_descriptor
	.word key_chest_3_descriptor
	.word key_chest_4_descriptor
	.word key_chest_5_descriptor
	.word key_chest_6_descriptor
	.word start_forest_chest_descriptor
	.word cave_chest_descriptor
	.word mine_chest_descriptor
	.word sewer_chest_descriptor
	.word dead_wood_chest_descriptor
	.word unbearable_chest_descriptor
	.word lost_cave_chest_descriptor
	.word forest_chest_descriptor
	.word lost_cave_end_descriptor
	.word lost_cave_note_descriptor
	.word base_entrance_descriptor

.rodata

VAR player_axe_descriptor
	.word player_melee_tick
	.word nothing
	.word axe_hit_enemy
	.word nothing
	.byte SPRITE_TILE_MELEE, 1
	.byte 2
	.byte 16, 16

VAR player_axe_hit_descriptor
	.word player_melee_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_MELEE, 1
	.byte 2
	.byte 16, 16

VAR player_sword_descriptor
	.word player_melee_tick
	.word nothing
	.word sword_hit_enemy
	.word nothing
	.byte SPRITE_TILE_MELEE, 1
	.byte 2
	.byte 16, 16

VAR player_sword_hit_descriptor
	.word player_melee_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_MELEE, 1
	.byte 2
	.byte 16, 16

VAR player_rocket_left_descriptor
	.word player_rocket_horizontal_tick
	.word nothing
	.word rocket_hit
	.word rocket_hit
	.byte SPRITE_TILE_ROCKET, $41
	.byte 3
	.byte 16, 8

VAR player_rocket_right_descriptor
	.word player_rocket_horizontal_tick
	.word nothing
	.word rocket_hit
	.word rocket_hit
	.byte SPRITE_TILE_ROCKET, 1
	.byte 3
	.byte 16, 8

VAR player_rocket_up_descriptor
	.word player_rocket_vertical_tick
	.word nothing
	.word rocket_hit
	.word rocket_hit
	.byte SPRITE_TILE_ROCKET + 8, 0
	.byte 3
	.byte 8, 16

VAR player_rocket_down_descriptor
	.word player_rocket_vertical_tick
	.word nothing
	.word rocket_hit
	.word rocket_hit
	.byte SPRITE_TILE_ROCKET + 8, $80
	.byte 3
	.byte 8, 16

VAR player_fireball_descriptor
	.word player_fireball_tick
	.word nothing
	.word fireball_hit_enemy
	.word fireball_hit_world
	.byte SPRITE_TILE_FIREBALL, 1
	.byte 3
	.byte 16, 16

VAR fireball_hit_descriptor
	.word player_fireball_hit_tick
	.word nothing
	.word nothing
	.word fireball_hit_world
	.byte SPRITE_TILE_FIREBALL, 1
	.byte 3
	.byte 16, 16

VAR player_grenade_descriptor
	.word grenade_tick
	.word nothing
	.word nothing
	.word grenade_hit
	.byte SPRITE_TILE_GRENADE, 1
	.byte 2
	.byte 16, 16

VAR player_bullet_descriptor
	.word player_bullet_tick
	.word nothing
	.word bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_lmg_bullet_descriptor
	.word player_bullet_tick
	.word nothing
	.word lmg_bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_ak_bullet_descriptor
	.word player_ak_bullet_tick
	.word nothing
	.word ak_bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_sniper_bullet_descriptor
	.word player_ak_bullet_tick
	.word nothing
	.word sniper_bullet_hit_enemy
	.word sniper_bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_shotgun_bullet_descriptor
	.word player_shotgun_bullet_tick
	.word nothing
	.word shotgun_bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_left_bullet_descriptor
	.word player_left_bullet_tick
	.word nothing
	.word shotgun_bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_hand_cannon_bullet_descriptor
	.word player_bullet_tick
	.word nothing
	.word hand_cannon_bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_right_bullet_descriptor
	.word player_right_bullet_tick
	.word nothing
	.word shotgun_bullet_hit_enemy
	.word bullet_hit_world
	.byte SPRITE_TILE_BULLET, 0
	.byte 2
	.byte 3, 3

VAR player_bullet_hit_descriptor
	.word player_bullet_hit_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_BULLET_HIT, 0
	.byte 2
	.byte 0, 0

VAR player_bullet_damage_descriptor
	.word player_bullet_hit_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_BULLET_DAMAGE, 0
	.byte 3
	.byte 0, 0

VAR explosion_stage_1_descriptor
	.word explosion_stage_1_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_FIREBALL, 1
	.byte 3
	.byte 0, 0

VAR explosion_stage_2_descriptor
	.word explosion_stage_2_tick
	.word nothing
	.word nothing
	.word nothing
	.byte SPRITE_TILE_FIREBALL, 1
	.byte 3
	.byte 0, 0

TILES unarmed_player_tiles, 4, "tiles/characters/player/unarmed.chr", 40
TILES ghillie_player_tiles, 4, "tiles/characters/player/unarmed-ghillie.chr", 32
TILES wizard_player_tiles, 4, "tiles/characters/player/unarmed-wizard.chr", 32
TILES interact_tiles, 2, "tiles/interact.chr", 8
TILES powerup_tiles, 2, "tiles/status/powerup.chr", 4
