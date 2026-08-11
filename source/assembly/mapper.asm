;
; UNROM Mapper registers, for use with the functions below
; 
.define UNROM_BANK_SELECT $8000

.segment "CODE"

    ; Bank table, used to 
    unrom_banktable:
        .byte $00, $01, $02, $03, $04, $05, $06, $07
        .byte $08, $09, $0a, $0b, $0c, $0d, $0e, $0f


    ; Set the prg bank to be used.
    unrom_set_prg_bank:
    _unrom_set_prg_bank:
        tax 
        sta unrom_banktable, x
        rts 
    .export _unrom_set_prg_bank

    initialize_mapper:
        ; Start in bank 0
        lda #0
        jsr unrom_set_prg_bank
        rts 

; Make sure to put something in every bank, so the library doesn't get confused. Let's just jump to reset.
.segment "ROM_00" 
    jmp reset
.segment "ROM_01" 
    jmp reset
.segment "ROM_02" 
    jmp reset
.segment "ROM_03" 
    jmp reset
.segment "ROM_04" 
    jmp reset
.segment "ROM_05" 
    jmp reset
.segment "ROM_06" 
    jmp reset
.segment "ROM_07" 
    jmp reset
.segment "ROM_08" 
    jmp reset
.segment "ROM_09" 
    jmp reset
.segment "ROM_10" 
    jmp reset
.segment "ROM_11" 
    jmp reset
.segment "ROM_12" 
    jmp reset
.segment "ROM_13" 
    jmp reset
.segment "ROM_14" 
    jmp reset


