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


; Background tile indexes
.define TILE_UI $00
.define TILE_Z  $5c

; Sprite tile indexes
.define TILE_VECTOR $01


; Globally accessible zero page variables
.zeropage
.global ptr ; For manipulating pointers
.global temp ; 2 byte temporary
.global arg0, arg1, arg2, arg3, arg4

.global rendering_enabled
.global ppu_settings

.global controller
