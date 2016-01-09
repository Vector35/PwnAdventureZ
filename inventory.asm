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

.code

PROC show_inventory
	ldx #0
palettesaveloop:
	lda active_palette, x
	sta saved_palette, x
	inx
	cpx #32
	bne palettesaveloop

	lda ppu_settings
	sta saved_ppu_settings

	jsr fade_out

	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_SIZE | PPUCTRL_NAMETABLE_2000
	sta ppu_settings

	jmp show_inventory_tab
.endproc

PROC show_inventory_tab
	jsr clear_alt_screen
	LOAD_ALL_TILES $000, inventory_ui_tiles

	lda #0
	sta selection
	lda #0
	sta scroll
	jsr render_inventory_screen

	lda #30
	sta repeat_time

	lda inventory_count
	bne selectloop
	jmp emptyloop
selectloop:
	jsr wait_for_vblank
	lda controller
	and #JOY_DOWN
	bne downpressed
	lda controller
	and #JOY_UP
	bne up
	lda controller
	and #JOY_A
	bne usepressed
	lda controller
	and #JOY_LEFT
	bne salvage
	lda controller
	and #JOY_RIGHT
	bne craft
	lda controller
	and #JOY_SELECT | JOY_START
	beq nobutton
	jmp done

salvage:
	lda horde_active
	bne nosalvage
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_salvage_tab
nosalvage:
	jmp waitfordepress

craft:
	lda horde_active
	bne nocraft
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_crafting_tab
nocraft:
	jmp waitfordepress

nobutton:
	lda #30
	sta repeat_time
	jmp selectloop

downpressed:
	jmp down

usepressed:
	jmp use

up:
	lda selection
	beq attop

	PLAY_SOUND_EFFECT effect_uimove

	jsr deselect_inventory_item

	lda selection
	sec
	sbc scroll
	cmp #2
	bcs noupscroll

	lda scroll
	beq noupscroll

	dec scroll

	lda controller
	and #JOY_B
	bne moveup

	jsr render_inventory_items
	dec selection
	jsr select_inventory_item
	jmp shortwaitfordepress

noupscroll:
	lda controller
	and #JOY_B
	bne moveup

	dec selection
	jsr select_inventory_item
attop:
	jmp waitfordepress

moveup:
	lda selection
	asl
	tax
	lda inventory - 2, x
	sta temp
	lda inventory - 1, x
	sta temp + 1
	lda inventory, x
	sta inventory - 2, x
	lda inventory + 1, x
	sta inventory - 1, x
	lda temp
	sta inventory, x
	lda temp + 1
	sta inventory + 1, x

	jsr render_inventory_items
	dec selection
	jsr select_inventory_item
	jmp shortwaitfordepress

down:
	lda selection
	clc
	adc #1
	cmp inventory_count
	beq atbottom

	PLAY_SOUND_EFFECT effect_uimove

	jsr deselect_inventory_item

	lda selection
	sec
	sbc scroll
	cmp #4
	bcc nodownscroll

	lda scroll
	clc
	adc #6
	cmp inventory_count
	bcs nodownscroll

	inc scroll

	lda controller
	and #JOY_B
	bne movedown

	jsr render_inventory_items
	inc selection
	jsr select_inventory_item
	jmp shortwaitfordepress

nodownscroll:
	lda controller
	and #JOY_B
	bne movedown

	inc selection
	jsr select_inventory_item
atbottom:
	jmp waitfordepress

movedown:
	lda selection
	asl
	tax
	lda inventory + 2, x
	sta temp
	lda inventory + 3, x
	sta temp + 1
	lda inventory, x
	sta inventory + 2, x
	lda inventory + 1, x
	sta inventory + 3, x
	lda temp
	sta inventory, x
	lda temp + 1
	sta inventory + 1, x

	jsr render_inventory_items
	inc selection
	jsr select_inventory_item
	jmp shortwaitfordepress

use:
	lda selection
	asl
	tax
	lda inventory + 1, x
	jsr get_item_type
	cmp #ITEM_TYPE_GUN
	beq equipweapon
	cmp #ITEM_TYPE_MELEE
	beq equipweapon
	cmp #ITEM_TYPE_GRENADE
	beq equipweapon
	cmp #ITEM_TYPE_OUTFIT
	beq equipwearable
	jmp performuse

equipweapon:
	PLAY_SOUND_EFFECT effect_equip

	lda selection
	asl
	tax
	lda inventory + 1, x

	cmp equipped_weapon
	beq uneqipweapon

	sta equipped_weapon
	jmp updateequip

uneqipweapon:
	lda #$ff
	sta equipped_weapon
	jmp updateequip

equipwearable:
	PLAY_SOUND_EFFECT effect_equip

	lda selection
	asl
	tax
	lda inventory + 1, x

	cmp equipped_armor
	beq unequiparmor

	sta equipped_armor
	jmp updateequip

unequiparmor:
	lda #$ff
	sta equipped_armor

updateequip:
	jsr wait_for_vblank
	lda equipped_weapon
	ldx #$18
	jsr load_item_sprite_tiles
	jsr prepare_for_rendering

	jsr wait_for_vblank
	lda equipped_armor
	ldx #$1c
	jsr load_item_sprite_tiles
	jsr prepare_for_rendering

	jmp waitfordepress

performuse:
	lda selection
	asl
	tax
	lda inventory + 1, x
	jsr use_item
	bne validuse

	jmp invaliduse

validuse:
	PLAY_SOUND_EFFECT_NO_OVERRIDE effect_select

	jsr deselect_inventory_item

	lda selection
	asl
	tax
	dec inventory, x
	beq usedall

	jsr update_inventory_status
	jsr render_inventory_items
	jsr select_inventory_item
	jmp waitfordepress

usedall:
	lda selection
	sta arg0
deleteloop:
	lda arg0
	clc
	adc #1
	cmp inventory_count
	beq deletedone

	lda arg0
	asl
	tax
	lda inventory + 2, x
	sta inventory, x
	lda inventory + 3, x
	sta inventory + 1, x

	inc arg0
	jmp deleteloop

deletedone:
	dec inventory_count
	beq deleteempty

	lda scroll
	clc
	adc #5
	cmp inventory_count
	bcc deletescrollok

	lda scroll
	beq deletelast

	dec selection
	dec scroll
	jmp deletescrollok

deleteempty:
	jsr clear_last_inventory_item

	jsr wait_for_vblank_if_rendering
	LOAD_PTR no_items_str
	ldx #11
	ldy #32 + 11
	jsr write_string
	jsr prepare_for_rendering

	jsr wait_for_vblank_if_rendering
	LOAD_PTR clear_item_description_str
	ldx #2
	ldy #32 + 21
	jsr write_string
	jsr prepare_for_rendering

	jmp emptyloop

deletelast:
	lda selection
	cmp inventory_count
	bne nochangeselect
	dec selection
nochangeselect:
	jsr clear_last_inventory_item

deletescrollok:
	jsr update_inventory_status
	jsr render_inventory_items
	jsr select_inventory_item
	jmp waitfordepress

invaliduse:
	jmp waitfordepress

shortwaitfordepress:
	lda repeat_time
	cmp #30
	bne nowait
	ldx #6
	jsr wait_for_frame_count
	lda #3
	sta repeat_time
	jmp selectloop

nowait:
	jmp selectloop

waitfordepress:
	lda repeat_time
	sta arg0
waitfordepressloop:
	dec arg0
	beq waitfordepresstimeout
	jsr wait_for_vblank
	lda controller
	bne waitfordepressloop
	jmp selectloop
waitfordepresstimeout:
	lda #3
	sta repeat_time
	jmp selectloop

emptyloop:
	jsr wait_for_vblank
	lda controller
	and #JOY_LEFT
	bne emptysalvage
	lda controller
	and #JOY_RIGHT
	bne emptycrafting
	lda controller
	and #JOY_SELECT
	beq emptyloop
	jmp done

emptysalvage:
	jmp salvage
emptycrafting:
	jmp craft

done:
	jmp end_inventory_screen
.endproc


PROC end_inventory_screen
	PLAY_SOUND_EFFECT effect_select

	jsr fade_out

	lda saved_ppu_settings
	sta ppu_settings

	jsr update_equipped_item_slots
	jsr back_to_game_from_alternate_screen

	LOAD_PTR saved_palette
	jsr fade_in

	rts
.endproc


.segment "FIXED"

PROC render_inventory_screen
	lda current_bank
	pha
	lda #^do_render_inventory_screen
	jsr bankswitch
	jsr do_render_inventory_screen & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC render_inventory_status_bar
	lda current_bank
	pha
	lda #^do_render_inventory_status_bar
	jsr bankswitch
	jsr do_render_inventory_status_bar & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC update_inventory_status
	lda current_bank
	pha
	lda #^do_update_inventory_status
	jsr bankswitch
	jsr do_update_inventory_status & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC render_inventory_items
	lda current_bank
	pha
	lda #^do_render_inventory_items
	jsr bankswitch
	jsr do_render_inventory_items & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC clear_last_inventory_item
	lda current_bank
	pha
	lda #^do_clear_last_inventory_item
	jsr bankswitch
	jsr do_clear_last_inventory_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC select_inventory_item
	lda current_bank
	pha
	lda #^do_select_inventory_item
	jsr bankswitch
	jsr do_select_inventory_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC deselect_inventory_item
	lda current_bank
	pha
	lda #^do_deselect_inventory_item
	jsr bankswitch
	jsr do_deselect_inventory_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_render_inventory_screen
	; Draw box around inventory screen
	lda #1
	sta arg0
	lda #32 + 1
	sta arg1
	lda #28
	sta arg2
	lda #32 + 22
	sta arg3
	jsr draw_large_box

	lda horde_active
	beq craft

	LOAD_PTR no_craft_inventory_str
	ldx #3
	ldy #32 + 1
	jsr write_string
	jmp titledone & $ffff

craft:
	LOAD_PTR inventory_str
	ldx #3
	ldy #32 + 1
	jsr write_string

	; Set palette for title
	lda #1
	sta arg0
	lda #16 + 0
	sta arg1
	lda #4
	sta arg2
	lda #16 + 0
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	lda #10
	sta arg0
	lda #16 + 0
	sta arg1
	lda #13
	sta arg2
	lda #16 + 0
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

titledone:
	; Set palette for inside of box
	lda #1
	sta arg0
	lda #16 + 1
	sta arg1
	lda #13
	sta arg2
	lda #16 + 10
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	; Set palette for status area
	lda #0
	sta arg0
	lda #16 + 12
	sta arg1
	lda #14
	sta arg2
	lda #16 + 13
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	; Draw initial items
	lda inventory_count
	bne notempty

	LOAD_PTR no_items_str
	ldx #11
	ldy #32 + 11
	jsr write_string
	jmp itemend & $ffff

notempty:
	jsr render_inventory_items

itemend:
	jsr render_inventory_status_bar

	; Draw help text
	LOAD_PTR inventory_help_str
	ldx #1
	ldy #32 + 23
	jsr write_string

	lda inventory_count
	beq nosetupselect
	jsr select_inventory_item
nosetupselect:

	LOAD_PTR inventory_palette
	jsr fade_in

	rts
.endproc


PROC do_render_inventory_status_bar
	jsr load_area_name_tiles

	; Render health bar outline
	LOAD_PTR inventory_health_bar_top_tiles
	ldx #1
	ldy #32 + 24
	lda #14
	jsr write_tiles
	ldx #1
	ldy #32 + 25
	lda #14
	jsr write_tiles
	ldx #1
	ldy #32 + 26
	lda #14
	jsr write_tiles
	ldx #2
	ldy #32 + 27
	lda #11
	jsr write_tiles

	jsr do_update_inventory_status & $ffff

	; Render item boxes for equipped item
	LOAD_PTR two_items_top_tiles
	ldx #15
	ldy #32 + 24
	lda #8
	jsr write_tiles
	ldx #15
	ldy #32 + 25
	lda #8
	jsr write_tiles
	ldx #15
	ldy #32 + 26
	lda #8
	jsr write_tiles
	ldx #15
	ldy #32 + 27
	lda #8
	jsr write_tiles

	; Show key count and gold
	LOAD_ALL_TILES $7b, inventory_key_tiles
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

	LOAD_ALL_TILES $7b, zero_key_tiles
	jmp keydone & $ffff

five:
	jmp dofive & $ffff
six:
	jmp dosix & $ffff

one:
	LOAD_ALL_TILES $7b, one_key_tiles
	jmp keydone & $ffff

two:
	LOAD_ALL_TILES $7b, two_key_tiles
	jmp keydone & $ffff

three:
	LOAD_ALL_TILES $7b, three_key_tiles
	jmp keydone & $ffff

four:
	LOAD_ALL_TILES $7b, four_key_tiles
	jmp keydone & $ffff

dofive:
	LOAD_ALL_TILES $7b, five_key_tiles
	jmp keydone & $ffff

dosix:
	LOAD_ALL_TILES $7b, six_key_tiles
	jmp keydone & $ffff

keydone:
	LOAD_PTR inventory_keys
	ldx #24
	ldy #32 + 25
	lda #5
	jsr write_tiles

	jsr generate_gold_string
	LOAD_PTR gold_str
	ldx #24
	ldy #32 + 26
	jsr write_string

	; Render currently equipped items
	lda equipped_weapon
	ldx #$18
	jsr load_item_sprite_tiles

	lda #207
	sta sprites + SPRITE_OAM_EQUIP_WEAPON
	lda #$19
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 1
	lda #2
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 2
	lda #168
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 3

	lda #207
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 4
	lda #$1b
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 5
	lda #2
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 6
	lda #176
	sta sprites + SPRITE_OAM_EQUIP_WEAPON + 7

	lda equipped_armor
	ldx #$1c
	jsr load_item_sprite_tiles

	lda #207
	sta sprites + SPRITE_OAM_EQUIP_ARMOR
	lda #$1d
	sta sprites + SPRITE_OAM_EQUIP_ARMOR + 1
	lda #2
	sta sprites + SPRITE_OAM_EQUIP_ARMOR + 2
	lda #136
	sta sprites + SPRITE_OAM_EQUIP_ARMOR + 3

	lda #207
	sta sprites + SPRITE_OAM_EQUIP_ARMOR + 4
	lda #$1f
	sta sprites + SPRITE_OAM_EQUIP_ARMOR + 5
	lda #2
	sta sprites + SPRITE_OAM_EQUIP_ARMOR + 6
	lda #144
	sta sprites + SPRITE_OAM_EQUIP_ARMOR + 7

	rts
.endproc


PROC do_update_inventory_status
	jsr wait_for_vblank_if_rendering

	; Render health bar according to player health
	LOAD_PTR inventory_full_health_tiles
	lda player_health
	lsr
	lsr
	lsr
	beq nofulltiles
	ldx #2
	ldy #32 + 25
	jsr write_tiles

nofulltiles:
	lda player_health
	cmp #96
	bcs fullhealth

	LOAD_PTR inventory_partial_health_tile
	lda player_health
	lsr
	lsr
	lsr
	clc
	adc #2
	tax
	ldy #32 + 25
	lda #1
	jsr write_tiles

	lda player_health
	and #7
	tay

	lda PPUSTATUS
	lda #$02
	sta PPUADDR
	lda #$e8
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
	jsr prepare_for_rendering
	rts
.endproc


PROC do_render_inventory_items
	lda #0
	sta arg0
itemloop:
	lda arg0
	clc
	adc scroll
	cmp inventory_count
	bne hasitem
	jmp itemend & $ffff

hasitem:
	lda arg0
	beq first
	LOAD_PTR inventory_item_second_box_tiles
	jmp drawitem & $ffff
first:
	LOAD_PTR inventory_item_first_box_tiles

drawitem:
	lda rendering_enabled
	bne count

	; Draw box around item graphic
	ldx #2
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 2
	sta arg1
	tay
	lda #4
	jsr write_tiles

	ldx #2
	inc arg1
	ldy arg1
	lda #4
	jsr write_tiles

	ldx #2
	inc arg1
	ldy arg1
	lda #4
	jsr write_tiles

	ldx #2
	inc arg1
	ldy arg1
	lda #4
	jsr write_tiles

count:
	; Load icon for the item
	jsr wait_for_vblank_if_rendering

	lda arg0
	asl
	asl
	tax
	lda arg0
	clc
	adc scroll
	asl
	tay
	lda inventory + 1, y
	jsr load_item_sprite_tiles

	jsr prepare_for_rendering

	lda arg0
	asl
	asl
	asl
	clc
	adc #16
	tay
	lda arg0
	asl
	clc
	adc arg0
	asl
	asl
	asl
	adc #31
	sta sprites, y
	sta sprites + 4, y
	lda arg0
	asl
	asl
	clc
	adc #1
	sta sprites + 1, y
	adc #2
	sta sprites + 5, y
	lda #1
	sta sprites + 2, y
	sta sprites + 6, y
	lda #32
	sta sprites + 3, y
	lda #40
	sta sprites + 7, y

	jsr wait_for_vblank_if_rendering

	; Get string with item count
	lda arg0
	clc
	adc scroll
	asl
	tax
	lda inventory, x
	jsr byte_to_padded_str

	; Get the item type
	lda arg0
	clc
	adc scroll
	asl
	tax
	lda inventory + 1, x
	jsr get_item_type
	sta arg2
	cmp #ITEM_TYPE_GUN
	beq ammocount

	; Draw item count
	lda #$40
	sta scratch + 3
	lda #0
	sta scratch + 4
	LOAD_PTR scratch
	ldx #7
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 3
	tay
	jsr write_string

	LOAD_PTR inventory_non_ammo_tiles
	ldx #7
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 4
	tay
	lda #3
	jsr write_tiles

	jmp drawname & $ffff

ammocount:
	; Draw ammo count
	lda #' '
	sta scratch + 3
	lda #0
	sta scratch + 4
	LOAD_PTR scratch
	ldx #7
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 3
	tay
	jsr write_string

	LOAD_PTR inventory_ammo_tiles
	ldx #7
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 4
	tay
	lda #3
	jsr write_tiles

drawname:
	lda arg0
	clc
	adc scroll
	asl
	tax
	lda inventory + 1, x
	jsr get_item_name
	ldx #12
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 3
	sta arg1
	tay
	jsr write_string

	; Draw item type
	lda arg2
	cmp #ITEM_TYPE_GUN
	beq weapon
	cmp #ITEM_TYPE_MELEE
	beq weapon
	cmp #ITEM_TYPE_GRENADE
	beq weapon
	cmp #ITEM_TYPE_CRAFTING
	beq crafting
	cmp #ITEM_TYPE_OUTFIT
	beq wearable
	cmp #ITEM_TYPE_HEALTH
	beq healing
	cmp #ITEM_TYPE_CONSUMABLE
	beq usable
	cmp #ITEM_TYPE_CAMPFIRE
	beq usable

	LOAD_PTR inventory_sell_tiles
	jmp drawtype & $ffff
weapon:
	LOAD_PTR inventory_weapon_tiles
	jmp drawtype & $ffff
crafting:
	LOAD_PTR inventory_crafting_tiles
	jmp drawtype & $ffff
wearable:
	LOAD_PTR inventory_wearable_tiles
	jmp drawtype & $ffff
healing:
	LOAD_PTR inventory_healing_tiles
	jmp drawtype & $ffff
usable:
	LOAD_PTR inventory_usable_tiles

drawtype:
	lda #6
	ldx #12
	ldy arg1
	iny
	jsr write_tiles

	jsr prepare_for_rendering

nextitem:
	ldx arg0
	inx
	stx arg0
	cpx #6
	beq itemend
	jmp itemloop & $ffff

itemend:
	rts
.endproc


PROC do_clear_last_inventory_item
	jsr wait_for_vblank_if_rendering

	lda inventory_count
	beq noitems
	LOAD_PTR clear_item_tiles
	jmp renderbox & $ffff
noitems:
	LOAD_PTR clear_last_item_tiles

renderbox:
	ldx #2
	lda inventory_count
	asl
	clc
	adc inventory_count
	adc #32 + 2
	sta arg1
	tay
	lda #4
	jsr write_tiles

	ldx #2
	inc arg1
	ldy arg1
	lda #4
	jsr write_tiles

	ldx #2
	inc arg1
	ldy arg1
	lda #4
	jsr write_tiles

	ldx #2
	inc arg1
	ldy arg1
	lda #4
	jsr write_tiles

	jsr prepare_for_rendering
	jsr wait_for_vblank_if_rendering

	LOAD_PTR clear_item_str
	ldx #7
	lda inventory_count
	asl
	clc
	adc inventory_count
	adc #32 + 3
	sta arg1
	tay
	jsr write_string

	LOAD_PTR clear_item_str
	ldx #7
	inc arg1
	ldy arg1
	jsr write_string

	jsr prepare_for_rendering

	lda arg0
	asl
	asl
	asl
	clc
	adc #16
	tay
	lda #$ff
	sta sprites, y
	sta sprites + 4, y

	rts
.endproc


PROC do_select_inventory_item
	lda selection
	sec
	sbc scroll
	and #1
	beq even

	lda selection
	sec
	sbc scroll
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 3
	sta temp

	lda #6
	sta arg0
	lda temp
	sta arg1
	lda #13
	sta arg2
	lda temp
	sta arg3
	lda #0
	sta arg4
	jsr wait_for_vblank
	jsr set_box_palette
	jsr prepare_for_rendering
	jmp palettedone & $ffff

even:
	lda selection
	sec
	sbc scroll
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 1
	sta temp

	lda #6
	sta arg0
	lda temp
	sta arg1
	lda #13
	sta arg2
	lda temp
	sta arg3
	lda #0
	sta arg4
	jsr wait_for_vblank
	jsr set_box_palette
	jsr prepare_for_rendering

	lda selection
	sec
	sbc scroll
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 2
	sta temp

	lda #6
	sta arg0
	lda temp
	sta arg1
	lda #13
	sta arg2
	lda temp
	sta arg3
	lda #0
	sta arg4
	jsr wait_for_vblank
	jsr set_box_palette
	jsr prepare_for_rendering
	jmp palettedone & $ffff

palettedone:
	jsr wait_for_vblank

	lda selection
	asl
	tax
	lda inventory + 1, x
	jsr get_item_description
	ldx #2
	ldy #32 + 21
	jsr write_string

	jsr prepare_for_rendering

	lda selection
	sec
	sbc scroll
	sta temp
	asl
	clc
	adc temp
	asl
	asl
	asl
	adc #24
	sta temp

	sta sprites
	lda #$5c
	sta sprites + 1
	lda #0
	sta sprites + 2
	lda #58
	sta sprites + 3

	lda temp
	clc
	adc #13
	sta sprites + 4
	lda #$5c
	sta sprites + 5
	lda #SPRITE_FLIP_VERT
	sta sprites + 6
	lda #58
	sta sprites + 7

	lda temp
	sta sprites + 8
	lda #$5c
	sta sprites + 9
	lda #SPRITE_FLIP_HORIZ
	sta sprites + 10
	lda #222
	sta sprites + 11

	lda temp
	clc
	adc #13
	sta sprites + 12
	lda #$5c
	sta sprites + 13
	lda #SPRITE_FLIP_HORIZ | SPRITE_FLIP_VERT
	sta sprites + 14
	lda #222
	sta sprites + 15

	rts
.endproc


PROC do_deselect_inventory_item
	lda selection
	sec
	sbc scroll
	and #1
	beq even

	lda selection
	sec
	sbc scroll
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 3
	sta temp

	lda #6
	sta arg0
	lda temp
	sta arg1
	lda #13
	sta arg2
	lda temp
	sta arg3
	lda #1
	sta arg4
	jsr wait_for_vblank
	jsr set_box_palette
	jsr prepare_for_rendering
	jmp updatesprites & $ffff

even:
	lda selection
	sec
	sbc scroll
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 1
	sta temp

	lda #6
	sta arg0
	lda temp
	sta arg1
	lda #13
	sta arg2
	lda temp
	sta arg3
	lda #1
	sta arg4
	jsr wait_for_vblank
	jsr set_box_palette
	jsr prepare_for_rendering

	lda selection
	sec
	sbc scroll
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 2
	sta temp

	lda #6
	sta arg0
	lda temp
	sta arg1
	lda #13
	sta arg2
	lda temp
	sta arg3
	lda #1
	sta arg4
	jsr wait_for_vblank
	jsr set_box_palette
	jsr prepare_for_rendering
	jmp updatesprites & $ffff

updatesprites:
	lda #$ff
	sta sprites
	sta sprites + 4
	sta sprites + 8
	sta sprites + 12
	rts
.endproc


.segment "TEMP"
VAR scroll
	.byte 0

VAR repeat_time
	.byte 0


.data

VAR inventory_str
	.byte "SALVAGE", $3c, $3b, " ITEMS ", $3d, $3c, "CRAFT", 0

VAR no_craft_inventory_str
	.byte $3c, $3c, $3c, $3c, $3c, $3c, $3c, $3c, $3b, " ITEMS ", $3d, $3c, $3c, $3c, $3c, $3c, $3c, 0

VAR inventory_help_str
	.byte "A:USE/EQUIP  B:MOVE  ", $23, "/", $25, ":TAB", 0

VAR no_items_str
	.byte "NO ITEMS", 0

VAR inventory_item_first_box_tiles
	.byte $2a, $28, $28, $2b
	.byte $02, $00, $00, $3f
	.byte $02, $00, $00, $3f
	.byte $01, $29, $29, $2c

VAR inventory_item_second_box_tiles
	.byte $21, $5b, $5b, $22
	.byte $02, $00, $00, $3f
	.byte $02, $00, $00, $3f
	.byte $01, $29, $29, $2c

VAR inventory_ammo_tiles
	.byte $70, $71, $72
VAR inventory_non_ammo_tiles
	.byte $00, $00, $00

VAR inventory_weapon_tiles
	.byte $60, $61, $62, $63, $00, $00
VAR inventory_crafting_tiles
	.byte $64, $65, $66, $67, $68, $69
VAR inventory_healing_tiles
	.byte $73, $74, $75, $76, $77, $00
VAR inventory_wearable_tiles
	.byte $60, $61, $6e, $6f, $78, $79
VAR inventory_usable_tiles
	.byte $6a, $6b, $6c, $6d, $00, $00
VAR inventory_sell_tiles
	.byte $7a, $5e, $5f, $00, $00, $00

VAR inventory_health_bar_top_tiles
	.byte $2a, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $2b
VAR inventory_health_bar_mid_tiles
	.byte $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3f
VAR inventory_health_bar_bot_tiles
	.byte $01, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $29, $2c
VAR inventory_health_bar_below_tiles
	.byte $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19

VAR inventory_full_health_tiles
	.byte $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d
VAR inventory_partial_health_tile
	.byte $2e

VAR two_items_top_tiles
	.byte $2a, $28, $28, $2b, $2a, $28, $28, $2b
VAR two_items_mid_tiles
	.byte $02, $00, $00, $3f, $02, $00, $00, $3f
	.byte $02, $00, $00, $3f, $02, $00, $00, $3f
VAR two_items_bot_tiles
	.byte $01, $29, $29, $2c, $01, $29, $29, $2c

VAR inventory_keys
	.byte $7b, $7c, $7d, $7e, $7f

VAR clear_item_tiles
	.byte $01, $29, $29, $2c
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00

VAR clear_last_item_tiles
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00
	.byte $00, $00, $00, $00

VAR clear_item_str
	.byte "                    ", 0

VAR clear_item_description_str
	.byte "                          ", 0

VAR inventory_palette
	.byte $0f, $21, $31, $21
	.byte $0f, $00, $16, $30
	.byte $0f, $21, $31, $00
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $21, $21
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30


TILES inventory_ui_tiles, 2, "tiles/items/ui.chr", 123
TILES inventory_key_tiles, 2, "tiles/items/keys.chr", 5
