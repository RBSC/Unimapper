;--------------------------------------------------------------------------------
; Utility for programming UniMapper cartridge v3.5
; Copyright (c) 2022-2023 RBSC
; Developers: Pyhesty and Wierzbowsky
;--------------------------------------------------------------------------------

; Note: use Sjasm assembler to compile

Konami_Select:  equ     '1'
SCC_Select:	equ     '3'	
ASC8_Select:	equ     '5'	
ASC16_Select:	equ     '7'		

ENASLT:		equ	00024h   ; bios proc enable slot  
INIT32:		equ	0006Fh 
RSLREG:		equ	00138h
BDOS:		equ	00005h	; dos function 

SIZE_DSK_BUFFER:EQU     128	

LF:		equ	0Ah
CR:		equ	0Dh


	        ORG	0100h	; Compilation start address.


START:
/********* start block **************/
		xor	a
		ld	(VERB),a	; no verbose mode
		ld	a,(0x0080)
		or	a
		jr	z,STARTM
		ld	a,(0x0082)
		cp	'/'
		jr	nz,STARTM
		ld	a,(0x0083)
		cp	'v'
		jr	nz,STARTM
		ld	a,1
		ld	(VERB),a	; verbose mode
STARTM:
		call    start_info
		call    read_flash_id_sst
		ld	a,(FLROMID)
		cp	0xBF
		jr	nz,STARTX
		ld	a,(FLROMID+1)
		cp	0xB7
		jr	z,STARTF
STARTX:
		call    mini_new_line
	        ld      de,wr_id	; wrong ID
	        ld      c,09H           ;string output function
	        CALL    BDOS
		jp      end_prog

STARTF:
		call    chip_erase	
		call    write_rom		
		jp      end_prog

wr_id:		db  "Wrong FlashROM ID, exiting...$",LF,CR

/********* write rom ******************/
slot_select:	db	01h  	 ; default slot A - 01, A <-> 01, B <-> 02
end_block_write:db	0A0h  	 ; hi address end block for write mode
Flash_WR_Addr0: dw	06AAAh   ; flash programm address page - 1
Flash_WR_Addr1: dw	0B555h   ; flash programm address page - 3 	
Seg_ad_switch:	dw	08000h	 ; Segment switch for page 8000h-9FFFh (Konami without SCC)
write_rom:
		call    Read_DSK_Buffer128	
		ld      iy, 0x0000
		ld      a, (end_block_write)
		ld      iyh, a 			; load end pos write block 0xA000 or 0xC000 (ASC16)
		call    mini_now_wr_segment
		ld      hl, Buff_WR	
		ld      ix, 0x8000
		ld      c,  128	
		
wr_loop0:
		ld      e, (hl)
		call    write_byte
		inc     hl
	        inc     ixl        
	        jr      nz, l_wr_incxy_next0
	        inc     ixh                
		ld      a, ixh
		cp      iyh			; cmp end pos write block 0xA000 or 0xC000 (ASC16)
		jr      nz, l_wr_incxy_next0

		ld      ix, 0x8000	
		inc     iyl 
		push    bc
		call    mini_now_wr_segment
		pop     bc

l_wr_incxy_next0:
		dec     c
		jr      nz, wr_loop0	
		call    Read_DSK_Buffer128
		ld      c, 128
		ld      hl, Buff_WR	
		ld      a, (End_of_file)
		cp      a, 0 
		jr      z, wr_loop0
		call    mini_write_finish_info
		ret

/********* write byte konami **********/
/* input   e - byte to write          */
/* 	   ix      - pos in slot      */
/* 	   iyl     - segment          */
write_byte:
		push    hl	
		ld      a,  iyl
		ld      hl, (Seg_ad_switch) :	ld	(hl), a	        
		ld 	a, 0AAh:	ld hl, (Flash_WR_Addr1): 	ld 	(hl), a   ; 1-wcycle write to 5555h ROM 
		ld 	a, 055h:	ld hl, (Flash_WR_Addr0): 	ld 	(hl), a   ; 2-wcycle write to 2AAAh ROM 
		ld 	a, 0A0h:	ld hl, (Flash_WR_Addr1): 	ld 	(hl), a   ; 3-wcycle write to 5555h byte-program
		ld      hl, ix        		
		ld 	(hl), e   			      ; 4-wcycle write to 5555h add + data			
		pop     hl
		;call    delay_20u	
		ret 

/********* now write rom info ***********/	
str_wr_seg:     db  "Flashing block: $"
mini_now_wr_segment:
		call    mini_new_line
	        ld      de, str_wr_seg       ;[DE] := str
	        ld      c,09H                ;string output function
	        CALL    BDOS
		ld	a, iyl
		call    print_hex         
		call    setup_mappers
		ret 

/********* finish  write rom info ***********/	
str_finish:     db  LF,CR,"Flashing complete! (seg, data): $"
mini_write_finish_info:
		call    mini_new_line
	        LD      DE, str_finish       ;[DE] := 'finish'
	        LD      C,09H                ;string output function
	        CALL    BDOS
		ld	a, iyl
		call    print_hex 
		ld      e, ',' 
		ld      c, 2
		call	BDOS		; Call the routine to display a character.	
		ld	a, ixh
		call    print_hex 
		ld	a, ixl
		call    print_hex 
		call    mini_new_line
		call    print_mappers_memory_info
		ret 		

/********* open file ******************/
str_file_ok:    db      "Finding file: OK",LF,CR,"$"
err_open_file:  db      "Can't open file: $",LF,CR,"$"
End_of_file:    db      0x00	
;----------------------------
;--- in DE - pointer FCB  
OPEN_FILE:
                ld      de,fROM         	;DE := default FCB address
                ld      c,0Fh: call    BDOS     ;open file function    
                or      a               ;success ?
                jr      nz, subERROR1   ;if so, goto READ
subOK1: 
		call    mini_new_line
                ld      de, str_file_ok 	;[DE] := 'Ok.'
                ld      c,09h:	call    BDOS    ;string output function
                ret                
subERROR1:                        	        ;error return
		call    mini_new_line
                ld      de, err_open_file      	;[DE] := 'Cannot open that file'
                ld      c,09h:	call    BDOS	;string output function
                ld      a, "$"
                ld 	(ROM_FILE_NAME_END), a                
                ld      de, ROM_FILE_NAME 	;[DE] := 'Ok.'                
                ld      c,09h:	call    BDOS	;string output function
                jp	end_prog
                ret                    ; return dos    

/********* read block data ******************/               
Read_DSK_Buffer128:
		push    ix
		push    iy	
                ld      de, Buff_WR	
                ld      c, 1Ah             ;set DMA address function
                call    BDOS                
                ld      de, fROM          ;read 
                ld      c, 14h
                call    BDOS
                ld      (End_of_file), a
                ;ld      e, '.'
		;ld      c, 2
		;call	BDOS		; Call the routine to display a character.                
		pop     iy
		pop     ix	
		call    setup_mappers
		ret               

/********* delay 20us *************/
delay_20u:
   	     	ld      a, 240
l_wait_20u:
		inc     a	
		jr      nz, l_wait_20u
		ret

/********* read ID block *************/
str_chip_erase:	db "Erasing FlashROM chip$"
chip_erase:		
        	ld      de, str_chip_erase	 	  ;[DE] :=  srt
        	ld      c,09h: 		call    BDOS 	  ;string output function
		call    setup_mappers
		ld 	a, 0AAh:	ld hl, (Flash_WR_Addr1): 	ld 	(hl), a   ; 1-wcycle write to 5555h ROM 
		ld 	a, 055h:	ld hl, (Flash_WR_Addr0): 	ld 	(hl), a   ; 2-wcycle write to 2AAAh ROM 
		ld 	a, 080h:	ld hl, (Flash_WR_Addr1): 	ld 	(hl), a   ; 3-wcycle write to 5555h ROM 
		ld 	a, 0AAh:	ld hl, (Flash_WR_Addr1): 	ld 	(hl), a   ; 4-wcycle write to 5555h ROM 	
		ld 	a, 055h:	ld hl, (Flash_WR_Addr0): 	ld 	(hl), a   ; 5-wcycle write to 2AAAh ROM 
		ld 	a, 010h:	ld hl, (Flash_WR_Addr1): 	ld 	(hl), a   ; chip-erase command to 5555h address 
		call 	delay05s:	call    mini_print_dot		
		call 	delay05s:	call    mini_print_dot		
		call 	delay05s:	call    mini_print_dot		
		call 	mini_new_line
		call    print_mappers_memory_info			
		ret

/********* read ID block *************/
str_search_flash:	db "Reading FlashROM ID code: $"
read_flash_id_sst:
        	ld      de, str_search_flash	 		;[DE] :=  srt
        	ld      c, 09h: 	call    BDOS	 	;string output function	        	
		ld 	a, 0AAh:	ld hl, (Flash_WR_Addr1):	ld 	(hl), a	    ; 1-wcycle write to 5555h ROM 
		ld 	a, 055h:	ld hl, (Flash_WR_Addr0):	ld 	(hl), a     ; 2-wcycle write to 2AAAh ROM 
		ld 	a, 090h:	ld hl, (Flash_WR_Addr1):	ld 	(hl), a     ; ID flash command to 5555h address 
		ld 	a, (4000h)    ; vendor ID, read with least add bit A0 == 0	
		ld	(FLROMID),a
	  	call    print_hex     ; print hex value = a 
	  	ld 	a, (4001h)    ; flash ID,  read with least add bit A0 == 1
		ld	(FLROMID+1),a
	  	call    print_hex     ; print hex value = a
		ld 	a, 0F0h       ; exit ID flash command
		ld 	(04000h), a  
		call 	mini_new_line	
		ret

read_flash_id_sst_asc16:
        	ld      de, str_search_flash	 		;[DE] :=  srt
        	ld      c, 09h: 	call    BDOS	 	;string output function	      
		call    setup_mappers
		ld 	a, 0AAh:	ld 	(0x5555), a	; 1-wcycle write to 5555h ROM 		
		ld 	a, 055h:	ld 	(0x6AAA), a     ; 2-wcycle write to 2AAAh ROM 
		ld 	a, 090h:	ld 	(0x5555), a     ; ID flash command to 5555h address 
		ld 	a, (4000h)    ; vendor ID, read with least add bit A0 == 0	
	  	call    print_hex     ; print hex value = a 
	  	ld 	a, (4001h)    ; flash ID,  read with least add bit A0 == 1
	  	call    print_hex     ; print hex value = a
		ld 	a, 0F0h       ; exit ID flash command
		ld 	(04000h), a  
		call 	mini_new_line	
		ret

/********* setup mappers *************/
setup_mappers:
		ld 	a, (slot_select)   ; hardcode SlotID - 2nd non-expanded A <-> 01, B <-> 02
		ld 	hl, 04000h:	call	ENASLT

		ld 	a, (slot_select)   ; hardcode SlotID - 2nd non-expanded A <-> 01, B <-> 02
		ld 	hl, 08000h:	call 	ENASLT
		ret	        

/********* print mapper info *************/
str_data_in_address_0x4000:	db "Block 0x4000:$"	
str_data_in_address_0x6000:	db "Block 0x6000:$"
str_data_in_address_0x8000:	db "Block 0x8000:$"	
str_data_in_address_0xA000:	db "Block 0xA000:$"	

print_mappers_memory_info:
		ld	a,(VERB)
		or	a		; verbose mode?
		ret	z
		call    setup_mappers
        	ld      de, str_data_in_address_0x4000 	  ;[DE] :=  srt
        	ld      c,09h: 		call    BDOS 	  ;string output function
        		
		ld	a, (04000h):	call    print_hex 
		ld	a, (04001h):	call    print_hex 
		ld	a, (04002h):	call    print_hex 
		ld	a, (04003h):	call    print_hex 	
		call 	mini_new_line		

        	ld      de, str_data_in_address_0x6000	 ;[DE] :=  srt
        	ld      c, 09h: 	call    BDOS  	 ;string output function
		ld	a, (06000h):	call    print_hex 
		ld	a, (06001h):	call    print_hex 
		ld	a, (06002h):	call    print_hex 
		ld	a, (06003h):	call    print_hex 	
		call 	mini_new_line		

        	ld      de, str_data_in_address_0x8000	 ;[DE] :=  srt
        	ld      c, 09h:		call    BDOS  	 ;string output function
		ld	a, (08000h):	call    print_hex 
		ld	a, (08001h):	call    print_hex 
		ld	a, (08002h):	call    print_hex 
		ld	a, (08003h):	call    print_hex 	
		call 	mini_new_line		

        	ld      de, str_data_in_address_0xA000 	 ;[DE] :=  srt
        	ld      c,  09h: 	call    BDOS   	 ;string output function
		ld	a, (0A000h):	call    print_hex 
		ld	a, (0A001h):	call    print_hex 
		ld	a, (0A002h):	call    print_hex 
		ld	a, (0A003h):	call    print_hex 	
		call 	mini_new_line
		ret

/********* print hex value procedure, a - value *************/
print_hex:
		push    af
		ld      e, 020h: ld      c, 2:	call	BDOS		; print space
		pop     af
		push    af
		and     a, 0F0h
		srl     a	
		srl     a	
		srl     a	
		srl     a
		cp      a, 09h	
		jr      nc, l_print_hex_add_0x40  
		add     a, 030h     
		jr      l_print__hex_next1  
l_print_hex_add_0x40:
		add     a, 037h     	        
l_print__hex_next1:	
		ld      e, a:	ld      c, 2:	call	BDOS		; Call the routine to display a character.
		pop     af
		and     a, 0Fh	
		cp      a, 0Ah	
		jr      nc, l_print_hex_add_0x40_2  
		add     a, 030h     
		jr      l_print__hex_next2  
l_print_hex_add_0x40_2:
		add     a, 037h     	        
l_print__hex_next2:	
		ld      e, a:	ld      c, 2:	call	BDOS		; Call the routine to display a character.
		call	setup_mappers
		ret

/********* delay procedure *************/
delay05s:
lDLL1: 		PUSH BC
		LD B, 05Fh
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

/******* new line in console ***********/ 
str_new_line:	db LF,CR,'$'	              
mini_new_line:		
        	ld      de, str_new_line  	  ;[DE] :=  str
        	ld      c,09h:	call    BDOS      ;string output function	
        	ret	

/******* print dot in console ***********/ 
mini_print_dot:		
                ld      e, '.'
		ld      c, 2:	call	BDOS	  ; Call the routine to display a character.                
        	ret	

/********* start info proc *************/        
str_start:		db "UniMapper Cartridge Flashing Tool v3.5",LF,CR
			db "Supported mappers:",LF,CR
			db "  Konami, Konami SCC, ASCII8, ASCII16",LF,CR		
			db "FlashROM type: SST39F040",LF,CR					
			db "Copyright (C) 2022 Pyhesty [RBSC]",LF,CR,LF,CR, "$"	
;			db "now setup mappers",LF,CR,"$"
str_select_page0:	db "now select page0 -> seg 1",LF,CR,"$"		
str_select_slot:	db "Select UniMapper's slot: 1 or 2","$"		
str_slota:		db LF,CR,"Selected slot: 1",LF,CR,LF,CR,"$"
str_slotb:		db LF,CR,"Selected slot: 2",LF,CR,LF,CR,"$"	
str_select_mapper:	db "Select mapper type:",LF,CR		
			db Konami_Select,"- Konami4",LF,CR			
			db SCC_Select,"- Konami SCC",LF,CR						
			db ASC8_Select,"- ASCII8",LF,CR
			db ASC16_Select,"- ASCII16","$"			
str_konami:		db "Konami4 mapper selected.",LF,CR,"$"
str_konamiSCC:		db "Konami SCC mapper selected.",LF,CR,"$"
str_ASC8:		db "ASCII8 mapper selected.",LF,CR,"$"	
str_ASC16:		db "ASCII16 mapper selected.",LF,CR,"$"		
str_write_name_rom:	db LF,CR,"Input file name (without .ROM extension):",LF,CR,"$"		
user_select_mapper:	db	0x00										
start_info:
        	ld      de, str_start   		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function 
        	ld      de, str_select_slot  		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  	
select_slot_again:        
		call 	mini_new_line		        	
        	ld      c,01h:		call    BDOS	  ;wait input char  
        	cp      '1':	  	jr	z, end_select_slot
        	cp      '2':  		jr	z, end_select_slot        	
        	jr 	select_slot_again
end_select_slot:        	
		cp	'1'		  		  ; slot a?
		jr	nz, slot_b
slot_a:				
        	ld      de, str_slota   		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  			        	
        	jr	next_step_select_mapper
slot_b:		        	
        	ld      de, str_slotb   		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  
        	ld      a, 02
        	ld      (slot_select), a

next_step_select_mapper:   
		call    print_mappers_memory_info	
        	ld      de, str_select_mapper  		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  	
select_again:        
		call 	mini_new_line		        	
        	ld      c,01h:		call    BDOS	  ;wait input char  
        	cp      Konami_Select:  jr	z, end_select
        	cp      SCC_Select:   	jr	z, end_select
        	cp      ASC8_Select:   	jr	z, end_select
        	cp      ASC16_Select:  	jr	z, end_select        	
        	jr 	select_again
end_select:
		push    af
		call 	mini_new_line				
		pop     af
		ld 	(user_select_mapper),a		        	
;                ld      e, a
;		ld      c, 2:	call	BDOS	  ; Call the routine to display a character.                
 ;               ld      e, "-"
;		ld      c, 2:	call	BDOS	  ; Call the routine to display a character.                
		ld 	a, (user_select_mapper)		
		cp	Konami_Select 		  	  ; Konami without SCC
		jr	nz, select_cp_next6
        	ld      de, str_konami   		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  			
        	jr	end_select_block
select_cp_next6:		
		cp	SCC_Select			  ; Konami SCC
		jr	nz, select_cp_next7
        	ld      de, str_konamiSCC   		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  			        	
        	ld      hl, 0x9000:    	ld      (Seg_ad_switch), hl
        	jr	end_select_block
select_cp_next7:				
		cp	ASC8_Select			  ; ASC8
		jr	nz, select_cp_next9
        	ld      de, str_ASC8	   		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  			
        	ld      hl, 0x7000:    	ld      (Seg_ad_switch), hl
        	jr      end_select_block
select_cp_next9:				
		cp	ASC16_Select			  ; ASC16
		jr	nz, select_cp_nextX
        	ld      de, str_ASC16	   		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  			
        	ld      hl, 0x7000:    	ld      (Seg_ad_switch), hl
        	ld      hl, 0x6AAA:    	ld      (Flash_WR_Addr0), hl        	
        	ld      hl, 0x5555:    	ld      (Flash_WR_Addr1), hl     
        	ld      a, 0xC0:       	ld      (end_block_write), a     ; load end pos write block 0xA000 or 0xC000 (ASC16) 
        	jr      end_select_block        	
select_cp_nextX:        	
end_select_block:
		call    setup_mappers
		;call    print_mappers_memory_info	
input_name_ROM:
        	ld      de, str_write_name_rom 		  ;[DE] :=  srt
        	ld      c,09h:		call    BDOS	  ;string output function  	
        	ld      hl, ROM_FILE_NAME
        	ld      c,0x08          ; len file name
wait_char_name:
        	push    hl
        	push    bc
        	ld      c, 01h:		call    BDOS	  ;wait input char  
		pop     bc
		pop     hl	            	
        	cp      0Dh        	
        	jr      z, end_input_name
        	ld      (hl), a
        	inc     hl
        	dec     c 
        	jr      z, end_input_name
		jr      wait_char_name    		
end_input_name:		
		call    OPEN_FILE
        	ret  	        	

/********* end programm    *************/
end_prog:	
	  	ld 	a, (0F342h)  ; RAM addr page 1 to restore
	  	ld	h, 40h
	  	call 	ENASLT
	  	ld 	a, (0F343h)  ; RAM addr page 2 to restore
	  	ld 	h, 80h
	  	call 	ENASLT	
		call    mini_new_line
	  	ld 	c, 00h
	  	call    BDOS         ; programm terminate
	        ret                  ; end program

/********** variables *****************/
VERB:		db	0
FLROMID:
		dw	0x0000
fROM:
                db 	0x00
ROM_FILE_NAME:       
                ds 	8, 0x20
                db 	"rom"
ROM_FILE_NAME_END:
                ds 	36-12,0x00  
Buff_WR:	ds 	(SIZE_DSK_BUFFER),0x55  




