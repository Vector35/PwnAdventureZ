.include "defines.inc"

.define FOREST_TILES    $80
.define SHOP_WALL_TILES $88
.define SHOP_SIGN_TILES $a8
.define HOUSE_EXT_TILES $b0

.define TABLE_TILES     $a8
.define NPC_FLOOR_TILE  $d8

.define HOUSE_ROOF_PALETTE  1
.define HOUSE_FRONT_PALETTE 2

.define FURNITURE_PALETTE   1


.segment "FIXED"

PROC gen_shop
	lda inside
	beq outside

	lda current_bank
	pha
	lda #^do_gen_shop_inside
	jsr bankswitch
	jsr do_gen_shop_inside & $ffff
	pla
	jsr bankswitch
	rts

outside:
	lda current_bank
	pha
	lda #^do_gen_shop_outside
	jsr bankswitch
	jsr do_gen_shop_outside & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_gen_shop_outside
	; Load forest tiles
	LOAD_ALL_TILES FOREST_TILES, forest_tiles
	LOAD_ALL_TILES SHOP_WALL_TILES, shop_wall_tiles
	LOAD_ALL_TILES SHOP_SIGN_TILES, shop_sign_tiles
	LOAD_ALL_TILES HOUSE_EXT_TILES, house_exterior_tiles

	; Set up collision and spawning info
	lda #FOREST_TILES + FOREST_GRASS
	sta traversable_tiles
	lda #HOUSE_EXT_TILES + 36
	sta traversable_tiles + 1
	lda #HOUSE_EXT_TILES + 28
	sta traversable_tiles + 2
	lda #HOUSE_EXT_TILES + 40
	sta traversable_tiles + 3
	lda #FOREST_TILES + FOREST_GRASS
	sta spawnable_tiles
	lda #HOUSE_EXT_TILES + 28
	sta spawnable_tiles + 1
	lda #HOUSE_EXT_TILES + 40
	sta spawnable_tiles + 2

	; Load palette
	LOAD_PTR shop_exterior_palette
	jsr load_background_game_palette

	; Generate parameters for map generation
	jsr gen_map_opening_locations

	lda #FOREST_TILES + FOREST_TREE
	jsr gen_left_wall_small
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_right_wall_small
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_top_wall_single
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_bot_wall_small

	lda #FOREST_TILES + FOREST_GRASS
	jsr gen_walkable_path

	; Generate wall around shop
	ldx #3
	ldy #2
	lda #SHOP_WALL_TILES + 0
	jsr write_gen_map
	lda #SHOP_WALL_TILES + 24
	ldx #4
topwall:
	jsr write_gen_map
	inx
	cpx #11
	bne topwall
	lda #SHOP_WALL_TILES + 4
	jsr write_gen_map

	ldy #3
	lda #SHOP_WALL_TILES + 8
centerwall:
	ldx #3
	jsr write_gen_map
	ldx #11
	jsr write_gen_map
	iny
	cpy #8
	bne centerwall

	lda #5
	jsr genrange_cur
	clc
	adc #5
	sta arg0

	ldx #3
	ldy #8
	lda #SHOP_WALL_TILES + 12
	jsr write_gen_map
	lda #SHOP_WALL_TILES + 24
	ldx #4
botwallleft:
	jsr write_gen_map
	inx
	cpx arg0
	bne botwallleft

	dex
	lda #SHOP_WALL_TILES + 28
	jsr write_gen_map
	inx
	lda #FOREST_TILES + FOREST_GRASS
	jsr write_gen_map
	inx
	lda #SHOP_WALL_TILES + 20
	jsr write_gen_map

	inx
	lda #SHOP_WALL_TILES + 24
botwallright:
	cpx #11
	beq botwalldone
	jsr write_gen_map
	inx
	jmp botwallright & $ffff
botwalldone:
	lda #SHOP_WALL_TILES + 16
	jsr write_gen_map

	ldx #5
	ldy #4
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 0 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 4 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 8 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx #5
	iny
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 16 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 20 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 24 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 12 + HOUSE_ROOF_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 28
	jsr write_gen_map

	ldx #5
	iny
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #SHOP_SIGN_TILES + 0 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 36 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #SHOP_SIGN_TILES + 4 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 32 + HOUSE_FRONT_PALETTE
	jsr write_gen_map
	inx
	lda #HOUSE_EXT_TILES + 40
	jsr write_gen_map

	lda #7
	sta entrance_x
	lda #6
	sta entrance_y

	; Pick house paint color
	lda #3
	jsr genrange_cur
	tay
	lda house_paint_colors & $ffff, y
	sta scratch + 3
	sta scratch + 7

	; Pick house roof color
	lda #3
	jsr genrange_cur
	tay
	lda roof_dark_colors & $ffff, y
	sta scratch + 1
	lda roof_light_colors & $ffff, y
	sta scratch + 2

	; Complete and load house palettes
	lda #$0f
	sta scratch
	sta scratch + 4
	lda #$01
	sta scratch + 5
	lda #$17
	sta scratch + 6

	LOAD_PTR scratch
	jsr load_game_palette_1
	LOAD_PTR scratch + 4
	jsr load_game_palette_2

	; Convert tiles that have not been generated into grass
	ldy #0
yloop:
	ldx #0
xloop:
	jsr read_gen_map
	cmp #0
	bne nextblank
	lda #FOREST_TILES + FOREST_GRASS
	jsr write_gen_map
nextblank:
	inx
	cpx #MAP_WIDTH
	bne xloop
	iny
	cpy #MAP_HEIGHT
	bne yloop
	rts
.endproc


PROC do_gen_shop_inside
	; When entering a shop, set spawn point
	lda cur_screen_x
	sta spawn_screen_x
	lda cur_screen_y
	sta spawn_screen_y
	lda inside
	sta spawn_inside
	lda player_entry_x
	sta spawn_pos_x
	lda player_entry_y
	sta spawn_pos_y

	jsr gen_house_inside_common & $ffff
	jsr init_npc_sprites

	LOAD_ALL_TILES TABLE_TILES, small_table_tiles

	ldx #3
	ldy #3
	lda #TABLE_TILES + 0 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 4 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 8 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #3
	lda #TABLE_TILES + 12 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 16 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 20 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #3
	lda #TABLE_TILES + 24 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 28 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 32 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	iny
	ldx #3
	lda #TABLE_TILES + 0 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 4 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 8 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #3
	lda #TABLE_TILES + 12 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 16 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 20 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #3
	lda #TABLE_TILES + 24 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 28 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 32 + FURNITURE_PALETTE
	jsr write_gen_map

	ldx #9
	ldy #3
	lda #TABLE_TILES + 0 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 4 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 8 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #9
	lda #TABLE_TILES + 12 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 16 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 20 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #9
	lda #TABLE_TILES + 24 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 28 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 32 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	iny
	ldx #9
	lda #TABLE_TILES + 0 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 4 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 8 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #9
	lda #TABLE_TILES + 12 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 16 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 20 + FURNITURE_PALETTE
	jsr write_gen_map

	iny
	ldx #9
	lda #TABLE_TILES + 24 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 28 + FURNITURE_PALETTE
	jsr write_gen_map
	inx
	lda #TABLE_TILES + 32 + FURNITURE_PALETTE
	jsr write_gen_map

	; Load a special tile for underneath the NPCs.  This looks exactly like a floor
	; but will collide and be interactable.  This is simply a way to make the NPC
	; interactable without a special NPC system.
	LOAD_ALL_TILES NPC_FLOOR_TILE, npc_floor_tiles

	lda #INTERACT_SHOP_NPC
	sta interactive_tile_types
	lda #NPC_FLOOR_TILE
	sta interactive_tile_values

	ldx #7
	ldy #3
	lda #NPC_FLOOR_TILE
	jsr write_gen_map
	ldx #3
	ldy #6
	lda #NPC_FLOOR_TILE
	jsr write_gen_map
	ldx #12
	ldy #5
	lda #NPC_FLOOR_TILE
	jsr write_gen_map

	; Spawn NPCs as "enemies"
	jsr prepare_spawn
	lda #ENEMY_MALE_NPC_1
	sta arg0
	lda #DIR_DOWN
	sta arg1
	ldx #$70
	ldy #$30
	lda #0
	jsr spawn_npc

	lda #ENEMY_FEMALE_NPC_1
	sta arg0
	lda #DIR_RIGHT
	sta arg1
	ldx #$30
	ldy #$60
	lda #1
	jsr spawn_npc

	lda #ENEMY_MALE_THIN_NPC_2
	sta arg0
	lda #DIR_DOWN
	sta arg1
	ldx #$c0
	ldy #$50
	lda #2
	jsr spawn_npc

	rts
.endproc


.code

PROC shop_npc_interact
	lda interaction_tile_x
	cmp #7
	beq shopkeeper
	rts

shopkeeper:
	lda #ITEM_PISTOL
	sta purchase_items
	lda #0
	sta purchase_price_high
	lda #2
	sta purchase_price_mid
	lda #5
	sta purchase_price_low

	lda #ITEM_SMG
	sta purchase_items + 1
	lda #1
	sta purchase_price_high + 1
	lda #5
	sta purchase_price_mid + 1
	lda #0
	sta purchase_price_low + 1

	lda #ITEM_METAL
	sta purchase_items + 2
	lda #0
	sta purchase_price_high + 2
	lda #0
	sta purchase_price_mid + 2
	lda #2
	sta purchase_price_low + 2

	lda #ITEM_GUNPOWDER
	sta purchase_items + 3
	lda #0
	sta purchase_price_high + 3
	lda #0
	sta purchase_price_mid + 3
	lda #2
	sta purchase_price_low + 3

	lda #ITEM_HEALTH_KIT
	sta purchase_items + 4
	lda #0
	sta purchase_price_high + 4
	lda #3
	sta purchase_price_mid + 4
	lda #0
	sta purchase_price_low + 4

	lda #ITEM_FUEL
	lda #0
	sta purchase_price_high + 5
	lda #4
	sta purchase_price_mid + 5
	lda #0
	sta purchase_price_low + 5

	lda #5
	sta purchase_item_count
	jsr show_shop
	rts
.endproc


.segment "EXTRA"

VAR shop_exterior_palette
	.byte $0f, $09, $19, $00
	.byte $0f, $09, $19, $00
	.byte $0f, $09, $19, $00
	.byte $0f, $09, $19, $00


.data

VAR shop_npc_descriptor
	.word always_interactable
	.word shop_npc_interact


TILES shop_wall_tiles, 3, "tiles/house/shopwall.chr", 32
TILES shop_sign_tiles, 3, "tiles/house/shopsign.chr", 8
TILES npc_floor_tiles, 3, "tiles/house/npcfloor.chr", 4
