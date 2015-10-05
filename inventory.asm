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

	lda #PPUCTRL_ENABLE_NMI | PPUCTRL_NAMETABLE_2000
	sta ppu_settings

	; Draw box around inventory screen
	lda #1
	sta arg0
	lda #32 + 1
	sta arg1
	lda #28
	sta arg2
	lda #32 + 24
	sta arg3
	jsr draw_large_box

	; Draw initial items
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
	cpx #5
	beq itemend
	jmp itemloop

itemend:
	LOAD_PTR inventory_palette
	jsr fade_in

loop:
	jsr wait_for_vblank
	jsr update_controller
	lda controller
	and #JOY_SELECT
	beq loop

	jsr fade_out

	lda saved_ppu_settings
	sta ppu_settings

	jsr back_to_game_from_alternate_screen

	LOAD_PTR saved_palette
	jsr fade_in

	rts
.endproc


.data

VAR inventory_item_first_box_tiles
	.byte $1c, $28, $28, $1e
	.byte $2b, $00, $00, $5b
	.byte $2b, $00, $00, $5b
	.byte $1d, $29, $29, $1f

VAR inventory_item_second_box_tiles
	.byte $13, $15, $15, $14
	.byte $2b, $00, $00, $5b
	.byte $2b, $00, $00, $5b
	.byte $1d, $29, $29, $1f

VAR inventory_ammo_tiles
	.byte $10, $11, $12

VAR inventory_weapon_tiles
	.byte $01, $02, $03, $04
VAR inventory_crafting_tiles
	.byte $05, $06, $07, $08, $09, $0a
VAR inventory_healing_tiles
	.byte $0b, $0c, $0d, $0e, $0f
VAR inventory_wearable_tiles
	.byte $01, $02, $21, $22, $2c, $2d
VAR inventory_usable_tiles
	.byte $2e, $2f, $3f, $2a
VAR inventory_sell_tiles
	.byte $5c, $5d, $5e

VAR inventory_palette
	.byte $0f, $21, $31, $37
	.byte $0f, $26, $37, $30
	.byte $0f, $21, $31, $26
	.byte $0f, $21, $31, $31
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30
	.byte $0f, $21, $31, $30


TILES inventory_ui_tiles, 2, "tiles/items/ui.chr", 102
