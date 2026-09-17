
; NES System Defines
; Contains various register definitions commonly used in NES development


;
; PPU Registers            
;

.define PPU_CTRL $2000
.define PPU_MASK $2001
.define PPU_STATUS $2002
.define OAM_ADDR $2003
.define OAM_DATA $2004
.define PPU_SCROLL $2005
.define PPU_ADDR $2006
.define PPU_DATA $2007
.define OAM_DMA $4014


;
; APU Registers            
;

.define APU_PULSE_1_DUTY $4000
.define APU_PULSE_1_SWEEP $4001
.define APU_PULSE_1_TIMER_LOW $4002
.define APU_PULSE_1_LEN_TIMER $4003
.define APU_PULSE_2_DUTY $4004
.define APU_PULSE_2_SWEEP $4005
.define APU_PULSE_2_TIMER_LOW $4006
.define APU_PULSE_2_LEN_TIMER $4007
.define APU_TRIANGLE_LEN $4008
.define APU_TRIANGLE_TIMER_LOW $400a
.define APU_TRIANGLE_LEN_TIMER $400b
.define APU_NOISE_LEN $400f
.define APU_NOISE_LOOP $400e
.define APU_DMC_IRQ $4010
.define APU_DMC_DIRECT_LOAD $4011
.define APU_DMC_SAMPLE_ADDR $4012
.define APU_DMC_SAMPLE_LEN $4013
.define APU_STATUS $4015
.define APU_FRAME_COUNTER $4017


;
; Controller Registers            
;

.define CTRL_PORT_1 $4016
.define CTRL_PORT_2 $4017

CTRL_BUTTON_A          = %10000000
CTRL_BUTTON_B          = %01000000
CTRL_BUTTON_SELECT     = %00100000
CTRL_BUTTON_START      = %00010000
CTRL_BUTTON_DPAD_UP    = %00001000
CTRL_BUTTON_DPAD_DOWN  = %00000100
CTRL_BUTTON_DPAD_LEFT  = %00000010
CTRL_BUTTON_DPAD_RIGHT = %00000001

CTRL_BUTTON_E = CTRL_BUTTON_SELECT
CTRL_BUTTON_S = CTRL_BUTTON_START
CTRL_BUTTON_U = CTRL_BUTTON_DPAD_UP
CTRL_BUTTON_D = CTRL_BUTTON_DPAD_DOWN
CTRL_BUTTON_L = CTRL_BUTTON_DPAD_LEFT
CTRL_BUTTON_R = CTRL_BUTTON_DPAD_RIGHT

;
; FamiStudio Segments
;
.define FAMISTUDIO_CA65_ZP_SEGMENT   ZEROPAGE
.define FAMISTUDIO_CA65_RAM_SEGMENT  BSS
.define FAMISTUDIO_CA65_CODE_SEGMENT CODE

;
; FamiStudio Global Engine Settings (External only)
;

FAMISTUDIO_CFG_EXTERNAL = 1

; One of these MUST be defined (PAL or NTSC playback). Note that only NTSC support is supported when using any of the audio expansions.
; FAMISTUDIO_CFG_PAL_SUPPORT   = 1
FAMISTUDIO_CFG_NTSC_SUPPORT  = 1

; Support for sound effects playback + number of SFX that can play at once.
FAMISTUDIO_CFG_SFX_SUPPORT   = 1
FAMISTUDIO_CFG_SFX_STREAMS   = 3
SFX_STRINGS = 0

; Blaarg's smooth vibrato technique. Eliminates phase resets ("pops") on square channels. 
; FAMISTUDIO_CFG_SMOOTH_VIBRATO = 1

; Enables DPCM playback support.
FAMISTUDIO_CFG_DPCM_SUPPORT   = 1

; Must be enabled if you are calling sound effects from a different thread than the sound engine update.
; FAMISTUDIO_CFG_THREAD         = 1

;
; Expansion Chips
;

; Konami VRC6 (2 extra square + saw)
; FAMISTUDIO_EXP_VRC6 = 1

; Rainbow-Net (homebrew clone of VRC6)
; FAMISTUDIO_EXP_RAINBOW = 1

; Konami VRC7 (6 FM channels)
; FAMISTUDIO_EXP_VRC7 = 1 

; Nintendo MMC5 (2 extra squares, extra DPCM not supported)
; FAMISTUDIO_EXP_MMC5 = 1 

; Sunsoft S5B (2 extra squares, advanced features not supported.)
; FAMISTUDIO_EXP_S5B = 1 

; Famicom Disk System (extra wavetable channel)
; FAMISTUDIO_EXP_FDS = 1 

; Namco 163 (between 1 and 8 extra wavetable channels) + number of channels.
; FAMISTUDIO_EXP_N163          = 1 
; FAMISTUDIO_EXP_N163_CHN_CNT  = 4

; EPSM (Expansion Port Sound Module)
; FAMISTUDIO_EXP_EPSM          = 1
; Fine-tune control for enabling specific channels
; Default values for the channels are to enable all channels.
; FAMISTUDIO_EXP_EPSM_SSG_CHN_CNT        = 3
; FAMISTUDIO_EXP_EPSM_FM_CHN_CNT         = 6
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN1_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN2_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN3_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN4_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN5_ENABLE = 1
; FAMISTUDIO_EXP_EPSM_RHYTHM_CHN6_ENABLE = 1

;
; FamiStudio Project-Local Engine Settings
;

; ALREADY ENABLED/DEFINED (Ignore if external):
; FAMISTUDIO_USE_RELEASE_NOTES (1)
; FAMISTUDIO_USE_VOLUME_TRACK (1)
; FAMISTUDIO_USE_PITCH_TRACK (1)
; FAMISTUDIO_USE_SLIDE_NOTES (1)
; FAMISTUDIO_USE_NOISE_SLIDE_NOTES (1)
; FAMISTUDIO_USE_VIBRATO (1)
; FAMISTUDIO_USE_ARPEGGIO (1)
; FAMISTUDIO_USE_DUTYCYCLE_EFFECT (1)

; Required flags for Abyssgarding:
FAMISTUDIO_USE_RELEASE_NOTES = 1
FAMISTUDIO_USE_VOLUME_TRACK = 1
FAMISTUDIO_USE_VOLUME_SLIDES = 1
FAMISTUDIO_USE_PITCH_TRACK = 1
FAMISTUDIO_USE_SLIDE_NOTES = 1
FAMISTUDIO_USE_NOISE_SLIDE_NOTES = 1
FAMISTUDIO_USE_VIBRATO = 1
FAMISTUDIO_USE_ARPEGGIO = 1
FAMISTUDIO_USE_DUTYCYCLE_EFFECT = 1
