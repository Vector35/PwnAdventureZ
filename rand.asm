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

.segment "FIXED"

PROC mod8
	sta temp
	lda #0
	sta temp + 1
	ldy #1

bitloop:
	cpx #0
	bmi divloop
	txa
	asl
	tax
	tya
	asl
	tay
	jmp bitloop

divloop:
	cpy #0
	beq end

	cpx temp
	bcc le
	bne gt
le:
	lda temp
	pha
	txa
	sta temp
	pla
	sec
	sbc temp
	sta temp
	lda temp + 1
	pha
	tya
	sta temp + 1
	pla
	clc
	adc temp + 1
	sta temp + 1
gt:

	txa
	lsr
	tax
	tya
	lsr
	tay
	jmp divloop

end:
	lda temp
	rts
.endproc


PROC gen8
	pha

	txa
	clc
	adc gen_base
	sta temp
	tya
	clc
	adc gen_base + 1
	sta temp + 1

	pla
	tax

	clc
	adc temp
	tay
	lda noise, y
	sta temp

	txa
	asl
	adc temp + 1
	tay
	lda noise, y
	eor temp
	rts
.endproc


VAR noise
	.byte $cb,$38,$35,$a2,$7b,$12,$c2,$e8,$8c,$30,$99,$10,$9b,$dc,$0b,$67
	.byte $61,$65,$e5,$ad,$b4,$2c,$cf,$f7,$d5,$22,$64,$bd,$4a,$2f,$71,$4c
	.byte $45,$e6,$b3,$0c,$a3,$43,$80,$d3,$23,$fe,$6e,$96,$74,$2d,$3c,$ac
	.byte $8f,$c9,$00,$29,$b8,$0a,$bc,$d4,$2a,$34,$e1,$af,$1a,$07,$bb,$5c
	.byte $85,$91,$b0,$75,$f4,$44,$1d,$f3,$a4,$e9,$84,$a9,$62,$86,$59,$53
	.byte $6f,$77,$4d,$d8,$01,$7c,$05,$f0,$7d,$28,$40,$66,$9e,$1c,$fa,$79
	.byte $de,$93,$50,$f9,$d6,$c3,$6a,$3e,$aa,$87,$dd,$1b,$37,$57,$1f,$90
	.byte $cd,$3b,$7f,$da,$19,$e0,$a0,$25,$f6,$d0,$03,$c5,$fb,$5b,$ab,$94
	.byte $08,$a6,$18,$ce,$0e,$55,$b7,$21,$15,$c0,$72,$fc,$ae,$63,$c4,$97
	.byte $4b,$04,$6d,$2b,$83,$4e,$11,$02,$ed,$3f,$b9,$41,$5e,$13,$51,$ee
	.byte $f2,$0f,$6b,$3d,$c7,$46,$60,$78,$b5,$bf,$a5,$5f,$17,$58,$73,$b6
	.byte $9a,$9c,$f5,$33,$82,$54,$ec,$49,$52,$0d,$d9,$47,$e4,$31,$fd,$d7
	.byte $48,$20,$cc,$92,$5a,$7a,$39,$ef,$36,$9d,$f8,$27,$56,$ea,$24,$32
	.byte $16,$8e,$c6,$9f,$a1,$8b,$a8,$b1,$c1,$76,$f1,$1e,$3a,$8d,$b2,$69
	.byte $70,$98,$2e,$5d,$df,$42,$68,$06,$db,$26,$e7,$89,$d1,$a7,$88,$09
	.byte $6c,$8a,$81,$eb,$95,$e2,$ca,$c8,$d2,$ff,$4f,$e3,$be,$7e,$14,$ba


.bss
VAR rand_seed
	.word 0

VAR gen_base
	.word 0
