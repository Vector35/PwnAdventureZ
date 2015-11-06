.include "defines.inc"

.segment "FIXED"

PROC init_bear_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_BEAR, bear_tiles

	LOAD_PTR bear_palette
	jsr load_sprite_palette_1

	rts
.endproc


.code

PROC bear_die
	PLAY_SOUND_EFFECT effect_enemydie

	LOAD_PTR normal_zombie_drop_table
	jsr enemy_die_with_drop_table

	jsr remove_enemy
	rts
.endproc


PROC bear_collide
	lda #16
	jsr take_damage
	jsr enemy_knockback
	rts
.endproc


.data

VAR bear_descriptor
	.word walking_ai_tick
	.word bear_die
	.word bear_collide
	.word walking_sprites_for_state
	.byte SPRITE_TILE_BEAR
	.byte 1
	.byte 1, 0
	.byte 40

VAR bear_palette
	.byte $0f, $07, $17, $27

TILES bear_tiles, 2, "tiles/enemies/bear/bear2.chr", 32
