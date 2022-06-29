; Example to create an MegaRom of 256kB that use an Konami SCC Mapper
; for Sjasm assembler

LF:	equ	0Ah
CR:	equ	0Dh

ENASLT:	equ	0024h
INIT32:	equ	006Fh
CHPUT:	equ	00A2h	; Address of character output routine of main Rom BIOS
RSLREG:	equ	0138h

StartPage:	equ	06000h	; 
PageSize:	equ	02000h	; 8kB
Seg_P6000_SW:	equ	07000h	; Segment switch for page 6000h-7FFFh (Konami  Mapper)
Seg_P8000_SW:	equ	09000h	; Segment switch for page 8000h-9FFFh (Konami  Mapper)	
Seg_PA000_SW:	equ	0B000h	; Segment switch for page A000h-BFFFh (Konami  Mapper)
PosText1:       equ	06000h	; 	
PosText2:       equ	08000h	; 	
PosText3:       equ	0A000h	; 		

LINL32:	equ	0F3AFh
EXPTBL:	equ	0FCC1h		; Extended slot flags table (4 bytes)


	defpage 0,4000H,PageSize
	page 0

	db	41h,42h
	dw	INIT,0,0,0,0,0,0

INIT:
	ld	a,32
	ld	(LINL32),a	; 32 columns
	call	INIT32		; SCREEN 1

; Typical routine to select the ROM on page 8000h-BFFFh from page 4000h-7BFFFh

	call	RSLREG
	rrca
	rrca
	and	3	;Keep bits corresponding to the page 4000h-7FFFh
	ld	c,a
	ld	b,0
	ld	hl,EXPTBL
	add	hl,bc
	ld	a,(hl)
	and	80h
	or	c
	ld	c,a
	inc	hl
	inc	hl
	inc	hl
	inc	hl
	ld	a,(hl)
	and	0Ch
	or	c
	ld	h,080h
	call	ENASLT		; Select the ROM on page 8000h-BFFFh

	ld	hl,asc_test_string
	call	Print		; Call the routine Print below

	ld	hl,text_page_0x6000
	call	Print		; Call the routine Print below

	ld	a,1
LOOP:
	ld	(Seg_P6000_SW),a	; Select the segment on page 8000h-BFFFh

	push	af
	ld	hl,PosText1	; Text pointer into HL
	call	Print		; Call the routine Print below
	pop	af

	call    delay05s
	inc	a	; Increment segment number
	cp	32
	jr	nz, LOOP	; Jump to LOOP if A<8

	ld	hl,text_page_0x8000
	call	Print		; Call the routine Print below

	ld	a,1
LOOP2:
	ld	(Seg_P8000_SW),a	; Select the segment on page 8000h-BFFFh

	push	af
	ld	hl,PosText2	; Text pointer into HL
	call	Print		; Call the routine Print below
	pop	af

	call    delay05s
	inc	a	; Increment segment number
	cp	32
	jr	nz, LOOP2	; Jump to LOOP if A<8	

	ld	hl,text_page_0xA000
	call	Print		; Call the routine Print below

 	ld	a,1
LOOP3:
	ld	(Seg_PA000_SW),a	; Select the segment on page 8000h-BFFFh

	push	af
	ld	hl,PosText3	; Text pointer into HL
	call	Print		; Call the routine Print below
	pop	af

	call    delay05s
	inc	a	        ; Increment segment number
	cp	32
	jr	nz, LOOP3 	; Jump to LOOP if A<8	

Finished:
	jr	Finished	; Jump to itself endlessly.

delay05s:
lDLL1: 		PUSH BC
		LD B, 01Fh
lDLL2:		PUSH BC
		PUSH AF
		POP AF
		PUSH AF
		POP AF
		PUSH AF
		POP AF
		POP BC
		DJNZ lDLL2

		POP BC
		DJNZ lDLL1

		RET

Print:
	ld	a,(hl)		; Load the byte from memory at address indicated by HL to A.
	and	a		; Same as CP 0 but faster.
	ret	z		; Back behind the call print if A = 0
	call	CHPUT		; Call the routine to display a character.
	inc	hl		; Increment the HL value.
	jr	Print		; Jump to the address in the label Print.

asc_test_string:
	db "Konami SCC mapper 256KB test",LF,CR,LF,CR,0	;  
text_page_0x6000:
	db "Page  0x6000-0x7FFF",LF,CR,0	; 
text_page_0x8000:
	db "Page  0x8000-0x9FFF",LF,CR,0	; 
text_page_0xA000:
	db "Page  0xA000-0xBFFF",LF,CR,0	; 


	defpage 1,StartPage,PageSize
	page 1

	db "Text from segment 01 ",0	; Zero indicates the end of text.

	defpage 2,StartPage,PageSize
	page 2

	db "02 ",0

	defpage 3,StartPage,PageSize
	page 3

	db "03 ",0

	defpage 4,StartPage,PageSize
	page 4

	db "04 ",0

	defpage 5,StartPage,PageSize
	page 5

	db "05 ",0

	defpage 6,StartPage,PageSize
	page 6

	db "06 ",0

	defpage 7,StartPage,PageSize
	page 7

	db "07 ",0

	defpage 8,StartPage,PageSize
	page 8

	db "08 ",0

	defpage 9,StartPage,PageSize
	page 9

	db "09 ",0

	defpage 10,StartPage,PageSize
	page 10

	db "10 ",0

	defpage 11,StartPage,PageSize
	page 11

	db "11 ",0

	defpage 12,StartPage,PageSize
	page 12

	db "12 ",0

	defpage 13,StartPage,PageSize
	page 13

	db "13 ",0

	defpage 14,StartPage,PageSize
	page 14

	db "14 ",0	

	defpage 15,StartPage,PageSize
	page 15

	db "15 ",0		

	defpage 16,StartPage,PageSize
	page 16

	db "16 ",0	; Zero indicates the end of text.

	defpage 17,StartPage,PageSize
	page 17

	db "17 ",0

	defpage 18,StartPage,PageSize
	page 18

	db "18 ",0

	defpage 19,StartPage,PageSize
	page 19

	db "19 ",0

	defpage 20,StartPage,PageSize
	page 20

	db "20 ",0

	defpage 21,StartPage,PageSize
	page 21

	db "21 ",0

	defpage 22,StartPage,PageSize
	page 22

	db "22 ",0

	defpage 23,StartPage,PageSize
	page 23

	db "23 ",0

	defpage 24,StartPage,PageSize
	page 24

	db "24 ",0

	defpage 25,StartPage,PageSize
	page 25

	db "25 ",0

	defpage 26,StartPage,PageSize
	page 26

	db "26 ",0

	defpage 27,StartPage,PageSize
	page 27

	db "27 ",0

	defpage 28,StartPage,PageSize
	page 28

	db "28 ",0	

	defpage 29,StartPage,PageSize
	page 29

	db "29 ",0	

	defpage 30,StartPage,PageSize
	page 30

	db "30 ",0		

	defpage 31,StartPage,PageSize
	page 31

	db "31 ",LF,CR,LF,CR,0			
