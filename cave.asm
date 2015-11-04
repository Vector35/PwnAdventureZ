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


.segment "EXTRA"

PROC do_gen_cave_start
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
	jsr do_gen_cave_common & $ffff

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

	lda #5
	jsr rand_range
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
	jsr do_gen_cave_common & $ffff

	; Create enemies
	jsr prepare_spawn
	jsr restore_enemies
	bne restoredspawn

	lda #2
	jsr rand_range
	clc
	adc #1
	tax

spawnloop:
	txa
	pha

	lda #3
	jsr rand_range
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


PROC do_gen_cave_common
	lda #MUSIC_CAVE
	jsr play_music

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
	bne notstartcave

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

	; Convert rock walls into the correct tile to account for surroundings.  This will
	; give them a contour along the edges.
	ldy #0
yloop:
	ldx #0
xloop:
	jsr process_border_sides_for_tile
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
	jmp done
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
	jmp skip

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


PROC is_starting_chest_interactable
	lda starting_chest_opened
	rts
.endproc


PROC starting_chest_interact
	PLAY_SOUND_EFFECT effect_open

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


.bss
VAR starting_chest_opened
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

VAR starting_chest_descriptor
	.word is_starting_chest_interactable
	.word starting_chest_interact

VAR starting_note_descriptor
	.word always_interactable
	.word starting_note_interact


VAR cave_enemy_types
	.byte ENEMY_NORMAL_MALE_ZOMBIE, ENEMY_NORMAL_FEMALE_ZOMBIE, ENEMY_SPIDER, ENEMY_SPIDER, ENEMY_SPIDER


TILES cave_border_tiles, 2, "tiles/cave/border.chr", 60
TILES chest_tiles, 2, "tiles/cave/chest2.chr", 8
TILES note_tiles, 2, "tiles/items/note.chr", 4

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
