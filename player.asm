.include "defines.inc"

.code

PROC init_player_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_PLAYER, unarmed_player_tiles

	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_START
	beq dark
	cmp #MAP_CAVE_INTERIOR
	beq dark

	LOAD_PTR light_player_palette
	jmp loadpal

dark:
	LOAD_PTR dark_player_palette

loadpal:
	jsr load_sprite_palette_0

	jsr update_player_sprite
	rts
.endproc


PROC update_player_sprite
	lda player_anim_frame
	lsr
	lsr
	lsr
	and #1
	sta temp

	lda player_direction
	asl
	ora temp
	asl
	asl
	tax

	lda player_y
	clc
	adc #7
	sta sprites + SPRITE_OAM_PLAYER
	sta sprites + SPRITE_OAM_PLAYER + 4

	lda player_sprites_for_state, x
	sta sprites + SPRITE_OAM_PLAYER + 1
	lda player_sprites_for_state + 1, x
	sta sprites + SPRITE_OAM_PLAYER + 2
	lda player_sprites_for_state + 2, x
	sta sprites + SPRITE_OAM_PLAYER + 5
	lda player_sprites_for_state + 3, x
	sta sprites + SPRITE_OAM_PLAYER + 6

	lda player_x
	clc
	adc #8
	sta sprites + SPRITE_OAM_PLAYER + 3
	adc #8
	sta sprites + SPRITE_OAM_PLAYER + 7

	rts
.endproc


.zeropage
VAR player_x
	.byte 0
VAR player_y
	.byte 0
VAR player_direction
	.byte 0
VAR player_anim_frame
	.byte 0


.data
VAR player_sprites_for_state
	; Up
	.byte SPRITE_TILE_PLAYER + $1c + 1, $00
	.byte SPRITE_TILE_PLAYER + $1e + 1, $00
	.byte SPRITE_TILE_PLAYER + $1c + 1, $00
	.byte SPRITE_TILE_PLAYER + $1e + 1, $00
	; Left
	.byte SPRITE_TILE_PLAYER + $0a + 1, $40
	.byte SPRITE_TILE_PLAYER + $08 + 1, $40
	.byte SPRITE_TILE_PLAYER + $0a + 1, $40
	.byte SPRITE_TILE_PLAYER + $08 + 1, $40
	; Right
	.byte SPRITE_TILE_PLAYER + $08 + 1, $00
	.byte SPRITE_TILE_PLAYER + $0a + 1, $00
	.byte SPRITE_TILE_PLAYER + $08 + 1, $00
	.byte SPRITE_TILE_PLAYER + $0a + 1, $00
	; Down
	.byte SPRITE_TILE_PLAYER + $18 + 1, $00
	.byte SPRITE_TILE_PLAYER + $1a + 1, $00
	.byte SPRITE_TILE_PLAYER + $18 + 1, $00
	.byte SPRITE_TILE_PLAYER + $1a + 1, $00
	; Run Up
	.byte SPRITE_TILE_PLAYER + $10 + 1, $00
	.byte SPRITE_TILE_PLAYER + $12 + 1, $00
	.byte SPRITE_TILE_PLAYER + $14 + 1, $00
	.byte SPRITE_TILE_PLAYER + $16 + 1, $00
	; Run Left
	.byte SPRITE_TILE_PLAYER + $0a + 1, $40
	.byte SPRITE_TILE_PLAYER + $08 + 1, $40
	.byte SPRITE_TILE_PLAYER + $0e + 1, $40
	.byte SPRITE_TILE_PLAYER + $0c + 1, $40
	; Run Right
	.byte SPRITE_TILE_PLAYER + $08 + 1, $00
	.byte SPRITE_TILE_PLAYER + $0a + 1, $00
	.byte SPRITE_TILE_PLAYER + $0c + 1, $00
	.byte SPRITE_TILE_PLAYER + $0e + 1, $00
	; Run Down
	.byte SPRITE_TILE_PLAYER + $00 + 1, $00
	.byte SPRITE_TILE_PLAYER + $02 + 1, $00
	.byte SPRITE_TILE_PLAYER + $04 + 1, $00
	.byte SPRITE_TILE_PLAYER + $06 + 1, $00

VAR dark_player_palette
	.byte $0f, $2d, $36, $17
VAR light_player_palette
	.byte $0f, $0f, $36, $07

TILES unarmed_player_tiles, 2, "tiles/characters/player/unarmed.chr", 32
