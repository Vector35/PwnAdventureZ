.include "defines.inc"


.code

.define SHARK_TILES $100
.define TILE1 0
.define TILE2 4
.define TILE3 8
.define SHARK_FIN 12

PROC init_shark_sprites
	LOAD_ALL_TILES SHARK_TILES + SPRITE_TILE_SHARK, shark_tiles
	rts
.endproc

PROC swiming_ai_tick
	rts
.endproc

PROC shark_collide
	;Player should never collide with shark
	rts
.endproc

.data

VAR shark_descriptor
	.word swiming_ai_tick
	.word remove_enemy
	.word shark_collide
	.word swiming_sprites_for_state
	.byte SPRITE_TILE_SHARK
	.byte 2 ;gun palette
	.byte 1, 0
	.byte 20

VAR swiming_sprites_for_state

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00

	.byte $0c + 1, $00
	.byte $0e + 1, $00
	.byte $0c + 1, $00
	.byte $0e + 1, $00


TILES shark_tiles, 2, "tiles/enemies/shark/shark.chr", 16
