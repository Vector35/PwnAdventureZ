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

.define RIGHT_PANEL_TILES $66
.define LOCATION_TILES    $04
.define DYNAMIC_TILES     $70

.define STATUS_STATE_NORMAL                 0
.define STATUS_STATE_NORMAL_DRAW            1
.define STATUS_STATE_NEW_ITEM_CLEAR_BEFORE  2
.define STATUS_STATE_NEW_ITEM_LOAD_ICON     3
.define STATUS_STATE_NEW_ITEM_LOAD_HEADER   4
.define STATUS_STATE_NEW_ITEM_DRAW          5
.define STATUS_STATE_NEW_ITEM_WAIT          6
.define STATUS_STATE_NEW_ITEM_CLEAR_AFTER   7

.segment "FIXED"

PROC load_area_name_tiles
	lda current_bank
	pha
	lda #^do_load_area_name_tiles
	jsr bankswitch
	jsr do_load_area_name_tiles & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC load_key_count_tiles
	lda current_bank
	pha
	lda #^do_load_key_count_tiles
	jsr bankswitch
	jsr do_load_key_count_tiles & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_load_area_name_tiles
	; Load tiles for name of area
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_START
	beq startcavelocation
	cmp #MAP_STARTING_CAVE
	beq startcavelocation
	cmp #MAP_START_FOREST
	beq startforestlocation
	cmp #MAP_START_FOREST_CHEST
	beq startforestlocation
	cmp #MAP_CAVE_INTERIOR
	beq maincavelocation
	cmp #MAP_CAVE_CHEST
	beq maincavelocation
	cmp #MAP_CAVE_BOSS
	beq maincavelocation
	cmp #MAP_LOST_CAVE
	beq lostcavelocation
	cmp #MAP_LOST_CAVE_WALL
	beq lostcavelocation
	cmp #MAP_LOST_CAVE_CHEST
	beq lostcavelocation
	cmp #MAP_LOST_CAVE_END
	beq lostcavelocation
	cmp #MAP_MINE
	beq minelocation
	cmp #MAP_MINE_ENTRANCE
	beq minelocation
	cmp #MAP_MINE_DOWN
	beq minelocation
	cmp #MAP_MINE_CHEST
	beq minelocation
	cmp #MAP_MINE_BOSS
	beq minelocation
	cmp #MAP_MINE_UP
	beq minelocation
	jmp resumesearch & $ffff

startcavelocation:
	jmp startcave & $ffff
startforestlocation:
	jmp startforest & $ffff
maincavelocation:
	jmp maincave & $ffff
lostcavelocation:
	jmp lostcave & $ffff
minelocation:
	jmp mine & $ffff

resumesearch:
	cmp #MAP_HOUSE
	beq townlocation
	cmp #MAP_SHOP
	beq townlocation
	cmp #MAP_PARK
	beq townlocation
	cmp #MAP_BOARDED_HOUSE
	beq outpostlocation
	cmp #MAP_OUTPOST_SHOP
	beq outpostlocation
	cmp #MAP_OUTPOST_HOUSE
	beq outpostlocation
	cmp #MAP_BOSS
	beq baselocation
	cmp #MAP_BASE_HORDE
	beq baselocation
	cmp #MAP_BASE_INTERIOR
	beq baselocation
	cmp #MAP_BLOCKY_TREASURE
	beq blockylocation
	cmp #MAP_BLOCKY_PUZZLE
	beq blockylocation
	cmp #MAP_BLOCKY_CAVE
	beq blockylocation
	cmp #MAP_DEAD_WOOD
	beq deadwood
	cmp #MAP_DEAD_WOOD_CHEST
	beq deadwood
	cmp #MAP_DEAD_WOOD_BOSS
	beq deadwood
	cmp #MAP_UNBEARABLE
	beq unbearable
	cmp #MAP_UNBEARABLE_CHEST
	beq unbearable
	cmp #MAP_UNBEARABLE_BOSS
	beq unbearable
	cmp #MAP_SEWER
	beq sewerlocation
	cmp #MAP_SEWER_CHEST
	beq sewerlocation
	cmp #MAP_SEWER_BOSS
	beq sewerlocation
	cmp #MAP_SEWER_UP
	beq sewerlocation

	LOAD_ALL_TILES LOCATION_TILES, forest_name_tiles
	jmp namedone & $ffff

baselocation:
	jmp base & $ffff
blockylocation:
	jmp blocky & $ffff
townlocation:
	jmp town & $ffff
outpostlocation:
	jmp outpost & $ffff
sewerlocation:
	jmp sewer & $ffff

deadwood:
	LOAD_ALL_TILES LOCATION_TILES, dead_wood_name_tiles
	jmp namedone & $ffff

unbearable:
	LOAD_ALL_TILES LOCATION_TILES, unbearable_name_tiles
	jmp namedone & $ffff

startcave:
	LOAD_ALL_TILES LOCATION_TILES, starting_cave_name_tiles
	jmp namedone & $ffff

startforest:
	LOAD_ALL_TILES LOCATION_TILES, starting_forest_name_tiles
	jmp namedone & $ffff

maincave:
	LOAD_ALL_TILES LOCATION_TILES, main_cave_name_tiles
	jmp namedone & $ffff

lostcave:
	LOAD_ALL_TILES LOCATION_TILES, lost_cave_name_tiles
	jmp namedone & $ffff

mine:
	LOAD_ALL_TILES LOCATION_TILES, mine_name_tiles
	jmp namedone & $ffff

town:
	LOAD_ALL_TILES LOCATION_TILES, town_name_tiles
	jmp namedone & $ffff

base:
	LOAD_ALL_TILES LOCATION_TILES, base_name_tiles
	jmp namedone & $ffff

blocky:
	LOAD_ALL_TILES LOCATION_TILES, blocky_cave_name_tiles
	jmp namedone & $ffff

outpost:
	LOAD_ALL_TILES LOCATION_TILES, outpost_name_tiles
	jmp namedone & $ffff

sewer:
	LOAD_ALL_TILES LOCATION_TILES, sewer_name_tiles
	jmp namedone & $ffff

namedone:
	rts
.endproc


.segment "FIXED"

PROC generate_gold_string
	lda #'$'
	sta gold_str
	ldx #0
	ldy #1
loop:
	lda gold, x
	bne nonzero
	lda #' '
	sta gold_str - 1, y
	lda #'$'
	sta gold_str, y
	inx
	iny
	cpx #3
	bne loop
nonzero:
	lda gold, x
	clc
	adc #'0'
	sta gold_str, y
	inx
	iny
	cpx #4
	bne nonzero
	lda #0
	sta gold_str, y
	rts
.endproc


PROC init_status_tiles
	lda current_bank
	pha
	lda #^do_init_status_tiles
	jsr bankswitch
	jsr do_init_status_tiles & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_init_status_tiles
	LOAD_ALL_TILES 0, status_ui_tiles
	LOAD_ALL_TILES RIGHT_PANEL_TILES, key_tiles
	jsr do_load_key_count_tiles & $ffff
	jsr load_area_name_tiles

	; Load status bar palette into palette 3
	LOAD_PTR status_palette
	jsr load_game_palette_3

	; Apply status bar palette
	lda #0
	sta arg0
	lda #MAP_HEIGHT
	sta arg1
	lda #15
	sta arg2
	lda #13
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	; Render health bar outline
	LOAD_PTR health_bar_top_tiles
	ldx #1
	ldy #24
	lda #14
	jsr write_tiles
	ldx #1
	ldy #25
	lda #14
	jsr write_tiles
	ldx #1
	ldy #26
	lda #14
	jsr write_tiles
	ldx #2
	ldy #27
	lda #11
	jsr write_tiles

	; Render health bar according to player health
	LOAD_PTR full_health_tiles
	lda player_health
	lsr
	lsr
	lsr
	beq nofulltiles
	ldx #2
	ldy #25
	jsr write_tiles

nofulltiles:
	lda player_health
	cmp #96
	bcs fullhealth

	LOAD_PTR partial_health_tile
	lda player_health
	lsr
	lsr
	lsr
	clc
	adc #2
	tax
	ldy #25
	lda #1
	jsr write_tiles

	lda player_health
	and #7
	tay

	lda PPUSTATUS
	lda #$02
	sta PPUADDR
	lda #$b8
	sta PPUADDR
	lda health_bar_mask, y
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA

fullhealth:
	lda player_health
	sta displayed_health

	; Check equipped weapon to see if it has ammo
	lda equipped_weapon
	cmp #ITEM_NONE
	beq noammo

	jsr get_item_type
	cmp #ITEM_TYPE_MELEE
	beq noammo

	; Render ammo counter
	LOAD_PTR ammo_tiles
	ldx #16
	ldy #25
	lda #3
	jsr write_tiles

	lda equipped_weapon_slot
	asl
	tax
	lda inventory, x
	sta displayed_ammo
	jsr byte_to_padded_str
	LOAD_PTR scratch
	ldx #16
	ldy #26
	jsr write_string

	jmp renderitem & $ffff

noammo:
	; No equipped item or does not have ammo
	LOAD_PTR clear_ammo_tiles
	ldx #16
	ldy #25
	lda #3
	jsr write_tiles

	LOAD_PTR clear_ammo_str
	ldx #16
	ldy #26
	jsr write_string

renderitem:
	; Render current item box
	LOAD_PTR cur_item_top_tiles
	ldx #19
	ldy #24
	lda #4
	jsr write_tiles
	ldx #19
	ldy #25
	lda #4
	jsr write_tiles
	ldx #19
	ldy #26
	lda #4
	jsr write_tiles
	ldx #19
	ldy #27
	lda #4
	jsr write_tiles

	; Render current item
	lda equipped_weapon
	ldx #DYNAMIC_TILES
	jsr load_item_background_tiles

	lda #207
	sta sprites + SPRITE_OAM_EQUIP_WEAPON
	lda #DYNAMIC_TILES
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 1
	lda #2
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 2
	lda #168
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 3

	lda #207
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 4
	lda #DYNAMIC_TILES + 2
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 5
	lda #2
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 6
	lda #176
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 7

	; Render right panel, which by default contains the game progress and gold
	LOAD_PTR right_panel_top_tiles
	ldx #24
	ldy #24
	lda #5
	jsr write_tiles
	ldx #24
	ldy #25
	lda #5
	jsr write_tiles

	jsr generate_gold_string
	LOAD_PTR gold_str
	ldx #24
	ldy #26
	jsr write_string

	lda #0
	sta status_display_state

	rts
.endproc


PROC do_load_key_count_tiles
	lda key_count
	cmp #1
	beq one
	cmp #2
	beq two
	cmp #3
	beq three
	cmp #4
	beq four
	cmp #5
	beq five
	cmp #6
	beq six

	LOAD_ALL_TILES RIGHT_PANEL_TILES + 5, zero_key_tiles
	rts

five:
	jmp dofive & $ffff
six:
	jmp dosix & $ffff

one:
	LOAD_ALL_TILES RIGHT_PANEL_TILES + 5, one_key_tiles
	rts

two:
	LOAD_ALL_TILES RIGHT_PANEL_TILES + 5, two_key_tiles
	rts

three:
	LOAD_ALL_TILES RIGHT_PANEL_TILES + 5, three_key_tiles
	rts

four:
	LOAD_ALL_TILES RIGHT_PANEL_TILES + 5, four_key_tiles
	rts

dofive:
	LOAD_ALL_TILES RIGHT_PANEL_TILES + 5, five_key_tiles
	rts

dosix:
	LOAD_ALL_TILES RIGHT_PANEL_TILES + 5, six_key_tiles
	rts
.endproc


.code

PROC update_status_bar
	lda status_display_state
	asl
	tax
	lda status_state_func, x
	sta ptr
	lda status_state_func + 1, x
	sta ptr + 1
	jsr call_ptr
	rts
.endproc


PROC update_status_bar_normal
	lda new_item_queue_length
	beq nonewitem

	lda #STATUS_STATE_NEW_ITEM_CLEAR_BEFORE
	sta status_display_state

nonewitem:
	jmp update_status_bar_health_and_ammo
.endproc


PROC update_status_bar_new_item_clear_before
.endproc


PROC update_status_bar_health_and_ammo
	lda equipped_weapon
	cmp #ITEM_NONE
	beq noammo
	jsr get_item_type
	cmp #ITEM_TYPE_MELEE
	beq noammo

	lda equipped_weapon_slot
	asl
	tax
	lda inventory, x
	cmp displayed_ammo
	beq noammo

	; Amount of ammo changed, display the new ammo count
	sta displayed_ammo
	jsr byte_to_padded_str
	LOAD_PTR scratch
	ldx #16
	ldy #26
	jsr write_string
	rts

noammo:
	lda displayed_health
	cmp player_health
	bne healthupdate
	jmp nohealthupdate
healthupdate:
	bcc healthup

	and #7
	bne downwithintile

	lda displayed_health
	cmp #96
	bcc downnotfull

	LOAD_PTR drop_health_tiles
	ldx #13
	ldy #25
	lda #1
	jsr write_tiles
	jmp downwithintile

downnotfull:
	lsr
	lsr
	lsr
	clc
	adc #1
	tax
	LOAD_PTR drop_health_tiles
	ldy #25
	lda #2
	jsr write_tiles

downwithintile:
	dec displayed_health

updatepartial:
	lda displayed_health
	lsr
	lsr
	lsr
	tax
	lda displayed_health
	and #7
	tay

	lda PPUSTATUS
	lda #$02
	sta PPUADDR
	lda #$b8
	sta PPUADDR
	lda health_bar_mask, y
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	sta PPUDATA
	rts

healthup:
	inc displayed_health
	lda displayed_health
	and #7
	bne updatepartial

	lda displayed_health
	cmp #96
	bcc upnotfull

	LOAD_PTR increase_health_tiles
	ldx #13
	ldy #25
	lda #1
	jsr write_tiles
	rts

upnotfull:
	lsr
	lsr
	lsr
	clc
	adc #1
	tax
	LOAD_PTR increase_health_tiles
	ldy #25
	lda #2
	jsr write_tiles
	jmp updatepartial

nohealthupdate:
	rts
.endproc


.segment "TEMP"
VAR gold_str
	.byte 0, 0, 0, 0, 0, 0

VAR displayed_health
	.byte 0
VAR displayed_ammo
	.byte 0

VAR status_display_state
	.byte 0
VAR status_display_counter
	.byte 0

VAR new_item_queue_type
	.byte 0, 0, 0, 0, 0, 0, 0, 0
VAR new_item_queue_count
	.byte 0, 0, 0, 0, 0, 0, 0, 0
VAR new_item_queue_length
	.byte 0


.segment "FIXED"

VAR status_palette
	.byte $0f, $00, $16, $30

VAR health_bar_top_tiles
	.byte $60, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $62
VAR health_bar_mid_tiles
	.byte $28, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $29
VAR health_bar_bot_tiles
	.byte $61, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $5d, $63
VAR health_bar_below_tiles
	.byte $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19

VAR ammo_tiles
	.byte $5e, $5f, $64
VAR clear_ammo_tiles
	.byte $00, $00, $00
VAR clear_ammo_str
	.byte "   ", 0

VAR cur_item_top_tiles
	.byte $60, $5b, $5b, $62
VAR cur_item_mid_tiles
	.byte $28, $00, $00, $29
	.byte $28, $00, $00, $29
VAR cur_item_bot_tiles
	.byte $61, $5d, $5d, $63

VAR right_panel_top_tiles
	.byte RIGHT_PANEL_TILES + 0, RIGHT_PANEL_TILES + 1
	.byte RIGHT_PANEL_TILES + 2, RIGHT_PANEL_TILES + 3
	.byte RIGHT_PANEL_TILES + 4
VAR right_panel_bot_tiles
	.byte RIGHT_PANEL_TILES + 5, RIGHT_PANEL_TILES + 6
	.byte RIGHT_PANEL_TILES + 7, RIGHT_PANEL_TILES + 8
	.byte RIGHT_PANEL_TILES + 9

VAR health_bar_mask
	.byte $00, $80, $c0, $e0, $f0, $f8, $fc, $fe

VAR drop_health_tiles
	.byte $2b, $00
VAR increase_health_tiles
	.byte $2a, $2b

VAR full_health_tiles
	.byte $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a
VAR partial_health_tile
	.byte $2b

VAR status_state_func
	.word update_status_bar_normal
	.word update_status_bar_new_item_clear_before


TILES status_ui_tiles, 1, "tiles/status/ui.chr", 102

TILES new_item_tiles, 2, "tiles/status/item.chr", 10
TILES time_tiles, 2, "tiles/status/time.chr", 10
TILES key_tiles, 2, "tiles/status/keys.chr", 10

TILES starting_cave_name_tiles, 2, "tiles/status/startcave.chr", 22
TILES starting_forest_name_tiles, 2, "tiles/status/startforest.chr", 22
TILES town_name_tiles, 2, "tiles/status/town.chr", 22
TILES outpost_name_tiles, 2, "tiles/status/outpost.chr", 22
TILES forest_name_tiles, 2, "tiles/status/forest.chr", 22
TILES unbearable_name_tiles, 2, "tiles/status/unbearable.chr", 22
TILES mine_name_tiles, 2, "tiles/status/mine.chr", 22
TILES main_cave_name_tiles, 2, "tiles/status/nope.chr", 22
TILES lost_cave_name_tiles, 2, "tiles/status/lostcave.chr", 22
TILES blocky_cave_name_tiles, 2, "tiles/status/blocky.chr", 22
TILES dead_wood_name_tiles, 2, "tiles/status/deadwood.chr", 22
TILES sewer_name_tiles, 2, "tiles/status/sewer.chr", 22
TILES base_name_tiles, 2, "tiles/status/base.chr", 22

TILES zero_key_tiles, 4, "tiles/status/0.chr", 1
TILES one_key_tiles, 4, "tiles/status/1.chr", 1
TILES two_key_tiles, 4, "tiles/status/2.chr", 1
TILES three_key_tiles, 4, "tiles/status/3.chr", 1
TILES four_key_tiles, 4, "tiles/status/4.chr", 1
TILES five_key_tiles, 4, "tiles/status/5.chr", 1
TILES six_key_tiles, 4, "tiles/status/6.chr", 1
