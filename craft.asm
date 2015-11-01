.include "defines.inc"

.code

PROC show_crafting_tab
	jsr clear_alt_screen
	LOAD_ALL_TILES $000, crafting_ui_tiles

	; Determine which craftable items are possible to craft (ammo for guns that
	; the player does not have should not be included)
	lda #0
	sta arg0
	sta valid_crafting_count

checkloop:
	ldx arg0
	lda craftable_items, x
	jsr find_item
	ldx valid_crafting_count
	sta valid_crafting_index, x
	cmp #$ff
	bne hasitem

	ldx arg0
	lda craftable_items, x
	jsr get_item_type
	cmp #ITEM_TYPE_GUN
	bne hasitem

	; Item is a gun that is not owned by the player, do not include in list
	jmp nextitem

hasitem:
	lda arg0
	ldx valid_crafting_count
	sta valid_crafting_list, x
	inc valid_crafting_count

nextitem:
	ldx arg0
	inx
	stx arg0
	cpx #12
	bne checkloop

	lda #0
	sta selection
	lda #0
	sta scroll
	jsr render_crafting_screen
	jsr select_crafting_item

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
	bne craftpressed
	lda controller
	and #JOY_LEFT
	bne inventory
	lda controller
	and #JOY_RIGHT
	bne salvage
	lda controller
	and #JOY_SELECT | JOY_START
	beq nobutton
	jmp done

inventory:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_inventory_tab

salvage:
	PLAY_SOUND_EFFECT effect_uimove
	jsr fade_out
	jmp show_salvage_tab

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

	jsr render_crafting_items
	dec selection
	jsr select_crafting_item
	jmp shortwaitfordepress

noupscroll:
	dec selection
	jsr select_crafting_item
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

	jsr render_crafting_items
	inc selection
	jsr select_crafting_item
	jmp shortwaitfordepress

nodownscroll:
	inc selection
	jsr select_crafting_item
atbottom:
	jmp waitfordepress

craft:
	jsr craft_current_item
	cmp #0
	beq waitfordepresslong

	PLAY_SOUND_EFFECT effect_craft

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


PROC craft_current_item
	; Get item to be crafted
	ldx selection
	lda valid_crafting_list, x
	sta arg0
	tax

	; Check for max count of item
	lda craftable_items, x
	jsr find_item
	cmp #$ff
	beq notmax
	asl
	tax
	lda inventory, x
	cmp #$ff
	bne notmax

	jmp invalidcraft

notmax:
	; Check for enough components
	ldx arg0
	lda craftable_component_count_1, x
	sta arg1
	lda craftable_component_1, x
	jsr find_item
	cmp #$ff
	beq invalidcraft
	asl
	tax
	lda inventory, x
	cmp arg1
	bcc invalidcraft

	ldx arg0
	lda craftable_component_count_2, x
	sta arg1
	lda craftable_component_2, x
	cmp #ITEM_NONE
	beq validcraft
	jsr find_item
	cmp #$ff
	beq invalidcraft
	asl
	tax
	lda inventory, x
	cmp arg1
	bcc invalidcraft

	jmp validcraft

invalidcraft:
	lda #0
	rts

validcraft:
	; Take away first component
	ldx arg0
	lda craftable_component_1, x
	jsr find_item
	asl
	tay
	ldx arg0
	lda inventory, y
	sec
	sbc craftable_component_count_1, x
	sta inventory, y
	bne firstnotempty

	; Out of the first component, remove it from inventory
	tya
	lsr
	sta arg1
deletefirstloop:
	lda arg1
	clc
	adc #1
	cmp inventory_count
	beq firstdeletedone

	lda arg1
	asl
	tax
	lda inventory + 2, x
	sta inventory, x
	lda inventory + 3, x
	sta inventory + 1, x

	inc arg1
	jmp deletefirstloop

firstdeletedone:
	dec inventory_count

firstnotempty:
	; Take away second component
	ldx arg0
	lda craftable_component_2, x
	cmp #ITEM_NONE
	beq secondnotempty
	jsr find_item
	asl
	tay
	ldx arg0
	lda inventory, y
	sec
	sbc craftable_component_count_2, x
	sta inventory, y
	bne secondnotempty

	; Out of the second component, remove it from inventory
	tya
	lsr
	sta arg1
deletesecondloop:
	lda arg1
	clc
	adc #1
	cmp inventory_count
	beq seconddeletedone

	lda arg1
	asl
	tax
	lda inventory + 2, x
	sta inventory, x
	lda inventory + 3, x
	sta inventory + 1, x

	inc arg1
	jmp deletesecondloop

seconddeletedone:
	dec inventory_count

secondnotempty:
	; Create crafted item
	ldx arg0
	lda craftable_items, x
	jsr give_item

	; Refresh item indexes as they may have changed
	lda #0
	sta arg0
refreshloop:
	ldx arg0
	lda valid_crafting_list, x
	tax
	lda craftable_items, x
	jsr find_item
	ldx arg0
	sta valid_crafting_index, x
	ldx arg0
	inx
	stx arg0
	cpx valid_crafting_count
	bne refreshloop

	; Refresh UI
	jsr select_crafting_item

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
	sta arg0
	asl
	clc
	adc arg0
	adc #32 + 4
	tay
	jsr write_string

	jsr prepare_for_rendering

	lda #1
	rts
.endproc


.segment "FIXED"

PROC render_crafting_screen
	lda current_bank
	pha
	lda #^do_render_crafting_screen
	jsr bankswitch
	jsr do_render_crafting_screen & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC render_crafting_items
	lda current_bank
	pha
	lda #^do_render_crafting_items
	jsr bankswitch
	jsr do_render_crafting_items & $ffff
	pla
	jsr bankswitch
	rts
.endproc

PROC select_crafting_item
	lda current_bank
	pha
	lda #^do_select_crafting_item
	jsr bankswitch
	jsr do_select_crafting_item & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "UI"

PROC do_render_crafting_screen
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

	LOAD_PTR crafting_str
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
	LOAD_PTR crafting_help_str
	ldx #2
	ldy #32 + 23
	jsr write_string

	; Draw requirements text
	LOAD_PTR requirements_tiles
	ldx #2
	ldy #32 + 19
	lda #6
	jsr write_tiles

	LOAD_PTR crafting_have_tiles
	ldx #25
	ldy #32 + 19
	lda #3
	jsr write_tiles

	; Draw initial items
	jsr render_crafting_items
	jsr select_crafting_item

	LOAD_PTR inventory_palette
	jsr fade_in

	rts
.endproc


PROC do_render_crafting_items
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
	lda craftable_items, y
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
	lda craftable_items, x
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
	lda craftable_items, x
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
	beq weapon
	cmp #ITEM_TYPE_OUTFIT
	beq wearable
	cmp #ITEM_TYPE_HEALTH
	beq healing

	LOAD_PTR inventory_usable_tiles
	jmp drawtype & $ffff
ammo:
	LOAD_PTR crafting_ammo_tiles
	jmp drawtype & $ffff
weapon:
	LOAD_PTR inventory_weapon_tiles
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


PROC do_select_crafting_item
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
	sec
	sbc scroll
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
	sec
	sbc scroll
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
	lda valid_crafting_list, x
	tax
	lda craftable_items, x
	sta temp
	jsr get_item_type
	cmp #ITEM_TYPE_GUN
	beq ammo

	lda temp
	jsr get_item_description
	jmp drawdesc & $ffff

ammo:
	LOAD_PTR ammo_desc_str

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
	lda craftable_component_1, x
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
	lda craftable_component_2, x
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

	; Render text for requirements
	ldx arg0
	lda craftable_component_count_1, x
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
	lda craftable_component_1, x
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
	lda craftable_component_count_2, x
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
	lda craftable_component_2, x
	jsr get_item_name
	ldx #7
	ldy #32 + 21
	jsr write_string

	lda rendering_enabled
	beq rendersprites

	lda arg1
	cmp arg3
	bcc notenough
	lda arg2
	cmp arg4
	bcc notenough

	LOAD_PTR valid_craft_palette
	lda #3
	jsr load_single_palette
	jmp rendersprites & $ffff

notenough:
	LOAD_PTR invalid_craft_palette
	lda #3
	jsr load_single_palette

rendersprites:
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

VAR crafting_str
	.byte "ITEMS", $3c, $3b, " CRAFT ", $3d, $3c, "SALVAGE", 0

VAR crafting_help_str
	.byte "A:CRAFT  B:REPEAT  ", $23, "/", $25, ":TAB", 0

VAR craftable_items
	.byte ITEM_PISTOL, ITEM_SMG, ITEM_LMG, ITEM_AK, ITEM_SHOTGUN, ITEM_SNIPER
	.byte ITEM_HAND_CANNON, ITEM_ROCKET, ITEM_GRENADE, ITEM_BANDAGE
	.byte ITEM_CAMPFIRE, ITEM_ARMOR

VAR craftable_component_1
	.byte ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER
	.byte ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_GUNPOWDER, ITEM_CLOTH
	.byte ITEM_STICKS, ITEM_METAL

VAR craftable_component_count_1
	.byte 1, 1, 2, 2, 3, 4
	.byte 3, 6, 5, 4
	.byte 20, 150

VAR craftable_component_2
	.byte ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_METAL
	.byte ITEM_METAL, ITEM_METAL, ITEM_METAL, ITEM_NONE
	.byte ITEM_FUEL, ITEM_CLOTH

VAR craftable_component_count_2
	.byte 1, 1, 2, 1, 2, 3
	.byte 4, 4, 4, 0
	.byte 1, 20

VAR crafting_have_tiles
	.byte $7a, $5e, $5f

VAR crafting_ammo_tiles
	.byte $70, $71, $72, $00, $00, $00

VAR requirements_tiles
	.byte $64, $65, $66, $67, $68, $69

VAR ammo_desc_str
	.byte "CRAFT MORE AMMUNITION     ", 0

VAR erase_required_count_str
	.byte "    ", 0

VAR erase_have_count_str
	.byte "   ", 0

VAR valid_craft_palette
	.byte $0f, $21, $31, $3a

VAR invalid_craft_palette
	.byte $0f, $21, $31, $26


.segment "TEMP"

VAR valid_crafting_list
	.byte 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0

VAR valid_crafting_index
	.byte 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0
	.byte 0, 0, 0, 0

VAR valid_crafting_count
	.byte 0

TILES crafting_ui_tiles, 3, "tiles/items/craft.chr", 123
