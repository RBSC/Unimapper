; Example to create an MegaRom of 128-512kB that use an ASCII 16K Mapper
; for Sjasm assembler

LF:	equ	0Ah
CR:	equ	0Dh

ENASLT:	equ	0024h
INIT32:	equ	006Fh
CHPUT:	equ	00A2h	; Address of character output routine of main Rom BIOS
RSLREG:	equ	0138h

PageSize:	equ	04000h	; 16kB
Seg_P4000_SW:	equ	06000h	; Segment switch for page 8000h-BFFFh (ASCII 16k Mapper)	
Seg_P8000_SW:	equ	07000h	; Segment switch for page 8000h-BFFFh (ASCII 16k Mapper)

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

	jr 	start_test

loop_test:
	ld 	a, 0
	ld	(Seg_P4000_SW),a
	ld 	a, 5
	ld	(Seg_P8000_SW),a	
	ld 	a, (09000h)	
	ld 	a, 0
	ld	(Seg_P8000_SW),a
	ld 	a, (05000h)
	ld 	a, (09000h)
	jr 	loop_test

start_test:
	call 	delay05s
	ld	a,0
LOOP:
	ld	(Seg_P8000_SW),a	; Select the segment on page 8000h-BFFFh

	push	af
	ld	hl,Seg1_TXT	; Text pointer into HL
	call	Print		; Call the routine Print below
	pop	af
	call    delay05s
	inc	a	; Increment segment number
	cp	31	
	jr	nz, LOOP	; Jump to LOOP if A<8
 
Finished:
	jr      start_test
	jr	Finished	; Jump to itself endlessly.

Print:
	ld	a,(hl)		; Load the byte from memory at address indicated by HL to A.
	and	a		; Same as CP 0 but faster.
	ret	z		; Back behind the call print if A = 0
	call	CHPUT		; Call the routine to display a character.
	inc	hl		; Increment the HL value.
	jr	Print		; Jump to the address in the label Print.
 
delay05s:
lDLL1: 		PUSH BC
		LD B, 02Fh
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

asc_test_string:
	db "ASC16 umapper 512KB test",LF,CR,LF,CR,0	;  

	;ORG 0x1000
T_PACK: ds (0x1000-0xA8),0x20 
	db "Text from segment 0",LF,CR,0	; Zero indicates the end of text.	
	 	
	defpage 1,8000H,PageSize
	page 1
	ds 0x1000, 0x20
Seg1_TXT:			; Text pointer label	
	db "Text from segment 1",LF,CR,0	; Zero indicates the end of text.

	defpage 2,8000H,PageSize
	page 2
	ds 0x1000, 0x20
	db "Text from segment 2",LF,CR,0

	defpage 3,8000H,PageSize
	page 3
	ds 0x1000, 0x20
	db "Text from segment 3",LF,CR,0

	defpage 4,8000H,PageSize
	page 4
	ds 0x1000, 0x20
	db "Text from segment 4",LF,CR,0

	defpage 5,8000H,PageSize
	page 5
	ds 0x1000, 0x20
	db "Text from segment 5",LF,CR,0

	defpage 6,8000H,PageSize
	page 6
	ds 0x1000, 0x20
	db "Text from segment 6",LF,CR,0

	defpage 7,8000H,PageSize
	page 7
	ds 0x1000, 0x20
	db "Text from segment 7",LF,CR,0

	defpage 8,8000H,PageSize
	page 8
	ds 0x1000, 0x20
	db "Text from segment 8",LF,CR,0

	defpage 9,8000H,PageSize
	page 9
	ds 0x1000, 0x20
	db "Text from segment 9",LF,CR,0

	defpage 10,8000H,PageSize
	page 10
	ds 0x1000, 0x20
	db "Text from segment 10",LF,CR,0

	defpage 11,8000H,PageSize
	page 11
	ds 0x1000, 0x20
	db "Text from segment 11",LF,CR,0

	defpage 12,8000H,PageSize
	page 12
	ds 0x1000, 0x20
	db "Text from segment 12",LF,CR,0

	defpage 13,8000H,PageSize
	page 13
	ds 0x1000, 0x20
	db "Text from segment 13",LF,CR,0

	defpage 14,8000H,PageSize
	page 14
	ds 0x1000, 0x20
	db "Text from segment 14",LF,CR,0

	defpage 15,8000H,PageSize
	page 15
	ds 0x1000, 0x20
	db "Text from segment 15",LF,CR,0

	defpage 16,8000H,PageSize
	page 16
	ds 0x1000, 0x20
	db "Text from segment 16",LF,CR,0

	defpage 17,8000H,PageSize
	page 17
	ds 0x1000, 0x20
	db "Text from segment 17",LF,CR,0

	defpage 18,8000H,PageSize
	page 18
	ds 0x1000, 0x20
	db "Text from segment 18",LF,CR,0

	defpage 19,8000H,PageSize
	page 19
	ds 0x1000, 0x20
	db "Text from segment 19",LF,CR,0

	defpage 20,8000H,PageSize
	page 20
	ds 0x1000, 0x20
	db "Text from segment 20",LF,CR,0

	defpage 21,8000H,PageSize
	page 21
	ds 0x1000, 0x20
	db "Text from segment 21",LF,CR,0

	defpage 22,8000H,PageSize
	page 22
	ds 0x1000, 0x20
	db "Text from segment 22",LF,CR,0

	defpage 23,8000H,PageSize
	page 23
	ds 0x1000, 0x20
	db "Text from segment 23",LF,CR,0

	defpage 24,8000H,PageSize
	page 24
	ds 0x1000, 0x20
	db "Text from segment 24",LF,CR,0

	defpage 25,8000H,PageSize
	page 25
	ds 0x1000, 0x20
	db "Text from segment 25",LF,CR,0

	defpage 26,8000H,PageSize
	page 26
	ds 0x1000, 0x20
	db "Text from segment 26",LF,CR,0

	defpage 27,8000H,PageSize
	page 27
	ds 0x1000, 0x20
	db "Text from segment 27",LF,CR,0

	defpage 28,8000H,PageSize
	page 28
	ds 0x1000, 0x20
	db "Text from segment 28",LF,CR,0

	defpage 29,8000H,PageSize
	page 29
	ds 0x1000, 0x20
	db "Text from segment 29",LF,CR,0

	defpage 30,8000H,PageSize
	page 30
	ds 0x1000, 0x20
	db "Text from segment 30",LF,CR,0

	defpage 31,8000H,PageSize
	page 31
	ds 0x1000, 0x20
	db "Text from segment 31",LF,CR,0


