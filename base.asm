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

.define WALL_TILES  $80
.define FLOOR_TILES $bc
.define CHEST_TILES $f8

.define FLOOR_PALETTE 1
.define CHEST_PALETTE 2

.segment "FIXED"

PROC gen_base_interior
	lda current_bank
	pha
	lda #^do_gen_base_interior
	jsr bankswitch
	jsr do_gen_base_interior & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_base_horde
	lda current_bank
	pha
	lda #^do_gen_base_horde
	jsr bankswitch
	jsr do_gen_base_horde & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_boss
	lda current_bank
	pha
	lda #^do_gen_boss
	jsr bankswitch
	jsr do_gen_boss & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC boss_main_tick
	lda current_bank
	pha
	lda #^do_boss_main_tick
	jsr bankswitch
	jsr do_boss_main_tick & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.code

PROC boss_die
	ldx cur_enemy
	lda enemy_x, x
	sta arg0
	lda enemy_y, x
	sta arg1
	jsr explode

	jsr remove_enemy

	lda #1
	sta boss_beaten
	lda #240
	sta boss_transition_time
	rts
.endproc


PROC boss_collide
	lda #10
	jsr take_damage
	jsr enemy_knockback
	rts
.endproc


PROC boss_top_right_tick
	ldx cur_enemy
	lda enemy_direction
	sta enemy_direction, x
	lda enemy_x
	clc
	adc #16
	sta enemy_x, x
	lda enemy_y
	sta enemy_y, x
	rts
.endproc


PROC boss_bot_left_tick
	ldx cur_enemy
	lda enemy_direction
	sta enemy_direction, x
	lda enemy_x
	sta enemy_x, x
	lda enemy_y
	clc
	adc #16
	sta enemy_y, x
	rts
.endproc


PROC boss_bot_right_tick
	ldx cur_enemy
	lda enemy_direction
	sta enemy_direction, x
	lda enemy_x
	clc
	adc #16
	sta enemy_x, x
	lda enemy_y
	clc
	adc #16
	sta enemy_y, x
	rts
.endproc


.segment "EXTRA"

PROC do_gen_base_interior
	jsr gen_base_common & $ffff
	jsr spawn_base_enemies & $ffff
	rts
.endproc


PROC do_gen_boss
	lda #MUSIC_HORDE
	jsr play_music

	LOAD_ALL_TILES WALL_TILES, base_border_tiles
	LOAD_ALL_TILES FLOOR_TILES, base_floor_tiles
	jsr init_zombie_sprites
	jsr init_spider_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_BOSS, boss_tiles

	; Set up collision and spawning info
	lda #WALL_TILES + BORDER_INTERIOR
	sta traversable_tiles
	lda #WALL_TILES + BORDER_INTERIOR
	sta spawnable_tiles

	lda #FLOOR_TILES
	sta traversable_range_min
	lda #FLOOR_TILES + 60
	sta traversable_range_max
	lda #FLOOR_TILES
	sta spawnable_range_min
	lda #FLOOR_TILES + 60
	sta spawnable_range_max

	LOAD_PTR base_palette
	jsr load_background_game_palette

	; Generate parameters for map generation
	jsr gen_map_opening_locations

	lda #WALL_TILES + BORDER_CENTER
	jsr gen_left_wall_small
	lda #WALL_TILES + BORDER_CENTER
	jsr gen_right_wall_small
	lda #WALL_TILES + BORDER_CENTER
	jsr gen_top_wall_very_large
	lda #WALL_TILES + BORDER_CENTER
	jsr gen_bot_wall_small
	lda #WALL_TILES + BORDER_INTERIOR
	jsr gen_walkable_path

	lda #WALL_TILES
	jsr process_border_sides

	lda #FLOOR_TILES + BORDER_CENTER + FLOOR_PALETTE
	jsr gen_walkable_path

	lda #5
	sta arg0
	lda #3
	sta arg1
	lda #9
	sta arg2
	lda #7
	sta arg3
	lda #FLOOR_TILES + BORDER_CENTER + FLOOR_PALETTE
	jsr fill_map_box

	lda #FLOOR_TILES + FLOOR_PALETTE
	jsr process_border_sides

	; Convert tiles that have not been generated into concrete
	ldy #0
yloop:
	ldx #0
xloop:
	jsr read_gen_map
	cmp #0
	bne nextblank
	lda #WALL_TILES + BORDER_INTERIOR
	jsr write_gen_map
nextblank:
	inx
	cpx #MAP_WIDTH
	bne xloop
	iny
	cpy #MAP_HEIGHT
	bne yloop

	jsr prepare_spawn

	lda #ENEMY_BOSS_TOP_LEFT
	sta arg0
	ldx #$60
	ldy #$30
	lda #0
	jsr spawn_boss & $ffff

	lda #ENEMY_BOSS_TOP_RIGHT
	sta arg0
	ldx #$70
	ldy #$30
	lda #1
	jsr spawn_boss & $ffff

	lda #ENEMY_BOSS_BOT_LEFT
	sta arg0
	ldx #$60
	ldy #$40
	lda #2
	jsr spawn_boss & $ffff

	lda #ENEMY_BOSS_BOT_RIGHT
	sta arg0
	ldx #$70
	ldy #$40
	lda #3
	jsr spawn_boss & $ffff

	lda #1
	sta horde_active

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #0
	sta enemy_health
	lda #5
	sta enemy_health + 1
	rts

hard:
	lda #0
	sta enemy_health
	lda #6
	sta enemy_health + 1
	rts

veryhard:
	lda #0
	sta enemy_health
	lda #8
	sta enemy_health + 1
	rts
.endproc


PROC spawn_boss
	stx arg2
	tax
	lda arg0
	sta enemy_type, x
	lda arg2
	sta enemy_x, x
	tya
	sta enemy_y, x
	lda #3
	sta enemy_speed_mask, x
	lda #0
	sta enemy_speed_value, x
	lda #<boss_sprites_for_state
	sta enemy_sprite_state_low, x
	lda #>boss_sprites_for_state
	sta enemy_sprite_state_high, x
	lda #0
	sta enemy_anim_frame, x
	sta enemy_knockback_time, x
	sta enemy_direction, x
	sta enemy_ai_state, x
	lda #180
	sta enemy_idle_time, x
	lda #255
	sta enemy_health, x
	rts
.endproc


PROC do_gen_base_horde
	jsr gen_base_common & $ffff
	jsr spawn_base_enemies & $ffff

	lda #MUSIC_HORDE
	jsr play_music

	lda #1
	sta horde_active
	sta horde_complete

	lda #ENEMY_NORMAL_MALE_ZOMBIE
	sta horde_enemy_types
	lda #ENEMY_NORMAL_FEMALE_ZOMBIE
	sta horde_enemy_types + 1
	lda #ENEMY_FAT_ZOMBIE
	sta horde_enemy_types + 2
	lda #ENEMY_SPIDER
	sta horde_enemy_types + 3

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #150
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #90
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

hard:
	lda #180
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #75
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

veryhard:
	lda #240
	sta horde_timer
	lda #0
	lda #60
	sta horde_spawn_timer
	sta horde_spawn_delay
	sta horde_timer + 1

hordesetup:
	rts
.endproc


PROC spawn_base_enemies
	; Create enemies
	jsr prepare_spawn
	jsr restore_enemies
	bne restoredspawn

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #4
	jsr rand_range
	clc
	adc #1
	tax
	jmp spawnloop & $ffff

hard:
	lda #5
	jsr rand_range
	clc
	adc #2
	tax
	jmp spawnloop & $ffff

veryhard:
	lda #3
	jsr rand_range
	clc
	adc #5
	tax

spawnloop:
	txa
	pha

	lda #4
	jsr rand_range
	tax
	lda base_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC gen_base_common
	lda #MUSIC_CAVE
	jsr play_music

	LOAD_ALL_TILES WALL_TILES, base_border_tiles
	LOAD_ALL_TILES FLOOR_TILES, base_floor_tiles
	jsr init_zombie_sprites
	jsr init_spider_sprites

	; Set up collision and spawning info
	lda #WALL_TILES + BORDER_INTERIOR
	sta traversable_tiles
	lda #WALL_TILES + BORDER_INTERIOR
	sta spawnable_tiles

	lda #FLOOR_TILES
	sta traversable_range_min
	lda #FLOOR_TILES + 60
	sta traversable_range_max
	lda #FLOOR_TILES
	sta spawnable_range_min
	lda #FLOOR_TILES + 60
	sta spawnable_range_max

	LOAD_PTR base_palette
	jsr load_background_game_palette

	; Generate parameters for map generation
	jsr gen_map_opening_locations

	lda #WALL_TILES + BORDER_CENTER
	jsr gen_left_wall_large
	lda #WALL_TILES + BORDER_CENTER
	jsr gen_right_wall_large
	lda #WALL_TILES + BORDER_CENTER
	jsr gen_top_wall_large
	lda #WALL_TILES + BORDER_CENTER
	jsr gen_bot_wall_large
	lda #WALL_TILES + BORDER_INTERIOR
	jsr gen_walkable_path

	lda #WALL_TILES
	jsr process_border_sides

	lda #FLOOR_TILES + BORDER_CENTER + FLOOR_PALETTE
	jsr gen_walkable_path

	lda #5
	sta arg0
	lda #3
	sta arg1
	lda #9
	sta arg2
	lda #7
	sta arg3
	lda #FLOOR_TILES + BORDER_CENTER + FLOOR_PALETTE
	jsr fill_map_box

	lda #FLOOR_TILES + FLOOR_PALETTE
	jsr process_border_sides

	; Convert tiles that have not been generated into concrete
	ldy #0
yloop:
	ldx #0
xloop:
	jsr read_gen_map
	cmp #0
	bne nextblank
	lda #WALL_TILES + BORDER_INTERIOR
	jsr write_gen_map
nextblank:
	inx
	cpx #MAP_WIDTH
	bne xloop
	iny
	cpy #MAP_HEIGHT
	bne yloop

	rts
.endproc


PROC do_boss_main_tick
	ldx cur_enemy
	lda enemy_ai_state, x
	cmp #0
	beq spawnstate
	cmp #1
	beq walkstate
	cmp #2
	beq waitstate
	cmp #3
	beq firestate

	dec enemy_idle_time, x
	beq gotospawnstate
	rts

gotospawnstate:
	lda #0
	sta enemy_ai_state, x
	lda #180
	sta enemy_idle_time, x
	rts

waitstate:
	jmp dowaitstate & $ffff
firestate:
	jmp dofirestate & $ffff

spawnstate:
	dec enemy_idle_time, x
	beq gotowalkstate
	lda enemy_idle_time, x
	and #63
	beq spawn
	rts

spawn:
	lda #2
	jsr rand_range
	cmp #0
	beq spawnzombie

	lda #ENEMY_SPIDER
	jsr spawn_starting_enemy
	rts

spawnzombie:
	lda #ENEMY_FAT_ZOMBIE
	jsr spawn_starting_enemy
	rts

gotowalkstate:
	lda #1
	sta enemy_ai_state, x
	lda #$60
	jsr rand_range
	clc
	adc #$30
	ldx cur_enemy
	sta enemy_walk_target, x
	lda #2
	sta enemy_direction, x
	rts

walkstate:
	inc enemy_idle_time, x
	lda enemy_idle_time, x
	and #8
	lsr
	lsr
	lsr
	ora #2
	sta enemy_direction, x

	lda enemy_x, x
	cmp enemy_walk_target, x
	beq gotowaitstate
	bcc walkright

	dec enemy_x, x
	rts

walkright:
	inc enemy_x, x
	rts

gotowaitstate:
	lda #2
	sta enemy_ai_state, x
	lda #30
	sta enemy_idle_time, x
	lda #0
	sta enemy_direction, x
	rts

dowaitstate:
	dec enemy_idle_time, x
	beq gotofirestate
	rts

gotofirestate:
	lda #3
	sta enemy_ai_state, x
	lda #60
	sta enemy_idle_time, x
	lda #1
	sta enemy_direction, x
	rts

dofirestate:
	dec enemy_idle_time, x
	beq gotoafterstate

	lda enemy_idle_time, x
	cmp #50
	beq shootgrenade
	cmp #20
	beq shootlasers
	rts

shootgrenade:
	lda enemy_x, x
	clc
	adc #8
	sta arg0
	lda enemy_y, y
	clc
	adc #16
	sta arg1
	lda #EFFECT_PLAYER_GRENADE
	sta arg2
	lda #JOY_DOWN
	sta arg3
	jsr create_effect
	rts

shootlasers:
	lda #10
	sta arg4
	lda #5
	sta arg5
	jsr fire_laser & $ffff

	lda #20
	sta arg4
	lda #5
	sta arg5
	jsr fire_laser & $ffff

	rts

gotoafterstate:
	lda #4
	sta enemy_ai_state, x
	lda #30
	sta enemy_idle_time, x
	lda #0
	sta enemy_direction, x
	rts
.endproc


.bss

VAR boss_beaten
	.byte 0
VAR boss_transition_time
	.byte 0


.data

VAR base_palette
	.byte $0f, $0c, $00, $10
	.byte $0f, $00, $2d, $10
	.byte $0f, $08, $07, $27
	.byte $0f, $08, $00, $10

VAR normal_base_chest_palette
	.byte $0f, $08, $07, $27
VAR trapped_base_chest_palette
	.byte $0f, $08, $0f, $18

VAR base_enemy_types
	.byte ENEMY_NORMAL_MALE_ZOMBIE, ENEMY_NORMAL_FEMALE_ZOMBIE, ENEMY_FAT_ZOMBIE, ENEMY_SPIDER

VAR boss_top_left_descriptor
	.word boss_main_tick
	.word boss_die
	.word boss_collide
	.word boss_sprites_for_state
	.byte SPRITE_TILE_BOSS
	.byte 1
	.byte 3, 0
	.byte 255

VAR boss_top_right_descriptor
	.word boss_top_right_tick
	.word boss_die
	.word boss_collide
	.word boss_sprites_for_state
	.byte SPRITE_TILE_BOSS + 4
	.byte 1
	.byte 3, 0
	.byte 255

VAR boss_bot_left_descriptor
	.word boss_bot_left_tick
	.word boss_die
	.word boss_collide
	.word boss_sprites_for_state
	.byte SPRITE_TILE_BOSS + $20
	.byte 1
	.byte 3, 0
	.byte 255

VAR boss_bot_right_descriptor
	.word boss_bot_right_tick
	.word boss_die
	.word boss_collide
	.word boss_sprites_for_state
	.byte SPRITE_TILE_BOSS + $24
	.byte 1
	.byte 3, 0
	.byte 255

VAR boss_sprites_for_state
	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $00 + 1, $00
	.byte $02 + 1, $00
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	.byte $08 + 1, $00
	.byte $0a + 1, $00
	.byte $10 + 1, $00
	.byte $12 + 1, $00
	.byte $10 + 1, $00
	.byte $12 + 1, $00
	.byte $18 + 1, $00
	.byte $1a + 1, $00
	.byte $18 + 1, $00
	.byte $1a + 1, $00


TILES base_border_tiles, 4, "tiles/lab/wall.chr", 60
TILES base_floor_tiles, 4, "tiles/lab/water.chr", 60
TILES boss_tiles, 4, "tiles/enemies/bosses/init.chr", 64
