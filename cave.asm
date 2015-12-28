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

.define NOTE_PALETTE 1

.segment "FIXED"

PROC gen_cave_start
	lda current_bank
	pha
	lda #^do_gen_cave_start
	jsr bankswitch
	jsr do_gen_cave_start & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_starting_cave
	lda #MUSIC_CAVE
	jsr play_music

	jsr gen_cave_common
	rts
.endproc


PROC gen_cave_interior
	lda current_bank
	pha
	lda #^do_gen_cave_interior
	jsr bankswitch
	jsr do_gen_cave_interior & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_cave_chest
	lda current_bank
	pha
	lda #^do_gen_cave_chest
	jsr bankswitch
	jsr do_gen_cave_chest & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_cave_boss
	lda current_bank
	pha
	lda #^do_gen_cave_boss
	jsr bankswitch
	jsr do_gen_cave_boss & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_mine_down
	lda current_bank
	pha
	lda #^do_gen_mine_down
	jsr bankswitch
	jsr do_gen_mine_down & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_blocky_cave_interior
	lda current_bank
	pha
	lda #^do_gen_blocky_cave_interior
	jsr bankswitch
	jsr do_gen_blocky_cave_interior & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_lost_cave
	lda current_bank
	pha
	lda #^do_gen_lost_cave
	jsr bankswitch
	jsr do_gen_lost_cave & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_lost_cave_wall
	lda current_bank
	pha
	lda #^do_gen_lost_cave_wall
	jsr bankswitch
	jsr do_gen_lost_cave_wall & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_lost_cave_end
	lda current_bank
	pha
	lda #^do_gen_lost_cave_end
	jsr bankswitch
	jsr do_gen_lost_cave_end & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC check_lost_cave_wall_explosion
	lda current_bank
	pha
	lda #^do_check_lost_cave_wall_explosion
	jsr bankswitch
	jsr do_check_lost_cave_wall_explosion & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_lost_cave_chest
	lda current_bank
	pha
	lda #^do_gen_lost_cave_chest
	jsr bankswitch
	jsr do_gen_lost_cave_chest & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_cave_common
	lda current_bank
	pha
	lda #^do_gen_cave_common
	jsr bankswitch
	jsr do_gen_cave_common & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC is_cave_chest_interactable
	lda minor_chests_opened
	and #MINOR_CHEST_CAVE
	rts
.endproc


PROC is_lost_cave_chest_interactable
	lda minor_chests_opened
	and #MINOR_CHEST_CAVE
	rts
.endproc


PROC cave_chest_interact
	lda current_bank
	pha
	lda #^do_cave_chest_interact
	jsr bankswitch
	jsr do_cave_chest_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC lost_cave_chest_interact
	lda current_bank
	pha
	lda #^do_lost_cave_chest_interact
	jsr bankswitch
	jsr do_lost_cave_chest_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC is_lost_cave_end_interactable
	lda lost_cave_large_chest_opened
	rts
.endproc


PROC lost_cave_end_interact
	lda current_bank
	pha
	lda #^do_lost_cave_end_interact
	jsr bankswitch
	jsr do_lost_cave_end_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC lost_cave_note_interact
	lda current_bank
	pha
	lda #^do_lost_cave_note_interact
	jsr bankswitch
	jsr do_lost_cave_note_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_gen_cave_start
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	; Place chest in the starting room to get the initial weapon
	LOAD_ALL_TILES $0f0, chest_tiles
	LOAD_ALL_TILES $0f8, note_tiles

	lda #INTERACT_STARTING_CHEST
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values

	lda #INTERACT_STARTING_NOTE
	sta interactive_tile_types + 1
	lda #$f8
	sta interactive_tile_values + 1

	ldx #9
	ldy #3
	lda #$f8 + NOTE_PALETTE
	jsr write_gen_map

	ldx #7
	ldy #4

	lda starting_chest_opened
	bne opened
	lda #$f0
	jsr write_gen_map
	rts

opened:
	lda #$f4
	jsr write_gen_map
	rts
.endproc


PROC do_gen_cave_interior
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff
	jsr gen_cave_enemies & $ffff
	rts
.endproc


PROC do_gen_cave_chest
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	LOAD_ALL_TILES $0f0, small_chest_tiles

	lda #INTERACT_CAVE_CHEST
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values

	lda minor_chests_opened
	and #MINOR_CHEST_CAVE
	bne questcomplete

	ldx #7
	ldy #4
	lda #$f0 + 2
	jsr write_gen_map
	jmp chestdone & $ffff

questcomplete:
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_gen_map

chestdone:
	jsr gen_cave_enemies & $ffff
	rts
.endproc


PROC do_gen_lost_cave
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	jsr read_overworld_left
	and #$3f
	cmp #MAP_LOST_CAVE_WALL
	bne done

	lda #$b8
	ldx #0
	ldy #5
	jsr write_gen_map
	ldx #1
	jsr write_gen_map
	ldx #2
	jsr write_gen_map
	ldx #0
	ldy #7
	jsr write_gen_map
	ldx #1
	jsr write_gen_map
	ldx #2
	jsr write_gen_map
	lda #0
	ldx #0
	ldy #6
	jsr write_gen_map
	ldx #1
	jsr write_gen_map
	ldx #2
	jsr write_gen_map

done:
	jsr gen_cave_enemies & $ffff
	rts
.endproc


PROC do_gen_lost_cave_wall
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	LOAD_ALL_TILES $0f0, small_chest_tiles

	lda lost_cave_wall_state
	beq notblown

	lda #$b8
	ldx #12
	ldy #5
	jsr write_gen_map
	ldx #13
	jsr write_gen_map
	ldx #14
	jsr write_gen_map
	ldx #12
	ldy #7
	jsr write_gen_map
	ldx #13
	jsr write_gen_map
	ldx #14
	jsr write_gen_map
	lda #0
	ldx #12
	ldy #6
	jsr write_gen_map
	ldx #13
	jsr write_gen_map
	ldx #14
	jsr write_gen_map
notblown:

chestdone:
	jsr gen_cave_enemies & $ffff
	rts
.endproc


PROC do_check_lost_cave_wall_explosion
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_LOST_CAVE_WALL
	beq look
	rts

look:
	lda lost_cave_wall_state
	bne done

	lda arg0
	cmp #$a0
	bcc done

	lda arg1
	cmp #$30
	bcc done
	cmp #$90
	bcs done

	jmp blown & $ffff

done:
	rts

blown:
	lda arg0
	pha
	lda arg1
	pha

	lda #1
	sta lost_cave_wall_state

	jsr wait_for_vblank
	lda #$b8
	ldx #12
	ldy #5
	jsr write_large_tile
	lda #$b8
	ldx #13
	ldy #5
	jsr write_large_tile

	jsr prepare_for_rendering
	jsr wait_for_vblank

	lda #$b8
	ldx #14
	ldy #5
	jsr write_large_tile
	lda #$b8
	ldx #12
	ldy #7
	jsr write_large_tile

	jsr prepare_for_rendering
	jsr wait_for_vblank

	lda #$b8
	ldx #13
	ldy #7
	jsr write_large_tile
	lda #$b8
	ldx #14
	ldy #7
	jsr write_large_tile

	jsr prepare_for_rendering
	jsr wait_for_vblank

	lda #0
	ldx #12
	ldy #6
	jsr write_large_tile
	lda #0
	ldx #13
	ldy #6
	jsr write_large_tile

	jsr prepare_for_rendering
	jsr wait_for_vblank

	lda #0
	ldx #14
	ldy #6
	jsr write_large_tile

	jsr prepare_for_rendering

	lda collision + 11
	and #$f0
	sta collision + 11
	lda collision + 13
	ora #$f
	sta collision + 13
	lda collision + 15
	and #$f0
	sta collision + 15

	pla
	sta arg1
	pla
	sta arg0
	rts
.endproc


PROC do_gen_lost_cave_end
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	LOAD_ALL_TILES $0f0, chest_tiles
	LOAD_ALL_TILES $0f8, note_tiles

	lda #INTERACT_LOST_CAVE_END
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values

	lda #INTERACT_LOST_CAVE_NOTE
	sta interactive_tile_types + 1
	lda #$f8
	sta interactive_tile_values + 1

	lda lost_cave_large_chest_opened
	bne questcomplete

	ldx #7
	ldy #4
	lda #$f0 + 2
	jsr write_gen_map
	jmp chestdone & $ffff

questcomplete:
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_gen_map

chestdone:
	ldx #9
	ldy #5
	lda #$f8 + NOTE_PALETTE
	jsr write_gen_map

	jsr gen_cave_enemies & $ffff
	rts
.endproc


PROC do_gen_lost_cave_chest
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	LOAD_ALL_TILES $0f0, small_chest_tiles

	lda #INTERACT_LOST_CAVE_CHEST
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values

	lda minor_chests_opened
	and #MINOR_CHEST_LOST_CAVE
	bne questcomplete

	ldx #7
	ldy #4
	lda #$f0 + 2
	jsr write_gen_map
	jmp chestdone & $ffff

questcomplete:
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_gen_map

chestdone:
	jsr gen_cave_enemies & $ffff
	rts
.endproc


PROC gen_cave_enemies
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
	jsr genrange_enemy
	clc
	adc #1
	tax
	jmp spawnloop & $ffff

hard:
	lda #5
	jsr genrange_enemy
	clc
	adc #2
	tax
	jmp spawnloop & $ffff

veryhard:
	lda #3
	jsr genrange_enemy
	clc
	adc #5
	tax

spawnloop:
	txa
	pha

	lda #5
	jsr genrange_enemy
	tax
	lda cave_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC do_gen_blocky_cave_interior
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	; Create enemies
	jsr prepare_spawn
	jsr restore_enemies
	bne restoredspawn

	lda #2
	jsr genrange_enemy
	clc
	adc #1
	tax

spawnloop:
	txa
	pha

	lda #3
	jsr genrange_enemy
	tax
	lda cave_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC do_gen_cave_boss
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	LOAD_ALL_TILES $0f0, chest_tiles

	lda #INTERACT_KEY_CHEST_4
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values
	lda #INTERACT_KEY_CHEST_4
	sta interactive_tile_types + 1
	lda #$f4
	sta interactive_tile_values + 1

	lda completed_quest_steps
	and #QUEST_KEY_4
	bne questcomplete

	ldx #7
	ldy #4
	lda #$f0 + 2
	jsr write_gen_map
	jmp chestdone & $ffff

questcomplete:
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_gen_map

chestdone:
	lda #0
	sta horde_active
	sta horde_complete

	lda #ENEMY_NORMAL_MALE_ZOMBIE
	sta horde_enemy_types
	lda #ENEMY_SPIDER
	sta horde_enemy_types + 1
	sta horde_enemy_types + 2
	lda #ENEMY_FAT_ZOMBIE
	sta horde_enemy_types + 3

	jsr gen_cave_enemies & $ffff
	rts
.endproc


PROC gen_mine_ladder
	ldx #5
	ldy #4
	lda #$80 + 52
	jsr write_gen_map
	ldx #6
	lda #$80 + 28
	jsr write_gen_map
	ldx #7
	jsr write_gen_map
	ldx #8
	jsr write_gen_map
	ldx #9
	lda #$80 + 48
	jsr write_gen_map
	ldx #5
	ldy #5
	lda #$80 + 20
	jsr write_gen_map
	ldx #6
	lda #$80 + 12
	jsr write_gen_map
	ldx #7
	lda #$f0 + 2
	jsr write_gen_map
	ldx #8
	lda #$80 + 20
	jsr write_gen_map
	ldx #9
	lda #$80 + 12
	jsr write_gen_map
	ldx #5
	ldy #6
	lda #$80 + 40
	jsr write_gen_map
	ldx #6
	lda #$80 + 36
	jsr write_gen_map
	ldx #7
	lda #0
	jsr write_gen_map
	ldx #8
	lda #$80 + 40
	jsr write_gen_map
	ldx #9
	lda #$80 + 36
	jsr write_gen_map
	rts
.endproc


PROC do_gen_mine_down
	lda #MUSIC_CAVE
	jsr play_music

	jsr do_gen_cave_common & $ffff

	LOAD_PTR mine_down_palette
	jsr load_background_game_palette

	; Place chest in the starting room to get the initial weapon
	LOAD_ALL_TILES $0f0, cave_ladder_tiles

	lda #INTERACT_MINE_ENTRANCE
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values

	jsr gen_mine_ladder & $ffff
	rts
.endproc


PROC do_gen_cave_common
	; Load cave tiles
	LOAD_ALL_TILES $080, cave_border_tiles
	jsr init_zombie_sprites
	jsr init_spider_sprites

	; Set up collision and spawning info
	lda #$80 + BORDER_INTERIOR
	sta traversable_tiles
	lda #$80 + BORDER_INTERIOR
	sta spawnable_tiles

	; Load cave palette
	LOAD_PTR cave_palette
	jsr load_background_game_palette

	; Generate parameters for map generation
	jsr gen_map_opening_locations

	; Generate the sides of the cave wall
	lda #$80 + BORDER_CENTER
	jsr gen_left_wall_large
	lda #$80 + BORDER_CENTER
	jsr gen_right_wall_large
	lda #$80 + BORDER_CENTER
	jsr gen_top_wall_large
	lda #$80 + BORDER_CENTER
	jsr gen_bot_wall_large

	lda #$80 + BORDER_INTERIOR
	jsr gen_walkable_path

	; In the starting cave, make sure the player spawn point is not covered
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_START
	beq startcave
	cmp #MAP_MINE_UP
	beq noclutter
	cmp #MAP_MINE_DOWN
	beq noclutter
	jmp notstartcave & $ffff

noclutter:
	jmp clutterend & $ffff

startcave:
	lda #6
	sta arg0
	lda #3
	sta arg1
	lda #8
	sta arg2
	lda #7
	sta arg3
	lda #$80 + BORDER_INTERIOR
	jsr fill_map_box

notstartcave:
	; Create clutter in the middle of the cave
	lda #5
	jsr genrange_cur
	sta clutter_count

clutterloop:
	lda clutter_count
	bne placeclutter
	jmp clutterend & $ffff
placeclutter:

	lda #4
	jsr genrange_cur
	sta clutter_size

	lda #8
	sta arg5

cluttertry:
	; Generate clutter position
	lda #11
	jsr genrange_cur
	clc
	adc #2
	sta arg0

	lda #8
	jsr genrange_cur
	clc
	adc #2
	sta arg1

	lda clutter_size
	cmp #0
	beq smallclutter

	ldx arg0
	inx
	stx arg2
	ldy arg1
	iny
	sty arg3
	jmp checkclutter & $ffff

smallclutter:
	lda arg0
	sta arg2
	lda arg1
	sta arg3

checkclutter:
	; Check to ensure clutter isn't blocking anything.  It must be surrounded with the
	; same type of blank space (not critical path, or all critical path) to ensure that
	; it will not block all paths to exits
	ldx arg0
	dex
	ldy arg1
	dey
	jsr read_gen_map
	cmp #0
	beq clutterblank
	cmp #$80 + BORDER_INTERIOR
	bne clutterblock
clutterblank:
	sta arg4

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg1
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg1
	iny
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	ldy arg1
	iny
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg3
	iny
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg2
	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	; Clutter is not blocking any paths, place it now
	lda #$80 + BORDER_CENTER
	jsr fill_map_box
	jmp nextclutter & $ffff

clutterblock:
	; Clutter was blocking, try again up to a max number of tries
	ldx arg5
	dex
	stx arg5
	beq nextclutter
	jmp cluttertry & $ffff

nextclutter:
	ldx clutter_count
	dex
	stx clutter_count
	jmp clutterloop & $ffff
clutterend:

	lda #$80
	jsr process_border_sides

	rts
.endproc


.segment "FIXED"

PROC process_border_sides
	sta border_tile_base
	clc
	adc #BORDER_INTERIOR
	sta border_tile_interior
	lda border_tile_base
	clc
	adc #BORDER_CENTER
	sta border_tile_wall

	lda current_bank
	pha
	lda #^do_process_border_sides
	jsr bankswitch
	jsr do_process_border_sides & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "CHR4"

PROC do_process_border_sides
	; Convert rock walls into the correct tile to account for surroundings.  This will
	; give them a contour along the edges.
	ldy #0
yloop:
	ldx #0
xloop:
	jsr process_border_sides_for_tile & $ffff
	inx
	cpx #MAP_WIDTH
	bne xloop
	iny
	cpy #MAP_HEIGHT
	bne yloop
	rts
.endproc


PROC process_border_sides_for_tile
	txa
	sta arg0
	tya
	sta arg1

	; If the tile is empty space, don't touch it
	jsr read_gen_map
	cmp border_tile_wall
	beq solid
	jmp done & $ffff
solid:

	; Create a bit mask based on the 8 surrounding tiles, where the bit is set
	; if the tile is a border wall or outside the map
	lda #0
	sta arg4
	lda #$80
	sta arg5

	lda #$ff
	sta arg3
yloop:
	lda #$ff
	sta arg2
xloop:
	; Skip center as we already know it is solid, and we have only 8 bits
	lda arg2
	cmp #0
	bne notcenter
	lda arg3
	cmp #0
	bne notcenter
	jmp skip & $ffff

notcenter:
	; Compute X and check for bounds
	lda arg0
	clc
	adc arg2
	cmp #$ff
	beq out
	cmp #MAP_WIDTH
	beq out
	tax

	; Compute Y and check for bounds
	lda arg1
	clc
	adc arg3
	cmp #$ff
	beq out
	cmp #MAP_HEIGHT
	beq out
	tay

	; Read map and check for a border wall
	jsr read_gen_map
	cmp border_tile_base
	bcc next
	cmp border_tile_interior
	beq next

out:
	; Solid, mark the bit
	lda arg4
	ora arg5
	sta arg4

next:
	; Move to next bit
	lda arg5
	lsr
	sta arg5

skip:
	; Go to next tile
	ldx arg2
	inx
	stx arg2
	cpx #2
	bne xloop

	ldy arg3
	iny
	sty arg3
	cpy #2
	bne yloop

	; The bit mask has been generated, look it up in the table to get the proper tile
	ldy arg4
	lda border_tile_for_sides, y
	clc
	adc border_tile_base

	; Write the new tile to the map
	ldx arg0
	ldy arg1
	jsr write_gen_map

done:
	lda arg0
	tax
	lda arg1
	tay
	rts
.endproc


.segment "FIXED"

PROC is_starting_chest_interactable
	lda starting_chest_opened
	rts
.endproc


PROC starting_chest_interact
	lda current_bank
	pha
	lda #^do_starting_chest_interact
	jsr bankswitch
	jsr do_starting_chest_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC starting_note_interact
	PLAY_SOUND_EFFECT effect_select

	LOAD_PTR starting_note_text
	lda #^starting_note_text
	jsr show_chat_text

	lda completed_quest_steps
	and #QUEST_START
	bne alreadycomplete

	lda highlighted_quest_steps
	ora #QUEST_START
	sta highlighted_quest_steps

alreadycomplete:
	rts
.endproc


PROC mine_entrance_interact
	lda current_bank
	pha
	lda #^do_mine_entrance_interact
	jsr bankswitch
	jsr do_mine_entrance_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC mine_exit_interact
	lda current_bank
	pha
	lda #^do_mine_exit_interact
	jsr bankswitch
	jsr do_mine_exit_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC key_chest_4_interact
	lda current_bank
	pha
	lda #^do_key_chest_4_interact
	jsr bankswitch
	jsr do_key_chest_4_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_starting_chest_interact
	jsr wait_for_vblank

	ldx interaction_tile_x
	ldy interaction_tile_y
	lda #$f4
	jsr write_large_tile

	jsr prepare_for_rendering

	lda #ITEM_AXE
	jsr give_item

	lda #1
	sta starting_chest_opened

	jsr save

	PLAY_SOUND_EFFECT effect_open
	rts
.endproc


PROC do_mine_entrance_interact
	jsr fade_out

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #^normal_mine_map
	sta map_bank
	lda #<normal_mine_map
	sta map_ptr
	lda #>normal_mine_map
	sta map_ptr + 1
	jmp done & $ffff

hard:
	lda #^hard_mine_map
	sta map_bank
	lda #<hard_mine_map
	sta map_ptr
	lda #>hard_mine_map
	sta map_ptr + 1
	jmp done & $ffff

veryhard:
	lda #^very_hard_mine_map
	sta map_bank
	lda #<very_hard_mine_map
	sta map_ptr
	lda #>very_hard_mine_map
	sta map_ptr + 1

done:
	lda #<mine_visited
	sta map_visited_ptr
	lda #>mine_visited
	sta map_visited_ptr + 1

	jsr generate_minimap_cache
	jsr invalidate_enemy_cache

	lda #$70
	sta player_x
	lda #$60
	sta player_y

	lda #1
	sta warp_to_new_screen
	rts
.endproc


PROC do_mine_exit_interact
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
	lda #$60
	sta player_y

	lda #1
	sta warp_to_new_screen
	rts
.endproc


PROC do_key_chest_4_interact
	lda completed_quest_steps
	and #QUEST_KEY_4
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

	lda #17
	sta horde_counter
	lda #90
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

hard:
	lda #25
	sta horde_counter
	lda #60
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

veryhard:
	lda #34
	sta horde_counter
	lda #50
	sta horde_spawn_timer
	sta horde_spawn_delay

hordesetup:
	jsr wait_for_vblank
	LOAD_PTR trapped_cave_chest_palette
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
	ora #QUEST_KEY_4
	sta completed_quest_steps
	lda highlighted_quest_steps
	and #$ff & (~QUEST_KEY_4)
	sta highlighted_quest_steps

	lda completed_quest_steps
	and #QUEST_KEY_5
	bne key5done
	lda highlighted_quest_steps
	ora #QUEST_KEY_5
	sta highlighted_quest_steps

key5done:
	inc key_count

	jsr wait_for_vblank
	jsr load_key_count_tiles
	jsr prepare_for_rendering

	lda key_count
	cmp #6
	bne notallkeys
	lda highlighted_quest_steps
	ora #QUEST_END
	sta highlighted_quest_steps
notallkeys:

	lda #ITEM_HAND_CANNON
	ldx #30
	jsr give_weapon
	lda #ITEM_GEM
	ldx #5
	jsr give_item_with_count
	lda #ITEM_HEALTH_KIT
	ldx #3
	jsr give_item_with_count

	jsr save

	jsr wait_for_vblank
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_large_tile
	jsr prepare_for_rendering

	PLAY_SOUND_EFFECT effect_open

completed:
	LOAD_PTR key_4_text
	lda #^key_4_text
	jsr show_chat_text
	rts
.endproc


PROC do_cave_chest_interact
	lda #ITEM_TINFOIL_HAT
	jsr give_item
	lda #ITEM_GEM
	ldx #3
	jsr give_item_with_count
	lda #ITEM_HEALTH_KIT
	ldx #1
	jsr give_item_with_count

	lda minor_chests_opened
	ora #MINOR_CHEST_CAVE
	sta minor_chests_opened

	jsr save

	jsr wait_for_vblank
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_large_tile
	jsr prepare_for_rendering

	PLAY_SOUND_EFFECT effect_open
	rts
.endproc


PROC do_lost_cave_chest_interact
	lda #ITEM_GRENADE
	ldx #5
	jsr give_item_with_count
	lda #ITEM_GEM
	ldx #3
	jsr give_item_with_count
	lda #ITEM_HEALTH_KIT
	ldx #2
	jsr give_item_with_count

	lda minor_chests_opened
	ora #MINOR_CHEST_LOST_CAVE
	sta minor_chests_opened

	jsr save

	jsr wait_for_vblank
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_large_tile
	jsr prepare_for_rendering

	PLAY_SOUND_EFFECT effect_open
	rts
.endproc


PROC do_lost_cave_end_interact
	lda lost_cave_wall_state
	beq done

	jsr wait_for_vblank

	ldx interaction_tile_x
	ldy interaction_tile_y
	lda #$f4
	jsr write_large_tile

	jsr prepare_for_rendering

	lda #ITEM_ROCKET
	ldx #20
	jsr give_weapon
	lda #ITEM_GEM
	ldx #5
	jsr give_item_with_count

	lda #1
	sta lost_cave_large_chest_opened

	jsr save

	PLAY_SOUND_EFFECT effect_open
done:
	rts
.endproc


PROC do_lost_cave_note_interact
	PLAY_SOUND_EFFECT effect_select

	LOAD_PTR lost_cave_flag_text
	lda #^lost_cave_flag_text
	jsr show_chat_text

	rts
.endproc


.bss
VAR starting_chest_opened
	.byte 0

VAR lost_cave_wall_state
	.byte 0

VAR lost_cave_large_chest_opened
	.byte 0


.segment "TEMP"
VAR border_tile_base
	.byte 0
VAR border_tile_interior
	.byte 0
VAR border_tile_wall
	.byte 0


.data
VAR cave_palette
	.byte $0f, $07, $17, $27
	.byte $0f, $16, $27, $37
	.byte $0f, $07, $17, $27
	.byte $0f, $07, $17, $27

VAR mine_down_palette
	.byte $0f, $07, $17, $27
	.byte $0f, $16, $27, $37
	.byte $0f, $00, $10, $30
	.byte $0f, $07, $17, $27

VAR trapped_cave_chest_palette
	.byte $0f, $08, $18, $28
VAR normal_cave_chest_palette
	.byte $0f, $07, $17, $27

VAR starting_chest_descriptor
	.word is_starting_chest_interactable
	.word starting_chest_interact

VAR starting_note_descriptor
	.word always_interactable
	.word starting_note_interact

VAR mine_entrance_descriptor
	.word always_interactable
	.word mine_entrance_interact

VAR mine_exit_descriptor
	.word always_interactable
	.word mine_exit_interact

VAR key_chest_4_descriptor
	.word always_interactable
	.word key_chest_4_interact

VAR cave_chest_descriptor
	.word is_cave_chest_interactable
	.word cave_chest_interact

VAR lost_cave_chest_descriptor
	.word is_lost_cave_chest_interactable
	.word lost_cave_chest_interact

VAR lost_cave_end_descriptor
	.word is_lost_cave_end_interactable
	.word lost_cave_end_interact

VAR lost_cave_note_descriptor
	.word always_interactable
	.word lost_cave_note_interact


VAR cave_enemy_types
	.byte ENEMY_NORMAL_MALE_ZOMBIE, ENEMY_NORMAL_FEMALE_ZOMBIE, ENEMY_SPIDER, ENEMY_SPIDER, ENEMY_FAT_ZOMBIE


TILES cave_border_tiles, 2, "tiles/cave/border.chr", 60
TILES chest_tiles, 2, "tiles/cave/chest2.chr", 8
TILES small_chest_tiles, 3, "tiles/cave/chest-small.chr", 8
TILES note_tiles, 2, "tiles/items/note.chr", 4
TILES cave_ladder_tiles, 4, "tiles/cave/ladder.chr", 4


; Place a lookup table for determining which tile to use based on the 8 surrounding tiles.  This
; is represented with a bit field, with $80 representing the top left and $01 representing the
; bottom right.
VAR border_tile_for_sides
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $00
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $04
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $08
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $0c
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $10
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_BOT_LEFT, BORDER_INNER_BOT_LEFT ; $14
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_LEFT_UP, BORDER_LEFT_UP ; $18
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_RIGHT_UP, BORDER_OUTER_BOT_CENTER ; $1c
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $20
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $24
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $28
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $2c
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $30
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_BOT_LEFT, BORDER_INNER_BOT_LEFT ; $34
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_LEFT_UP, BORDER_LEFT_UP ; $38
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_OUTER_BOT_CENTER ; $3c
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $40
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $44
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_LEFT, BORDER_UP_LEFT ; $48
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_LEFT, BORDER_UP_LEFT ; $4c
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_RIGHT, BORDER_UP_RIGHT ; $50
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_RIGHT, BORDER_UP_RIGHT ; $54
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_BOTH, BORDER_UP_BOTH ; $58
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_BOTH, BORDER_UP_BOTH ; $5c
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $60
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $64
	.byte BORDER_INNER_TOP_RIGHT, BORDER_INNER_TOP_RIGHT, BORDER_DOWN_LEFT, BORDER_OUTER_CENTER_RIGHT ; $68
	.byte BORDER_INNER_TOP_RIGHT, BORDER_INNER_TOP_RIGHT, BORDER_DOWN_LEFT, BORDER_OUTER_CENTER_RIGHT ; $6c
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_RIGHT, BORDER_UP_RIGHT ; $70
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_RIGHT, BORDER_UP_RIGHT ; $74
	.byte BORDER_LEFT_DOWN, BORDER_LEFT_DOWN, BORDER_DOWN_BOTH, BORDER_LEFT_BOTH ; $78
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UL_DR, BORDER_OUTER_BOT_RIGHT ; $7c
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $80
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $84
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $88
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $8c
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $90
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_BOT_LEFT, BORDER_INNER_BOT_LEFT ; $94
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $98
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_RIGHT_UP, BORDER_OUTER_BOT_CENTER ; $9c
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $a0
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_SINGLE_UP, BORDER_SINGLE_UP ; $a4
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $a8
	.byte BORDER_SINGLE_LEFT, BORDER_SINGLE_LEFT, BORDER_INNER_SINGLE, BORDER_INNER_BOT_RIGHT ; $ac
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $b0
	.byte BORDER_SINGLE_RIGHT, BORDER_SINGLE_RIGHT, BORDER_INNER_BOT_LEFT, BORDER_INNER_BOT_LEFT ; $b4
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $b8
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_OUTER_BOT_CENTER ; $bc
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $c0
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $c4
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_LEFT, BORDER_UP_LEFT ; $c8
	.byte BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UP_LEFT, BORDER_UP_LEFT ; $cc
	.byte BORDER_INNER_TOP_LEFT, BORDER_INNER_TOP_LEFT, BORDER_DOWN_RIGHT, BORDER_DOWN_RIGHT ; $d0
	.byte BORDER_INNER_TOP_LEFT, BORDER_INNER_TOP_LEFT, BORDER_OUTER_CENTER_LEFT, BORDER_OUTER_CENTER_LEFT ; $d4
	.byte BORDER_RIGHT_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE, BORDER_UR_DL ; $d8
	.byte BORDER_RIGHT_DOWN, BORDER_INNER_SINGLE, BORDER_RIGHT_BOTH, BORDER_OUTER_BOT_LEFT ; $dc
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $e0
	.byte BORDER_SINGLE_DOWN, BORDER_SINGLE_DOWN, BORDER_INNER_SINGLE, BORDER_INNER_SINGLE ; $e4
	.byte BORDER_INNER_TOP_RIGHT, BORDER_INNER_TOP_RIGHT, BORDER_DOWN_LEFT, BORDER_OUTER_CENTER_RIGHT ; $e8
	.byte BORDER_INNER_TOP_RIGHT, BORDER_INNER_TOP_RIGHT, BORDER_DOWN_LEFT, BORDER_OUTER_CENTER_RIGHT ; $ec
	.byte BORDER_INNER_TOP_LEFT, BORDER_INNER_TOP_LEFT, BORDER_DOWN_RIGHT, BORDER_DOWN_RIGHT ; $f0
	.byte BORDER_INNER_TOP_LEFT, BORDER_INNER_TOP_LEFT, BORDER_OUTER_CENTER_LEFT, BORDER_OUTER_CENTER_LEFT ; $f4
	.byte BORDER_OUTER_TOP_CENTER, BORDER_OUTER_TOP_CENTER, BORDER_DOWN_BOTH, BORDER_OUTER_TOP_RIGHT ; $f8
	.byte BORDER_OUTER_TOP_CENTER, BORDER_OUTER_TOP_CENTER, BORDER_OUTER_TOP_LEFT, BORDER_CENTER ; $fc


.segment "UI"

VAR starting_note_text
	.byte "THE ZOMBIE APOCALYPSE", 0
	.byte "IS UPON US! WE NEED", 0
	.byte "HELP! MEET ME IN TOWN.", 0
	.byte 0, 0

VAR key_4_text
	.byte "YOU FOUND THE FOURTH", 0
	.byte "KEY! INSIDE THE CHEST", 0
	.byte "IS ALSO THE LOCATION", 0
	.byte "OF THE NEXT KEY.", 0
	.byte 0
