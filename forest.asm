.include "defines.inc"

.define FOREST_TILES   $80
.define CHEST_TILES    $b8
.define ENTRANCE_TILES $b8
.define BORDER_TILES   $c0

.define FOREST_PALETTE   0
.define BORDER_PALETTE   1
.define CHEST_PALETTE    2
.define ENTRANCE_PALETTE 2


.segment "FIXED"

PROC is_map_type_forest
	cmp #MAP_FOREST
	beq forest
	cmp #MAP_FOREST_CHEST
	beq forest
	cmp #MAP_DEAD_WOOD
	beq forest
	cmp #MAP_DEAD_WOOD_CHEST
	beq forest
	cmp #MAP_DEAD_WOOD_BOSS
	beq forest
	cmp #MAP_UNBEARABLE
	beq forest
	cmp #MAP_UNBEARABLE_CHEST
	beq forest
	cmp #MAP_UNBEARABLE_BOSS
	beq forest
	cmp #MAP_START_FOREST
	beq forest
	cmp #MAP_START_FOREST_CHEST
	beq forest
	cmp #MAP_START_FOREST_BOSS
	beq forest
	lda #0
	rts
forest:
	lda #1
	rts
.endproc


PROC gen_forest
	lda current_bank
	pha
	lda #^do_gen_forest
	jsr bankswitch
	jsr do_gen_forest & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_forest_boss
	lda current_bank
	pha
	lda #^do_gen_forest_boss
	jsr bankswitch
	jsr do_gen_forest_boss & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_dead_wood
	lda current_bank
	pha
	lda #^do_gen_dead_wood
	jsr bankswitch
	jsr do_gen_dead_wood & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_dead_wood_boss
	lda current_bank
	pha
	lda #^do_gen_dead_wood_boss
	jsr bankswitch
	jsr do_gen_dead_wood_boss & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC gen_sewer_down
	lda current_bank
	pha
	lda #^do_gen_sewer_down
	jsr bankswitch
	jsr do_gen_sewer_down & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC sewer_entrance_interact
	lda current_bank
	pha
	lda #^do_sewer_entrance_interact
	jsr bankswitch
	jsr do_sewer_entrance_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC key_chest_1_interact
	lda current_bank
	pha
	lda #^do_key_chest_1_interact
	jsr bankswitch
	jsr do_key_chest_1_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


PROC key_chest_5_interact
	lda current_bank
	pha
	lda #^do_key_chest_5_interact
	jsr bankswitch
	jsr do_key_chest_5_interact & $ffff
	pla
	jsr bankswitch
	rts
.endproc


.segment "EXTRA"

PROC do_gen_forest
	lda #MUSIC_FOREST
	jsr play_music

	jsr gen_forest_common & $ffff
	jsr finish_forest & $ffff

	jsr spawn_forest_enemies & $ffff
	rts
.endproc


PROC do_gen_forest_boss
	lda #MUSIC_FOREST
	jsr play_music

	jsr gen_forest_common & $ffff

	LOAD_ALL_TILES CHEST_TILES, forest_chest_tiles
	lda #INTERACT_KEY_CHEST_1
	sta interactive_tile_types
	lda #CHEST_TILES
	sta interactive_tile_values
	lda #INTERACT_KEY_CHEST_1
	sta interactive_tile_types + 1
	lda #CHEST_TILES + 4
	sta interactive_tile_values + 1

	lda completed_quest_steps
	and #QUEST_KEY_1
	bne questcomplete

	ldx #7
	ldy #4
	lda #CHEST_TILES + CHEST_PALETTE
	jsr write_gen_map
	jmp chestdone & $ffff

questcomplete:
	ldx #7
	ldy #4
	lda #CHEST_TILES + 4 + CHEST_PALETTE
	jsr write_gen_map

chestdone:
	jsr finish_forest & $ffff

	lda #0
	sta horde_active
	sta horde_complete

	lda #ENEMY_NORMAL_MALE_ZOMBIE
	sta horde_enemy_types
	sta horde_enemy_types + 1
	lda #ENEMY_NORMAL_FEMALE_ZOMBIE
	sta horde_enemy_types + 2
	sta horde_enemy_types + 3

	jsr spawn_forest_enemies & $ffff
	rts
.endproc


PROC do_gen_dead_wood
	lda #MUSIC_FOREST
	jsr play_music

	jsr gen_forest_common & $ffff
	jsr finish_forest & $ffff

	jsr spawn_dead_wood_enemies & $ffff
	rts
.endproc


PROC do_gen_dead_wood_boss
	lda #MUSIC_FOREST
	jsr play_music

	jsr gen_forest_common & $ffff

	LOAD_ALL_TILES CHEST_TILES, forest_chest_tiles
	lda #INTERACT_KEY_CHEST_5
	sta interactive_tile_types
	lda #CHEST_TILES
	sta interactive_tile_values
	lda #INTERACT_KEY_CHEST_5
	sta interactive_tile_types + 1
	lda #CHEST_TILES + 4
	sta interactive_tile_values + 1

	lda completed_quest_steps
	and #QUEST_KEY_5
	bne questcomplete

	ldx #7
	ldy #4
	lda #CHEST_TILES + CHEST_PALETTE
	jsr write_gen_map
	jmp chestdone & $ffff

questcomplete:
	ldx #7
	ldy #4
	lda #CHEST_TILES + 4 + CHEST_PALETTE
	jsr write_gen_map

chestdone:
	jsr finish_forest & $ffff

	lda #0
	sta horde_active
	sta horde_complete

	lda #ENEMY_NORMAL_MALE_ZOMBIE
	sta horde_enemy_types
	lda #ENEMY_SPIDER
	sta horde_enemy_types + 1
	lda #ENEMY_SHARK
	sta horde_enemy_types + 2
	sta horde_enemy_types + 3

	jsr spawn_dead_wood_enemies & $ffff
	rts
.endproc


PROC do_gen_sewer_down
	lda #MUSIC_FOREST
	jsr play_music

	jsr gen_forest_common & $ffff

	LOAD_PTR sewer_entrance_palette
	jsr load_background_game_palette

	LOAD_ALL_TILES ENTRANCE_TILES, sewer_entrance_tiles
	lda #INTERACT_SEWER_ENTRANCE
	sta interactive_tile_types
	lda #ENTRANCE_TILES
	sta interactive_tile_values

	ldx #7
	ldy #4
	lda #ENTRANCE_TILES + ENTRANCE_PALETTE
	jsr write_gen_map

	jsr finish_forest & $ffff

	jsr spawn_forest_enemies & $ffff
	rts
.endproc


PROC spawn_forest_enemies
	jsr prepare_spawn
	jsr restore_enemies
	beq notrestoredspawn
	jmp restoredspawn & $ffff

notrestoredspawn:
	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #3
	jsr rand_range
	clc
	adc #1
	tax
	jmp spawnloop & $ffff

hard:
	lda #4
	jsr rand_range
	clc
	adc #2
	tax
	jmp spawnloop & $ffff

veryhard:
	lda #4
	jsr rand_range
	clc
	adc #4
	tax

spawnloop:
	txa
	pha

	jsr forest_has_water & $ffff ;returns 1 or 0
	clc
	adc #2
	jsr rand_range
	tax
	lda forest_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC spawn_dead_wood_enemies
	jsr prepare_spawn
	jsr restore_enemies
	bne restoredspawn

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #3
	jsr rand_range
	clc
	adc #2
	tax
	jmp spawnloop & $ffff

hard:
	lda #4
	jsr rand_range
	clc
	adc #3
	tax
	jmp spawnloop & $ffff

veryhard:
	lda #3
	jsr rand_range
	clc
	adc #5
	tax

spawnloop:
	txa
	pha

	lda #6
	jsr rand_range
	tax
	lda forest_enemy_types, x
	jsr spawn_starting_enemy

	pla
	tax
	dex
	bne spawnloop

restoredspawn:
	rts
.endproc


PROC gen_forest_common
	; Load forest tiles
	LOAD_ALL_TILES FOREST_TILES, forest_tiles
	jsr init_zombie_sprites
	jsr init_shark_sprites
	jsr init_spider_sprites

	; Set up collision and spawning info
	lda #FOREST_TILES + FOREST_GRASS
	sta traversable_tiles
	lda #BORDER_TILES + BORDER_INTERIOR
	sta traversable_tiles + 1
	lda #FOREST_TILES + FOREST_GRASS
	sta spawnable_tiles

	; Load forest palette
	LOAD_PTR forest_palette
	jsr load_background_game_palette

	; Determine which kind of border (if there is one) needs to be generated
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_DEAD_WOOD
	beq deadwood
	cmp #MAP_DEAD_WOOD_CHEST
	beq deadwood
	cmp #MAP_DEAD_WOOD_BOSS
	bne notdeadwood

deadwood:
	lda #MAP_LAKE
	sta temp
	jmp bordertypedone & $ffff

notdeadwood:
	jsr read_overworld_up
	and #$3f
	sta temp
	jsr is_map_type_forest
	beq bordertypedone

	jsr read_overworld_down
	and #$3f
	sta temp
	jsr is_map_type_forest
	beq bordertypedone

	jsr read_overworld_left
	and #$3f
	sta temp
	jsr is_map_type_forest
	beq bordertypedone

	jsr read_overworld_right
	and #$3f
	sta temp

bordertypedone:
	lda temp
	sta border_type

	cmp #MAP_BOUNDARY
	beq rockborderset
	cmp #MAP_CAVE_INTERIOR
	beq caveborderset
	cmp #MAP_STARTING_CAVE
	beq caveborderset
	cmp #MAP_BLOCKY_CAVE
	beq caveborderset
	cmp #MAP_LOST_CAVE
	beq caveborderset
	cmp #MAP_MINE_ENTRANCE
	beq caveborderset
	cmp #MAP_LAKE
	beq lakeborderset

	; Not a special border set, use trees to block
	lda #MAP_FOREST
	sta border_type
	jmp borderloaded & $ffff

caveborderset:
	; There is a cave next to this area, but it might be inaccessible, check path
	jsr read_overworld_up
	and #$3f
	cmp #MAP_CAVE_INTERIOR
	beq topcave
	cmp #MAP_STARTING_CAVE
	beq topcave
	cmp #MAP_LOST_CAVE
	beq topcave
	cmp #MAP_MINE_ENTRANCE
	beq topcave
	cmp #MAP_BLOCKY_CAVE
	bne topnotcave
topcave:
	jsr can_travel_up
	beq rockborderset

topnotcave:
	; There is a cave but it is not accessible, use the normal solid rock border
	lda #MAP_BOUNDARY
	sta border_type

rockborderset:
	; There is a map boundary or cave next to this area, load the rock border tile set
	LOAD_ALL_TILES BORDER_TILES, forest_rock_border_tiles
	LOAD_PTR forest_rock_border_palette
	jsr load_game_palette_1
	jmp borderloaded & $ffff

lakeborderset:
	; There is a lake next to this area, load the lake border tile set
	LOAD_ALL_TILES BORDER_TILES, forest_lake_border_tiles
	LOAD_PTR forest_lake_border_palette
	jsr load_game_palette_1
	lda #BORDER_TILES
	sta water_tile_start
	lda #BORDER_TILES + 56
	sta water_tile_end
	jmp borderloaded & $ffff

borderloaded:
	; Generate parameters for map generation
	jsr gen_map_opening_locations

	; Generate the surrounding trees, but avoid generating borders of different types
	lda border_type
	cmp #MAP_FOREST
	beq leftisforest
	jsr read_overworld_left
	and #$3f
	jsr is_map_type_forest
	beq leftnotforest
leftisforest:
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_left_wall_small

leftnotforest:
	lda border_type
	cmp #MAP_FOREST
	beq rightisforest
	jsr read_overworld_right
	and #$3f
	jsr is_map_type_forest
	beq rightnotforest
rightisforest:
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_right_wall_small

rightnotforest:
	lda border_type
	cmp #MAP_FOREST
	beq topisforest
	jsr read_overworld_up
	and #$3f
	jsr is_map_type_forest
	beq topnotforest
topisforest:
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_top_wall_small

topnotforest:
	lda border_type
	cmp #MAP_FOREST
	beq botisforest
	jsr read_overworld_down
	and #$3f
	jsr is_map_type_forest
	beq botnotforest
botisforest:
	lda #FOREST_TILES + FOREST_TREE
	jsr gen_bot_wall_small

botnotforest:
	lda #FOREST_TILES + FOREST_GRASS
	jsr gen_walkable_path

	; Generate border for other types
	lda border_type
	cmp #MAP_BOUNDARY
	beq rock_boundary
	cmp #MAP_CAVE_INTERIOR
	beq cave_boundary
	cmp #MAP_STARTING_CAVE
	beq cave_boundary
	cmp #MAP_BLOCKY_CAVE
	beq cave_boundary
	cmp #MAP_LOST_CAVE
	beq cave_boundary
	cmp #MAP_MINE_ENTRANCE
	beq cave_boundary
	cmp #MAP_LAKE
	beq lake_boundary
	jmp boundarydone & $ffff

rock_boundary:
	jsr gen_forest_rock_boundary & $ffff
	jmp boundarydone & $ffff

cave_boundary:
	; Place the cave entrance tile while generating the rocks
	ldx top_opening_pos
	dex
	stx top_opening_pos
	jsr gen_forest_rock_boundary & $ffff

	ldx top_opening_pos
	inx
	ldy top_wall_right_extent
	lda #BORDER_TILES + BORDER_INTERIOR + BORDER_PALETTE
	stx entrance_x
	sty entrance_y
	jsr write_gen_map

	jmp boundarydone & $ffff

lake_boundary:
	jsr read_overworld_cur
	and #$3f
	cmp #MAP_DEAD_WOOD
	beq deadwoodborder
	cmp #MAP_DEAD_WOOD_CHEST
	beq deadwoodborder
	cmp #MAP_DEAD_WOOD_BOSS
	bne normallake

deadwoodborder:
	jsr gen_forest_dead_wood_boundary & $ffff
	jmp boundarydone & $ffff

normallake:
	jsr gen_forest_lake_boundary & $ffff
	jmp boundarydone & $ffff

boundarydone:
	rts
.endproc


PROC finish_forest
	; Create clutter in the middle of the forest
	lda #8
	jsr genrange_cur
	clc
	adc #8
	sta clutter_count

clutterloop:
	lda clutter_count
	bne placeclutter
	jmp clutterend & $ffff
placeclutter:

	lda #8
	sta arg5

cluttertry:
	; Generate clutter position
	lda #11
	jsr genrange_cur
	clc
	adc #2
	sta arg0

	lda #8
	jsr genrange_cur
	clc
	adc #2
	sta arg1

	; Check to ensure clutter isn't blocking anything.  It must be surrounded with the
	; same type of blank space (not critical path, or all critical path) to ensure that
	; it will not block all paths to exits
	ldx arg0
	ldy arg1
	jsr read_gen_map
	cmp #0
	beq clutterblank
	cmp #FOREST_TILES + FOREST_GRASS
	bne clutterblock
clutterblank:
	sta arg4

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg1
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	ldx arg0
	dex
	ldy arg1
	iny
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	inx
	jsr read_gen_map
	cmp arg4
	bne clutterblock

	; Clutter is not blocking any paths, place it now
	lda #FOREST_TILES + FOREST_TREE
	ldx arg0
	ldy arg1
	jsr write_gen_map
	jmp nextclutter & $ffff

clutterblock:
	; Clutter was blocking, try again up to a max number of tries
	ldx arg5
	dex
	stx arg5
	beq nextclutter
	jmp cluttertry & $ffff

nextclutter:
	ldx clutter_count
	dex
	stx clutter_count
	jmp clutterloop & $ffff
clutterend:

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


PROC forest_has_water
	ldx #32
check_for_water:
	dex
	lda water_collision, x
	cmp #0
	bne found_water
	cpx #0
	beq no_water
	jmp check_for_water & $ffff
found_water:
	lda #1
	rts
no_water:
	lda #0
	rts
.endproc

PROC gen_forest_rock_boundary
	; Generate borders of rock type with the rock tile set
	jsr read_overworld_left
	and #$3f
	jsr is_map_type_forest
	bne leftnotrock
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_left_wall_large

leftnotrock:
	jsr read_overworld_right
	and #$3f
	jsr is_map_type_forest
	bne rightnotrock
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_right_wall_large

rightnotrock:
	jsr read_overworld_up
	and #$3f
	jsr is_map_type_forest
	bne topnotrock

	lda border_type
	cmp #MAP_CAVE_INTERIOR
	beq rightcave
	cmp #MAP_STARTING_CAVE
	beq rightcave
	cmp #MAP_LOST_CAVE
	beq rightcave
	cmp #MAP_MINE_ENTRANCE
	beq rightcave
	cmp #MAP_BLOCKY_CAVE
	bne rightnotcave
rightcave:
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_top_wall_always_thick
	jmp topnotrock & $ffff
rightnotcave:
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_top_wall_large

topnotrock:
	jsr read_overworld_down
	and #$3f
	jsr is_map_type_forest
	bne botnotrock
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_bot_wall_large

botnotrock:
	; Process the rock tiles to give them a contoured appearance
	lda #BORDER_TILES + BORDER_PALETTE
	jsr process_border_sides

	rts
.endproc


PROC gen_forest_lake_boundary
	; Generate borders of lake type with the lake tile set
	jsr read_overworld_left
	and #$3f
	jsr is_map_type_forest
	bne leftnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_left_wall_very_large

leftnotlake:
	jsr read_overworld_right
	and #$3f
	jsr is_map_type_forest
	bne rightnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_right_wall_very_large

rightnotlake:
	jsr read_overworld_up
	and #$3f
	jsr is_map_type_forest
	bne topnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_top_wall_very_large

topnotlake:
	jsr read_overworld_down
	and #$3f
	jsr is_map_type_forest
	bne botnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_bot_wall_very_large

botnotlake:
	; Process the lake tiles to give them a contoured appearance
	lda #BORDER_TILES + BORDER_PALETTE
	jsr process_border_sides
	rts
.endproc


PROC gen_forest_dead_wood_boundary
	; Generate borders of lake type with the lake tile set
	jsr can_travel_left
	beq leftnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_left_wall_very_large

leftnotlake:
	jsr can_travel_right
	beq rightnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_right_wall_very_large

rightnotlake:
	jsr can_travel_up
	beq topnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_top_wall_very_large

topnotlake:
	jsr can_travel_down
	beq botnotlake
	lda #BORDER_TILES + BORDER_CENTER + BORDER_PALETTE
	jsr gen_bot_wall_very_large

botnotlake:
	; Process the lake tiles to give them a contoured appearance
	lda #BORDER_TILES + BORDER_PALETTE
	jsr process_border_sides
	rts
.endproc


PROC do_sewer_entrance_interact
	jsr fade_out

	lda #^normal_sewer_map
	sta map_bank
	lda #<normal_sewer_map
	sta map_ptr
	lda #>normal_sewer_map
	sta map_ptr + 1
	lda #<sewer_visited
	sta map_visited_ptr
	lda #>sewer_visited
	sta map_visited_ptr + 1

	jsr generate_minimap_cache

	lda #1
	sta warp_to_new_screen
	rts
.endproc


PROC do_key_chest_1_interact
	lda completed_quest_steps
	and #QUEST_KEY_1
	beq notcompleted
	jmp completed & $ffff

notcompleted:
	lda horde_active
	bne inhorde

	lda horde_complete
	bne done

	LOAD_PTR start_horde_text
	lda #^start_horde_text
	jsr show_chat_text

	lda #1
	sta horde_active

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #20
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #120
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

hard:
	lda #30
	sta horde_timer
	lda #0
	sta horde_timer + 1
	lda #90
	sta horde_spawn_timer
	sta horde_spawn_delay
	jmp hordesetup & $ffff

veryhard:
	lda #45
	sta horde_timer
	lda #0
	lda #60
	sta horde_spawn_timer
	sta horde_spawn_delay
	sta horde_timer + 1

hordesetup:
	jsr wait_for_vblank
	LOAD_PTR trapped_chest_palette
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	rts

inhorde:
	LOAD_PTR locked_chest_text
	lda #^locked_chest_text
	jsr show_chat_text
	rts

done:
	lda completed_quest_steps
	ora #QUEST_KEY_1
	sta completed_quest_steps
	lda highlighted_quest_steps
	and #$ff & (~QUEST_KEY_1)
	sta highlighted_quest_steps

	lda completed_quest_steps
	and #QUEST_KEY_2
	bne key2done
	lda highlighted_quest_steps
	ora #QUEST_KEY_2
	sta highlighted_quest_steps

key2done:
	inc key_count

	lda #ITEM_SWORD
	jsr give_item
	lda #ITEM_GEM
	ldx #30
	jsr give_item_with_count
	lda #ITEM_HEALTH_KIT
	ldx #5
	jsr give_item_with_count

	jsr save

	jsr wait_for_vblank
	ldx #7
	ldy #4
	lda #CHEST_TILES + 4 + CHEST_PALETTE
	jsr write_large_tile
	jsr prepare_for_rendering

	PLAY_SOUND_EFFECT effect_open

completed:
	LOAD_PTR key_1_text
	lda #^key_1_text
	jsr show_chat_text
	rts
.endproc


PROC do_key_chest_5_interact
	lda completed_quest_steps
	and #QUEST_KEY_5
	beq notcompleted
	jmp completed & $ffff

notcompleted:
	lda horde_active
	bne inhorde

	lda horde_complete
	bne done

	LOAD_PTR start_horde_text
	lda #^start_horde_text
	jsr show_chat_text

	lda #1
	sta horde_active

	lda #120
	sta horde_spawn_timer
	sta horde_spawn_delay

	lda difficulty
	cmp #1
	beq hard
	cmp #2
	beq veryhard

	lda #120
	sta horde_timer
	lda #0
	sta horde_timer + 1
	jmp hordesetup & $ffff

hard:
	lda #150
	sta horde_timer
	lda #0
	sta horde_timer + 1
	jmp hordesetup & $ffff

veryhard:
	lda #180
	sta horde_timer
	lda #0
	sta horde_timer + 1

hordesetup:
	jsr wait_for_vblank
	LOAD_PTR trapped_chest_palette
	lda #2
	jsr load_single_palette
	jsr prepare_for_rendering

	rts

inhorde:
	LOAD_PTR locked_chest_text
	lda #^locked_chest_text
	jsr show_chat_text
	rts

done:
	lda completed_quest_steps
	ora #QUEST_KEY_5
	sta completed_quest_steps
	lda highlighted_quest_steps
	and #$ff & (~QUEST_KEY_5)
	sta highlighted_quest_steps

	lda completed_quest_steps
	and #QUEST_KEY_6
	bne key6done
	lda highlighted_quest_steps
	ora #QUEST_KEY_6
	sta highlighted_quest_steps

key6done:
	inc key_count

	lda #ITEM_SNIPER
	jsr give_item
	lda #ITEM_GEM
	ldx #40
	jsr give_item_with_count
	lda #ITEM_HEALTH_KIT
	ldx #7
	jsr give_item_with_count

	jsr save

	jsr wait_for_vblank
	ldx #7
	ldy #4
	lda #CHEST_TILES + 4 + CHEST_PALETTE
	jsr write_large_tile
	jsr prepare_for_rendering

	PLAY_SOUND_EFFECT effect_open

completed:
	LOAD_PTR key_5_text
	lda #^key_5_text
	jsr show_chat_text
	rts
.endproc


.data
VAR forest_palette
	.byte $0f, $09, $19, $08
	.byte $0f, $09, $19, $08
	.byte $0f, $19, $07, $27
	.byte $0f, $09, $19, $08

VAR sewer_entrance_palette
	.byte $0f, $09, $19, $08
	.byte $0f, $09, $19, $08
	.byte $0f, $19, $00, $10
	.byte $0f, $09, $19, $08

VAR forest_rock_border_palette
	.byte $0f, $19, $07, $17

VAR forest_lake_border_palette
	.byte $0f, $02, $12, $19

VAR normal_forest_chest_palette
	.byte $0f, $19, $07, $27
VAR trapped_chest_palette
	.byte $0f, $19, $08, $18

VAR forest_enemy_types
	.byte ENEMY_NORMAL_MALE_ZOMBIE, ENEMY_NORMAL_FEMALE_ZOMBIE, ENEMY_SHARK

VAR dead_wood_enemy_types
	.byte ENEMY_NORMAL_MALE_ZOMBIE, ENEMY_NORMAL_FEMALE_ZOMBIE, ENEMY_SPIDER, ENEMY_SPIDER, ENEMY_SHARK, ENEMY_SHARK

VAR key_chest_1_descriptor
	.word always_interactable
	.word key_chest_1_interact

VAR key_chest_5_descriptor
	.word always_interactable
	.word key_chest_5_interact

VAR sewer_entrance_descriptor
	.word always_interactable
	.word sewer_entrance_interact


TILES forest_tiles, 2, "tiles/forest/forest.chr", 8
TILES forest_rock_border_tiles, 2, "tiles/forest/rock.chr", 60
TILES forest_lake_border_tiles, 2, "tiles/forest/lake.chr", 60
TILES forest_chest_tiles, 3, "tiles/forest/chest.chr", 8
TILES sewer_entrance_tiles, 3, "tiles/sewer/entrance.chr", 4


.segment "UI"

VAR start_horde_text
	.byte "THIS CHEST HAS A TRAP!", 0
	.byte "THE HORDE IS COMING.", 0
	.byte "DEFEND YOURSELF!", 0
	.byte 0, 0

VAR locked_chest_text
	.byte "THIS CHEST IS STILL", 0
	.byte "LOCKED. SURVIVE THE", 0
	.byte "HORDE TO OPEN.", 0
	.byte 0, 0

VAR key_1_text
	.byte "YOU FOUND THE FIRST", 0
	.byte "KEY! INSIDE THE CHEST", 0
	.byte "IS ALSO THE LOCATION", 0
	.byte "OF THE NEXT KEY.", 0
	.byte 0

VAR key_5_text
	.byte "YOU FOUND THE FIFTH", 0
	.byte "KEY! INSIDE THE CHEST", 0
	.byte "IS ALSO THE LOCATION", 0
	.byte "OF THE NEXT KEY.", 0
	.byte 0
