; Macros for defining functions and variables
.macro PROC name
.proc name
.export name
.endmacro

.macro VAR name
name:
.export name
.endmacro

; Macro for loading pointer
.macro LOAD_PTR var
	lda #<(var)
	sta ptr
	lda #>(var)
	sta ptr + 1
.endmacro

; Macro for defining and loading tiles
.macro TILES var, seg, file, count
.segment .concat("CHR", .string(seg))
VAR var
.incbin file
.data
VAR .ident(.concat(.string(var), "_count"))
	.byte count
.endmacro

.macro LOAD_TILES addr, var, count
	LOAD_PTR var
	ldy #^var
	lda #<((addr) * $10)
	sta temp
	lda #>((addr) * $10)
	sta temp + 1
	lda count
	jsr copy_tiles
.endmacro

.macro LOAD_ALL_TILES addr, var
LOAD_TILES addr, var, .ident(.concat(.string(var), "_count"))
.endmacro

.macro PLAY_SOUND_EFFECT var
	LOAD_PTR var
	lda #^var
	jsr play_sound_effect
.endmacro


; NES hardware defines
.define PPUCTRL    $2000
.define PPUMASK    $2001
.define PPUSTATUS  $2002
.define OAMADDR    $2003
.define OAMDATA    $2004
.define PPUSCROLL  $2005
.define PPUADDR    $2006
.define PPUDATA    $2007
.define SQ1_VOL    $4000
.define SQ1_SWEEP  $4001
.define SQ1_LO     $4002
.define SQ1_HI     $4003
.define SQ2_VOL    $4004
.define SQ2_SWEEP  $4005
.define SQ2_LO     $4006
.define SQ2_HI     $4007
.define TRI_LINEAR $4008
.define TRI_LO     $400a
.define TRI_HI     $400b
.define NOISE_VOL  $400c
.define NOISE_LO   $400e
.define NOISE_HI   $400f
.define DMC_FREQ   $4010
.define DMC_RAW    $4011
.define DMC_START  $4012
.define DMC_LEN    $4013
.define OAMDMA     $4014
.define SND_CHN    $4015
.define JOY1       $4016
.define JOY2       $4017

.define PPUCTRL_NAMETABLE_2000     $00
.define PPUCTRL_NAMETABLE_2400     $01
.define PPUCTRL_NAMETABLE_2800     $02
.define PPUCTRL_NAMETABLE_2C00     $03
.define PPUCTRL_ADD_32             $04
.define PPUCTRL_SPRITE_PATTERN     $08
.define PPUCTRL_BACKGROUND_PATTERN $10
.define PPUCTRL_SPRITE_SIZE        $20
.define PPUCTRL_ENABLE_NMI         $80

.define PPUMASK_GRAYSCALE          $01
.define PPUMASK_BACKGROUND_LEFT_8  $02
.define PPUMASK_SPRITE_LEFT_8      $04
.define PPUMASK_BACKGROUND         $08
.define PPUMASK_SPRITES            $10
.define PPUMASK_RED                $20
.define PPUMASK_GREEN              $40
.define PPUMASK_BLUE               $80

.define SPRITE_PRIORITY   $20
.define SPRITE_FLIP_HORIZ $40
.define SPRITE_FLIP_VERT  $80

.define JOY_A      $01
.define JOY_B      $02
.define JOY_SELECT $04
.define JOY_START  $08
.define JOY_UP     $10
.define JOY_DOWN   $20
.define JOY_LEFT   $40
.define JOY_RIGHT  $80


; Game hardware settings

; Use 8x16 sprites, set nametable so that x=0 is leftmost usable tile
.define PPUCTRL_SETTINGS PPUCTRL_ENABLE_NMI | PPUCTRL_SPRITE_SIZE | PPUCTRL_SPRITE_PATTERN | PPUCTRL_NAMETABLE_2400


; Map screen types
.define MAP_CAVE_START         0
.define MAP_BOUNDARY           1
.define MAP_CAVE_INTERIOR      2
.define MAP_FOREST             3
.define MAP_HOUSE              4
.define MAP_SHOP               5
.define MAP_PARK               6
.define MAP_LAKE               7
.define MAP_BOSS               8
.define MAP_BASE_HORDE         9
.define MAP_BASE_INTERIOR      10
.define MAP_BLOCKY_TREASURE    11
.define MAP_BLOCKY_PUZZLE      12
.define MAP_BLOCKY_CAVE        13
.define MAP_STARTING_CAVE      14
.define MAP_LOST_CAVE          15
.define MAP_MINE_ENTRANCE      16
.define MAP_MINE_DOWN          17
.define MAP_DEAD_WOOD          18
.define MAP_UNBEARABLE         19
.define MAP_START_FOREST       20
.define MAP_START_FOREST_CHEST 21
.define MAP_START_FOREST_BOSS  22
.define MAP_BOARDED_HOUSE      23
.define MAP_CAVE_CHEST         24
.define MAP_CAVE_BOSS          25
.define MAP_FOREST_CHEST       26
.define MAP_MINE_CHEST         27
.define MAP_MINE_BOSS          28
.define MAP_SEWER              29
.define MAP_SEWER_CHEST        30
.define MAP_SEWER_BOSS         31
.define MAP_DEAD_WOOD_CHEST    32
.define MAP_DEAD_WOOD_BOSS     33
.define MAP_UNBEARABLE_CHEST   34
.define MAP_UNBEARABLE_BOSS    35
.define MAP_LOST_CAVE_WALL     36
.define MAP_LOST_CAVE_CHEST    37
.define MAP_LOST_CAVE_END      38
.define MAP_SECRET_SHOP        39
.define MAP_OUTPOST_SHOP       40
.define MAP_SEWER_DOWN         41
.define MAP_OUTPOST_HOUSE      42
.define MAP_TYPE_COUNT         43

; Map parameters
.define MAP_WIDTH  15
.define MAP_HEIGHT 12

.define FINAL_KEY_COUNT 6


; Border tile sets
.define BORDER_OUTER_TOP_LEFT     $00
.define BORDER_OUTER_TOP_CENTER   $04
.define BORDER_OUTER_TOP_RIGHT    $08
.define BORDER_OUTER_CENTER_LEFT  $0c
.define BORDER_INTERIOR           $10
.define BORDER_OUTER_CENTER_RIGHT $14
.define BORDER_OUTER_BOT_LEFT     $18
.define BORDER_OUTER_BOT_CENTER   $1c
.define BORDER_OUTER_BOT_RIGHT    $20
.define BORDER_INNER_TOP_LEFT     $24
.define BORDER_INNER_TOP_RIGHT    $28
.define BORDER_CENTER             $2c
.define BORDER_INNER_BOT_LEFT     $30
.define BORDER_INNER_BOT_RIGHT    $34
.define BORDER_INNER_SINGLE       $38
.define BORDER_SINGLE_LEFT        $3c ; Not present in most sets
.define BORDER_SINGLE_RIGHT       $40 ; Not present in most sets
.define BORDER_SINGLE_UP          $44 ; Not present in most sets
.define BORDER_SINGLE_DOWN        $48 ; Not present in most sets
.define BORDER_UL_DR              $4c ; Not present in most sets
.define BORDER_UR_DL              $50 ; Not present in most sets
.define BORDER_UP_LEFT            $54 ; Not present in most sets
.define BORDER_UP_RIGHT           $58 ; Not present in most sets
.define BORDER_UP_BOTH            $5c ; Not present in most sets
.define BORDER_DOWN_LEFT          $60 ; Not present in most sets
.define BORDER_DOWN_RIGHT         $64 ; Not present in most sets
.define BORDER_DOWN_BOTH          $68 ; Not present in most sets
.define BORDER_LEFT_UP            $6c ; Not present in most sets
.define BORDER_LEFT_DOWN          $70 ; Not present in most sets
.define BORDER_LEFT_BOTH          $74 ; Not present in most sets
.define BORDER_RIGHT_UP           $78 ; Not present in most sets
.define BORDER_RIGHT_DOWN         $7c ; Not present in most sets
.define BORDER_RIGHT_BOTH         $80 ; Not present in most sets

.define SMALL_BORDER_OUTER_TOP_LEFT     $00
.define SMALL_BORDER_OUTER_TOP_CENTER   $01
.define SMALL_BORDER_OUTER_TOP_RIGHT    $02
.define SMALL_BORDER_OUTER_CENTER_LEFT  $03
.define SMALL_BORDER_INTERIOR           $04
.define SMALL_BORDER_OUTER_CENTER_RIGHT $05
.define SMALL_BORDER_OUTER_BOT_LEFT     $06
.define SMALL_BORDER_OUTER_BOT_CENTER   $07
.define SMALL_BORDER_OUTER_BOT_RIGHT    $08
.define SMALL_BORDER_INNER_TOP_LEFT     $09
.define SMALL_BORDER_INNER_TOP_RIGHT    $0a
.define SMALL_BORDER_CENTER             $0b
.define SMALL_BORDER_INNER_BOT_LEFT     $0c
.define SMALL_BORDER_INNER_BOT_RIGHT    $0d
.define SMALL_BORDER_INNER_SINGLE       $0e
.define SMALL_BORDER_SINGLE_LEFT        $0f
.define SMALL_BORDER_SINGLE_RIGHT       $10
.define SMALL_BORDER_SINGLE_UP          $11
.define SMALL_BORDER_SINGLE_DOWN        $12
.define SMALL_BORDER_UL_DR              $13
.define SMALL_BORDER_UR_DL              $14
.define SMALL_BORDER_UP_LEFT            $15
.define SMALL_BORDER_UP_RIGHT           $16
.define SMALL_BORDER_UP_BOTH            $17
.define SMALL_BORDER_DOWN_LEFT          $18
.define SMALL_BORDER_DOWN_RIGHT         $19
.define SMALL_BORDER_DOWN_BOTH          $1a
.define SMALL_BORDER_LEFT_UP            $1b
.define SMALL_BORDER_LEFT_DOWN          $1c
.define SMALL_BORDER_LEFT_BOTH          $1d
.define SMALL_BORDER_RIGHT_UP           $1e
.define SMALL_BORDER_RIGHT_DOWN         $1f
.define SMALL_BORDER_RIGHT_BOTH         $20


; Forest tile set
.define FOREST_GRASS $00
.define FOREST_TREE  $04


; Save stats tile set
.define SAVE_TILE_NORMAL      $00
.define SAVE_TILE_HARD        $04
.define SAVE_TILE_APOCALYPSE  $07
.define SAVE_TILE_KEY_COUNT   $0e
.define SAVE_TILE_NUMBERS     $15
.define SAVE_TILE_COLON       $1f


; Minimap tile set
.define MINIMAP_TILE_BACKGROUND    $001
.define MINIMAP_TILE_FOREST        $00a
.define MINIMAP_TILE_CAVE_ENTRANCE $00c
.define MINIMAP_TILE_ROCK          $00d
.define MINIMAP_TILE_BASE          $02e
.define MINIMAP_TILE_TOWN          $03d
.define MINIMAP_TILE_ARROWS        $03f
.define MINIMAP_TILE_LAKE          $05c
.define MINIMAP_TILE_INDICATORS    $07d


; Movement directions
.define DIR_UP        0
.define DIR_LEFT      1
.define DIR_RIGHT     2
.define DIR_DOWN      3
.define DIR_RUN_UP    4
.define DIR_RUN_LEFT  5
.define DIR_RUN_RIGHT 6
.define DIR_RUN_DOWN  7


; Enemy types
.define ENEMY_NORMAL_MALE_ZOMBIE   0
.define ENEMY_NORMAL_FEMALE_ZOMBIE 1
.define ENEMY_SHARK                2
.define ENEMY_FAT_ZOMBIE           3
.define ENEMY_MALE_NPC_1           4
.define ENEMY_FEMALE_NPC_1         5
.define ENEMY_MALE_THIN_NPC_1      6
.define ENEMY_FEMALE_THIN_NPC_1    7
.define ENEMY_MALE_NPC_2           8
.define ENEMY_FEMALE_NPC_2         9
.define ENEMY_MALE_THIN_NPC_2      10
.define ENEMY_FEMALE_THIN_NPC_2    11
.define ENEMY_SPIDER               12
.define ENEMY_NONE                 $ff

.define ENEMY_MAX_COUNT          8

.define ENEMY_DESC_TICK          0
.define ENEMY_DESC_DIE           2
.define ENEMY_DESC_COLLIDE       4
.define ENEMY_DESC_SPRITE_STATES 6
.define ENEMY_DESC_TILE          8
.define ENEMY_DESC_PALETTE       9
.define ENEMY_DESC_SPEED_MASK    10
.define ENEMY_DESC_SPEED_VALUE   11
.define ENEMY_DESC_HEALTH        12


; Interaction types
.define INTERACT_STARTING_CHEST     0
.define INTERACT_URN                1
.define INTERACT_BIGDOOR            2
.define INTERACT_BLOCKY_CHEST       3
.define INTERACT_SHOP_NPC           4
.define INTERACT_STARTING_NOTE      5
.define INTERACT_BLOCKY_NOTE        6
.define INTERACT_BOARDED_HOUSE_NOTE 7
.define INTERACT_BOARDED_HOUSE_NPC  8
.define INTERACT_KEY_CHEST_1        9
.define INTERACT_KEY_CHEST_5        10
.define INTERACT_NONE               $ff

.define INTERACT_DESC_IS_VALID 0
.define INTERACT_DESC_ACTIVATE 2


; Sprite tile indicies
.define SPRITE_OAM_PLAYER   $00
.define SPRITE_OAM_INTERACT $08
.define SPRITE_OAM_ENEMIES  $90
.define SPRITE_OAM_EFFECTS  $10
.define SPRITE_OAM_EQUIP_WEAPON $f0
.define SPRITE_OAM_EQUIP_ARMOR  $f8

.define SPRITE_TILE_PLAYER $00

.define SPRITE_TILE_NORMAL_MALE_ZOMBIE   $20
.define SPRITE_TILE_NORMAL_FEMALE_ZOMBIE $40
.define SPRITE_TILE_FAT_ZOMBIE           $60
.define SPRITE_TILE_SHARK                $80
.define SPRITE_TILE_SPIDER               $a0

.define SPRITE_TILE_MALE_NPC        $20
.define SPRITE_TILE_FEMALE_NPC      $40
.define SPRITE_TILE_MALE_THIN_NPC   $60
.define SPRITE_TILE_FEMALE_THIN_NPC $80

.define SPRITE_TILE_WARP          $dc
.define SPRITE_TILE_SPLAT         $e0
.define SPRITE_TILE_ORB           $ee
.define SPRITE_TILE_BULLET        $f2
.define SPRITE_TILE_BULLET_HIT    $f4
.define SPRITE_TILE_BULLET_DAMAGE $f6
.define SPRITE_TILE_INTERACT      $f8
.define SPRITE_TILE_LASER         $100

; Effects
.define EFFECT_PLAYER_BULLET         0
.define EFFECT_PLAYER_LMG_BULLET     1
.define EFFECT_PLAYER_AK_BULLET      2
.define EFFECT_PLAYER_SNIPER_BULLET  3
.define EFFECT_PLAYER_SHOTGUN_BULLET 4
.define EFFECT_PLAYER_LEFT_BULLET    5
.define EFFECT_PLAYER_RIGHT_BULLET   6
.define EFFECT_DROP                  7
.define EFFECT_ENEMY_DEATH           8
.define EFFECT_PLAYER_BULLET_DAMAGE  9
.define EFFECT_PLAYER_BULLET_HIT     10
.define EFFECT_SHARK_LASER           11
.define EFFECT_SHARK_LASER_HIT       12
.define EFFECT_SHARK_LASER_DAMAGE    13
.define EFFECT_WARP                  14
.define EFFECT_NONE                 $ff

.define EFFECT_MAX_COUNT     16

.define EFFECT_DESC_TICK           0
.define EFFECT_DESC_PLAYER_COLLIDE 2
.define EFFECT_DESC_ENEMY_COLLIDE  4
.define EFFECT_DESC_WORLD_COLLIDE  6
.define EFFECT_DESC_TILE           8
.define EFFECT_DESC_LARGE          9
.define EFFECT_DESC_PALETTE        10
.define EFFECT_DESC_COLLIDE_WIDTH  11
.define EFFECT_DESC_COLLIDE_HEIGHT 12


; Save state header
.define SAVE_HEADER_SIGNATURE   $00
.define SAVE_HEADER_NAME        $04
.define SAVE_HEADER_DIFFICULTY  $12
.define SAVE_HEADER_KEY_COUNT   $13
.define SAVE_HEADER_TIME_PLAYED $14
.define SAVE_HEADER_CHECKSUM    $1e


; Inventory
.define INVENTORY_SIZE     29

.define ITEM_AXE           0
.define ITEM_SWORD         1
.define ITEM_PISTOL        2
.define ITEM_SMG           3
.define ITEM_LMG           4
.define ITEM_AK            5
.define ITEM_SHOTGUN       6
.define ITEM_SNIPER        7
.define ITEM_HAND_CANNON   8
.define ITEM_ROCKET        9
.define ITEM_FLAMETHROWER  10
.define ITEM_GRENADE       11
.define ITEM_BANDAGE       12
.define ITEM_HEALTH_KIT    13
.define ITEM_FUEL          14
.define ITEM_STICKS        15
.define ITEM_CLOTH         16
.define ITEM_SHIRT         17
.define ITEM_PANTS         18
.define ITEM_METAL         19
.define ITEM_GEM           20
.define ITEM_GUNPOWDER     21
.define ITEM_CAMPFIRE      22
.define ITEM_SNEAKERS      23
.define ITEM_WIZARD_HAT    24
.define ITEM_ARMOR         25
.define ITEM_TINFOIL_HAT   26
.define ITEM_GHILLIE_SUIT  27
.define ITEM_COFFEE        28
.define ITEM_WINE          29

.define ITEM_NONE          $ff

.define ITEM_DESC_USE      0
.define ITEM_DESC_TILE     2
.define ITEM_DESC_TYPE     4
.define ITEM_DESC_NAME     5

.define ITEM_TYPE_GUN        0
.define ITEM_TYPE_MELEE      1
.define ITEM_TYPE_GRENADE    2
.define ITEM_TYPE_CRAFTING   3
.define ITEM_TYPE_OUTFIT     4
.define ITEM_TYPE_HEALTH     5
.define ITEM_TYPE_CONSUMABLE 6
.define ITEM_TYPE_SELL       7
.define ITEM_TYPE_CAMPFIRE   8


; Music defines
.define MUSIC_NONE    0
.define MUSIC_CAVE    1
.define MUSIC_FOREST  2


; Quest complete bits
.define QUEST_KEY_1   1
.define QUEST_KEY_2   2
.define QUEST_KEY_3   4
.define QUEST_KEY_4   8
.define QUEST_KEY_5   $10
.define QUEST_KEY_6   $20
.define QUEST_START   $40
.define QUEST_END     $80


; Globally accessible zero page variables
.zeropage
.global ptr ; For manipulating pointers
.global temp ; 2 byte temporary
.global arg0, arg1, arg2, arg3, arg4, arg5
.global vblank_count, in_nmi

.global rendering_enabled
.global ppu_settings

.global controller

.global player_x, player_y, player_entry_x, player_entry_y
.global player_health, gold

.global cur_enemy

.global inventory, inventory_count
.global map_screen_generators, cur_screen_x, cur_screen_y, inside, map_bank, map_ptr, map_visited_ptr
.global equipped_weapon, equipped_armor, equipped_weapon_slot, equipped_armor_slot
.global spawn_screen_x, spawn_screen_y, spawn_inside, spawn_pos_x, spawn_pos_y
.global active_save_slot

.global secret_code

.global music_page_list_ptr, music_page_bank_ptr, music_page_ptr, audio_reg_ptr

.global completed_quest_steps, highlighted_quest_steps
.global horde_active, horde_complete, horde_timer, horde_enemy_types
.global horde_spawn_timer, horde_spawn_delay
