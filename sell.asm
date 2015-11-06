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

PROC show_sell_tab
	jsr clear_alt_screen
	LOAD_ALL_TILES $000, inventory_ui_tiles

	; Determine which sell items are available
	lda #0
	sta arg0
	sta valid_shop_count

checkloop:
	ldx arg0
	lda sell_items, x
	jsr find_item
	ldx valid_shop_count
	sta valid_shop_index, x
	cmp #$ff
	beq nextitem

hasitem:
	lda arg0
	ldx valid_shop_count
	sta valid_shop_list, x
	inc valid_shop_count

nextitem:
	ldx arg0
	inx
	stx arg0
	cpx sell_item_count
	bne checkloop

	lda #0
	sta selection
	lda #0
	sta scroll
	jsr render_sell_screen

	lda valid_shop_count
	beq nosetupselect
	jsr select_sell_item
nosetupselect:

	lda #30
	sta repeat_time

	lda valid_shop_count
	bne selectloop
	jmp emptyloop
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
	bne sellpressed
	lda controller
	and #JOY_LEFT
	bne buy
	lda controller
	and #JOY_RIGHT
	bne buyback
	lda controller
	and #JOY_SELECT | JOY_START
	beq nobutton
	jmp done

buy:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_buy_tab

buyback:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_buyback_tab

nobutton:
	lda #30
	sta repeat_time
	jmp selectloop

downpressed:
	jmp down

sellpressed:
	jmp sell

up:
	lda selection
	beq attop

	PLAY_SOUND_EFFECT effect_uimove

	jsr deselect_inventory_item
	dec selection
	jsr select_sell_item
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
	jsr select_sell_item
atbottom:
	jmp waitfordepress

sell:
	jsr sell_current_item
	cmp #0
	beq waitfordepresslong

	jsr wait_for_vblank
	jsr generate_gold_string
	LOAD_PTR gold_str
	ldx #24
	ldy #32 + 26
	jsr write_string
	jsr prepare_for_rendering

	PLAY_SOUND_EFFECT effect_sell

	lda controller
	and #JOY_B
	beq waitfordepresslong

	ldx #8
	jsr wait_for_frame_count
	jmp selectloop

shortwaitfordepress:
	lda repeat_time
	cmp #30
	bne nowait
	ldx #6
	jsr wait_for_frame_count
	lda #3
	sta repeat_time
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

emptyloop:
	jsr update_controller
	jsr wait_for_vblank
	lda controller
	and #JOY_LEFT
	bne emptybuy
	lda controller
	and #JOY_RIGHT
	bne emptybuyback
	lda controller
	and #JOY_SELECT | JOY_START
	beq emptyloop
	jmp done

emptybuy:
	jmp buy
emptybuyback:
	jmp buyback

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


PROC sell_current_item
	; Get item to be sold
	ldx selection
	lda valid_shop_list, x
	sta arg2
	tax

	lda sell_items, x
	jsr get_item_type
	cmp #ITEM_TYPE_GUN
	beq sellgun

	; Check for item
	ldx arg2
	lda sell_items, x
	jsr find_item
	cmp #$ff
	beq invalidsell
	asl
	tay
	lda inventory, y
	bne validsell

invalidsell:
	lda #0
	rts

validsell:
	; Take away item
	sec
	sbc #1
	sta inventory, y
	bne notempty
	jmp deleteitem

sellgun:
	; Selling a gun will remove the item no matter what the ammo count is
	ldx arg2
	lda sell_items, x
	jsr find_item
	cmp #$ff
	beq invalidsell
	asl
	tay

	; Out of the item, remove it from inventory
deleteitem:
	tya
	lsr
	sta arg3
deleteloop:
	lda arg3
	clc
	adc #1
	cmp inventory_count
	beq deletedone

	lda arg3
	asl
	tax
	lda inventory + 2, x
	sta inventory, x
	lda inventory + 3, x
	sta inventory + 1, x

	inc arg3
	jmp deleteloop

deletedone:
	dec inventory_count

notempty:
	; Give gold for item
	ldx arg2
	lda sell_price_low, x
	clc
	adc gold + 3
	cmp #10
	bcc nocarry3
	adc #$f5
nocarry3:
	sta gold + 3
	lda sell_price_mid, x
	adc gold + 2
	cmp #10
	bcc nocarry2
	adc #$f5
nocarry2:
	sta gold + 2
	lda sell_price_high, x
	adc gold + 1
	cmp #10
	bcc nocarry1
	adc #$f5
nocarry1:
	sta gold + 1
	lda gold
	adc #0
	sta gold
	cmp #10
	bcc notmax
	lda #9
	sta gold
	sta gold + 1
	sta gold + 2
	sta gold + 3
notmax:

	ldx arg2
	jsr add_buyback_item

	; Refresh item indexes as they may have changed
	lda #0
	sta arg2
refreshloop:
	ldx arg2
	lda valid_shop_list, x
	tax
	lda sell_items, x
	jsr find_item
	ldx arg2
	sta valid_shop_index, x
	ldx arg2
	inx
	stx arg2
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
	sta arg2
	asl
	clc
	adc arg2
	adc #32 + 3
	tay
	jsr write_string

	jsr prepare_for_rendering

	lda #1
	rts
.endproc


PROC add_buyback_item
	; Save sold item into buyback list, first move previous entries down
	ldy #5
movebuyback:
	lda buyback_items - 1, y
	sta buyback_items, y
	lda buyback_price_low - 1, y
	sta buyback_price_low, y
	lda buyback_price_mid - 1, y
	sta buyback_price_mid, y
	lda buyback_price_high - 1, y
	sta buyback_price_high, y
	dey
	bne movebuyback

	lda sell_items, x
	sta buyback_items
	lda sell_price_low, x
	sta buyback_price_low
	lda sell_price_mid, x
	sta buyback_price_mid
	lda sell_price_mid, x
	sta buyback_price_mid

	ldy buyback_count
	cpy #6
	beq maxbuyback
	iny
	sty buyback_count
maxbuyback:
	rts
.endproc


.segment "FIXED"

PROC render_sell_screen
	lda current_bank
	pha
	lda #^do_render_sell_screen
	jsr bankswitch
	jsr do_render_sell_screen & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC render_sell_items
	lda current_bank
	pha
	lda #^do_render_sell_items
	jsr bankswitch
	jsr do_render_sell_items & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC select_sell_item
	lda current_bank
	pha
	lda #^do_select_sell_item
	jsr bankswitch
	jsr do_select_sell_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_render_sell_screen
	; Draw box around sell screen
	lda #1
	sta arg0
	lda #32 + 1
	sta arg1
	lda #28
	sta arg2
	lda #32 + 22
	sta arg3
	jsr draw_large_box

	LOAD_PTR sell_str
	ldx #4
	ldy #32 + 1
	jsr write_string

	; Set palette for title
	lda #1
	sta arg0
	lda #16 + 0
	sta arg1
	lda #3
	sta arg2
	lda #16 + 0
	sta arg3
	lda #2
	sta arg4
	jsr set_box_palette

	lda #9
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

	jsr render_inventory_status_bar

	; Draw help text
	LOAD_PTR sell_help_str
	ldx #2
	ldy #32 + 23
	jsr write_string

	lda valid_shop_count
	bne hasitems

	LOAD_PTR no_items_str
	ldx #11
	ldy #32 + 11
	jsr write_string
	jmp itemend & $ffff

hasitems:
	; Draw initial items
	lda valid_shop_count
	bne notempty

	LOAD_PTR no_items_str
	ldx #11
	ldy #32 + 11
	jsr write_string
	jmp itemend & $ffff

notempty:
	jsr render_sell_items
	jsr select_sell_item

itemend:
	LOAD_PTR inventory_palette
	jsr fade_in

	rts
.endproc


PROC do_render_sell_items
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
	lda sell_items, y
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
	lda sell_items, x
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
	lda sell_items, x
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
	lda sell_price_high, x
	beq twodigit

	clc
	adc #$30
	sta scratch + 1
	lda sell_price_mid, x
	adc #$30
	sta scratch + 2
	lda sell_price_low, x
	adc #$30
	sta scratch + 3
	lda #'$'
	sta scratch
	lda #0
	sta scratch + 4

	jmp renderprice & $ffff

twodigit:
	lda sell_price_mid, x
	beq onedigit

	clc
	adc #$30
	sta scratch + 2
	lda sell_price_low, x
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
	lda sell_price_low, x
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


PROC do_select_sell_item
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
	lda sell_items, x
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


.data

VAR sell_str
	.byte "BUY", $3c, $3c, $3b, " SELL ", $3d, $3c, $3c, "BUYBACK", 0

VAR sell_help_str
	.byte "A:SELL   B:REPEAT  ", $23, "/", $25, ":TAB", 0


.segment "TEMP"

VAR sell_items
	.byte 0, 0, 0, 0, 0, 0
VAR sell_price_high
	.byte 0, 0, 0, 0, 0, 0
VAR sell_price_mid
	.byte 0, 0, 0, 0, 0, 0
VAR sell_price_low
	.byte 0, 0, 0, 0, 0, 0

VAR sell_item_count
	.byte 0
