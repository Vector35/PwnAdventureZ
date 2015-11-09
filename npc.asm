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

.segment "FIXED"

PROC init_npc_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_MALE_NPC, male_npc_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_FEMALE_NPC, female_npc_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_MALE_THIN_NPC, male_thin_npc_tiles
	LOAD_ALL_TILES $100 + SPRITE_TILE_FEMALE_THIN_NPC, female_thin_npc_tiles

	LOAD_PTR npc_palette_1
	jsr load_sprite_palette_1

	rts
.endproc


PROC spawn_npc
	stx arg2
	tax
	lda arg0
	sta enemy_type, x
	lda arg2
	sta enemy_x, x
	tya
	sta enemy_y, x
	lda arg1
	sta enemy_direction, x
	lda #1
	sta enemy_speed_mask, x
	lda #0
	sta enemy_speed_value, x
	lda #<walking_sprites_for_state
	sta enemy_sprite_state_low, x
	lda #>walking_sprites_for_state
	sta enemy_sprite_state_high, x
	lda #0
	sta enemy_anim_frame, x
	sta enemy_knockback_time, x
	lda #255
	sta enemy_health, x
	rts
.endproc


.data

VAR npc_palette_1
	.byte $0f, $09, $37, $0f

VAR male_npc_1_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_MALE_NPC
	.byte 1
	.byte 1, 0
	.byte 255

VAR female_npc_1_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_FEMALE_NPC
	.byte 1
	.byte 1, 0
	.byte 255

VAR male_thin_npc_1_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_MALE_THIN_NPC
	.byte 1
	.byte 1, 0
	.byte 255

VAR female_thin_npc_1_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_FEMALE_THIN_NPC
	.byte 1
	.byte 1, 0
	.byte 255

VAR male_npc_2_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_MALE_NPC
	.byte 0
	.byte 1, 0
	.byte 255

VAR female_npc_2_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_FEMALE_NPC
	.byte 0
	.byte 1, 0
	.byte 255

VAR male_thin_npc_2_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_MALE_THIN_NPC
	.byte 0
	.byte 1, 0
	.byte 255

VAR female_thin_npc_2_descriptor
	.word nothing
	.word nothing
	.word nothing
	.word walking_sprites_for_state
	.byte SPRITE_TILE_FEMALE_THIN_NPC
	.byte 0
	.byte 1, 0
	.byte 255


TILES male_npc_tiles, 3, "tiles/characters/npc/npc-male.chr", 32
TILES female_npc_tiles, 3, "tiles/characters/npc/npc-female.chr", 32
TILES male_thin_npc_tiles, 3, "tiles/characters/npc/npc-male-thin.chr", 32
TILES female_thin_npc_tiles, 3, "tiles/characters/npc/npc-female-thin.chr", 32
