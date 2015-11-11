.include "defines.inc"

.segment "FIXED"

PROC gen_mine
	lda current_bank
	pha
	lda #^do_gen_mine
	jsr bankswitch
	jsr do_gen_mine & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC gen_mine_up
	lda current_bank
	pha
	lda #^do_gen_mine_up
	jsr bankswitch
	jsr do_gen_mine_up & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC gen_mine_chest
	lda current_bank
	pha
	lda #^do_gen_mine_chest
	jsr bankswitch
	jsr do_gen_mine_chest & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC gen_mine_boss
	lda current_bank
	pha
	lda #^do_gen_mine_boss
	jsr bankswitch
	jsr do_gen_mine_boss & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC key_chest_3_interact
	lda current_bank
	pha
	lda #^do_key_chest_3_interact
	jsr bankswitch
	jsr do_key_chest_3_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC is_mine_chest_interactable
	lda minor_chests_opened
	and #MINOR_CHEST_MINE
	rts
.endproc

PROC mine_chest_interact
	lda current_bank
	pha
	lda #^do_mine_chest_interact
	jsr bankswitch
	jsr do_mine_chest_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_gen_mine_common
	lda #MUSIC_MINE
	jsr play_music

	inc gen_cur_index
	inc gen_left_index
	inc gen_right_index
	inc gen_up_index
	inc gen_down_index

	jsr do_gen_cave_common & $ffff
	LOAD_ALL_TILES $100 + SPRITE_TILE_THIN_ZOMBIE , thin_zombie_tiles
	rts
.endproc

PROC do_gen_mine
	jsr do_gen_mine_common & $ffff
	jsr gen_mine_enemies & $ffff
	rts
.endproc


PROC gen_mine_enemies
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

	lda #2
	jsr rand_range
	tax
	lda mine_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC do_gen_mine_up
	jsr do_gen_mine_common & $ffff

	LOAD_PTR mine_down_palette
	jsr load_background_game_palette

	LOAD_ALL_TILES $0f0, cave_ladder_tiles

	lda #INTERACT_MINE_EXIT
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values

	jsr gen_mine_ladder & $ffff
	rts
.endproc


PROC do_gen_mine_chest
	jsr do_gen_mine_common & $ffff

	LOAD_ALL_TILES $0f0, small_chest_tiles

	lda #INTERACT_MINE_CHEST
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values

	lda minor_chests_opened
	and #MINOR_CHEST_MINE
	bne opened

	ldx #7
	ldy #4
	lda #$f0 + 2
	jsr write_gen_map
	jmp chestdone & $ffff

opened:
	ldx #7
	ldy #4
	lda #$f4 + 2
	jsr write_gen_map

chestdone:
	jsr gen_mine_enemies & $ffff
	rts
.endproc


PROC do_gen_mine_boss
	jsr do_gen_mine_common & $ffff

	LOAD_ALL_TILES $0f0, chest_tiles

	lda #INTERACT_KEY_CHEST_3
	sta interactive_tile_types
	lda #$f0
	sta interactive_tile_values
	lda #INTERACT_KEY_CHEST_3
	sta interactive_tile_types + 1
	lda #$f4
	sta interactive_tile_values + 1

	lda completed_quest_steps
	and #QUEST_KEY_3
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

	lda #ENEMY_THIN_ZOMBIE
	sta horde_enemy_types
	sta horde_enemy_types + 1
	lda #ENEMY_SPIDER
	sta horde_enemy_types + 2
	sta horde_enemy_types + 3

	jsr gen_mine_enemies & $ffff
	rts
.endproc


PROC do_key_chest_3_interact
	lda completed_quest_steps
	and #QUEST_KEY_3
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

	lda #90
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #60
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

hard:
	lda #120
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #50
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

veryhard:
	lda #150
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #40
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
	ora #QUEST_KEY_3
	sta completed_quest_steps
	lda highlighted_quest_steps
	and #$ff & (~QUEST_KEY_3)
	sta highlighted_quest_steps

	lda completed_quest_steps
	and #QUEST_KEY_4
	bne key4done
	lda highlighted_quest_steps
	ora #QUEST_KEY_4
	sta highlighted_quest_steps

key4done:
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
	LOAD_PTR key_3_text
	lda #^key_3_text
	jsr show_chat_text
	rts
.endproc


PROC do_mine_chest_interact
	lda #ITEM_WIZARD_HAT
	jsr give_item
	lda #ITEM_GEM
	ldx #2
	jsr give_item_with_count
	lda #ITEM_HEALTH_KIT
	ldx #1
	jsr give_item_with_count

	lda minor_chests_opened
	ora #MINOR_CHEST_MINE
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


.data

VAR mine_enemy_types
	.byte ENEMY_THIN_ZOMBIE, ENEMY_SPIDER

VAR key_chest_3_descriptor
	.word always_interactable
	.word key_chest_3_interact

VAR mine_chest_descriptor
	.word is_mine_chest_interactable
	.word mine_chest_interact


.segment "UI"

VAR key_3_text
	.byte "YOU FOUND THE THIRD", 0
	.byte "KEY! INSIDE THE CHEST", 0
	.byte "IS ALSO THE LOCATION", 0
	.byte "OF THE NEXT KEY.", 0
	.byte 0
