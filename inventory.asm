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
	jsr clear_alt_screen

	LOAD_ALL_TILES $000, inventory_ui_tiles

	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_SIZE | PPUCTRL_NAMETABLE_2000
	sta ppu_settings

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

	LOAD_PTR inventory_str
	ldx #8
	ldy #32 + 1
	jsr write_string

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

	; Set palette for help text
	lda #0
	sta arg0
	lda #16 + 11
	sta arg1
	lda #14
	sta arg2
	lda #16 + 11
	sta arg3
	lda #2
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
	jmp itemend

notempty:
	lda #0
	sta arg0
itemloop:
	lda arg0
	cmp inventory_count
	bne hasitem
	jmp itemend

hasitem:
	lda arg0
	beq first
	LOAD_PTR inventory_item_second_box_tiles
	jmp drawitem
first:
	LOAD_PTR inventory_item_first_box_tiles

drawitem:
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

	; Get string with item count
	lda arg0
	asl
	tax
	lda inventory, x
	jsr byte_to_padded_str

	; Get the item type
	lda arg0
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
	jmp drawname

ammocount:
	; Draw ammo count
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
	lda #3
	jmp drawtype
weapon:
	LOAD_PTR inventory_weapon_tiles
	lda #4
	jmp drawtype
crafting:
	LOAD_PTR inventory_crafting_tiles
	lda #6
	jmp drawtype
wearable:
	LOAD_PTR inventory_wearable_tiles
	lda #6
	jmp drawtype
healing:
	LOAD_PTR inventory_healing_tiles
	lda #5
	jmp drawtype
usable:
	LOAD_PTR inventory_usable_tiles
	lda #4

drawtype:
	ldx #12
	ldy arg1
	iny
	jsr write_tiles

nextitem:
	ldx arg0
	inx
	stx arg0
	cpx #6
	beq itemend
	jmp itemloop

itemend:
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

	; Render health bar according to player health
	LOAD_PTR full_health_tiles
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

	LOAD_PTR partial_health_tile
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

emptyloop:
	jsr wait_for_vblank
	jsr update_controller
	lda controller
	and #JOY_SELECT
	beq emptyloop

done:
	jsr fade_out

	lda saved_ppu_settings
	sta ppu_settings

	jsr back_to_game_from_alternate_screen

	LOAD_PTR saved_palette
	jsr fade_in

	rts
.endproc


PROC select_inventory_item
	lda #3
	sta arg0
	lda #16 + 1
	sta arg1
	lda #13
	sta arg2
	lda #16 + 2
	sta arg3
	lda #3
	sta arg4
	jsr set_box_palette

	lda #24
	sta sprites
	lda #$5c
	sta sprites + 1
	lda #0
	sta sprites + 2
	lda #58
	sta sprites + 3

	lda #37
	sta sprites + 4
	lda #$5c
	sta sprites + 5
	lda #SPRITE_FLIP_VERT
	sta sprites + 6
	lda #58
	sta sprites + 7

	lda #24
	sta sprites + 8
	lda #$5c
	sta sprites + 9
	lda #SPRITE_FLIP_HORIZ
	sta sprites + 10
	lda #222
	sta sprites + 11

	lda #37
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

VAR inventory_str
	.byte $3b, " INVENTORY ", $3d, 0

VAR craft_str
	.byte " CRAFT ", 0

VAR salvage_str
	.byte " SALVAGE ", 0

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

VAR inventory_weapon_tiles
	.byte $60, $61, $62, $63
VAR inventory_crafting_tiles
	.byte $64, $65, $66, $67, $68, $69
VAR inventory_healing_tiles
	.byte $73, $74, $75, $76, $77
VAR inventory_wearable_tiles
	.byte $60, $61, $6e, $6f, $78, $79
VAR inventory_usable_tiles
	.byte $6a, $6b, $6c, $6d
VAR inventory_sell_tiles
	.byte $7a, $5e, $5f

VAR inventory_health_bar_top_tiles
	.byte $2a, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $2b
VAR inventory_health_bar_mid_tiles
	.byte $02, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3f
VAR inventory_health_bar_bot_tiles
	.byte $01, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $29, $2c
VAR inventory_health_bar_below_tiles
	.byte $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19

VAR two_items_top_tiles
	.byte $2a, $28, $28, $2b, $2a, $28, $28, $2b
VAR two_items_mid_tiles
	.byte $02, $00, $00, $3f, $02, $00, $00, $3f
	.byte $02, $00, $00, $3f, $02, $00, $00, $3f
VAR two_items_bot_tiles
	.byte $01, $29, $29, $2c, $01, $29, $29, $2c

VAR inventory_keys
	.byte $7b, $7c, $7d, $7e, $7f

VAR inventory_palette
	.byte $0f, $21, $31, $37
	.byte $0f, $00, $16, $30
	.byte $0f, $21, $31, $21
	.byte $0f, $21, $31, $31
	.byte $0f, $31, $31, $31
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30
	.byte $0f, $00, $10, $30


TILES inventory_ui_tiles, 2, "tiles/items/ui.chr", 123
TILES inventory_key_tiles, 2, "tiles/items/keys.chr", 5
