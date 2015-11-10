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

.define FOREST_TILES    $80
.define FENCE_TILES     $88
.define BORDER_TILES    $c0

.define BORDER_PALETTE  1


.segment "FIXED"

PROC gen_park
	lda current_bank
	pha
	lda #^do_gen_park
	jsr bankswitch
	jsr do_gen_park & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_gen_park
	lda #MUSIC_TOWN
	jsr play_music

	; Load forest tiles
	LOAD_ALL_TILES FOREST_TILES, forest_tiles
	LOAD_ALL_TILES FENCE_TILES, fence_tiles
	LOAD_ALL_TILES BORDER_TILES, forest_lake_border_tiles
	jsr init_zombie_sprites

	; Set up collision and spawning info
	lda #FOREST_TILES + FOREST_GRASS
	sta traversable_tiles
	lda #FOREST_TILES + FOREST_GRASS
	sta spawnable_tiles

	; Load palettes
	LOAD_PTR forest_palette
	jsr load_background_game_palette
	LOAD_PTR forest_lake_border_palette
	jsr load_game_palette_1

	; Generate parameters for map generation
	jsr gen_map_opening_locations

	lda #FOREST_TILES + FOREST_TREE
	jsr gen_left_wall_small
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_right_wall_small
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_top_wall_small
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_bot_wall_small

	lda #FOREST_TILES + FOREST_GRASS
	jsr gen_walkable_path

	; Generate fence around park
	ldx #3
	ldy #3
	lda #FENCE_TILES + 0
	jsr write_gen_map
	lda #FENCE_TILES + 24
	ldx #4
topfence:
	jsr write_gen_map
	inx
	cpx #11
	bne topfence
	lda #FENCE_TILES + 4
	jsr write_gen_map

	ldy #4
	lda #FENCE_TILES + 8
centerfence:
	ldx #3
	jsr write_gen_map
	ldx #11
	jsr write_gen_map
	iny
	cpy #8
	bne centerfence

	lda #4
	jsr genrange_cur
	clc
	adc #5
	sta arg0

	ldx #3
	ldy #8
	lda #FENCE_TILES + 12
	jsr write_gen_map
	lda #FENCE_TILES + 24
	ldx #4
botfenceleft:
	jsr write_gen_map
	inx
	cpx arg0
	bne botfenceleft

	dex
	lda #FENCE_TILES + 28
	jsr write_gen_map
	inx
	lda #FOREST_TILES + FOREST_GRASS
	jsr write_gen_map
	inx
	jsr write_gen_map
	inx
	lda #FENCE_TILES + 20
	jsr write_gen_map

	inx
	lda #FENCE_TILES + 24
botfenceright:
	cpx #11
	beq botfencedone
	jsr write_gen_map
	inx
	jmp botfenceright & $ffff
botfencedone:
	lda #FENCE_TILES + 16
	jsr write_gen_map

	; Generate pond in the park
	lda #6
	jsr genrange_cur
	clc
	adc #4
	sta arg0

	lda #2
	jsr genrange_cur
	clc
	adc #4
	sta arg1

	ldx arg0
	ldy arg1
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr write_gen_map
	inx
	jsr write_gen_map
	iny
	jsr write_gen_map
	dex
	jsr write_gen_map
	lda #BORDER_TILES + BORDER_PALETTE
	jsr process_border_sides

	; Create clutter in the middle of the park
	lda #3
	jsr genrange_cur
	clc
	adc #2
	sta clutter_count

clutterloop:
	lda clutter_count
	bne placeclutter
	jmp clutterend & $ffff
placeclutter:

	lda #8
	sta arg5

cluttertry:
	; Generate clutter position
	lda #5
	jsr genrange_cur
	clc
	adc #5
	sta arg0

	lda #2
	jsr genrange_cur
	clc
	adc #5
	sta arg1

	; Check to ensure clutter isn't blocking anything.  It must be surrounded with the
	; same type of blank space (not critical path, or all critical path) to ensure that
	; it will not block all paths to exits
	ldx arg0
	ldy arg1
	jsr read_gen_map
	cmp #0
	beq clutterblank
	cmp #FOREST_TILES + FOREST_GRASS
	bne clutterblock
clutterblank:
	; Clutter is not blocking any paths, place it now
	lda #FOREST_TILES + FOREST_TREE
	ldx arg0
	ldy arg1
	jsr write_gen_map
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

	; Convert tiles that have not been generated into grass
	ldy #0
yloop:
	ldx #0
xloop:
	jsr read_gen_map
	cmp #0
	bne nextblank
	lda #FOREST_TILES + FOREST_GRASS
	jsr write_gen_map
nextblank:
	inx
	cpx #MAP_WIDTH
	bne xloop
	iny
	cpy #MAP_HEIGHT
	bne yloop

	; Create enemies
	jsr prepare_spawn
	jsr restore_enemies
	bne restoredspawn

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #2
	jsr rand_range
	clc
	adc #1
	tax
	jmp spawnloop & $ffff

hard:
	lda #3
	jsr rand_range
	clc
	adc #2
	tax
	jmp spawnloop & $ffff

veryhard:
	lda #3
	jsr rand_range
	clc
	adc #3
	tax

spawnloop:
	txa
	pha

	lda #2
	jsr rand_range
	tax
	lda house_exterior_enemy_types & $ffff, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc
