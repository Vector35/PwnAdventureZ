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

PROC init_spider_sprites
	LOAD_ALL_TILES $100 + SPRITE_TILE_SPIDER, spider_tiles
	rts
.endproc


.code

PROC spider_die
	PLAY_SOUND_EFFECT effect_enemydie

	LOAD_PTR spider_drop_table
	jsr enemy_die_with_drop_table

	jsr remove_enemy
	rts
.endproc


PROC spider_collide
	lda #10
	jsr take_damage
	jsr enemy_knockback
	rts
.endproc


.data

VAR spider_descriptor
	.word walking_ai_tick
	.word spider_die
	.word spider_collide
	.word walking_sprites_for_state
	.byte SPRITE_TILE_SPIDER
	.byte 2
	.byte 3, 0
	.byte 25

VAR spider_drop_table
	.byte 16
	.word spider_drop_type
	.word spider_drop_base_count
	.word spider_drop_rand_count
VAR spider_drop_type
	.byte ITEM_NONE, ITEM_GEM
	.byte ITEM_METAL, ITEM_METAL, ITEM_GUNPOWDER, ITEM_GUNPOWDER
	.byte ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER
	.byte ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_METAL
	.byte ITEM_GEM, ITEM_HEALTH_KIT
VAR spider_drop_base_count
	.byte 0, 1
	.byte 8, 8, 8, 8
	.byte 8, 8, 8, 8
	.byte 8, 8, 8, 8
	.byte 1, 1
VAR spider_drop_rand_count
	.byte 1, 1
	.byte 10, 10, 10, 10
	.byte 10, 10, 10, 10
	.byte 10, 10, 10, 10
	.byte 1, 1

TILES spider_tiles, 3, "tiles/enemies/spider/spider.chr", 32
