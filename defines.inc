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
VAR .ident(.concat(.string(var), "_bank"))
	.byte seg
VAR .ident(.concat(.string(var), "_count"))
	.byte count
.endmacro

.macro LOAD_TILES addr, var, count
	LOAD_PTR var
	lda .ident(.concat(.string(var), "_bank"))
	tay
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
.define MAP_CAVE_START      0
.define MAP_BOUNDARY        1
.define MAP_CAVE_INTERIOR   2
.define MAP_FOREST          3
.define MAP_HOUSE           4
.define MAP_SHOP            5
.define MAP_PARK            6
.define MAP_LAKE            7
.define MAP_BOSS            8
.define MAP_BASE_HORDE      9
.define MAP_BASE_INTERIOR   10
.define MAP_BLOCKY_TREASURE 11
.define MAP_BLOCKY_PUZZLE   12
.define MAP_TYPE_COUNT      13


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
.define ENEMY_FAT_ZOMBIE           2
.define ENEMY_NONE                 $ff

.define ENEMY_MAX_COUNT        8

.define ENEMY_DESC_TICK        0
.define ENEMY_DESC_DIE         2
.define ENEMY_DESC_COLLIDE     4
.define ENEMY_DESC_TILE        6
.define ENEMY_DESC_PALETTE     7
.define ENEMY_DESC_SPEED_MASK  8
.define ENEMY_DESC_SPEED_VALUE 9
.define ENEMY_DESC_HEALTH      10


; Interaction types
.define INTERACT_STARTING_CHEST   0
.define INTERACT_URN			  1
.define INTERACT_BIGDOOR          2
.define INTERACT_BLOCKY_CHEST     3
.define INTERACT_NONE             $ff

.define INTERACT_DESC_IS_VALID 0
.define INTERACT_DESC_ACTIVATE 2


; Sprite tile indicies
.define SPRITE_OAM_PLAYER   $00
.define SPRITE_OAM_INTERACT $08
.define SPRITE_OAM_ENEMIES  $10
.define SPRITE_OAM_EFFECTS  $50

.define SPRITE_TILE_PLAYER $00

.define SPRITE_TILE_NORMAL_MALE_ZOMBIE   $20
.define SPRITE_TILE_NORMAL_FEMALE_ZOMBIE $40
.define SPRITE_TILE_FAT_ZOMBIE           $60

.define SPRITE_TILE_BULLET        $f2
.define SPRITE_TILE_BULLET_HIT    $f4
.define SPRITE_TILE_BULLET_DAMAGE $f6
.define SPRITE_TILE_INTERACT      $f8


; Effects
.define EFFECT_PLAYER_BULLET        0
.define EFFECT_PLAYER_BULLET_DAMAGE 1
.define EFFECT_PLAYER_BULLET_HIT    2
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


; Globally accessible zero page variables
.zeropage
.global ptr ; For manipulating pointers
.global temp ; 2 byte temporary
.global arg0, arg1, arg2, arg3, arg4, arg5

.global rendering_enabled
.global ppu_settings

.global controller

.global player_x, player_y, player_direction, player_anim_frame
.global player_damage_flash_time, player_palette
.global player_left_tile, player_right_tile, player_up_tile, player_down_tile
.global interaction_type, interaction_sprite_x, interaction_sprite_y, interaction_tile_x, interaction_tile_y
.global possible_interaction_tile_x, possible_interaction_tile_y
.global player_health

.global cur_enemy

.global inventory, map_screen_generators, cur_screen_x, cur_screen_y
.global spawn_screen_x, spawn_screen_y, spawn_pos_x, spawn_pos_y
.global active_save_slot
