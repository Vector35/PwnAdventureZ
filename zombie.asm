.include "defines.inc"

.code


PROC init_zombie_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_NORMAL_MALE_ZOMBIE, normal_male_zombie_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_NORMAL_FEMALE_ZOMBIE, normal_female_zombie_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_FAT_ZOMBIE, fat_zombie_tiles

	LOAD_PTR zombie_palette
	jsr load_sprite_palette_1

	rts
.endproc


PROC normal_zombie_die
	LOAD_PTR normal_zombie_drop_table
	jsr enemy_die_with_drop_table

	jsr remove_enemy
	rts
.endproc


PROC normal_zombie_collide
	lda #8
	jsr take_damage
	jsr enemy_knockback
	rts
.endproc


PROC fat_zombie_explode
	rts
.endproc


.data

VAR normal_male_zombie_descriptor
	.word walking_ai_tick
	.word normal_zombie_die
	.word normal_zombie_collide
	.word walking_sprites_for_state
	.byte SPRITE_TILE_NORMAL_MALE_ZOMBIE
	.byte 1
	.byte 1, 0
	.byte 20

VAR normal_female_zombie_descriptor
	.word walking_ai_tick
	.word normal_zombie_die
	.word normal_zombie_collide
	.word walking_sprites_for_state
	.byte SPRITE_TILE_NORMAL_FEMALE_ZOMBIE
	.byte 1
	.byte 1, 0
	.byte 20

VAR fat_zombie_descriptor
	.word walking_ai_tick
	.word fat_zombie_explode
	.word fat_zombie_explode
	.word walking_sprites_for_state
	.byte SPRITE_TILE_FAT_ZOMBIE
	.byte 1
	.byte 1, 0
	.byte 30

VAR zombie_palette
	.byte $0f, $18, $28, $08

VAR normal_zombie_drop_table
	.byte 4
	.word normal_zombie_drop_type
	.word normal_zombie_drop_base_count
	.word normal_zombie_drop_rand_count
VAR normal_zombie_drop_type
	.byte ITEM_NONE, ITEM_PISTOL, ITEM_PISTOL, ITEM_BANDAGE
VAR normal_zombie_drop_base_count
	.byte 0, 2, 2, 1
VAR normal_zombie_drop_rand_count
	.byte 1, 4, 4, 1
;VAR normal_zombie_drop_table
;	.byte 6
;	.word normal_zombie_drop_type
;	.word normal_zombie_drop_base_count
;	.word normal_zombie_drop_rand_count
;VAR normal_zombie_drop_type
;	.byte ITEM_CLOTH, ITEM_SHIRT, ITEM_PANTS, ITEM_STICKS, ITEM_GUNPOWDER, ITEM_METAL
;VAR normal_zombie_drop_base_count
;	.byte 2, 1, 1, 1, 1, 1, 1, 2, 2
;VAR normal_zombie_drop_rand_count
;	.byte 3, 1, 1, 1, 2, 1, 1, 3, 3

TILES normal_male_zombie_tiles, 2, "tiles/enemies/zombie/zombie-male.chr", 32
TILES normal_female_zombie_tiles, 2, "tiles/enemies/zombie/zombie-female.chr", 32
TILES fat_zombie_tiles, 2, "tiles/enemies/zombie/zombie-fat.chr", 32
