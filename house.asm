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
.define HOUSE_EXT_TILES $a8

.define WALL_TILES        $80
.define TABLE_TILES       $a8
.define BED_TILES         $d8

.define HOUSE_ROOF_PALETTE  1
.define HOUSE_FRONT_PALETTE 2

.define FURNITURE_PALETTE   1
.define BED_PALETTE         2


.segment "FIXED"

PROC gen_house
	lda inside
	beq outside

	lda current_bank
	pha
	lda #^do_gen_house_inside
	jsr bankswitch
	jsr do_gen_house_inside & $ffff
	pla
	jsr bankswitch
	rts

outside:
	LOAD_ALL_TILES HOUSE_EXT_TILES, house_exterior_tiles

	lda current_bank
	pha
	lda #^do_gen_house_outside
	jsr bankswitch
	jsr do_gen_house_outside & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC gen_boarded_house
	lda inside
	beq outside

	lda current_bank
	pha
	lda #^do_gen_house_inside
	jsr bankswitch
	jsr do_gen_house_inside & $ffff
	pla
	jsr bankswitch
	rts

outside:
	LOAD_ALL_TILES HOUSE_EXT_TILES, boarded_house_exterior_tiles

	lda current_bank
	pha
	lda #^do_gen_house_outside
	jsr bankswitch
	jsr do_gen_house_outside & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_gen_house_outside
	lda #MUSIC_TOWN
	jsr play_music

	; Load forest tiles
	LOAD_ALL_TILES FOREST_TILES, forest_tiles
	LOAD_ALL_TILES FENCE_TILES, fence_tiles
	jsr init_zombie_sprites

	; Set up collision and spawning info
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_BOARDED_HOUSE
	bne notboarded

	lda #FOREST_TILES + FOREST_GRASS
	sta traversable_tiles
	lda #HOUSE_EXT_TILES + 28
	sta traversable_tiles + 1
	lda #HOUSE_EXT_TILES + 40
	sta traversable_tiles + 2
	lda #FOREST_TILES + FOREST_GRASS
	sta spawnable_tiles
	lda #HOUSE_EXT_TILES + 28
	sta spawnable_tiles + 1
	lda #HOUSE_EXT_TILES + 40
	sta spawnable_tiles + 2
	jmp collisiondone & $ffff

notboarded:
	lda #FOREST_TILES + FOREST_GRASS
	sta traversable_tiles
	lda #HOUSE_EXT_TILES + 36
	sta traversable_tiles + 1
	lda #HOUSE_EXT_TILES + 28
	sta traversable_tiles + 2
	lda #HOUSE_EXT_TILES + 40
	sta traversable_tiles + 3
	lda #FOREST_TILES + FOREST_GRASS
	sta spawnable_tiles
	lda #HOUSE_EXT_TILES + 28
	sta spawnable_tiles + 1
	lda #HOUSE_EXT_TILES + 40
	sta spawnable_tiles + 2

collisiondone:
	; Load forest palette as a base
	LOAD_PTR forest_palette
	jsr load_background_game_palette

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

	; Generate fence around house
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

	; Generate house exterior
	lda #3
	jsr genrange_cur
	cmp #2
	beq bighouse
	cmp #3
	beq bighouse
	cmp #1
	beq smallhouseright
	jmp smallhouseleft & $ffff

smallhouseright:
	jmp gensmallhouseright & $ffff
bighouse:
	jmp genbighouse & $ffff

smallhouseleft:
	lda #3
	jsr genrange_cur
	clc
	adc #4
	sta arg0

	tax
	ldy #4
	lda #HOUSE_EXT_TILES + 0 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 4 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 8 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx arg0
	iny
	lda #HOUSE_EXT_TILES + 16 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 20 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 24 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx arg0
	iny
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 36 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 40
	jsr write_gen_map

	lda arg0
	clc
	adc #1
	sta entrance_x
	lda #6
	sta entrance_y

	jmp housedone & $ffff

gensmallhouseright:
	lda #3
	jsr genrange_cur
	clc
	adc #4
	sta arg0

	tax
	ldy #4
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 0 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 4 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 8 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx arg0
	iny
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 16 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 20 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 24 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx arg0
	iny
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 36 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 40
	jsr write_gen_map

	lda arg0
	clc
	adc #2
	sta entrance_x
	lda #6
	sta entrance_y

	jmp housedone & $ffff

genbighouse:
	lda #2
	jsr genrange_cur
	clc
	adc #4
	sta arg0

	tax
	ldy #4
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 0 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 4 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 8 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx arg0
	iny
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 16 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 20 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 24 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx arg0
	iny
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 36 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 40
	jsr write_gen_map

	lda arg0
	clc
	adc #2
	sta entrance_x
	lda #6
	sta entrance_y

housedone:
	; Pick house paint color
	lda #3
	jsr genrange_cur
	tay
	lda house_paint_colors & $ffff, y
	sta scratch + 3
	sta scratch + 7

	; Pick house roof color
	lda #3
	jsr genrange_cur
	tay
	lda roof_dark_colors & $ffff, y
	sta scratch + 1
	lda roof_light_colors & $ffff, y
	sta scratch + 2

	; Complete and load house palettes
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_BOARDED_HOUSE
	bne palnotboarded

	lda #$0f
	sta scratch
	sta scratch + 4
	lda #$0f
	sta scratch + 5
	lda #$17
	sta scratch + 6
	jmp paldone & $ffff

palnotboarded:
	lda #$0f
	sta scratch
	sta scratch + 4
	lda #$01
	sta scratch + 5
	lda #$17
	sta scratch + 6

paldone:
	LOAD_PTR scratch
	jsr load_game_palette_1
	LOAD_PTR scratch + 4
	jsr load_game_palette_2

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


PROC do_gen_house_inside
	jsr gen_house_inside_common & $ffff
	jsr init_zombie_sprites

	; Pick random positions for furniture
	lda #2
	jsr genrange_cur
	cmp #0
	beq tableleft

	lda #8
	sta arg0
	lda #3
	sta arg2
	jmp tabletype & $ffff

tableleft:
	lda #3
	sta arg0
	lda #10
	sta arg2

tabletype:
	lda #4
	jsr genrange_cur
	cmp #0
	beq bigtable
	cmp #1
	beq bigtable

	jmp smalltable & $ffff

bigtable:
	LOAD_ALL_TILES TABLE_TILES, big_table_tiles

	lda #5
	jsr genrange_cur
	clc
	adc #3
	tay

	ldx arg0
	lda #TABLE_TILES + 0 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 4 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 8 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 12 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx arg0
	lda #TABLE_TILES + 16 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 20 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 24 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 28 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx arg0
	lda #TABLE_TILES + 32 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 36 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 40 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 44 + FURNITURE_PALETTE
	jsr write_gen_map

	jmp tabledone & $ffff

smalltable:
	LOAD_ALL_TILES TABLE_TILES, small_table_tiles

	lda arg0
	cmp #8
	bne notrighttable

	lda #9
	sta arg0

notrighttable:
	ldx arg0
	ldy #3
	lda #TABLE_TILES + 0 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 4 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 8 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx arg0
	lda #TABLE_TILES + 12 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 16 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 20 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx arg0
	lda #TABLE_TILES + 24 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 28 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 32 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	iny
	ldx arg0
	lda #TABLE_TILES + 0 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 4 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 8 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx arg0
	lda #TABLE_TILES + 12 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 16 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 20 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx arg0
	lda #TABLE_TILES + 24 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 28 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 32 + FURNITURE_PALETTE
	jsr write_gen_map

tabledone:
	lda #4
	jsr genrange_cur
	cmp #0
	beq bedtop
	cmp #1
	beq bedtop

	lda #6
	sta arg3
	jmp genbed & $ffff

bedtop:
	lda #3
	sta arg3

genbed:
	LOAD_ALL_TILES BED_TILES, bed_tiles

	ldx arg2
	ldy arg3
	lda #BED_TILES + 0 + BED_PALETTE
	jsr write_gen_map

	inx
	lda #BED_TILES + 4 + BED_PALETTE
	jsr write_gen_map

	iny
	ldx arg2
	lda #BED_TILES + 8 + BED_PALETTE
	jsr write_gen_map

	inx
	lda #BED_TILES + 12 + BED_PALETTE
	jsr write_gen_map

	iny
	ldx arg2
	lda #BED_TILES + 16 + BED_PALETTE
	jsr write_gen_map

	inx
	lda #BED_TILES + 20 + BED_PALETTE
	jsr write_gen_map

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_BOARDED_HOUSE
	bne notboarded

	; Boarded house has NPC and a note, not enemies
	LOAD_ALL_TILES $fc, house_note_tiles
	lda #INTERACT_BOARDED_HOUSE_NOTE
	sta interactive_tile_types
	lda #$fc
	sta interactive_tile_values

	ldx #7
	ldy #3
	lda #$fc + FURNITURE_PALETTE
	jsr write_gen_map

	jsr init_npc_sprites

	; Load a special tile for underneath the NPCs.  This looks exactly like a floor
	; but will collide and be interactable.  This is simply a way to make the NPC
	; interactable without a special NPC system.
	LOAD_ALL_TILES $f8, npc_floor_tiles

	lda #INTERACT_BOARDED_HOUSE_NPC
	sta interactive_tile_types + 1
	lda #$f8
	sta interactive_tile_values + 1

	ldx #8
	ldy #5
	lda #$f8
	jsr write_gen_map

	jsr prepare_spawn
	lda #ENEMY_MALE_NPC_1
	sta arg0
	lda #DIR_DOWN
	sta arg1
	ldx #$80
	ldy #$50
	lda #0
	jsr spawn_npc

	rts

notboarded:
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

	lda #3
	jsr rand_range
	tax
	lda house_interior_enemy_types & $ffff, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC gen_house_inside_common
	lda #MUSIC_TOWN
	jsr play_music

	LOAD_ALL_TILES WALL_TILES, wood_wall_tiles

	LOAD_PTR house_interior_palette
	jsr load_background_game_palette

	lda #WALL_TILES + 32
	sta traversable_tiles
	lda #WALL_TILES + 36
	sta traversable_tiles + 1
	lda #WALL_TILES + 28
	sta traversable_tiles + 2
	lda #WALL_TILES + 32
	sta spawnable_tiles
	lda #WALL_TILES + 36
	sta spawnable_tiles + 1

	; Generate surrounding wall
	ldx #1
	ldy #1
	lda #WALL_TILES + 0
	jsr write_gen_map

	ldx #2
topwallloop:
	lda #WALL_TILES + 24
	jsr write_gen_map
	inx
	cpx #13
	bne topwallloop

	lda #WALL_TILES + 4
	jsr write_gen_map

	ldx #1
	ldy #2
	lda #WALL_TILES + 8
	jsr write_gen_map

	ldx #2
firstxloop:
	lda #WALL_TILES + 36
	jsr write_gen_map
	inx
	cpx #13
	bne firstxloop

	lda #WALL_TILES + 20
	jsr write_gen_map

	ldy #3
centeryloop:
	ldx #1
	lda #WALL_TILES + 8
	jsr write_gen_map

	ldx #2
centerxloop:
	lda #WALL_TILES + 32
	jsr write_gen_map
	inx
	cpx #13
	bne centerxloop

	lda #WALL_TILES + 20
	jsr write_gen_map

	iny
	cpy #10
	bne centeryloop

	ldx #1
	lda #WALL_TILES + 12
	jsr write_gen_map

	ldx #2
botloop:
	lda #WALL_TILES + 24
	jsr write_gen_map
	inx
	cpx #13
	bne botloop

	lda #WALL_TILES + 16
	jsr write_gen_map

	ldx #7
	lda #WALL_TILES + 28
	jsr write_gen_map

	stx entrance_x
	sty entrance_y
	lda #1
	sta entrance_down

	rts
.endproc


.code

PROC boarded_house_note_interact
	LOAD_PTR boarded_house_flag_text
	lda #^boarded_house_flag_text
	jsr show_chat_text
	rts
.endproc

PROC boarded_house_npc_interact
	LOAD_PTR boarded_house_npc_text
	lda #^boarded_house_npc_text
	jsr show_chat_text
	rts
.endproc


.segment "EXTRA"

VAR house_paint_colors
	.byte $30, $38, $31

VAR roof_dark_colors
	.byte $07, $08, $0b

VAR roof_light_colors
	.byte $17, $18, $1b

VAR house_exterior_enemy_types
	.byte ENEMY_NORMAL_MALE_ZOMBIE, ENEMY_NORMAL_FEMALE_ZOMBIE

VAR house_interior_enemy_types
	.byte ENEMY_NORMAL_MALE_ZOMBIE, ENEMY_NORMAL_FEMALE_ZOMBIE, ENEMY_FAT_ZOMBIE

VAR house_interior_palette
	.byte $0f, $07, $17, $27
	.byte $0f, $07, $17, $37
	.byte $0f, $07, $17, $10
	.byte $0f, $07, $17, $27


.data

VAR boarded_house_note_descriptor
	.word always_interactable
	.word boarded_house_note_interact

VAR boarded_house_npc_descriptor
	.word always_interactable
	.word boarded_house_npc_interact


TILES fence_tiles, 3, "tiles/house/fence.chr", 32
TILES house_exterior_tiles, 3, "tiles/house/exterior.chr", 44
TILES boarded_house_exterior_tiles, 3, "tiles/house/exterior-boarded.chr", 44

TILES wood_wall_tiles, 3, "tiles/house/woodwalls.chr", 40
TILES big_table_tiles, 3, "tiles/house/bigtable.chr", 48
TILES small_table_tiles, 3, "tiles/house/smalltable.chr", 36
TILES bed_tiles, 3, "tiles/house/bed.chr", 24
TILES house_note_tiles, 3, "tiles/items/note-house.chr", 4


.segment "UI"

VAR boarded_house_npc_text
	.byte "I BOARDED MY HOUSE UP", 0
	.byte "TO KEEP THE ZOMBIES", 0
	.byte "OUT. HOW DID YOU GET", 0
	.byte "IN HERE?", 0, 0
