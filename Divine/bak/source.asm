; ============================================================
; DIVINE DEMO - C64
; ============================================================
; Minneskarta:
;   $0801-$080C  BASIC-stub
;   $080D-$0FFF  Kod
;   $1006-$3022  SID-musik
;   $3200-$3DFF  SINTBL + kod-data
;   $3E00-$3FFF  Spritedata (Källkod-data)
;   ; --- VIC BANK 1 ($4000-$7FFF) ---
;   $4000-$5F3F  Bitmap (8000 bytes)
;   $6000-$63E7  Skärmminne / Video-RAM (1000 bytes)
;   $63F8-$63FF  Sprite-pekare (Ligger i slutet av Video-RAM!)
;   $7E00-$7FFF  Spritedata (VIC:s måladress för block 248-255)
;   ; --- Färg-RAM (Fast adress i C64) ---
;   $D800-$DBE7  Färg-RAM (1000 bytes)
; ============================================================

; --- VIC-II ---
SPRPOS   = $D000
SPRX_MSB = $D010
SPREN    = $D015
SPRDBL_Y = $D017
SPRCOL   = $D027
BORDER   = $D020
BGCOL    = $D021
VICCTRL  = $D011
VICCTRL2 = $D016
RASTER   = $D012
VICIRQ   = $D019
VICICR   = $D01A
VICMEM   = $D018

; --- CIA2 (VIC-bank) ---
CIA2PRA  = $DD00

; --- CIA ---
CIAICR   = $DC0D
CIA2ICR  = $DD0D

; --- SID ---
SID_INIT = $1103
SID_PLAY = $1006

; ============================================================
; BASIC-stub på $0801 (SYS 2061)
; ============================================================
        *= $0801
        BYTE $0C,$08,$0A,$00,$9E,$32,$30,$36,$31,$00,$00,$00

; ============================================================
; KODEN STARTAR HÄR ($080D)
; ============================================================
        *= $080D

START
        SEI

        ; Stäng av CIA1 och CIA2 IRQ
        LDA #$7F
        STA CIAICR
        STA CIA2ICR
        LDA CIAICR          ; Kvittera pending IRQ
        LDA CIA2ICR

        ; Svart ram och bakgrund
        LDA #$00
        STA BORDER
        STA BGCOL

        ; Byt till VIC bank 1 ($4000-$7FFF)
        LDA CIA2PRA
        AND #$FC
        ORA #$02
        STA CIA2PRA

        ; Sätt VIC-minne: bitmap @ $4000 (bit3=0), skärm @ $6000 (bits7-4=%1000)
        LDA #$80
        STA VICMEM

        ; Aktivera multicolor bitmap-läge
        LDA VICCTRL
        ORA #$20            ; Bit 5 = BMM (bitmap mode)
        STA VICCTRL
        LDA VICCTRL2
        ORA #$10            ; Bit 4 = MCM (multicolor)
        STA VICCTRL2

        ; Kopiera bitmap till $4000 (8000 bytes)
        LDY #$00
BMP_LP1
        LDA BITMAPDATA+$000,Y
        STA $4000,Y
        LDA BITMAPDATA+$100,Y
        STA $4100,Y
        LDA BITMAPDATA+$200,Y
        STA $4200,Y
        LDA BITMAPDATA+$300,Y
        STA $4300,Y
        LDA BITMAPDATA+$400,Y
        STA $4400,Y
        LDA BITMAPDATA+$500,Y
        STA $4500,Y
        LDA BITMAPDATA+$600,Y
        STA $4600,Y
        LDA BITMAPDATA+$700,Y
        STA $4700,Y
        INY
        BNE BMP_LP1

        LDY #$00
BMP_LP2
        LDA BITMAPDATA+$800,Y
        STA $4800,Y
        LDA BITMAPDATA+$900,Y
        STA $4900,Y
        LDA BITMAPDATA+$A00,Y
        STA $4A00,Y
        LDA BITMAPDATA+$B00,Y
        STA $4B00,Y
        LDA BITMAPDATA+$C00,Y
        STA $4C00,Y
        LDA BITMAPDATA+$D00,Y
        STA $4D00,Y
        LDA BITMAPDATA+$E00,Y
        STA $4E00,Y
        LDA BITMAPDATA+$F00,Y
        STA $4F00,Y
        INY
        BNE BMP_LP2

        LDY #$00
BMP_LP3
        LDA BITMAPDATA+$1000,Y
        STA $5000,Y
        LDA BITMAPDATA+$1100,Y
        STA $5100,Y
        LDA BITMAPDATA+$1200,Y
        STA $5200,Y
        LDA BITMAPDATA+$1300,Y
        STA $5300,Y
        LDA BITMAPDATA+$1400,Y
        STA $5400,Y
        LDA BITMAPDATA+$1500,Y
        STA $5500,Y
        LDA BITMAPDATA+$1600,Y
        STA $5600,Y
        LDA BITMAPDATA+$1700,Y
        STA $5700,Y
        INY
        BNE BMP_LP3

        LDY #$00
BMP_LP4
        LDA BITMAPDATA+$1800,Y
        STA $5800,Y
        LDA BITMAPDATA+$1900,Y
        STA $5900,Y
        LDA BITMAPDATA+$1A00,Y
        STA $5A00,Y
        LDA BITMAPDATA+$1B00,Y
        STA $5B00,Y
        LDA BITMAPDATA+$1C00,Y
        STA $5C00,Y
        LDA BITMAPDATA+$1D00,Y
        STA $5D00,Y
        LDA BITMAPDATA+$1E00,Y
        STA $5E00,Y
        LDA BITMAPDATA+$1F00,Y
        STA $5F00,Y
        INY
        BNE BMP_LP4

        ; Kopiera skärmdata till $6000 (1000 bytes)
        LDX #$00
SCR_LOOP
        LDA SCREENDATA,X
        STA $6000,X
        INX
        CPX #$E8
        BNE SCR_LOOP
        LDX #$00
SCR_LOOP2
        LDA SCREENDATA+$E8,X
        STA $60E8,X
        INX
        CPX #$E8
        BNE SCR_LOOP2
        LDX #$00
SCR_LOOP3
        LDA SCREENDATA+$1D0,X
        STA $61D0,X
        INX
        CPX #$E8
        BNE SCR_LOOP3
        LDX #$00
SCR_LOOP4
        LDA SCREENDATA+$2B8,X
        STA $62B8,X
        INX
        CPX #$88
        BNE SCR_LOOP4

        ; Kopiera färg-RAM till $D800 (1000 bytes)
        LDX #$00
CLR_LOOP
        LDA COLORDATA,X
        STA $D800,X
        INX
        CPX #$E8
        BNE CLR_LOOP
        LDX #$00
CLR_LOOP2
        LDA COLORDATA+$E8,X
        STA $D8E8,X
        INX
        CPX #$E8
        BNE CLR_LOOP2
        LDX #$00
CLR_LOOP3
        LDA COLORDATA+$1D0,X
        STA $D9D0,X
        INX
        CPX #$E8
        BNE CLR_LOOP3
        LDX #$00
CLR_LOOP4
        LDA COLORDATA+$2B8,X
        STA $DAB8,X
        INX
        CPX #$88
        BNE CLR_LOOP4

        ; Aktivera alla 8 sprites med normala proportioner (ingen Y-expansion)
        LDA #$FF
        STA SPREN

        ; Sätt alla spritefärger till svart initialt
        LDA #$00
        LDX #$00
COL_LOOP
        STA SPRCOL,X
        INX
        CPX #$08
        BNE COL_LOOP
        ; Peka sprite-pekare i det sista 8 bytes-blocket av skarmminnets 1K-omrade
        ; ($6000 + $3F8 = $63F8), vilket ar dar VIC-II faktiskt laser pekarna.
        LDX #$00
SPR_PTR
        TXA
        CLC
        ADC #$F8
        STA $63F8,X
        INX
        CPX #$08
        BNE SPR_PTR
        LDX #$00
SPR_CP1
        LDA SPRITEDATA,X
        STA $7E00,X
        INX
        BNE SPR_CP1
        ; Pass 2: $7F00-$7FFF
        LDX #$00
SPR_CP2
        LDA SPRITEDATA+$100,X
        STA $7F00,X
        INX
        BNE SPR_CP2

        ; Sätt start-X-positioner för alla sprites
        LDX #$00
INIT_POS
        LDA SPR_X,X
        STA SPRPOS,X
        INX
        CPX #$10
        BNE INIT_POS

        ; Sprite 6 och 7 behöver MSB p.g.a. 8-bit X-limit
        LDA #%11000000
        STA SPRX_MSB

        ; Initiera SID
        LDA #$00
        JSR SID_INIT

        ; Konfigurera raster-IRQ på rad 150
        LDA VICCTRL
        AND #$7F
        STA VICCTRL
        LDA #150
        STA RASTER

        ; Koppla in vår IRQ-rutin
        LDA #<IRQ
        STA $0314
        LDA #>IRQ
        STA $0315

        ; Aktivera och kvittera raster-IRQ
        LDA #$01
        STA VICICR
        STA VICIRQ

        CLI

; ============================================================
; MAINLOOP
; ============================================================
MAIN
        JMP MAIN

; ============================================================
; IRQ-rutin
; ============================================================
IRQ
        PHA
        TXA
        PHA
        TYA
        PHA

        LDA #$01
        STA VICIRQ          ; Kvittera VIC IRQ

        JSR SID_PLAY        ; Spela musik
        JSR MUSIC           ; Hantera loop
        JSR MOVE            ; Uppdatera sprites
        JSR FADE            ; Tona spritefärger

        PLA
        TAY
        PLA
        TAX
        PLA
        JMP $EA81           ; Återgå via KERNAL

; ============================================================
; MOVE - sinusvåg på Y
; ============================================================
MOVE
        INC PHASE

        LDX #$00
MOVE_LOOP
        TXA
        ASL A               ; Gånger 2 för att stega rätt i sinus-offseten per sprite
        ASL A
        ASL A
        CLC
        ADC PHASE
        TAY
        LDA SINTBL,Y
        STA SPRPOS+1,X      ; Skriv till Y-registret för sprite (1, 3, 5, 7...)
        INX
        INX
        CPX #$10
        BNE MOVE_LOOP
        RTS

PHASE   BYTE $00

; ============================================================
; MUSIC - frame-räknare och loop
; ============================================================
MUSIC_LEN_LO = $B6      
MUSIC_LEN_MI = $0D      
MUSIC_LEN_HI = $00      

MUSIC
        INC FRMCNT_LO
        BNE MUSIC_NO_CARRY
        INC FRMCNT_MI
        BNE MUSIC_NO_CARRY
        INC FRMCNT_HI
MUSIC_NO_CARRY
        LDA FRMCNT_HI
        CMP #MUSIC_LEN_HI
        BCC MUSIC_DONE      
        BNE MUSIC_RESET     
        LDA FRMCNT_MI
        CMP #MUSIC_LEN_MI
        BCC MUSIC_DONE
        BNE MUSIC_RESET
        LDA FRMCNT_LO
        CMP #MUSIC_LEN_LO
        BCC MUSIC_DONE
MUSIC_RESET
        LDA #$00
        STA FRMCNT_LO
        STA FRMCNT_MI
        STA FRMCNT_HI
        LDA #$00
        JSR SID_INIT
MUSIC_DONE
        RTS

FRMCNT_LO BYTE $00
FRMCNT_MI BYTE $00
FRMCNT_HI BYTE $00

; ============================================================
; FADE - tonar spritefärger
; ============================================================
FADE
        INC FADECOUNT
        LDA FADECOUNT
        AND #$03            
        BNE FADE_DONE

        LDX #$00
FADE_LOOP
        INC FADEPHASE,X     
        LDA FADEPHASE,X
        AND #$1F            
        STA FADEPHASE,X
        TAY
        LDA FADETBL,Y       
        STA SPRCOL,X        
        INX
        CPX #$08
        BNE FADE_LOOP
FADE_DONE
        RTS

FADECOUNT BYTE $00

FADEPHASE
        BYTE $00,$04,$08,$0C,$10,$14,$18,$1C

FADETBL
        BYTE $00,$00,$00,$00  
        BYTE $0B,$0B,$0B,$0B  
        BYTE $0C,$0C,$0C,$0C  
        BYTE $0F,$0F,$0F,$0F  
        BYTE $01,$01,$01,$01  
        BYTE $0F,$0F,$0F,$0F  
        BYTE $0C,$0C,$0C,$0C  
        BYTE $0B,$0B,$0B,$0B  

SPR_X
        BYTE 33,80, 73,80, 113,80, 153,80
        BYTE 193,80, 233,80, 17,80, 57,80

; ============================================================
; MUSIK - laddas på $1006
; ============================================================
        *= $1006
        incbin "..\i_touch_myself.sid",$7C

; ============================================================
; DATA - på $3200
; ============================================================
        *= $3200

SINTBL
    BYTE 120,121,122,123,124,125,126,127,128,129,130,131,132,133,133,134
    BYTE 135,136,137,138,139,140,141,141,142,143,144,145,145,146,147,148
    BYTE 148,149,150,150,151,152,152,153,153,154,154,155,155,156,156,157
    BYTE 157,157,158,158,158,159,159,159,159,159,160,160,160,160,160,160
    BYTE 160,160,160,160,160,160,160,159,159,159,159,159,158,158,158,157
    BYTE 157,157,156,156,155,155,154,154,153,153,152,152,151,150,150,149
    BYTE 148,148,147,146,145,145,144,143,142,141,141,140,139,138,137,136
    BYTE 135,134,133,133,132,131,130,129,128,127,126,125,124,123,122,121
    BYTE 120,119,118,117,116,115,114,113,112,111,110,109,108,107,107,106
    BYTE 105,104,103,102,101,100,99,99,98,97,96,95,95,94,93,92
    BYTE 92,91,90,90,89,88,88,87,87,86,86,85,85,84,84,83
    BYTE 83,83,82,82,82,81,81,81,81,81,80,80,80,80,80,80
    BYTE 80,80,80,80,80,80,80,81,81,81,81,81,82,82,82,83
    BYTE 83,83,84,84,85,85,86,86,87,87,88,88,89,90,90,91
    BYTE 92,92,93,94,95,95,96,97,98,99,99,100,101,102,103,104
    BYTE 105,106,107,107,108,109,110,111,112,113,114,115,116,117,118,119

; 8 sprites: bokstäverna D I V I N Y L S (hi-res, 24x21, 64 bytes var inkl. padding)
SPRITEDATA
    ; D
    BYTE $0F,$FF,$00,$0F,$FF,$00,$0F,$FF,$00,$0F,$FF,$C0,$0F,$03,$C0,$0F
    BYTE $03,$C0,$0F,$03,$C0,$0F,$03,$C0,$0F,$03,$C0,$0F,$03,$C0,$0F,$03
    BYTE $C0,$0F,$03,$C0,$0F,$03,$C0,$0F,$03,$C0,$0F,$03,$C0,$0F,$03,$C0
    BYTE $0F,$03,$C0,$0F,$FF,$C0,$0F,$FF,$00,$0F,$FF,$00,$0F,$FF,$00,$00
    ; I
    BYTE $03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$00,$3C,$00,$00
    BYTE $3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C
    BYTE $00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00
    BYTE $00,$3C,$00,$03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$00
    ; V
    BYTE $1E,$00,$F0,$1E,$00,$F0,$0F,$01,$E0,$0F,$01,$E0,$0F,$01,$E0,$0F
    BYTE $03,$C0,$07,$83,$C0,$07,$83,$C0,$07,$83,$C0,$03,$C7,$80,$03,$C7
    BYTE $80,$03,$C7,$80,$01,$EF,$00,$01,$EF,$00,$01,$EF,$00,$00,$FF,$00
    BYTE $00,$FE,$00,$00,$FE,$00,$00,$FE,$00,$00,$7C,$00,$00,$7C,$00,$00
    ; I
    BYTE $03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$00,$3C,$00,$00
    BYTE $3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C
    BYTE $00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00
    BYTE $00,$3C,$00,$03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$03,$FF,$C0,$00
    ; N
    BYTE $0F,$00,$F0,$0F,$80,$F0,$0F,$80,$F0,$0F,$C0,$F0,$0F,$C0,$F0,$0F
    BYTE $E0,$F0,$0F,$E0,$F0,$0F,$F0,$F0,$0F,$F0,$F0,$0F,$78,$F0,$0F,$3C
    BYTE $F0,$0F,$3C,$F0,$0F,$1E,$F0,$0F,$1E,$F0,$0F,$0F,$F0,$0F,$0F,$F0
    BYTE $0F,$07,$F0,$0F,$07,$F0,$0F,$03,$F0,$0F,$03,$F0,$0F,$01,$F0,$00
    ; Y
    BYTE $1E,$00,$F0,$0F,$01,$E0,$0F,$01,$E0,$07,$83,$C0,$03,$C7,$80,$03
    BYTE $C7,$80,$01,$EF,$00,$00,$FE,$00,$00,$FE,$00,$00,$7C,$00,$00,$3C
    BYTE $00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00
    BYTE $00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00,$3C,$00,$00
    ; L
    BYTE $0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F
    BYTE $00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00
    BYTE $00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00
    BYTE $0F,$00,$00,$0F,$FF,$F0,$0F,$FF,$F0,$0F,$FF,$F0,$0F,$FF,$F0,$00
    ; S
    BYTE $0F,$FF,$F0,$0F,$FF,$F0,$0F,$FF,$F0,$0F,$FF,$F0,$0F,$00,$00,$0F
    BYTE $00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$00,$00,$0F,$FF,$F0,$0F,$FF
    BYTE $F0,$0F,$FF,$F0,$0F,$FF,$F0,$00,$00,$F0,$00,$00,$F0,$00,$00,$F0
    BYTE $00,$00,$F0,$0F,$FF,$F0,$0F,$FF,$F0,$0F,$FF,$F0,$0F,$FF,$F0,$00

; ============================================================
; BILDDATA 
; ============================================================
        *= $4000 ; Vi mappar källfilerna till fiktiva adresser för assemblern,
                 ; men de läses in linjärt via incbin
BITMAPDATA
        incbin "..\bitmap.bin"    ; 8000 bytes
SCREENDATA
        incbin "..\screen.bin"    ; 1000 bytes
COLORDATA
        incbin "..\colorram.bin"  ; 1000 bytes
