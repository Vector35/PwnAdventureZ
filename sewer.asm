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
.define WATER_TILES $bc
.define EXIT_TILES  $f8
.define CHEST_TILES $f8

.define WATER_PALETTE 1
.define CHEST_PALETTE 2

.segment "FIXED"

PROC gen_sewer
	lda current_bank
	pha
	lda #^do_gen_sewer
	jsr bankswitch
	jsr do_gen_sewer & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_sewer_up
	lda current_bank
	pha
	lda #^do_gen_sewer_up
	jsr bankswitch
	jsr do_gen_sewer_up & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_sewer_boss
	lda current_bank
	pha
	lda #^do_gen_sewer_boss
	jsr bankswitch
	jsr do_gen_sewer_boss & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC sewer_exit_interact
	lda current_bank
	pha
	lda #^do_sewer_exit_interact
	jsr bankswitch
	jsr do_sewer_exit_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC key_chest_2_interact
	lda current_bank
	pha
	lda #^do_key_chest_2_interact
	jsr bankswitch
	jsr do_key_chest_2_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_gen_sewer
	jsr gen_sewer_common & $ffff
	jsr spawn_sewer_enemies & $ffff
	rts
.endproc


PROC do_gen_sewer_boss
	jsr gen_sewer_common & $ffff

	LOAD_ALL_TILES CHEST_TILES, forest_chest_tiles
	lda #INTERACT_KEY_CHEST_2
	sta interactive_tile_types
	lda #CHEST_TILES
	sta interactive_tile_values
	lda #INTERACT_KEY_CHEST_2
	sta interactive_tile_types + 1
	lda #CHEST_TILES + 4
	sta interactive_tile_values + 1

	lda completed_quest_steps
	and #QUEST_KEY_2
	bne questcomplete

	ldx #10
	ldy #3
	lda #CHEST_TILES + CHEST_PALETTE
	jsr write_gen_map
	jmp chestdone & $ffff

questcomplete:
	ldx #10
	ldy #3
	lda #CHEST_TILES + 4 + CHEST_PALETTE
	jsr write_gen_map

chestdone:
	lda #0
	sta horde_active
	sta horde_complete

	lda #ENEMY_SPIDER
	sta horde_enemy_types
	lda #ENEMY_RAT
	sta horde_enemy_types + 1
	sta horde_enemy_types + 2
	sta horde_enemy_types + 3

	jsr spawn_sewer_enemies & $ffff
	rts
.endproc


PROC do_gen_sewer_up
	jsr gen_sewer_common & $ffff

	LOAD_ALL_TILES EXIT_TILES, sewer_exit_tiles
	lda #INTERACT_SEWER_EXIT
	sta interactive_tile_types
	lda #EXIT_TILES
	sta interactive_tile_values

	ldx #6
	ldy #3
	lda #WALL_TILES
	jsr write_gen_map
	ldx #7
	lda #WALL_TILES + 4
	jsr write_gen_map
	ldx #8
	lda #WALL_TILES + 8
	jsr write_gen_map
	ldx #6
	ldy #4
	lda #WALL_TILES + 40
	jsr write_gen_map
	ldx #7
	lda #EXIT_TILES
	jsr write_gen_map
	ldx #8
	lda #WALL_TILES + 36
	jsr write_gen_map
	ldx #6
	ldy #5
	lda #WATER_TILES + 56
	jsr write_gen_map
	ldx #7
	jsr write_gen_map
	ldx #8
	jsr write_gen_map

	rts
.endproc


PROC spawn_sewer_enemies
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
	lda sewer_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC gen_sewer_common
	lda #MUSIC_CAVE
	jsr play_music

	LOAD_ALL_TILES WALL_TILES, sewer_border_tiles
	LOAD_ALL_TILES WATER_TILES, sewer_water_tiles
	jsr init_spider_sprites
	jsr init_rat_sprites

	; Set up collision and spawning info
	lda #WALL_TILES + BORDER_INTERIOR
	sta traversable_tiles
	lda #WALL_TILES + BORDER_INTERIOR
	sta spawnable_tiles

	lda #WATER_TILES
	sta traversable_range_min
	lda #WATER_TILES + 60
	sta traversable_range_max
	lda #WATER_TILES
	sta spawnable_range_min
	lda #WATER_TILES + 60
	sta spawnable_range_max

	LOAD_PTR sewer_palette
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

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_SEWER_BOSS
	beq nowater

	lda #WATER_TILES + BORDER_CENTER + WATER_PALETTE
	jsr gen_walkable_path

	lda #5
	sta arg0
	lda #3
	sta arg1
	lda #9
	sta arg2
	lda #7
	sta arg3
	lda #WATER_TILES + BORDER_CENTER + WATER_PALETTE
	jsr fill_map_box

	lda #WATER_TILES + WATER_PALETTE
	jsr process_border_sides

nowater:
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


PROC do_sewer_exit_interact
	jsr fade_out

	jsr activate_overworld_map

	lda #<overworld_visited
	sta map_visited_ptr
	lda #>overworld_visited
	sta map_visited_ptr + 1

	jsr generate_minimap_cache
	jsr invalidate_enemy_cache

	lda #$70
	sta player_x
	lda #$50
	sta player_y

	lda #1
	sta warp_to_new_screen
	rts
.endproc


PROC do_key_chest_2_interact
	lda completed_quest_steps
	and #QUEST_KEY_2
	beq notcompleted
	jmp completed & $ffff

notcompleted:
	lda horde_active
	bne inhorde

	lda horde_complete
	bne done

	LOAD_PTR start_horde_text
	lda #^start_horde_text
	jsr show_chat_text

	lda #1
	sta horde_active

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #45
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #120
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

hard:
	lda #60
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #90
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

veryhard:
	lda #75
	sta horde_timer
	lda #0
	lda #60
	sta horde_spawn_timer
	sta horde_spawn_delay
	sta horde_timer + 1

hordesetup:
	jsr wait_for_vblank
	LOAD_PTR trapped_sewer_chest_palette
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	lda #MUSIC_HORDE
	jsr play_music

	rts

inhorde:
	LOAD_PTR locked_chest_text
	lda #^locked_chest_text
	jsr show_chat_text
	rts

done:
	lda completed_quest_steps
	ora #QUEST_KEY_2
	sta completed_quest_steps
	lda highlighted_quest_steps
	and #$ff & (~QUEST_KEY_2)
	sta highlighted_quest_steps

	lda completed_quest_steps
	and #QUEST_KEY_3
	bne key2done
	lda highlighted_quest_steps
	ora #QUEST_KEY_3
	sta highlighted_quest_steps

key2done:
	inc key_count

	lda key_count
	cmp #6
	bne notallkeys
	lda highlighted_quest_steps
	ora #QUEST_END
	sta highlighted_quest_steps
notallkeys:

	lda #ITEM_SHOTGUN
	jsr give_item
	lda #ITEM_GEM
	ldx #35
	jsr give_item_with_count
	lda #ITEM_HEALTH_KIT
	ldx #5
	jsr give_item_with_count

	jsr save

	jsr wait_for_vblank
	ldx #10
	ldy #3
	lda #CHEST_TILES + 4 + CHEST_PALETTE
	jsr write_large_tile
	jsr prepare_for_rendering

	PLAY_SOUND_EFFECT effect_open

completed:
	LOAD_PTR key_2_text
	lda #^key_2_text
	jsr show_chat_text
	rts
.endproc


.data

VAR sewer_palette
	.byte $0f, $08, $00, $10
	.byte $0f, $09, $08, $10
	.byte $0f, $08, $07, $27
	.byte $0f, $08, $00, $10

VAR normal_sewer_chest_palette
	.byte $0f, $08, $07, $27
VAR trapped_sewer_chest_palette
	.byte $0f, $08, $0f, $18

VAR sewer_enemy_types
	.byte ENEMY_SPIDER, ENEMY_RAT, ENEMY_RAT, ENEMY_RAT

VAR sewer_exit_descriptor
	.word always_interactable
	.word sewer_exit_interact

VAR key_chest_2_descriptor
	.word always_interactable
	.word key_chest_2_interact


TILES sewer_border_tiles, 4, "tiles/sewer/wall.chr", 60
TILES sewer_water_tiles, 4, "tiles/sewer/water.chr", 60
TILES sewer_exit_tiles, 4, "tiles/sewer/exit.chr", 4


.segment "UI"

VAR key_2_text
	.byte "YOU FOUND THE SECOND", 0
	.byte "KEY! INSIDE THE CHEST", 0
	.byte "IS ALSO THE LOCATION", 0
	.byte "OF THE NEXT KEY.", 0
	.byte 0
