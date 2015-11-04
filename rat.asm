.include "defines.inc"

.segment "FIXED"

PROC init_rat_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_RAT, rat_tiles
	rts
.endproc


.code

PROC rat_die
	PLAY_SOUND_EFFECT effect_enemydie

	LOAD_PTR normal_zombie_drop_table
	jsr enemy_die_with_drop_table

	jsr remove_enemy
	rts
.endproc


PROC rat_collide
	lda #8
	jsr take_damage
	jsr enemy_knockback
	rts
.endproc


.data

VAR rat_descriptor
	.word walking_ai_tick
	.word rat_die
	.word rat_collide
	.word walking_sprites_for_state
	.byte SPRITE_TILE_RAT
	.byte 2
	.byte 3, 0
	.byte 15


TILES rat_tiles, 3, "tiles/enemies/rat/rat.chr", 32
