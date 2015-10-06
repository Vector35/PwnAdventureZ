.include "defines.inc"

.define RIGHT_PANEL_TILES $66
.define LOCATION_TILES    $04
.define DYNAMIC_TILES     $70

.code

PROC load_area_name_tiles
	; Load tiles for name of area
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_CAVE_START
	beq startcavelocation
	cmp #MAP_STARTING_CAVE
	beq startcavelocation
	cmp #MAP_START_FOREST
	beq startforestlocation
	cmp #MAP_CAVE_INTERIOR
	beq maincavelocation
	cmp #MAP_LOST_CAVE
	beq lostcavelocation
	cmp #MAP_MINE_ENTRANCE
	beq minelocation
	cmp #MAP_MINE_DOWN
	beq minelocation
	cmp #MAP_HOUSE
	beq townlocation
	cmp #MAP_SHOP
	beq townlocation
	cmp #MAP_PARK
	beq townlocation
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
	cmp #MAP_UNBEARABLE
	beq unbearable

	LOAD_ALL_TILES LOCATION_TILES, forest_name_tiles
	jmp namedone

startcavelocation:
	jmp startcave
startforestlocation:
	jmp startforest
maincavelocation:
	jmp maincave
lostcavelocation:
	jmp lostcave
minelocation:
	jmp mine
baselocation:
	jmp base
blockylocation:
	jmp blocky
townlocation:
	jmp town

deadwood:
	LOAD_ALL_TILES LOCATION_TILES, dead_wood_name_tiles
	jmp namedone

unbearable:
	LOAD_ALL_TILES LOCATION_TILES, unbearable_name_tiles
	jmp namedone

startcave:
	LOAD_ALL_TILES LOCATION_TILES, starting_cave_name_tiles
	jmp namedone

startforest:
	LOAD_ALL_TILES LOCATION_TILES, starting_forest_name_tiles
	jmp namedone

maincave:
	LOAD_ALL_TILES LOCATION_TILES, main_cave_name_tiles
	jmp namedone

lostcave:
	LOAD_ALL_TILES LOCATION_TILES, lost_cave_name_tiles
	jmp namedone

mine:
	LOAD_ALL_TILES LOCATION_TILES, mine_name_tiles
	jmp namedone

town:
	LOAD_ALL_TILES LOCATION_TILES, town_name_tiles
	jmp namedone

base:
	LOAD_ALL_TILES LOCATION_TILES, base_name_tiles
	jmp namedone

blocky:
	LOAD_ALL_TILES LOCATION_TILES, blocky_cave_name_tiles
	jmp namedone

namedone:
	rts
.endproc


PROC init_status_tiles
	LOAD_ALL_TILES 0, status_ui_tiles
	LOAD_ALL_TILES RIGHT_PANEL_TILES, key_tiles
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
	lda player_health
	sta displayed_health

	; Render ammo counter
	LOAD_PTR ammo_tiles
	ldx #16
	ldy #25
	lda #3
	jsr write_tiles

	LOAD_PTR ammo_test_str
	ldx #16
	ldy #26
	jsr write_string

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

	rts
.endproc


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


PROC update_status_bar
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


.data

VAR status_palette
	.byte $0f, $00, $16, $30

VAR health_bar_top_tiles
	.byte $60, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $5b, $62
VAR health_bar_mid_tiles
	.byte $28, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $29
VAR health_bar_bot_tiles
	.byte $61, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $3e, $63
VAR health_bar_below_tiles
	.byte $0f, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19

VAR ammo_tiles
	.byte $2a, $2b, $2c
VAR ammo_test_str
	.byte "120", 0

VAR cur_item_top_tiles
	.byte $60, $5b, $5b, $62
VAR cur_item_mid_tiles
	.byte $28, $00, $00, $29
	.byte $28, $00, $00, $29
VAR cur_item_bot_tiles
	.byte $61, $3e, $3e, $63

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
	.byte $2e, $00
VAR increase_health_tiles
	.byte $2d, $2e

VAR full_health_tiles
	.byte $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d
VAR partial_health_tile
	.byte $2e


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
