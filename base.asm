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


.segment "EXTRA"

PROC do_gen_base_interior
	jsr gen_base_common & $ffff
	jsr spawn_base_enemies & $ffff
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


TILES base_border_tiles, 4, "tiles/lab/wall.chr", 60
TILES base_floor_tiles, 4, "tiles/lab/water.chr", 60
