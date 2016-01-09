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

PROC show_salvage_tab
	jsr clear_alt_screen
	LOAD_ALL_TILES $000, salvage_ui_tiles

	; Determine which salvagable items are available
	lda #0
	sta arg0
	sta valid_crafting_count

checkloop:
	ldx arg0
	lda salvage_items, x
	jsr find_item
	ldx valid_crafting_count
	sta valid_crafting_index, x
	cmp #$ff
	beq nextitem

hasitem:
	lda arg0
	ldx valid_crafting_count
	sta valid_crafting_list, x
	inc valid_crafting_count

nextitem:
	ldx arg0
	inx
	stx arg0
	cpx #14
	bne checkloop

	lda #0
	sta selection
	lda #0
	sta scroll
	jsr render_salvage_screen

	lda valid_crafting_count
	beq nosetupselect
	jsr select_salvage_item
nosetupselect:

	lda #30
	sta repeat_time

	lda valid_crafting_count
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
	and #JOY_A | JOY_B
	bne craftpressed
	lda controller
	and #JOY_LEFT
	bne crafting
	lda controller
	and #JOY_RIGHT
	bne inventory
	lda controller
	and #JOY_SELECT
	beq nobutton
	jmp done

crafting:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_crafting_tab

inventory:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_inventory_tab

nobutton:
	lda #30
	sta repeat_time
	jmp selectloop

downpressed:
	jmp down

craftpressed:
	jmp craft

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

	jsr render_salvage_items
	dec selection
	jsr select_salvage_item
	jmp shortwaitfordepress

noupscroll:
	dec selection
	jsr select_salvage_item
attop:
	jmp waitfordepress

down:
	lda selection
	clc
	adc #1
	cmp valid_crafting_count
	beq atbottom

	PLAY_SOUND_EFFECT effect_uimove

	jsr deselect_inventory_item

	lda selection
	sec
	sbc scroll
	cmp #3
	bcc nodownscroll

	lda scroll
	clc
	adc #5
	cmp valid_crafting_count
	bcs nodownscroll

	inc scroll

	jsr render_salvage_items
	inc selection
	jsr select_salvage_item
	jmp shortwaitfordepress

nodownscroll:
	inc selection
	jsr select_salvage_item
atbottom:
	jmp waitfordepress

craft:
	jsr salvage_current_item
	cmp #0
	beq waitfordepresslong

	PLAY_SOUND_EFFECT_NO_OVERRIDE effect_craft

	lda controller
	and #JOY_B
	beq waitfordepresslong
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
	bne emptycrafting
	lda controller
	and #JOY_RIGHT
	bne emptyinventory
	lda controller
	and #JOY_SELECT | JOY_START
	beq emptyloop
	jmp done

emptycrafting:
	jmp crafting
emptyinventory:
	jmp inventory

done:
	jmp end_inventory_screen
.endproc


.segment "FIXED"

PROC salvage_current_item
	lda current_bank
	pha
	lda #^do_salvage_current_item
	jsr bankswitch
	jsr do_salvage_current_item & $ffff
	sta arg0
	pla
	jsr bankswitch
	lda arg0
	rts
.endproc


.segment "UI"

PROC do_salvage_current_item
	; Get item to be salvaged
	ldx selection
	lda valid_crafting_list, x
	sta arg2
	tax

	; Check for item
	lda salvage_items, x
	jsr find_item
	cmp #$ff
	beq invalidcraft
	asl
	tay
	lda inventory, y
	bne validcraft

invalidcraft:
	lda #0
	rts

validcraft:
	; Take away item
	sec
	sbc #1
	sta inventory, y
	bne notempty

	; Out of the item, remove it from inventory
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
	jmp deleteloop & $ffff

deletedone:
	dec inventory_count

notempty:
	; Give components
	ldy arg2
	lda salvage_component_count_1, y
	tax
	lda salvage_component_1, y
	jsr give_item_with_count

	ldy arg2
	lda salvage_component_count_2, y
	tax
	lda salvage_component_2, y
	cmp #ITEM_NONE
	beq noseconditem
	jsr give_item_with_count

noseconditem:
	; Refresh item indexes as they may have changed
	lda #0
	sta arg2
refreshloop:
	ldx arg2
	lda valid_crafting_list, x
	tax
	lda salvage_items, x
	jsr find_item
	ldx arg2
	sta valid_crafting_index, x
	ldx arg2
	inx
	stx arg2
	cpx valid_crafting_count
	bne refreshloop

	; Refresh UI
	jsr select_salvage_item

	; Get string with item count
	lda selection
	tax
	lda valid_crafting_index, x
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
	sec
	sbc scroll
	sta arg2
	asl
	clc
	adc arg2
	adc #32 + 4
	tay
	jsr write_string

	jsr prepare_for_rendering

	lda #1
	rts
.endproc


.segment "FIXED"

PROC render_salvage_screen
	lda current_bank
	pha
	lda #^do_render_salvage_screen
	jsr bankswitch
	jsr do_render_salvage_screen & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC render_salvage_items
	lda current_bank
	pha
	lda #^do_render_salvage_items
	jsr bankswitch
	jsr do_render_salvage_items & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC select_salvage_item
	lda current_bank
	pha
	lda #^do_select_salvage_item
	jsr bankswitch
	jsr do_select_salvage_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_render_salvage_screen
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

	LOAD_PTR salvage_str
	ldx #4
	ldy #32 + 1
	jsr write_string

	; Set palette for title
	lda #2
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

	lda #11
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
	lda #16 + 9
	sta arg3
	lda #1
	sta arg4
	jsr set_box_palette

	; Set palette for components
	lda #1
	sta arg0
	lda #16 + 10
	sta arg1
	lda #13
	sta arg2
	lda #16 + 10
	sta arg3
	lda #3
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
	LOAD_PTR salvage_help_str
	ldx #1
	ldy #32 + 23
	jsr write_string

	lda valid_crafting_count
	bne hasitems

	LOAD_PTR no_items_str
	ldx #11
	ldy #32 + 11
	jsr write_string
	jmp itemend & $ffff

hasitems:
	; Draw initial items
	jsr render_salvage_items
	jsr select_salvage_item

	; Draw yield text
	LOAD_PTR yield_tiles
	ldx #2
	ldy #32 + 19
	lda #4
	jsr write_tiles

	LOAD_PTR crafting_have_tiles
	ldx #25
	ldy #32 + 19
	lda #3
	jsr write_tiles

itemend:
	LOAD_PTR salvage_palette
	jsr fade_in

	rts
.endproc


PROC do_render_salvage_items
	lda #0
	sta arg0
itemloop:
	lda arg0
	clc
	adc scroll
	cmp valid_crafting_count
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
	tay
	lda valid_crafting_list, y
	tay
	lda salvage_items, y
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
	tax
	lda valid_crafting_index, x
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
	clc
	adc scroll
	tax
	lda valid_crafting_list, x
	tax
	lda salvage_items, x
	jsr get_item_type
	sta arg2

	; Draw item count
	LOAD_PTR scratch
	ldx #7
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 4
	tay
	jsr write_string

	LOAD_PTR crafting_have_tiles
	ldx #7
	lda arg0
	asl
	clc
	adc arg0
	adc #32 + 3
	tay
	lda #3
	jsr write_tiles

	; Draw item name
	lda arg0
	clc
	adc scroll
	tax
	lda valid_crafting_list, x
	tax
	lda salvage_items, x
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
	beq ammo
	cmp #ITEM_TYPE_GRENADE
	beq ammo
	cmp #ITEM_TYPE_CRAFTING
	beq crafting
	cmp #ITEM_TYPE_OUTFIT
	beq wearable
	cmp #ITEM_TYPE_HEALTH
	beq healing

	LOAD_PTR inventory_usable_tiles
	jmp drawtype & $ffff
ammo:
	LOAD_PTR crafting_ammo_tiles
	jmp drawtype & $ffff
crafting:
	LOAD_PTR inventory_crafting_tiles
	jmp drawtype & $ffff
wearable:
	LOAD_PTR inventory_wearable_tiles
	jmp drawtype & $ffff
healing:
	LOAD_PTR inventory_healing_tiles

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
	cpx #5
	beq itemend
	jmp itemloop & $ffff

itemend:
	rts
.endproc


PROC do_select_salvage_item
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
	tax
	lda valid_crafting_list, x
	tax
	lda salvage_items, x
	sta temp
	jsr get_item_type
	cmp #ITEM_TYPE_GUN
	beq ammo

	lda temp
	jsr get_item_description
	jmp drawdesc & $ffff

ammo:
	LOAD_PTR salvage_ammo_desc_str

drawdesc:
	ldx #2
	ldy #32 + 18
	jsr write_string

	jsr prepare_for_rendering

	; Get index into crafting table
	ldx selection
	lda valid_crafting_list, x
	tax
	stx arg0

	; Get counts in inventory of each component
	lda salvage_component_1, x
	jsr find_item
	cmp #$ff
	beq havefirstzero
	asl
	tax
	lda inventory, x
	sta arg1
	jmp checksecond & $ffff
havefirstzero:
	lda #0
	sta arg1

checksecond:
	ldx arg0
	lda salvage_component_2, x
	cmp #ITEM_NONE
	beq havesecondzero
	jsr find_item
	cmp #$ff
	beq havesecondzero
	asl
	tax
	lda inventory, x
	sta arg2
	jmp renderrequirements & $ffff
havesecondzero:
	lda #0
	sta arg2

renderrequirements:
	jsr wait_for_vblank

	; Render text for yield
	ldx arg0
	lda salvage_component_count_1, x
	sta arg3
	jsr byte_to_padded_str
	lda #$40
	sta scratch + 3
	lda #0
	sta scratch + 4
	LOAD_PTR scratch
	ldx #2
	ldy #32 + 20
	jsr write_string

	ldx arg0
	lda salvage_component_1, x
	jsr get_item_name
	ldx #7
	ldy #32 + 20
	jsr write_string

	lda arg1
	jsr byte_to_padded_str
	LOAD_PTR scratch
	ldx #25
	ldy #32 + 20
	jsr write_string

	jsr prepare_for_rendering
	jsr wait_for_vblank

	ldx arg0
	lda salvage_component_count_2, x
	sta arg4
	bne hassecondcomponent

	LOAD_PTR erase_required_count_str
	ldx #2
	ldy #32 + 21
	jsr write_string

	LOAD_PTR erase_have_count_str
	ldx #25
	ldy #32 + 21
	jsr write_string

	jmp drawsecondname & $ffff

hassecondcomponent:
	jsr byte_to_padded_str
	lda #$40
	sta scratch + 3
	lda #0
	sta scratch + 4
	LOAD_PTR scratch
	ldx #2
	ldy #32 + 21
	jsr write_string

	lda arg2
	jsr byte_to_padded_str
	LOAD_PTR scratch
	ldx #25
	ldy #32 + 21
	jsr write_string

drawsecondname:
	ldx arg0
	lda salvage_component_2, x
	jsr get_item_name
	ldx #7
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


.data

VAR salvage_str
	.byte "CRAFT", $3c, $3b, " SALVAGE ", $3d, $3c, "ITEMS", 0

VAR salvage_help_str
	.byte "A:SALVAGE  B:REPEAT  ", $23, "/", $25, ":TAB", 0

VAR salvage_items
	.byte ITEM_PISTOL, ITEM_SMG, ITEM_LMG, ITEM_AK, ITEM_SHOTGUN, ITEM_SNIPER
	.byte ITEM_HAND_CANNON, ITEM_ROCKET, ITEM_GRENADE, ITEM_BANDAGE
	.byte ITEM_SHIRT, ITEM_PANTS, ITEM_CAMPFIRE, ITEM_ARMOR

VAR salvage_component_1
	.byte ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER
	.byte ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_CLOTH
	.byte ITEM_CLOTH, ITEM_CLOTH, ITEM_STICKS, ITEM_METAL

VAR salvage_component_count_1
	.byte 1, 1, 1, 1, 2, 3
	.byte 2, 5, 4, 3
	.byte 5, 5, 15, 100

VAR salvage_component_2
	.byte ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_METAL
	.byte ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_NONE
	.byte ITEM_NONE, ITEM_NONE, ITEM_NONE, ITEM_CLOTH

VAR salvage_component_count_2
	.byte 1, 1, 1, 1, 1, 2
	.byte 3, 3, 3, 0
	.byte 0, 0, 0, 15

VAR yield_tiles
	.byte $62, $63, $03, $58

VAR salvage_ammo_desc_str
	.byte "BREAK AMMO INTO COMPONENTS", 0

VAR salvage_palette
	.byte $0f, $21, $31, $21
	.byte $0f, $00, $16, $30
	.byte $0f, $21, $31, $00
	.byte $0f, $21, $31, $31
	.byte $0f, $21, $21, $21
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30


TILES salvage_ui_tiles, 3, "tiles/items/salvage.chr", 123
