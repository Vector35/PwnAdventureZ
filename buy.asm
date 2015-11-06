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

PROC show_shop
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

	jmp show_buy_tab
.endproc

PROC show_buy_tab
	jsr clear_alt_screen
	LOAD_ALL_TILES $000, inventory_ui_tiles

	; Determine which items are possible to buy (don't imclude guns the player already has)
	lda #0
	sta arg0
	sta valid_shop_count

checkloop:
	ldx arg0
	lda purchase_items, x
	jsr find_item
	ldx valid_shop_count
	sta valid_shop_index, x
	cmp #$ff
	beq noitem

	ldx arg0
	lda purchase_items, x
	jsr get_item_type
	cmp #ITEM_TYPE_GUN
	bne noitem

	; Item is a gun that is already owned by the player, do not include in list
	jmp nextitem

noitem:
	lda arg0
	ldx valid_shop_count
	sta valid_shop_list, x
	inc valid_shop_count

nextitem:
	ldx arg0
	inx
	stx arg0
	cpx purchase_item_count
	bne checkloop

	lda #0
	sta selection
	lda #0
	sta scroll
	jsr render_buy_screen

	lda #30
	sta repeat_time

selectloop:
	jsr update_controller
	jsr wait_for_vblank
	lda controller
	and #JOY_DOWN
	bne downpressed
	lda controller
	and #JOY_UP
	bne up
	lda controller
	and #JOY_A | JOY_B
	bne buypressed
	lda controller
	and #JOY_LEFT
	bne buyback
	lda controller
	and #JOY_RIGHT
	bne sell
	lda controller
	and #JOY_SELECT | JOY_START
	beq nobutton
	jmp done

buyback:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_buyback_tab

sell:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_sell_tab

nobutton:
	lda #30
	sta repeat_time
	jmp selectloop

downpressed:
	jmp down

buypressed:
	jmp buy

up:
	lda selection
	beq attop

	PLAY_SOUND_EFFECT effect_uimove

	jsr deselect_inventory_item
	dec selection
	jsr select_buy_item
attop:
	jmp waitfordepress

down:
	lda selection
	clc
	adc #1
	cmp valid_shop_count
	beq atbottom

	PLAY_SOUND_EFFECT effect_uimove

	jsr deselect_inventory_item
	inc selection
	jsr select_buy_item
atbottom:
	jmp waitfordepress

buy:
	lda selection
	tax
	lda valid_shop_list, x
	tax
	stx arg0

	lda purchase_items, x
	jsr find_item
	cmp #$ff
	beq notfull
	asl
	tax
	lda inventory, x
	cmp #$ff
	bne notfull

	jmp waitfordepress

notfull:
	ldx arg0
	lda gold
	bne buyok
	lda gold + 1
	cmp purchase_price_high, x
	bcc notenough
	bne buyok
	lda gold + 2
	cmp purchase_price_mid, x
	bcc notenough
	bne buyok
	lda gold + 3
	cmp purchase_price_low, x
	bcc notenough
	jmp buyok

notenough:
	jmp waitfordepress

buyok:
	lda gold + 3
	sec
	sbc purchase_price_low, x
	bcs nocarry3
	sbc #$f5
	clc
nocarry3:
	sta gold + 3
	lda gold + 2
	sbc purchase_price_mid, x
	bcs nocarry2
	sbc #$f5
	clc
nocarry2:
	sta gold + 2
	lda gold + 1
	sbc purchase_price_high, x
	bcs nocarry1
	sbc #$f5
	clc
nocarry1:
	sta gold + 1
	lda gold
	sbc #0
	sta gold

	lda purchase_items, x
	sta arg0
	jsr get_item_type
	cmp #ITEM_TYPE_GUN
	bne notgun

	lda arg0
	jsr buy_gun
	jmp buydone & $ffff

notgun:
	jsr buy_item

buydone:
	PLAY_SOUND_EFFECT effect_buy

	jsr wait_for_vblank
	jsr generate_gold_string
	LOAD_PTR gold_str
	ldx #24
	ldy #32 + 26
	jsr write_string
	jsr prepare_for_rendering

	lda controller
	and #JOY_B
	beq waitfordepresslong
	jmp selectloop
	jmp shortwaitfordepress

shortwaitfordepress:
	lda repeat_time
	cmp #30
	bne nowait
	ldx #6
	jsr wait_for_frame_count
	lda #3
	sta repeat_time

	ldx #8
	jsr wait_for_frame_count
	jmp selectloop

waitfordepresslong:
	jsr update_controller
	jsr wait_for_vblank
	lda controller
	bne waitfordepresslong
	jmp selectloop

nowait:
	jmp selectloop

waitfordepress:
	lda repeat_time
	sta arg0
waitfordepressloop:
	dec arg0
	beq waitfordepresstimeout
	jsr update_controller
	jsr wait_for_vblank
	lda controller
	bne waitfordepressloop
	jmp selectloop
waitfordepresstimeout:
	lda #3
	sta repeat_time
	jmp selectloop

done:
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


PROC buy_gun
	ldx #12
	jsr give_weapon

	; Guns can only be bought once
	ldx selection
moveloop:
	lda valid_shop_list + 1, x
	sta valid_shop_list, x

	inx
	cpx valid_shop_count
	bne moveloop

	dec valid_shop_count

	; Refresh item indexes as they may have changed
	lda #0
	sta arg0
refreshloop:
	ldx arg0
	lda valid_shop_list, x
	tax
	lda purchase_items, x
	jsr find_item
	ldx arg0
	sta valid_shop_index, x
	ldx arg0
	inx
	stx arg0
	cpx valid_shop_count
	bne refreshloop

	jsr render_buy_items
	jsr clear_last_buy_item
	rts
.endproc


PROC buy_item
	lda arg0
	jsr give_item

	; Refresh item indexes as they may have changed
	lda #0
	sta arg0
refreshloop:
	ldx arg0
	lda valid_shop_list, x
	tax
	lda purchase_items, x
	jsr find_item
	ldx arg0
	sta valid_shop_index, x
	ldx arg0
	inx
	stx arg0
	cpx valid_shop_count
	bne refreshloop

	; Get string with item count
	lda selection
	tax
	lda valid_shop_index, x
	cmp #$ff
	bne nonzerocount
	lda #0
	jmp getcountstr & $ffff
nonzerocount:
	asl
	tax
	lda inventory, x
getcountstr:
	jsr byte_to_padded_str

	; Draw item count
	jsr wait_for_vblank

	LOAD_PTR scratch
	ldx #7
	lda selection
	sta arg0
	asl
	clc
	adc arg0
	adc #32 + 3
	tay
	jsr write_string

	jsr prepare_for_rendering

	rts
.endproc


.segment "FIXED"

PROC render_buy_screen
	lda current_bank
	pha
	lda #^do_render_buy_screen
	jsr bankswitch
	jsr do_render_buy_screen & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC render_buy_items
	lda current_bank
	pha
	lda #^do_render_buy_items
	jsr bankswitch
	jsr do_render_buy_items & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC select_buy_item
	lda current_bank
	pha
	lda #^do_select_buy_item
	jsr bankswitch
	jsr do_select_buy_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC clear_last_buy_item
	lda current_bank
	pha
	lda #^do_clear_last_buy_item
	jsr bankswitch
	jsr do_clear_last_buy_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_render_buy_screen
	; Draw box around buy screen
	lda #1
	sta arg0
	lda #32 + 1
	sta arg1
	lda #28
	sta arg2
	lda #32 + 22
	sta arg3
	jsr draw_large_box

	LOAD_PTR buy_str
	ldx #4
	ldy #32 + 1
	jsr write_string

	; Set palette for title
	lda #1
	sta arg0
	lda #16 + 0
	sta arg1
	lda #5
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
	jsr render_buy_items

itemend:
	jsr render_inventory_status_bar

	; Draw help text
	LOAD_PTR buy_help_str
	ldx #3
	ldy #32 + 23
	jsr write_string

	jsr select_buy_item

	LOAD_PTR inventory_palette
	jsr fade_in

	rts
.endproc

PROC do_render_buy_items
	lda #0
	sta arg0
itemloop:
	lda arg0
	cmp valid_shop_count
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
	tay
	lda valid_shop_list, y
	tay
	lda purchase_items, y
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
	tax
	lda valid_shop_index, x
	cmp #$ff
	bne nonzerocount
	lda #0
	jmp getcountstr & $ffff
nonzerocount:
	asl
	tax
	lda inventory, x
getcountstr:
	jsr byte_to_padded_str

	; Get the item type
	lda arg0
	tax
	lda valid_shop_list, x
	tax
	lda purchase_items, x
	jsr get_item_type
	sta arg2
	cmp #ITEM_TYPE_GUN
	bne notgun
	lda #' '
	sta scratch
	sta scratch + 1
	lda #'1'
	sta scratch + 2
notgun:

	lda #$40
	sta scratch + 3
	lda #0
	sta scratch + 4

	; Draw item count
	LOAD_PTR scratch
	ldx #7
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 3
	tay
	jsr write_string

	; Draw item name
	lda arg0
	tax
	lda valid_shop_list, x
	tax
	lda purchase_items, x
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
	jsr wait_for_vblank_if_rendering

	; Draw item price
	lda arg0
	tax
	lda valid_shop_list, x
	tax
	lda purchase_price_high, x
	beq twodigit

	clc
	adc #$30
	sta scratch + 1
	lda purchase_price_mid, x
	adc #$30
	sta scratch + 2
	lda purchase_price_low, x
	adc #$30
	sta scratch + 3
	lda #'$'
	sta scratch
	lda #0
	sta scratch + 4

	jmp renderprice & $ffff

twodigit:
	lda purchase_price_mid, x
	beq onedigit

	clc
	adc #$30
	sta scratch + 2
	lda purchase_price_low, x
	adc #$30
	sta scratch + 3
	lda #' '
	sta scratch
	lda #'$'
	sta scratch + 1
	lda #0
	sta scratch + 4

	jmp renderprice & $ffff

onedigit:
	lda purchase_price_low, x
	clc
	adc #$30
	sta scratch + 3
	lda #' '
	sta scratch
	sta scratch + 1
	lda #'$'
	sta scratch + 2
	lda #0
	sta scratch + 4

renderprice:
	LOAD_PTR scratch
	ldx #23
	ldy arg1
	iny
	jsr write_string

	jsr prepare_for_rendering

nextitem:
	ldx arg0
	inx
	stx arg0
	jmp itemloop & $ffff

itemend:
	rts
.endproc


PROC do_select_buy_item
	lda selection
	and #1
	beq even

	lda selection
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 3
	sta temp

	lda #3
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
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 1
	sta temp

	lda #3
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
	lsr
	sta temp
	asl
	clc
	adc temp
	adc #16 + 2
	sta temp

	lda #3
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
	tax
	lda valid_shop_list, x
	tax
	lda purchase_items, x
	jsr get_item_description
	ldx #2
	ldy #32 + 21
	jsr write_string

	jsr prepare_for_rendering

	lda selection
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


PROC do_clear_last_buy_item
	jsr wait_for_vblank_if_rendering

	lda valid_shop_count
	beq noitems
	LOAD_PTR clear_item_tiles
	jmp renderbox & $ffff
noitems:
	LOAD_PTR clear_last_item_tiles

renderbox:
	ldx #2
	lda valid_shop_count
	asl
	clc
	adc valid_shop_count
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
	lda valid_shop_count
	asl
	clc
	adc valid_shop_count
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


.data

VAR buy_str
	.byte "BUYBACK", $3c, $3c, $3b, " BUY ", $3d, $3c, $3c, "SELL", 0

VAR buy_help_str
	.byte "A:BUY  B:REPEAT  ", $23, "/", $25, ":TAB", 0


.segment "TEMP"

VAR valid_shop_list
	.byte 0, 0, 0, 0, 0, 0

VAR valid_shop_index
	.byte 0, 0, 0, 0, 0, 0

VAR valid_shop_count
	.byte 0

VAR purchase_items
	.byte 0, 0, 0, 0, 0, 0
VAR purchase_price_high
	.byte 0, 0, 0, 0, 0, 0
VAR purchase_price_mid
	.byte 0, 0, 0, 0, 0, 0
VAR purchase_price_low
	.byte 0, 0, 0, 0, 0, 0

VAR purchase_item_count
	.byte 0
