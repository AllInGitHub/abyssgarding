;
; main.asm
;
; The entrypoint to your game! 
; Everything you will write should go into files included in this file, 
; or of course this file itself.
; 
; Note: Much of this was lifted and adapted from the nerdy nights tutorials
; https://nerdy-nights.nes.science

.include "sound/sfx_men_sfxlist.inc"

; System defines for various registers on the console
.include "./system-defines.asm"
.include "./mapper.asm"

;
; Enums and Structs
;

.enum States
	blank ; Empty
	mainmenu ; Menu Screen
	settings ; Settings Screen (Before starting the game)
	abyssMap ; Map of a world
	abyssMenus ; Menu of a world's level beore it loads
	abyssLevels ; The main gameplay state
.endenum

.enum Worlds
	abyss0 ; Tutorial Stage
	abyss1 ; Underworld/Abyss Levels
	abyss2 ; Underground Levels
	abyss3 ; Underwater Levels
	abyss4 ; Overseas/Above Water Levels
	abyss5 ; Overworld/Above Ground Levels
	abyss6 ; Castle Levels
.endenum

.struct Velocity
	velx .byte ; X Velocity (Signed 8-bit Byte)
	vely .byte ; Y Velocity (Signed 8-bit Byte)
	prx .word ; Result Point X (Signed 16-bit Fixed-Point Word (4-bit density))
	pry .word ; Result Point Y (Signed 16-bit Fixed-Point Word (4-bit density))
.endstruct

.struct RomPtr
	ptr .word ; Low then High
	bank .byte ; >= $F means do not change
.endstruct

.struct Level
	world .byte
	offset .byte
	pointer .tag RomPtr
.endstruct

;
; iNES header
; 
; This declares basic information about your game. You probably don't want
; to change it.
;
.segment "HEADER"

	INES_MAPPER = 2 ; 2 = unrom
	INES_MIRROR = 1 ; 0 = horizontal mirroring, 1 = vertical mirroring
	INES_SRAM   = 1 ; 1 = battery backed SRAM at $6000-7FFF

	.byte 'N', 'E', 'S', $1A ; ID
	.byte 16 ; 16k PRG chunk count
	.byte 0 ; 8k CHR chunk count
	.byte INES_MIRROR | (INES_SRAM << 1) | ((INES_MAPPER & $f) << 4)
	.byte (INES_MAPPER & %11110000)
	.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding

;
; Graphics
; 
; Includes chr files for the graphics - see the included file for more details.
;

.include "../../graphics/graphics.config.asm"

;
; Vectors
; 
; These definitions have to be kept here so the NES knows how to reset the game, and what to call when
; it's time to redraw the screen. 
;

.segment "VECTORS"
	.word nmi
	.word reset
	.word irq

;
; ZeroPage variables 
; 
; This is a section of "special" variables that can be accessed faster than the rest, because they are in the first "page" of
; memory. It can have up to 256 bytes worth of variables in it. They otherwise work the same as all other variables.
;

.segment "ZEROPAGE"
	backgroundPointerLo: .res 1    ; pointer variables declared in RAM
	backgroundPointerHi: .res 1    ; low byte first, high byte immediately after
	; palPtr: .res 2 ; Low then High
	chrramPtr: .res 2 ; Low then High
	nmiFrameCount: .res 1          ; 256 byte counter, will increment every time nmi is called. Used to wait for vblank
	vblankPreviousFrame: .res 1    ; Used to track when we started waiting for vblank
	fwmcstates: .res 2 ; fwmcstates+0 for Fuwawa; fwmcstates+1 for Mococo
	gamestate: .res 1
	gamestatereq: .res 1
	dynamicJumpAddr: .res 3 ; Low then High then Bank Number
	jumpTableLoBytesPtr: .res 3 ; Low then High then Bank Number
	jumpTableHiBytesPtr: .res 3 ; Low then High then Bank Number
	fuwavel: .tag Velocity
	mocovel: .tag Velocity
	choice: .res 1
	arrowLeftPosPtr:  .tag RomPtr
	arrowRightPosPtr: .tag RomPtr
	arrowYPosPtr:     .tag RomPtr
	; Shorthands
	fuwastate = fwmcstates+0
	mocostate = fwmcstates+1
	dynamicJumpPtrLO   = dynamicJumpAddr+0
	dynamicJumpPtrHI   = dynamicJumpAddr+1
	dynamicJumpPtrBank = dynamicJumpAddr+2
;
; OAM Memory
; 
; This is the sprite memory for your game. IT is used for "hardware" sprites (you might create more information for your)
; sprites elsewhere. Don't add anything here.
;
; Note: This game doesn't shuffle anything in OAM!
;

.segment "OAM"
	oam: .res 256        ; sprite OAM data to be uploaded by DMA
	; Objects: Title Screen
	oam_arrowLeft  = oam+4
	oam_arrowRight = oam+8

;
; BSS variables
; 
; This is the "rest" of the memory for your game. There are about 1500 bytes available in total.

.segment "BSS"
; yourvariable: .res 8
	buttons: .res 1
	lastButtons: .res 1
	pressedButtons: .res 1
	testVariable: .res 1
	justGamestateChanged: .res 1
	arrowsFrame: .res 1

;
; Batery Backed SRAM variables
;
; This is basically the game's save file, but in the late 1980s and
; early 1990s
;

.segment "SRAM"
	gameLearned: .res 1

.if INES_SRAM+INES_MIRROR+INES_MAPPER <> 4
	.error "LEAVE THE FUCKING HEADER ALONE!"
.elseif INES_SRAM <> 1 || INES_MIRROR <> 1 || INES_MAPPER <> 2
	.error "Nice try! LEAVE THE FUCKING HEADER ALONE!"
.else
	; "Header is valid!"
.endif

FAMISTUDIO_DPCM_OFF = dmc

.segment "CODE"
.include "./famistudio/famistudio_ca65.s"
.include "./sound/sfx_men.s"
; 
; Main Code area
; 
; You know this one! This is the primary code bank for your game. There may be more banks available, but this 
; one will always be loaded. 
;

.segment "CODE"
	.macro switchState
		sta gamestatereq
	.endmacro

	.macro choiceCap max
		lda choice
			cmp #0
			bmi :++
				lda choice
				cmp #max+1
				bcc :+
					ldx #max
					stx choice
					jsr playInvalidSFX
				:
				jmp @end
			:
				ldx #0
				stx choice
				jsr playInvalidSFX
	.endmacro

	.macro loadMusic ptr
		ldx #<ptr
		ldy #>ptr
		jsr famistudio_init
	.endmacro
	.macro playLoadedMusic
		lda #0
		jsr famistudio_music_play
	.endmacro

	.macro playSFX idLoadedBank, streamChannel
		ldx #streamChannel
		lda #idLoadedBank
		jsr famistudio_sfx_play
	.endmacro

	.proc nothing
		nop ; Vibe check
		rts 
	.endproc

	;
	; reset routine
	;
	; This is used to reset the NES (and sometimes memory on your cartridge) to a known state, so the game
	; can play consistently. Don't change this unless you know what you're doing!
	; Note: It should be the first thing written to the CODE segment, so it's always the first thing the console runs!
	;
	reset:
		sei       ; mask interrupts
		lda #0
		sta PPU_CTRL    ; disable NMI
		sta PPU_MASK    ; disable rendering
		sta APU_STATUS  ; disable APU sound
		sta APU_DMC_IRQ ; disable DMC IRQ
		lda #$40
		sta APU_FRAME_COUNTER ; disable APU IRQ
		cld                   ; disable decimal mode
		ldx #$FF
		txs       ; initialize stack
		; wait for first vblank
		bit PPU_STATUS
		:
			bit PPU_STATUS
			bpl :-
		; clear all RAM to 0
		lda #0
		tax 
		:
			sta $0000, x ; Clears Zeropage
			sta $0100, x ; Clears Stack(?)
			sta $0200, x ; Clears OAM
			; Clear BSS
			sta $0300, x
			sta $0400, x
			sta $0500, x
			sta $0600, x
			sta $0700, x
			inx 
			bne :-
		; place all sprites offscreen at Y=255
		lda #255
		ldx #0
		:
			sta oam, x
			inx 
			inx 
			inx 
			inx 
			bne :-
		; wait for second vblank
		:
			bit PPU_STATUS
			bpl :-

		; Do any initialization the mapper needs
		jsr initialize_mapper

		; NES is initialized, ready to begin!
		lda #255
		ldx #<music_data_preabyss_title
		ldy #>music_data_preabyss_title
		jsr famistudio_init
		jsr switchToMenu

		; enable the NMI for graphical updates, and jump to our main program
		lda #%10001000
		sta PPU_CTRL
		lda #States::mainmenu
		switchState
		jmp main

	.proc playInvalidSFX
		ldx #FAMISTUDIO_SFX_CH1
		lda #sfx_no
		jsr famistudio_sfx_play
		rts 
	.endproc

	.proc bankFloop
		clc 
		clv 

		lda pressedButtons
		tay 
		beq @end
		and #CTRL_BUTTON_S|CTRL_BUTTON_A
		bne @doOptionThing
		jmp :+
		@invalid:
			jsr playInvalidSFX
			jmp @end
		:

		tya 
		and #CTRL_BUTTON_D
		beq :+
			inc choice
			playSFX sfx_scroll_menu, FAMISTUDIO_SFX_CH1
			jmp @checkChoice
		:

		tya 
		and #CTRL_BUTTON_U
		beq :+
			dec choice
			playSFX sfx_scroll_menu, FAMISTUDIO_SFX_CH1
			jmp @checkChoice
		:

		jmp @invalid

		jmp @skipOptionThing
		@doOptionThing:
			ldx choice
			beq @stateSwitchSettings
			cpx #1
			beq :+
			@stateSwitchSettings:
				lda #States::settings
				sta gamestatereq
				jmp :++
			:
				jmp @invalid
			:
		@skipOptionThing:

		; Do Vibe Check
		lda nothing
		cmp #$EA
		beq :+
			lda nmiFrameCount
			sta PPU_SCROLL
			lda #0
			sta PPU_SCROLL
			.byte $02 ; Vibe Check Fail
			brk 
		: ; Vibe Check Pass!
		jmp @end
		@checkChoice:
			; lda choice
			; cmp #0
			; bmi :++
			; 	lda choice
			; 	cmp #3
			; 	bcc :+
			; 		ldx #2
			; 		stx choice
			; 		jmp @invalid
			; 	:
			; 	jmp @end
			; :
			; 	ldx #0
			; 	stx choice
			; 	jmp @invalid
			choiceCap 2
		@end:
		ldx #<title_leftArrowPositions
		ldy #>title_leftArrowPositions
		stx arrowLeftPosPtr+0
		sty arrowLeftPosPtr+1
		
		ldx #<title_rightArrowPositions
		ldy #>title_rightArrowPositions
		stx arrowRightPosPtr+0
		sty arrowRightPosPtr+1
		
		ldx #<title_arrowYPositions
		ldy #>title_arrowYPositions
		stx arrowYPosPtr+0
		sty arrowYPosPtr+1

		; jsr processArrows
		; rts 
		jmp processArrows
	.endproc

	.proc settings
		lda justGamestateChanged
		beq :+
			lda #<settingsBG
			sta backgroundPointerLo
			lda #>settingsBG
			sta backgroundPointerHi
			jsr updateNT
			loadMusic music_data_abyssmodding_settings
			playLoadedMusic
		:
		rts 
	.endproc

	.proc switchToMenu
		ldx #<sounds_menu
		ldy #>sounds_menu
		jsr famistudio_sfx_init
		rts 
	.endproc

	.ifdef sounds_game
	.proc switchToGame
		ldx #<sounds_game
		ldy #>sounds_game
		jsr famistudio_sfx_init
		rts 
	.endproc
	.endif

	.proc processArrows
		lda nmiFrameCount
		and #%1111
		bne :+
			ldx arrowsFrame
			inx 
			txa 
			and #%11
			sta arrowsFrame
		:
		ldx #$10
		ldy #%01000000
		stx oam_arrowLeft+1
		stx oam_arrowRight+1
		sty oam_arrowRight+2

		ldy choice
		; asl a
		; tay 
		ldx arrowsFrame

		sec 
		lda (arrowLeftPosPtr), y
		sbc arrowAnimationOffsets, x
		sta oam_arrowLeft+3
		lda (arrowYPosPtr), y
		sta oam_arrowLeft+0

		clc 
		lda (arrowRightPosPtr), y
		adc arrowAnimationOffsets, x
		sta oam_arrowRight+3
		lda (arrowYPosPtr), y
		sta oam_arrowRight+0
		rts 
	.endproc

	;
	; Main entrypoint
	; 
	; This is the "start" of your game. It is the very first thing that is run after power on.
	; You'll often want to put a logic loop here, or something like that.
	; 

	main:

		; First write palettes that we define later on in the file. This will write
		; both the nametable and sprite palettes.
		lda #<palette
		sta chrramPtr
		lda #>palette
		sta chrramPtr+1
		jsr updatePal

		; Next we'll update the CHRRAM because this uses UNROM
		lda #<bg0
		sta chrramPtr
		lda #>bg0
		sta chrramPtr+1
		jsr updateUnromCHRRAM

		; Then, we will update the nametables
		lda #<background
		sta backgroundPointerLo
		lda #>background
		sta backgroundPointerHi
		jsr updateNT_SkipPPUDisable ; Skip PPU Off because PPU is already off

		; Set testVariable to 1 for unit tests
		lda #1
		sta testVariable

		lda #0
		; sta justGamestateChanged
		jsr famistudio_music_play

		loop_de_forever:
		; After getting through the drawing, just run an infinite loop. Effectively crashes the game on the new screen.
		@forever:
			ldx #<jumpTableLO
			ldy #<jumpTableHI
			stx jumpTableLoBytesPtr+0
			sty jumpTableHiBytesPtr+0
			ldx #>jumpTableLO
			ldy #>jumpTableHI
			stx jumpTableLoBytesPtr+1
			sty jumpTableHiBytesPtr+1
			jsr dynamicJump

			jsr vblankwait
			jmp @forever

	.proc dynamicJump
		ldx #0
		stx justGamestateChanged
		; Phase 1: Selection
		ldy gamestatereq
		pha 
		tya 
		tax 
		pla 
		cpx gamestate
			beq :+
			ldx #1
			stx justGamestateChanged
		:
		sty gamestate
		; Phase 2: Lookup
		lda (jumpTableLoBytesPtr), y
		sta dynamicJumpAddr+0
		lda (jumpTableHiBytesPtr), y
		sta dynamicJumpAddr+1

		lda dynamicJumpAddr+1
		pha 
		dec dynamicJumpAddr+0
		lda dynamicJumpAddr+0
		pha 
		; Phase 3: Branching/Jumping - RTS Manipulation
		@skip:
		rts 
	.endproc

	.proc pollInput
		; Hippity Hoppity, your 6502 CA65 ASM code is now my property (From https://www.nesdev.org/wiki/Controller_reading_code)
		lda #$01
		; While the strobe bit is set, buttons will be continuously reloaded.
		; This means that reading from CTRL_PORT_1 will only return the state of the
		; first button: button A.
		sta CTRL_PORT_1
		sta buttons
		lsr a        ; now A is 0
		; By storing 0 into CTRL_PORT_1, the strobe bit is cleared and the reloading stops.
		; This allows all 8 buttons (newly reloaded) to be read from CTRL_PORT_1.
		sta CTRL_PORT_1
		@loop:
			lda CTRL_PORT_1
			lsr a        ; bit 0 -> Carry
			rol buttons  ; Carry -> bit 0; bit 7 -> Carry
			bcc @loop
		rts 
	.endproc

	.proc pollInputSafe
		lda buttons
		sta lastButtons
		jsr pollInput
		@reread:
			lda buttons
			pha 
			jsr pollInput
			pla 
			cmp buttons
			bne @reread
		lda buttons
		eor lastButtons
		and buttons
		sta pressedButtons
		rts 
	.endproc

	;
	; NMI Handler
	; 
	; This will run once every frame, and give you a chance to update graphics. Keep it short!
	;

	nmi:
		; Store all registers - since this can run at any time, and any changes we make to the registers
		; will impact whatever code was running before otherwise. 
		pha 
		txa 
		pha 
		tya 
		pha 

		; Tell the ppu to draw sprites from $0200 to the screen
		lda #$02
		sta OAM_DMA

		; Keep track of how many frames have run (note: this loops over to 0 after 255.)
		inc nmiFrameCount

		; Update sound engine
		jsr famistudio_update

		; Poll the conlorllers
		jsr pollInputSafe

		; Restore all registers from the stack
		pla 
		tay 
		pla 
		tax 
		pla 

		rti ; Return from interrupt 


	; 
	; Helper function: Wait for a vblank to happen
	; 
	; Waits until the frame count is incremented by the nmi method
	; 

	vblankwait:
		lda nmiFrameCount
		sta vblankPreviousFrame

		@vblank_wait:
			cmp nmiFrameCount
			beq @vblank_wait
		clc 
		clv 
		rts 
	; 
	; IRQ Handler
	;
	; Empty - we don't need to use them, but a handler must be present.
	irq:
		jmp reset
		rti 

	updateUnromCHRRAM:
		; Next we need to load graphics data into the chr ram, so we see something on the screen. So, let's use nested 
		; loops to copy that all over. 
		; NOTE: This copies both the background and sprite graphics at once, since we store them in prg in sequence. 
		; If you want to break them up, change the `cpx #$20` line below to be `cpx #$10` to only copy 4kb then repeat
		; the code again with a new address!
		lda PPU_STATUS ; read ppu status to reset the high/low latch
		lda #0
		sta PPU_ADDR ; Write the high byte
		sta PPU_ADDR ; Write 0 to the low byte as well, since we want to start at $0000
		ldx #$00                ; start at pointer + 0
		ldy #$00
		@ramOutsideLoop:

			@ramInsideLoop:
				lda (chrramPtr),Y       ; copy one background byte from address in pointer + Y
				sta PPU_DATA            ; runs 256*32=8192 times

				iny                     ; inside loop counter
				cpy #$00                
				bne @ramInsideLoop         ; run inside loop 256 times before continuing

			inc chrramPtr+1     ; low byte went from 0 -> 256, so high byte needs to be changed now

			inx                     ; increment outside loop counter
			cpx #$20                ; needs to happen $20 times, to copy 8KB data
			bne @ramOutsideLoop
		rts 

	updateNT:
		; Disable everything
		lda #0
		sta PPU_CTRL
		sta PPU_MASK
	updateNT_SkipPPUDisable:
		lda #$20
		sta PPU_ADDR
		lda #$00
		sta PPU_ADDR
		ldx #$08
		ldy #$00
		lda #$00 ; clear background tile
		@nametableWriteLoop:
			sta PPU_DATA
			dey 
			bne @nametableWriteLoop
			dex 
			bne @nametableWriteLoop

					
		; Use nested loops to load the background efficiently
		lda PPU_STATUS          ; read PPU status to reset the high/low latch
		lda #$20
		sta PPU_ADDR            ; write high byte of $2000 address
		lda #$00
		sta PPU_ADDR            ; write low byte of $2000 address

		; lda testVariable
		; bne :+
		; lda #<background 
		; sta backgroundPointerLo ; put the low byte of address of background into pointer
		; lda #>background        ; #> is the same as HIGH() function in NESASM, used to get the high byte
		; sta backgroundPointerHi ; put high byte of address into pointer
		; :

		ldx #$00                ; start at pointer + 0
		ldy #$00
		@outsideLoop:

			@insideLoop:
				lda (backgroundPointerLo),Y       ; copy one background byte from address in pointer + Y
				sta PPU_DATA            ; runs 256*4=1024 times

				iny                     ; inside loop counter
				cpy #$00                
				bne @insideLoop         ; run inside loop 256 times before continuing

			inc backgroundPointerHi     ; low byte went from 0 -> 256, so high byte needs to be changed now

			inx                     ; increment outside loop counter
			cpx #$04                ; needs to happen 4 times, to copy 1KB data
			bne @outsideLoop         


		; Reset ppu scrolling by writing 0 to both the X and Y positions.
		lda #0
		sta PPU_SCROLL
		sta PPU_SCROLL
		; Re-enable everything to show the graphics again.
		cli             ; Re-enable interrupts
		lda #%10001000  ; enable NMI, sprites from pattern table 1, background from 0
		sta PPU_CTRL
		lda #%00011110  ; background and sprites enable, no left clipping
		sta PPU_MASK
		rts 

	updatePal:
		; Next we'll write palettes that we define later on in the file. This will write
		; both the nametable and sprite palettes.
		lda PPU_STATUS
		lda #$3f
		sta PPU_ADDR
		lda #$00
		sta PPU_ADDR
		ldy #$00
		@loadPalettesLoop:
			lda (chrramPtr),y ; load data from adddress (palette + y)
							  ; 1st time through loop it will load palette+0
							  ; 2nd time through loop it will load palette+1
							  ; 3rd time through loop it will load palette+2
							  ; etc
			sta PPU_DATA
			iny 
			cpy #$20
			bne @loadPalettesLoop
		rts 

	.proc resetOAMSprite
		pha 
		asl a
		asl a
		pla 
		tax 
		and #3
		tay 
		:
			lda oamNull, y
			sta oam, x
			dey 
			dex 
			beq :-
		rts 
	.endproc

	.proc resetOAM
		lda #0
		:
			pha 
			jsr resetOAMSprite
			pla 
			tax 
			inx 
			tay 
			cmp #64
			bcc :-
		rts 
	.endproc

	;
	; Data
	; 
	; Game data is in this section. It's in the same code bank as above, and is only separated to make it easier to understand.
	;

	oamNull:
		; Null Sprite contains:
		;	Y position of 255 (offscreen)
		;	Sprite Tile #0 (VRAM $0000-$0001 or $1000-$1001 depending
		;		on PPU_CTRL's settings)
		;	Attributes %0000 0000 (Not flipped either axis, In front of
		;		Nametables, colored using pallete 0 (1/4))
		;	X position of 0
		;
		; Did I realy just glaze over four bytes?

		.byte $FF, $00, $00, $00

	arrowAnimationOffsets:
		.byte 0, 1, 2, 1

	; Include the nametable data as a binary file
	background:
		.incbin "../../graphics/title.nam"
	
	; Do the same with palettes
	palette:
		; Foreground first
		.incbin "../../graphics/palette.pal"
		; Next, background. We don't have two palettes created, so repeat the same palette for now
		; .incbin "../../graphics/example.pal"

	dmc:
		.incbin "./sound/abyssgarding_dmc.dmc"

	jumpTableLO:
		.lobytes nothing, bankFloop, settings, nothing, nothing, nothing
	jumpTableHI:
		.hibytes nothing, bankFloop, settings, nothing, nothing, nothing
	
	; initJumpTableLO:
	; 	.lobytes nothing, nothing, nothing, nothing, nothing, nothing
	; initJumpTableHI:
	; 	.hibytes nothing, nothing, nothing, nothing, nothing, nothing
	; initJumpTableBank:
	; 	.byte $FF, $F, $FF

.segment "ROM_00"
	bank0loop:
		rts 
	.include "./sound/music_abyssgarding_preabyss_title.s"
	.include "./sound/music_abyssgarding_abyssmodding_settings.s"
	title_leftArrowPositions:
		.byte 104;, 127
		.byte 80;, 151
		.byte 88;, 159
	title_rightArrowPositions:
		.byte 153;, 127
		.byte 169;, 151
		.byte 161;, 159
	title_arrowYPositions:
		.byte 127
		.byte 143
		.byte 159

	setting_leftArrowPositions:
		.byte 255;, 127
		.byte 72;, 151
		.byte 88;, 159
	setting_rightArrowPositions:
		.byte 177;, 127
		.byte 145;, 151
		.byte 161;, 159
	setting_arrowYPositions:
		.byte 95
		.byte 111
		.byte 159

	settingsBG:
		.incbin "../../graphics/settings.nam"
.segment "ROM_01"
	bank1loop:
		rts 
.segment "ROM_02"
	bank2loop:
		rts 
.segment "ROM_03"
	bank3loop:
		rts 
.segment "ROM_04"
	bank4loop:
		rts 
.segment "ROM_05"
	bank5loop:
		rts 
.segment "ROM_06"
	bank6loop:
		rts 
.segment "ROM_07"
	bank7loop:
		rts 
.segment "ROM_08"
	bank8loop:
		rts 
.segment "ROM_09"
	bank9loop:
		rts 
.segment "ROM_10"
	bankAloop:
		rts 
.segment "ROM_11"
	bankBloop:
		rts 
.segment "ROM_12"
	bankCloop:
		rts 
.segment "ROM_13"
	bankDloop:
		rts 
.segment "ROM_14"
	bankEloop:
		rts 

