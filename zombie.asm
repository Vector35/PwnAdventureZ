.include "defines.inc"

.code


PROC init_zombie_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_NORMAL_ZOMBIE, normal_zombie_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_FAT_ZOMBIE, fat_zombie_tiles

	LOAD_PTR zombie_palette
	jsr load_sprite_palette_1

	rts
.endproc


PROC normal_zombie_collide
	rts
.endproc


PROC fat_zombie_explode
	rts
.endproc


.data

VAR normal_zombie_descriptor
	.word walking_ai_tick
	.word enemy_die
	.word normal_zombie_collide
	.byte SPRITE_TILE_NORMAL_ZOMBIE
	.byte 1

VAR fat_zombie_descriptor
	.word walking_ai_tick
	.word fat_zombie_explode
	.word fat_zombie_explode
	.byte SPRITE_TILE_FAT_ZOMBIE
	.byte 1

VAR zombie_palette
	.byte $0f, $18, $28, $08

TILES normal_zombie_tiles, 2, "tiles/enemies/zombie/zombie1.chr", 32
TILES fat_zombie_tiles, 2, "tiles/enemies/zombie/zombie-extrawide.chr", 32
