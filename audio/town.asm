VAR music_town_ptr
	.word music_town_page_0 & $ffff
	.word music_town_page_1 & $ffff
	.word music_town_page_2 & $ffff
	.word music_town_page_3 & $ffff
	.word music_town_page_4 & $ffff
	.word music_town_page_5 & $ffff
	.word music_town_page_6 & $ffff
	.word music_town_page_7 & $ffff
	.word music_town_page_8 & $ffff
	.word music_town_page_9 & $ffff
	.word music_town_page_10 & $ffff
	.word music_town_page_11 & $ffff
	.word music_town_page_12 & $ffff
	.word music_town_page_13 & $ffff
	.word music_town_page_14 & $ffff
	.word music_town_page_15 & $ffff
	.word music_town_page_16 & $ffff
	.word music_town_page_17 & $ffff
	.word music_town_page_18 & $ffff
	.word music_town_page_19 & $ffff
	.word music_town_page_20 & $ffff
	.word music_town_page_21 & $ffff
	.word music_town_page_22 & $ffff
	.word music_town_page_23 & $ffff
	.word music_town_page_24 & $ffff

VAR music_town_bank
	.byte ^music_town_page_0
	.byte ^music_town_page_1
	.byte ^music_town_page_2
	.byte ^music_town_page_3
	.byte ^music_town_page_4
	.byte ^music_town_page_5
	.byte ^music_town_page_6
	.byte ^music_town_page_7
	.byte ^music_town_page_8
	.byte ^music_town_page_9
	.byte ^music_town_page_10
	.byte ^music_town_page_11
	.byte ^music_town_page_12
	.byte ^music_town_page_13
	.byte ^music_town_page_14
	.byte ^music_town_page_15
	.byte ^music_town_page_16
	.byte ^music_town_page_17
	.byte ^music_town_page_18
	.byte ^music_town_page_19
	.byte ^music_town_page_20
	.byte ^music_town_page_21
	.byte ^music_town_page_22
	.byte ^music_town_page_23
	.byte ^music_town_page_24


VAR music_town_page_0
	.byte $1f, $dd, $ff, $08, $ab, $01, $30, $81, $ab, $01, $3f, $0d, $00, $0d, $9c, $3f
	.byte $56, $03, $56, $03, $39, $00, $01, $98, $7f, $03, $36, $00, $00, $98, $03, $32
	.byte $00, $00, $18, $03, $30, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $01, $08, $30, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03
	.byte $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $0d
	.byte $d1, $ff, $3f, $01, $00, $34, $04, $00, $0d, $d0, $3f, $80, $02, $35, $02, $00
	.byte $01, $90, $7f, $32, $00, $00, $90, $31, $00, $00, $10, $30, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $30, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $0d, $dd, $ff, $fd, $00, $81, $1c, $01, $3c, $06, $00, $0d, $dc
	.byte $3f, $fb, $01, $3a, $02, $37, $08, $00, $01, $c8, $7f, $02, $05, $00, $00, $88
	.byte $02, $00, $00, $d8, $02, $36, $04, $00, $00, $88, $02, $00, $00, $c8, $02, $03
	.byte $00, $00, $98, $02, $35, $00, $00, $88, $02, $00, $00, $98, $02, $34, $00, $00
	.byte $88, $02, $00, $00, $98, $02, $33, $00, $01, $88, $30, $02, $00, $00, $98, $02
	.byte $32, $00, $00, $88, $02, $00, $00, $98, $02, $31, $00, $00, $88, $02, $00, $00

VAR music_town_page_1
	.byte $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $0d, $d1, $ff, $d5, $00, $00, $34, $04, $00, $0d, $d0
	.byte $3f, $ab, $01, $35, $02, $00, $01, $90, $7f, $32, $00, $00, $90, $31, $00, $00
	.byte $10, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $01, $00, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $0d, $dd, $ff, $0c, $01, $81, $ab
	.byte $01, $3f, $0d, $00, $0d, $9c, $3f, $1a, $02, $56, $03, $39, $00, $01, $98, $7f
	.byte $03, $36, $00, $00, $98, $03, $32, $00, $00, $18, $03, $30, $00, $08, $03, $00
	.byte $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $04, $08, $16
	.byte $03, $04, $08, $14, $03, $00, $08, $03, $04, $08, $16, $03, $04, $08, $1a, $03
	.byte $04, $08, $1c, $03, $00, $08, $03, $04, $08, $1a, $03, $04, $d1, $16, $00, $34
	.byte $04, $00, $04, $d0, $14, $35, $02, $00, $00, $90, $32, $00, $04, $90, $16, $31
	.byte $00, $04, $10, $1a, $30, $04, $00, $1c, $00, $00, $04, $00, $1a, $04, $00, $16
	.byte $04, $00, $14, $00, $00, $04, $00, $16, $04, $00, $1a, $04, $00, $1c, $00, $00
	.byte $04, $00, $1a, $04, $00, $16, $04, $00, $14, $00, $00, $04, $00, $16, $04, $00

VAR music_town_page_2
	.byte $1a, $04, $00, $1c, $00, $00, $04, $00, $1a, $0d, $dd, $ff, $fd, $00, $81, $0c
	.byte $01, $3c, $06, $00, $0d, $dc, $3f, $fb, $01, $1a, $02, $37, $08, $00, $01, $c8
	.byte $7f, $02, $05, $00, $00, $88, $02, $00, $00, $d8, $02, $36, $04, $00, $00, $88
	.byte $02, $00, $00, $c8, $02, $03, $00, $00, $98, $02, $35, $00, $00, $88, $02, $00
	.byte $00, $98, $02, $34, $00, $00, $88, $02, $00, $00, $98, $02, $33, $00, $01, $88
	.byte $30, $02, $00, $00, $98, $02, $32, $00, $00, $88, $02, $00, $00, $98, $02, $31
	.byte $00, $00, $88, $02, $00, $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $dc, $1c, $01, $34
	.byte $04, $00, $00, $dc, $3a, $02, $35, $02, $00, $00, $98, $02, $32, $00, $00, $98
	.byte $02, $31, $00, $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $d1, $00, $34
	.byte $04, $00, $00, $d0, $35, $02, $00, $00, $90, $32, $00, $00, $90, $31, $00, $00
	.byte $10, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $0d, $dd, $ff, $ef, $00, $81, $c4, $01, $3f, $0d, $00, $0d, $9c, $3f, $df, $01
	.byte $89, $03, $39, $00, $01, $98, $7f, $03, $36, $00, $00, $98, $03, $32, $00, $00
	.byte $18, $03, $30, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00

VAR music_town_page_3
	.byte $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $04, $08, $db, $03, $04, $08, $d9, $03, $00, $08, $03, $04
	.byte $08, $db, $03, $04, $08, $df, $03, $04, $08, $e1, $03, $00, $08, $03, $04, $08
	.byte $df, $03, $0d, $d1, $ff, $fd, $00, $00, $34, $04, $00, $0d, $d0, $3f, $fb, $01
	.byte $35, $02, $00, $01, $90, $7f, $32, $00, $00, $90, $31, $00, $00, $10, $30, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $30
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $0d, $dd, $ff, $0c, $01, $81, $2d, $01, $3c, $06
	.byte $00, $0d, $dc, $3f, $1a, $02, $5c, $02, $37, $08, $00, $01, $c8, $7f, $02, $05
	.byte $00, $00, $88, $02, $00, $00, $d8, $02, $36, $04, $00, $00, $88, $02, $00, $00
	.byte $c8, $02, $03, $00, $00, $98, $02, $35, $00, $00, $88, $02, $00, $00, $98, $02
	.byte $34, $00, $00, $88, $02, $00, $00, $98, $02, $33, $00, $01, $88, $30, $02, $00
	.byte $00, $98, $02, $32, $00, $00, $88, $02, $00, $00, $98, $02, $31, $00, $00, $88
	.byte $02, $00, $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $0d, $d1, $ff, $1c, $01, $00, $34, $04
	.byte $00, $0d, $d0, $3f, $3a, $02, $35, $02, $00, $01, $90, $7f, $32, $00, $00, $90

VAR music_town_page_4
	.byte $31, $00, $00, $10, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $01, $00, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0d, $dd, $ff, $2d
	.byte $01, $81, $c4, $01, $3f, $0d, $00, $0d, $9c, $3f, $5c, $02, $89, $03, $39, $00
	.byte $01, $98, $7f, $03, $36, $00, $00, $98, $03, $32, $00, $00, $18, $03, $30, $00
	.byte $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03
	.byte $04, $08, $58, $03, $04, $08, $56, $03, $00, $08, $03, $04, $08, $58, $03, $04
	.byte $08, $5c, $03, $04, $08, $5e, $03, $00, $08, $03, $04, $08, $5c, $03, $f4, $d1
	.byte $58, $fa, $08, $9f, $00, $00, $34, $04, $00, $d4, $d0, $56, $3a, $3f, $01, $35
	.byte $02, $00, $10, $90, $7a, $32, $00, $04, $90, $58, $31, $00, $04, $10, $5c, $30
	.byte $04, $00, $5e, $10, $00, $30, $04, $00, $5c, $04, $00, $58, $04, $00, $56, $00
	.byte $00, $04, $00, $58, $d4, $00, $5c, $fa, $96, $00, $d4, $00, $5e, $3a, $2d, $01
	.byte $10, $00, $7a, $04, $00, $5c, $04, $00, $58, $04, $00, $56, $10, $00, $30, $04
	.byte $00, $58, $04, $00, $5c, $04, $00, $5e, $00, $00, $04, $00, $5c, $d4, $dd, $58
	.byte $fa, $8e, $00, $81, $1c, $01, $3c, $06, $00, $d4, $dc, $56, $3a, $1c, $01, $3a

VAR music_town_page_5
	.byte $02, $37, $08, $00, $10, $c8, $7a, $02, $05, $00, $04, $88, $58, $02, $00, $04
	.byte $d8, $5c, $02, $36, $04, $00, $04, $88, $5e, $02, $00, $00, $c8, $02, $03, $00
	.byte $04, $98, $5c, $02, $35, $00, $04, $88, $58, $02, $00, $04, $98, $56, $02, $34
	.byte $00, $00, $88, $02, $00, $04, $98, $58, $02, $33, $00, $04, $88, $5c, $02, $00
	.byte $04, $98, $5e, $02, $32, $00, $00, $88, $02, $00, $04, $98, $5c, $02, $31, $00
	.byte $44, $88, $58, $18, $02, $00, $44, $18, $56, $16, $02, $30, $00, $08, $02, $44
	.byte $08, $58, $18, $02, $44, $08, $5c, $1c, $02, $44, $08, $5e, $1e, $02, $00, $08
	.byte $02, $44, $08, $5c, $1c, $02, $d4, $dc, $58, $fa, $96, $00, $0c, $01, $3c, $06
	.byte $00, $d4, $dc, $56, $3a, $2d, $01, $1a, $02, $37, $08, $00, $10, $c8, $7a, $02
	.byte $05, $00, $04, $88, $58, $02, $00, $04, $d8, $5c, $02, $36, $04, $00, $04, $88
	.byte $5e, $02, $00, $00, $c8, $02, $03, $00, $04, $98, $5c, $02, $35, $00, $04, $88
	.byte $58, $02, $00, $04, $98, $56, $02, $34, $00, $00, $88, $02, $00, $04, $98, $58
	.byte $02, $33, $00, $14, $81, $5c, $30, $00, $00, $04, $90, $5e, $32, $00, $00, $80
	.byte $00, $04, $90, $5c, $31, $00, $04, $80, $58, $00, $04, $10, $56, $30, $00, $00
	.byte $04, $00, $58, $04, $00, $5c, $04, $00, $5e, $00, $00, $04, $00, $5c, $0d, $dd
	.byte $ff, $ab, $01, $81, $ab, $01, $3f, $0d, $00, $0d, $9c, $3f, $56, $03, $56, $03

VAR music_town_page_6
	.byte $39, $00, $01, $98, $7f, $03, $36, $00, $00, $98, $03, $32, $00, $00, $18, $03
	.byte $30, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03
	.byte $00, $08, $03, $00, $08, $03, $01, $08, $30, $03, $00, $08, $03, $00, $08, $03
	.byte $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00
	.byte $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $0d, $d1, $ff, $3f, $01
	.byte $00, $34, $04, $00, $0d, $d0, $3f, $80, $02, $35, $02, $00, $01, $90, $7f, $32
	.byte $00, $00, $90, $31, $00, $00, $10, $30, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $01, $00, $30, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0d
	.byte $dd, $ff, $fd, $00, $81, $1c, $01, $3c, $06, $00, $0d, $dc, $3f, $fb, $01, $3a
	.byte $02, $37, $08, $00, $01, $c8, $7f, $02, $05, $00, $00, $88, $02, $00, $00, $d8
	.byte $02, $36, $04, $00, $00, $88, $02, $00, $00, $c8, $02, $03, $00, $00, $98, $02
	.byte $35, $00, $00, $88, $02, $00, $00, $98, $02, $34, $00, $00, $88, $02, $00, $00
	.byte $98, $02, $33, $00, $01, $88, $30, $02, $00, $00, $98, $02, $32, $00, $00, $88
	.byte $02, $00, $00, $98, $02, $31, $00, $00, $88, $02, $00, $00, $18, $02, $30, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08

VAR music_town_page_7
	.byte $02, $0d, $d1, $ff, $d5, $00, $00, $34, $04, $00, $0d, $d0, $3f, $ab, $01, $35
	.byte $02, $00, $01, $90, $7f, $32, $00, $00, $90, $31, $00, $00, $10, $30, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $30, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $0d, $dd, $ff, $0c, $01, $81, $ab, $01, $3f, $0d, $00
	.byte $0d, $9c, $3f, $1a, $02, $56, $03, $39, $00, $01, $98, $7f, $03, $36, $00, $00
	.byte $98, $03, $32, $00, $00, $18, $03, $30, $00, $08, $03, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03
	.byte $00, $08, $03, $00, $08, $03, $00, $08, $03, $04, $08, $16, $03, $04, $08, $14
	.byte $03, $00, $08, $03, $04, $08, $16, $03, $04, $08, $1a, $03, $04, $08, $1c, $03
	.byte $00, $08, $03, $04, $08, $1a, $03, $04, $d1, $16, $00, $34, $04, $00, $04, $d0
	.byte $14, $35, $02, $00, $00, $90, $32, $00, $04, $90, $16, $31, $00, $04, $10, $1a
	.byte $30, $04, $00, $1c, $00, $00, $04, $00, $1a, $04, $00, $16, $04, $00, $14, $00
	.byte $00, $04, $00, $16, $04, $00, $1a, $04, $00, $1c, $00, $00, $04, $00, $1a, $04
	.byte $00, $16, $04, $00, $14, $00, $00, $04, $00, $16, $04, $00, $1a, $04, $00, $1c
	.byte $00, $00, $04, $00, $1a, $0d, $dd, $ff, $fd, $00, $81, $0c, $01, $3c, $06, $00

VAR music_town_page_8
	.byte $0d, $dc, $3f, $fb, $01, $1a, $02, $37, $08, $00, $01, $c8, $7f, $02, $05, $00
	.byte $00, $88, $02, $00, $00, $d8, $02, $36, $04, $00, $00, $88, $02, $00, $00, $c8
	.byte $02, $03, $00, $00, $98, $02, $35, $00, $00, $88, $02, $00, $00, $98, $02, $34
	.byte $00, $00, $88, $02, $00, $00, $98, $02, $33, $00, $01, $88, $30, $02, $00, $00
	.byte $98, $02, $32, $00, $00, $88, $02, $00, $00, $98, $02, $31, $00, $00, $88, $02
	.byte $00, $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $dc, $1c, $01, $34, $04, $00, $00, $dc
	.byte $3a, $02, $35, $02, $00, $00, $98, $02, $32, $00, $00, $98, $02, $31, $00, $00
	.byte $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $d1, $00, $34, $04, $00, $00, $d0
	.byte $35, $02, $00, $00, $90, $32, $00, $00, $90, $31, $00, $00, $10, $30, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0d, $dd, $ff, $ef
	.byte $00, $81, $c4, $01, $3f, $0d, $00, $0d, $9c, $3f, $df, $01, $89, $03, $39, $00
	.byte $01, $98, $7f, $03, $36, $00, $00, $98, $03, $32, $00, $00, $18, $03, $30, $00
	.byte $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03

VAR music_town_page_9
	.byte $04, $08, $db, $03, $04, $08, $d9, $03, $00, $08, $03, $04, $08, $db, $03, $04
	.byte $08, $df, $03, $04, $08, $e1, $03, $00, $08, $03, $04, $08, $df, $03, $0d, $d1
	.byte $ff, $fd, $00, $00, $34, $04, $00, $0d, $d0, $3f, $fb, $01, $35, $02, $00, $01
	.byte $90, $7f, $32, $00, $00, $90, $31, $00, $00, $10, $30, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $30, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $0d, $dd, $ff, $0c, $01, $81, $2d, $01, $3c, $06, $00, $0d, $dc, $3f
	.byte $1a, $02, $5c, $02, $37, $08, $00, $01, $c8, $7f, $02, $05, $00, $00, $88, $02
	.byte $00, $00, $d8, $02, $36, $04, $00, $00, $88, $02, $00, $00, $c8, $02, $03, $00
	.byte $00, $98, $02, $35, $00, $00, $88, $02, $00, $00, $98, $02, $34, $00, $00, $88
	.byte $02, $00, $00, $98, $02, $33, $00, $01, $88, $30, $02, $00, $00, $98, $02, $32
	.byte $00, $00, $88, $02, $00, $00, $98, $02, $31, $00, $00, $88, $02, $00, $00, $18
	.byte $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $0d, $d1, $ff, $d5, $00, $00, $34, $04, $00, $0d, $d0, $3f
	.byte $ab, $01, $35, $02, $00, $01, $90, $7f, $32, $00, $00, $90, $31, $00, $00, $10
	.byte $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01

VAR music_town_page_10
	.byte $00, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $0d, $dd, $ff, $e1, $00, $81, $c4, $01
	.byte $3f, $0d, $00, $0d, $9c, $3f, $c4, $01, $89, $03, $39, $00, $01, $98, $7f, $03
	.byte $36, $00, $00, $98, $03, $32, $00, $00, $18, $03, $30, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03
	.byte $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $04, $08, $c0, $03
	.byte $04, $08, $be, $03, $00, $08, $03, $04, $08, $c0, $03, $04, $08, $c4, $03, $04
	.byte $08, $c6, $03, $00, $08, $03, $04, $08, $c4, $03, $d4, $d1, $c0, $fa, $8e, $00
	.byte $00, $34, $04, $00, $d4, $d0, $be, $3a, $1c, $01, $35, $02, $00, $10, $90, $7a
	.byte $32, $00, $04, $90, $c0, $31, $00, $04, $10, $c4, $30, $04, $00, $c6, $10, $00
	.byte $30, $04, $00, $c4, $04, $00, $c0, $04, $00, $be, $00, $00, $04, $00, $c0, $d4
	.byte $00, $c4, $fa, $86, $00, $d4, $00, $c6, $3a, $0c, $01, $10, $00, $7a, $04, $00
	.byte $c4, $04, $00, $c0, $04, $00, $be, $10, $00, $30, $04, $00, $c0, $04, $00, $c4
	.byte $04, $00, $c6, $00, $00, $04, $00, $c4, $d4, $dd, $c0, $fa, $7e, $00, $81, $1c
	.byte $01, $3c, $06, $00, $54, $dc, $be, $3a, $fd, $3a, $02, $37, $08, $00, $10, $c8
	.byte $7a, $02, $05, $00, $04, $88, $c0, $02, $00, $04, $d8, $c4, $02, $36, $04, $00

VAR music_town_page_11
	.byte $04, $88, $c6, $02, $00, $00, $c8, $02, $03, $00, $04, $98, $c4, $02, $35, $00
	.byte $04, $88, $c0, $02, $00, $04, $98, $be, $02, $34, $00, $00, $88, $02, $00, $04
	.byte $98, $c0, $02, $33, $00, $04, $88, $c4, $02, $00, $04, $98, $c6, $02, $32, $00
	.byte $00, $88, $02, $00, $04, $98, $c4, $02, $31, $00, $44, $88, $c0, $f9, $02, $00
	.byte $44, $18, $be, $f7, $02, $30, $00, $08, $02, $44, $08, $c0, $f9, $02, $44, $08
	.byte $c4, $fd, $02, $44, $08, $c6, $ff, $02, $00, $08, $02, $44, $08, $c4, $fd, $02
	.byte $54, $dc, $c0, $fa, $77, $0c, $01, $3c, $06, $00, $54, $dc, $be, $3a, $ef, $1a
	.byte $02, $37, $08, $00, $10, $c8, $7a, $02, $05, $00, $04, $88, $c0, $02, $00, $04
	.byte $d8, $c4, $02, $36, $04, $00, $04, $88, $c6, $02, $00, $00, $c8, $02, $03, $00
	.byte $04, $98, $c4, $02, $35, $00, $04, $88, $c0, $02, $00, $04, $98, $be, $02, $34
	.byte $00, $00, $88, $02, $00, $04, $98, $c0, $02, $33, $00, $04, $81, $c4, $00, $00
	.byte $04, $90, $c6, $32, $00, $00, $80, $00, $04, $90, $c4, $31, $00, $44, $80, $c0
	.byte $eb, $00, $44, $10, $be, $e9, $30, $00, $00, $44, $00, $c0, $eb, $44, $00, $c4
	.byte $ef, $44, $00, $c6, $f1, $00, $00, $44, $00, $c4, $ef, $5d, $dd, $ff, $d5, $00
	.byte $fa, $6a, $81, $1c, $01, $3f, $0d, $00, $5d, $9c, $3f, $ab, $01, $3a, $d5, $3a
	.byte $02, $39, $00, $11, $98, $7f, $7a, $02, $36, $00, $00, $98, $02, $32, $00, $00

VAR music_town_page_12
	.byte $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $44, $08, $a7, $d1, $02, $44, $08, $a5, $cf, $02, $00, $08
	.byte $02, $44, $08, $a7, $d1, $02, $44, $08, $ab, $d5, $02, $44, $08, $ad, $d7, $02
	.byte $00, $08, $02, $44, $08, $ab, $d5, $02, $11, $01, $30, $30, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $dd, $0d, $ff, $1c, $01, $fa, $8e, $00, $81, $1c, $01, $dd, $0c
	.byte $3f, $3a, $02, $3a, $1c, $01, $3a, $02, $11, $08, $7f, $7a, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $11, $01, $30, $30, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $dd, $dd, $ff, $1c, $01, $fa, $8e, $00, $81, $1c, $01
	.byte $3c, $06, $00, $dd, $dc, $3f, $3a, $02, $3a, $1c, $01, $3a, $02, $37, $08, $00
	.byte $11, $c8, $7f, $7a, $02, $05, $00, $00, $88, $02, $00, $00, $d8, $02, $36, $04
	.byte $00, $00, $88, $02, $00, $00, $c8, $02, $03, $00, $00, $98, $02, $35, $00, $00
	.byte $88, $02, $00, $00, $98, $02, $34, $00, $00, $88, $02, $00, $00, $98, $02, $33
	.byte $00, $00, $88, $02, $00, $00, $98, $02, $32, $00, $00, $88, $02, $00, $00, $98
	.byte $02, $31, $00, $44, $88, $36, $18, $02, $00, $44, $18, $34, $16, $02, $30, $11

VAR music_town_page_13
	.byte $01, $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $dd, $dd
	.byte $ff, $d5, $00, $fa, $6a, $00, $81, $1c, $01, $3c, $06, $00, $5d, $dc, $3f, $ab
	.byte $01, $3a, $d5, $3a, $02, $37, $08, $00, $11, $c8, $7f, $7a, $02, $05, $00, $00
	.byte $88, $02, $00, $00, $d8, $02, $36, $04, $00, $00, $88, $02, $00, $00, $c8, $02
	.byte $03, $00, $00, $98, $02, $35, $00, $00, $88, $02, $00, $00, $98, $02, $34, $00
	.byte $00, $88, $02, $00, $00, $98, $02, $33, $00, $00, $88, $02, $00, $00, $98, $02
	.byte $32, $00, $00, $88, $02, $00, $00, $98, $02, $31, $00, $44, $88, $a7, $d1, $02
	.byte $00, $44, $18, $a5, $cf, $02, $30, $11, $01, $30, $30, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $dd, $dd, $ff, $ef, $00, $fa, $77, $00, $81, $3f
	.byte $01, $3f, $0d, $00, $5d, $9c, $3f, $df, $01, $3a, $ef, $80, $02, $39, $00, $11
	.byte $98, $7f, $7a, $02, $36, $00, $00, $98, $02, $32, $00, $00, $18, $02, $30, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $44, $08, $db, $eb, $02, $44, $08, $d9, $e9, $02, $00, $08, $02, $44, $08, $db
	.byte $eb, $02, $44, $08, $df, $ef, $02, $44, $08, $e1, $f1, $02, $00, $08, $02, $44
	.byte $08, $df, $ef, $02, $41, $01, $30, $eb, $00, $40, $00, $e9, $00, $00, $40, $00

VAR music_town_page_14
	.byte $eb, $40, $00, $ef, $40, $00, $f1, $00, $00, $40, $00, $ef, $40, $00, $eb, $40
	.byte $00, $e9, $00, $00, $40, $00, $eb, $5d, $0d, $ff, $3f, $01, $fa, $9f, $81, $3f
	.byte $01, $dd, $0c, $3f, $80, $02, $3a, $3f, $01, $80, $02, $11, $08, $7f, $7a, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $11, $01, $30, $30, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $dd, $dd, $ff, $3f, $01, $fa, $9f, $00
	.byte $81, $3f, $01, $3c, $06, $00, $dd, $dc, $3f, $80, $02, $3a, $3f, $01, $80, $02
	.byte $37, $08, $00, $11, $c8, $7f, $7a, $02, $05, $00, $00, $88, $02, $00, $00, $d8
	.byte $02, $36, $04, $00, $00, $88, $02, $00, $00, $c1, $00, $03, $00, $00, $90, $35
	.byte $00, $00, $80, $00, $00, $90, $34, $00, $00, $80, $00, $00, $90, $33, $00, $00
	.byte $8d, $81, $3f, $01, $00, $00, $9c, $80, $02, $32, $00, $00, $88, $02, $00, $00
	.byte $98, $02, $31, $00, $44, $88, $7c, $3b, $02, $00, $44, $18, $7a, $39, $02, $30
	.byte $00, $08, $02, $44, $08, $7c, $3b, $02, $44, $08, $80, $3f, $02, $44, $08, $82
	.byte $41, $02, $00, $08, $02, $44, $08, $80, $3f, $02, $44, $08, $7c, $3b, $02, $44
	.byte $08, $7a, $39, $02, $00, $08, $02, $44, $08, $7c, $3b, $02, $44, $08, $80, $3f
	.byte $02, $44, $08, $82, $41, $02, $00, $08, $02, $44, $08, $80, $3f, $02, $44, $08
	.byte $7c, $3b, $02, $44, $08, $7a, $39, $02, $00, $08, $02, $44, $08, $7c, $3b, $02

VAR music_town_page_15
	.byte $44, $08, $80, $3f, $02, $44, $08, $82, $41, $02, $00, $08, $02, $44, $08, $80
	.byte $3f, $02, $44, $08, $7c, $3b, $02, $44, $08, $7a, $39, $02, $00, $01, $00, $44
	.byte $00, $7c, $3b, $44, $00, $80, $3f, $44, $00, $82, $41, $00, $00, $44, $00, $80
	.byte $3f, $1d, $dd, $ff, $7c, $01, $30, $81, $7c, $01, $3f, $0d, $00, $0d, $9c, $3f
	.byte $f9, $02, $f9, $02, $39, $00, $01, $98, $7f, $02, $36, $00, $00, $98, $02, $32
	.byte $00, $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $0d, $08, $ff, $52, $01, $02
	.byte $0d, $08, $3f, $a6, $02, $02, $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $0d, $08, $ff, $3f, $01, $02, $0d, $08, $3f, $80, $02
	.byte $02, $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $01, $00, $00, $00, $00, $00, $00, $00, $04, $00, $7c, $04, $00, $7a, $00
	.byte $00, $04, $00, $7c, $04, $00, $80, $04, $00, $82, $00, $00, $04, $00, $80, $0d
	.byte $dd, $ff, $52, $01, $81, $7c, $01, $3c, $06, $00, $0d, $dc, $3f, $a6, $02, $f9
	.byte $02, $37, $08, $00, $01, $c8, $7f, $02, $05, $00, $00, $88, $02, $00, $00, $d8

VAR music_town_page_16
	.byte $02, $36, $04, $00, $00, $88, $02, $00, $00, $c8, $02, $03, $00, $00, $98, $02
	.byte $35, $00, $00, $88, $02, $00, $00, $98, $02, $34, $00, $00, $88, $02, $00, $00
	.byte $98, $02, $33, $00, $0d, $88, $ff, $3f, $01, $02, $00, $0d, $98, $3f, $80, $02
	.byte $02, $32, $00, $01, $88, $7f, $02, $00, $00, $98, $02, $31, $00, $00, $88, $02
	.byte $00, $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $0d, $08, $ff, $1c, $01, $02, $0d, $08, $3f
	.byte $3a, $02, $02, $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $01, $00, $00, $00, $00, $00, $00, $00, $04, $00, $36, $04, $00
	.byte $34, $00, $00, $04, $00, $36, $04, $00, $3a, $04, $00, $3c, $00, $00, $04, $00
	.byte $3a, $0d, $dd, $ff, $3f, $01, $81, $3f, $01, $3f, $0d, $00, $0d, $9c, $3f, $80
	.byte $02, $80, $02, $39, $00, $01, $98, $7f, $02, $36, $00, $00, $98, $02, $32, $00
	.byte $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $0d, $08, $ff, $1c, $01, $02, $0d
	.byte $08, $3f, $3a, $02, $02, $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08

VAR music_town_page_17
	.byte $02, $00, $08, $02, $0d, $08, $ff, $fd, $00, $02, $0d, $08, $3f, $fb, $01, $02
	.byte $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $01, $00, $00, $00, $00, $00, $00, $00, $04, $00, $f7, $04, $00, $f5, $00, $00
	.byte $04, $00, $f7, $04, $00, $fb, $04, $00, $fd, $00, $00, $04, $00, $fb, $05, $dd
	.byte $ff, $1c, $81, $3f, $01, $3c, $06, $00, $0d, $dc, $3f, $3a, $02, $80, $02, $37
	.byte $08, $00, $01, $c8, $7f, $02, $05, $00, $00, $88, $02, $00, $00, $d8, $02, $36
	.byte $04, $00, $00, $88, $02, $00, $00, $c8, $02, $03, $00, $00, $98, $02, $35, $00
	.byte $00, $88, $02, $00, $00, $98, $02, $34, $00, $00, $88, $02, $00, $00, $98, $02
	.byte $33, $00, $0d, $88, $ff, $fd, $00, $02, $00, $0d, $98, $3f, $fb, $01, $02, $32
	.byte $00, $01, $88, $7f, $02, $00, $00, $98, $02, $31, $00, $00, $88, $02, $00, $00
	.byte $18, $02, $30, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $0d, $08, $ff, $e1, $00, $02, $0d, $08, $3f, $c4, $01
	.byte $02, $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $0d, $01, $ff, $bd, $00, $00, $0d, $00, $3f, $7c, $01, $01, $00, $7f, $00, $00

VAR music_town_page_18
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $dd, $dd, $ff, $d5, $00, $fa, $6a, $00, $81, $1c, $01, $3f, $0d, $00, $5d, $9c
	.byte $3f, $ab, $01, $3a, $d5, $3a, $02, $39, $00, $11, $98, $7f, $7a, $02, $36, $00
	.byte $00, $98, $02, $32, $00, $00, $18, $02, $30, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $44, $08, $a7, $d1, $02, $44
	.byte $08, $a5, $cf, $02, $00, $08, $02, $44, $08, $a7, $d1, $02, $44, $08, $ab, $d5
	.byte $02, $44, $08, $ad, $d7, $02, $00, $08, $02, $44, $08, $ab, $d5, $02, $11, $01
	.byte $30, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $dd, $0d, $ff, $1c, $01, $fa, $8e
	.byte $00, $81, $1c, $01, $dd, $0c, $3f, $3a, $02, $3a, $1c, $01, $3a, $02, $11, $08
	.byte $7f, $7a, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $11, $01, $30, $30
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $dd, $dd, $ff, $1c, $01
	.byte $fa, $8e, $00, $81, $1c, $01, $3c, $06, $00, $dd, $dc, $3f, $3a, $02, $3a, $1c
	.byte $01, $3a, $02, $37, $08, $00, $11, $c8, $7f, $7a, $02, $05, $00, $00, $88, $02
	.byte $00, $00, $d8, $02, $36, $04, $00, $00, $88, $02, $00, $00, $c8, $02, $03, $00

VAR music_town_page_19
	.byte $00, $98, $02, $35, $00, $00, $88, $02, $00, $00, $98, $02, $34, $00, $00, $88
	.byte $02, $00, $00, $98, $02, $33, $00, $00, $88, $02, $00, $00, $98, $02, $32, $00
	.byte $00, $88, $02, $00, $00, $98, $02, $31, $00, $44, $88, $36, $18, $02, $00, $44
	.byte $18, $34, $16, $02, $30, $11, $01, $30, $30, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $dd, $dd, $ff, $d5, $00, $fa, $6a, $00, $81, $1c, $01, $3c
	.byte $06, $00, $5d, $dc, $3f, $ab, $01, $3a, $d5, $3a, $02, $37, $08, $00, $11, $c8
	.byte $7f, $7a, $02, $05, $00, $00, $88, $02, $00, $00, $d8, $02, $36, $04, $00, $00
	.byte $88, $02, $00, $00, $c8, $02, $03, $00, $00, $98, $02, $35, $00, $00, $88, $02
	.byte $00, $00, $98, $02, $34, $00, $00, $88, $02, $00, $00, $98, $02, $33, $00, $00
	.byte $88, $02, $00, $00, $98, $02, $32, $00, $00, $88, $02, $00, $00, $98, $02, $31
	.byte $00, $44, $88, $a7, $d1, $02, $00, $44, $18, $a5, $cf, $02, $30, $11, $01, $30
	.byte $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $dd, $dd, $ff, $ef
	.byte $00, $fa, $77, $00, $81, $3f, $01, $3f, $0d, $00, $5d, $9c, $3f, $df, $01, $3a
	.byte $ef, $80, $02, $39, $00, $11, $98, $7f, $7a, $02, $36, $00, $00, $98, $02, $32
	.byte $00, $00, $18, $02, $30, $00, $08, $02, $11, $08, $30, $30, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00

VAR music_town_page_20
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $dd, $08
	.byte $ff, $fd, $00, $fa, $7e, $00, $02, $5d, $08, $3f, $fb, $01, $3a, $fd, $02, $11
	.byte $08, $7f, $7a, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $11, $01, $30
	.byte $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $dd, $0d, $ff, $ef, $00, $fa, $77, $00
	.byte $81, $3f, $01, $5d, $0c, $3f, $df, $01, $3a, $ef, $80, $02, $11, $08, $7f, $7a
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $11, $01, $30, $30, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $dd, $dd, $ff, $1c, $01, $fa, $8e
	.byte $00, $81, $3f, $01, $3c, $06, $00, $dd, $dc, $3f, $3a, $02, $3a, $1c, $01, $80
	.byte $02, $37, $08, $00, $11, $c8, $7f, $7a, $02, $05, $00, $00, $88, $02, $00, $00
	.byte $d8, $02, $36, $04, $00, $00, $88, $02, $00, $00, $c1, $00, $03, $00, $00, $90
	.byte $35, $00, $00, $80, $00, $00, $90, $34, $00, $00, $80, $00, $00, $90, $33, $00
	.byte $00, $8d, $81, $3f, $01, $00, $00, $9c, $80, $02, $32, $00, $00, $88, $02, $00
	.byte $00, $98, $02, $31, $00, $44, $88, $36, $18, $02, $00, $44, $18, $34, $16, $02
	.byte $30, $00, $08, $02, $44, $08, $36, $18, $02, $44, $08, $3a, $1c, $02, $44, $08
	.byte $3c, $1e, $02, $00, $08, $02, $44, $08, $3a, $1c, $02, $44, $08, $36, $18, $02

VAR music_town_page_21
	.byte $44, $08, $34, $16, $02, $00, $08, $02, $44, $08, $36, $18, $02, $44, $08, $3a
	.byte $1c, $02, $44, $08, $3c, $1e, $02, $00, $08, $02, $44, $08, $3a, $1c, $02, $44
	.byte $08, $36, $18, $02, $44, $08, $34, $16, $02, $00, $08, $02, $44, $08, $36, $18
	.byte $02, $44, $08, $3a, $1c, $02, $44, $08, $3c, $1e, $02, $00, $08, $02, $44, $08
	.byte $3a, $1c, $02, $44, $08, $36, $18, $02, $44, $08, $34, $16, $02, $00, $01, $00
	.byte $44, $00, $36, $18, $44, $00, $3a, $1c, $44, $00, $3c, $1e, $00, $00, $44, $00
	.byte $3a, $1c, $1d, $dd, $ff, $fd, $00, $30, $81, $7c, $01, $3f, $0d, $00, $0d, $9c
	.byte $3f, $fb, $01, $f9, $02, $39, $00, $01, $98, $7f, $02, $36, $00, $00, $98, $02
	.byte $32, $00, $00, $18, $02, $30, $00, $08, $02, $01, $08, $30, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $0d, $08, $ff, $0c
	.byte $01, $02, $0d, $08, $3f, $1a, $02, $02, $01, $08, $7f, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $01, $08, $30, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $08, $02, $00, $08, $02, $0d, $08, $ff, $fd, $00, $02, $0d, $08
	.byte $3f, $fb, $01, $02, $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02, $00, $08
	.byte $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $01, $00, $00, $00, $00, $00, $00, $00, $04, $00, $f7, $04

VAR music_town_page_22
	.byte $00, $f5, $01, $00, $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0d
	.byte $dd, $ff, $1c, $01, $81, $1c, $01, $3c, $06, $00, $0d, $dc, $3f, $3a, $02, $3a
	.byte $02, $37, $08, $00, $01, $c8, $7f, $02, $05, $00, $00, $88, $02, $00, $00, $d8
	.byte $02, $36, $04, $00, $00, $88, $02, $00, $01, $c8, $30, $02, $03, $00, $00, $98
	.byte $02, $35, $00, $00, $88, $02, $00, $00, $98, $02, $34, $00, $00, $88, $02, $00
	.byte $00, $98, $02, $33, $00, $0d, $88, $ff, $2d, $01, $02, $00, $0d, $98, $3f, $5c
	.byte $02, $02, $32, $00, $01, $88, $7f, $02, $00, $00, $98, $02, $31, $00, $00, $88
	.byte $02, $00, $00, $18, $02, $30, $01, $08, $30, $02, $00, $08, $02, $00, $08, $02
	.byte $00, $08, $02, $00, $08, $02, $00, $08, $02, $0d, $08, $ff, $1c, $01, $02, $0d
	.byte $08, $3f, $3a, $02, $02, $01, $08, $7f, $02, $00, $08, $02, $00, $08, $02, $00
	.byte $08, $02, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $04, $00, $36, $04, $00, $34, $01, $00, $30
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0d, $dd, $ff, $3f, $01, $81
	.byte $ab, $01, $3f, $0d, $00, $0d, $9c, $3f, $80, $02, $56, $03, $39, $00, $01, $98
	.byte $7f, $03, $36, $00, $00, $98, $03, $32, $00, $00, $18, $03, $30, $00, $08, $03
	.byte $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00

VAR music_town_page_23
	.byte $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $04, $08
	.byte $7c, $03, $04, $08, $7a, $03, $01, $08, $30, $03, $00, $08, $03, $00, $08, $03
	.byte $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00
	.byte $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08
	.byte $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $08, $03, $00, $01, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $00, $00, $d0, $3c, $06, $00, $00, $d0, $37, $08, $00
	.byte $00, $c0, $05, $00, $00, $80, $00, $00, $d0, $36, $04, $00, $00, $80, $00, $00
	.byte $c0, $03, $00, $00, $90, $35, $00, $00, $80, $00, $00, $90, $34, $00, $00, $80
	.byte $00, $00, $90, $33, $00, $00, $80, $00, $00, $90, $32, $00, $00, $80, $00, $00
	.byte $90, $31, $00, $00, $80, $00, $00, $10, $30, $00, $00, $00, $00, $00, $00, $00
	.byte $00, $00, $00, $00, $00, $0d, $d0, $ff, $c4, $01, $3c, $06, $00, $0d, $d0, $3f
	.byte $89, $03, $37, $08, $00, $01, $c0, $7f, $05, $00, $00, $80, $00, $00, $d0, $36
	.byte $04, $00, $00, $80, $00, $00, $c0, $03, $00, $00, $90, $35, $00, $00, $80, $00
	.byte $00, $90, $34, $00, $00, $80, $00, $00, $90, $33, $00, $00, $80, $00, $00, $90
	.byte $32, $00, $00, $80, $00, $00, $90, $31, $00, $04, $80, $85, $00, $04, $10, $83

VAR music_town_page_24
	.byte $30, $00, $00, $04, $00, $85, $04, $00, $89, $04, $00, $8b, $00, $00, $04, $02
	.byte $89