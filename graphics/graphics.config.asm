
;
; CHR Data
;
; The files below are currently loaded into your game's prg banks, and have to be loaded
; manually in your code. 
; 
; You will probably want to add compression to this data, since you have limited space!
; It also is a good idea to move this to a prg bank other than the primary.
;

.segment "CODE"
    
    ; background_graphics:
    ;     .incbin "./background.chr"
    ; sprite_graphics:
    ;     .incbin "./sprite.chr"
    bg0: .incbin "./background.chr"
    spr0: .incbin "./sprite.chr"

;
; Make sure to export all symbols created, too, so we can read them from our code!
;
.export bg0
.export spr0
