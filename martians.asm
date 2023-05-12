; *************************
; ****** MARTIAN WAR ******
; *************************
;
;     ------------------
;     Fausto Pracek 2023
;     ------------------


; --- BIOS CALLS ---
CHGMOD: 			equ #005f   					; Used to initialize the screen
RDSLT:				equ	#000c						; Read slot routine
WRTVRM:				equ #004d   					; Write value into WRAM
VDP_DW:				equ	#0007						; VDP data write port
VDP_DR:				equ	#0006						; VDP data read port
LDIRVM:				equ #005c						; Write a block of memory to VRAM memory
SETWRT:				equ #0053						; Enable WRAM to write
RDVRM:				equ 004ah						; Read VRAM

; --- BIOS CONSTANT ---
LINL40: 			equ #f3ae   					; Screen 0 screen width
REG2SAV:			equ #f3e1						; VDP reg #2
REG4SAV: 			equ #f3e3						; VDP reg #4
REG9SAV:			equ	#ffe8 						; VDP reg #9
NEWKEY:				equ #fbe5						; Pressed key
CLIKSW:   			equ #f3dB						; Key Press Click Switch: 0=Off 1=On
HTIMI:      		equ #fd9f      					; Memory adress of hook that's invoked after VBLANK	
KEYS:				equ	#fbe5						; NEWKEY memory area 0xFBE5-0xFBEF


; --- INIT ROM ---
	org #4000
	db "AB"											; ID for auto-executable ROM
	dw start										; Main program execution address.
	db 00,00,00,00,00,00 							; Unused

start:
 ; --- INIT SCREEN ---
init_screen:
	ld 		a,80              				; 80 columns 
	ld 		(LINL40),a
	xor 	a
	call 	CHGMOD          				; Screen 0  

	ld		a,(#0fcc1)
	ld		hl,#002d
	call	RDSLT
	or		a
	jp		nz, init_screen_msx2			; Check if running on a MSX1 machine						
	ld		c, 0
	ld		b, 0
	ld		hl, TXT_MSX1
	call	print_string_at
	di
	halt
	ret
init_screen_msx2:
	ld		a,26							; Set TEXT 2 mode w with 26.5 rows
	ld		(#F3B1),a					
	ld		a,(#0fcc1)
	ld		hl,#0007
	call	RDSLT
	ld		c,a
	inc		c
	ld		a,(REG9SAV)
	or		#080
	di
	ld		(REG9SAV),a
	out 	(c),a
	ld 		a,#80+9
	ei
	out 	(c),a		
	ld 		a,#080
	di
	out 	(c),a
	ld 		a,#047
	out 	(c),a
	ei
	dec 	c
	ld 		a,32	
	ld 		b,240	

	xor a 			
	ld (CLIKSW),a	; 0=click off
init_screen_loop:
	out		(c),a
	djnz	init_screen_loop

; --- LOAD CHAR MAP ---
load_char_map:
	
	ld 		a, (REG4SAV)							; VRAM reg #4 in A registry
	ld		de, 2048								; Base VRAM address for table generator patterns
	call	mult_8bit_16bit_values					; Calculate table generator patterns address using VRAM reg #4 factor
	ld		bc, 1024								; Put into BC registry bytes before char 128
	add		hl, bc									; Add to table generator patterns bytes before char 128
	ld		bc, CHAR_MAP_BLOCK_LEN					; Bytes block to copy into VRAM
	push	hl										; Put HL registry to stack (for to exchange its value with DE registry in next instruction)
	pop		de										; Restore  table generator patterns address from stack
	ld 		hl,RunningHuman1_11_128  				; First memory address to write into VRAM
    call 	LDIRVM

; --- GAME PRESENTATION ---
show_presentation:									; Print all messages on presentation screen

	ld		hl,TXT_MARTIAN_WAR
	ld		c, 30
	ld		b, 0
	call	print_string_at


	ld		hl, TXT_PRES_1
	ld		c, 5
	ld		b, 2
	call    print_string_at

	ld		hl, TXT_KEYS
	ld		c, 5
	ld		b, 4
	call    print_string_at

	ld		hl, TXT_KEY_4
	ld		c, 20
	ld		b, 6
	call    print_string_at

	ld		hl, TXT_KEY_5
	ld		c, 20
	ld		b, 7
	call    print_string_at

	ld		hl, TXT_KEY_6
	ld		c, 20
	ld		b, 8
	call    print_string_at

	ld		hl, TXT_KEY_8
	ld		c, 20
	ld		b, 9
	call    print_string_at

	ld		hl, TXT_PRES_2
	ld		c, 5
	ld		b, 11
	call    print_string_at

	ld		hl, TXT_PRES_3
	ld		c, 5
	ld		b, 12
	call    print_string_at

	ld		hl, TXT_PRES_4
	ld		c, 5
	ld		b, 14
	call    print_string_at

	ld		hl, TXT_PRES_5
	ld		c, 5
	ld		b, 15
	call    print_string_at

	ld		hl, TXT_PRES_6
	ld		c, 5
	ld		b, 16
	call    print_string_at

	ld		hl, TXT_PRES_7
	ld		c, 5
	ld		b, 18
	call    print_string_at

	ld		hl, TXT_PRES_8
	ld		c, 5
	ld		b, 19
	call    print_string_at

	ld		hl, TXT_PRES_9
	ld		c, 5
	ld		b, 21
	call    print_string_at

waiting_enter_on_presentation:						; Waiting enter key pressing
	ld		a, (NEWKEY+7)	
	bit		7, a
	jp		z, show_level_selection					; Key ENTER pressed
	jp		waiting_enter_on_presentation


; --- LEVEL SELECTION ---
show_level_selection:						
	call	clear_screen							; Clear screen
	
	ld		hl, TXT_MARTIAN_WAR
	ld		c, 30
	ld		b, 0
	call    print_string_at

	ld		hl, TXT_LEVELS
	ld		c, 5
	ld		b, 7
	call    print_string_at

	ld		hl, TXT_LEVEL_1
	ld		c, 5
	ld		b, 9
	call    print_string_at

	ld     hl, TXT_LEVEL_2
	ld		c, 5
	ld		b, 10
	call    print_string_at

	ld      hl, TXT_LEVEL_3
	ld		c, 5
	ld		b, 11
	call    print_string_at

waiting_level_selection:
	ld		a,(NEWKEY+0)					
	bit		1,a
	jp		z,level_1_selected						; Key 1 pressed
	bit     2,a
	jp		z,level_2_selected						; Key 1 pressed
	bit     3,a
	jp		z,level_3_selected						; Key 1 pressed
	jp		waiting_level_selection
level_1_selected:
	ld		c, 49
	ld		b, 7
	ld		a, 49
	call	print_char_at
	ld		hl, SELECTED_LEVEL
	ld		(hl), 1
	jp		show_sounds_effect_selection:
level_2_selected:
	ld		c, 49
	ld		b, 7
	ld		a, 50
	call	print_char_at
	ld		hl, SELECTED_LEVEL
	ld		(hl), 2
	jp		show_sounds_effect_selection:
level_3_selected:
	ld		c, 49
	ld		b, 7
	ld		a, 51
	call	print_char_at
	ld		hl, SELECTED_LEVEL
	ld		(hl), 3

; --- SOUNDS EFFECT SELECTION ---
show_sounds_effect_selection:
	jp		show_war_field							; NO SOUND SELECTION AT THE MOMENT
	ld      hl, TXT_SOUNDS
	ld		c, 5
	ld		b, 15
	call    print_string_at

	ld		hl, SOUND_EFFECTS
	ld		(hl),0
waiting_sound_effects_selection:
	ld		a,(NEWKEY+5)							; Key Y pressed
	bit		6,a
	jp		z,sound_effects_selected
	ld		a,(NEWKEY+4)							; Key N pressed
	bit     3,a
	jp		z,init_game_variables
	jp		waiting_sound_effects_selection
sound_effects_selected:
	ld		hl, SOUND_EFFECTS
	ld		(hl),1

; --- SHOW WAR FIELD ---
show_war_field:
	call	clear_screen					; Clear screen
	ld		c, 63
	ld    	b, 0
show_war_field_upper_line_loop				
	ld    	a, CHAR_HORIZONTAL
	call  	print_char_at
	ld		a, c
	cp		0
	jp		z, show_war_field_bottom_line
	dec		c
	jp		show_war_field_upper_line_loop
show_war_field_bottom_line:
	ld		c,	78
	ld		b,  26
show_war_field_bottom_line_loop:
	ld    	a, CHAR_HORIZONTAL
	call  	print_char_at
	dec		c
	ld		a, c
	cp		0
	jp		z, show_war_field_right_line
	jp		show_war_field_bottom_line_loop
show_war_field_right_line:
	call	draw_war_field_right_line
show_war_field_left_line:
	call	draw_war_field_left_line
show_war_field_left_right_top_line:
	ld		c, 78
	ld		b, 3
show_war_field_left_right_top_line_loop:
	ld    	a, CHAR_HORIZONTAL
	call   	print_char_at
	dec		c
	ld		a, c
	cp		62
	jp		z, show_war_field_single_characters
	jp		show_war_field_left_right_top_line_loop
show_war_field_single_characters:
	ld    	b, 0
	ld    	c, 0
	ld    	a, CHAR_TOP_LEFT
	call   	print_char_at
	ld    	b, 26
	ld    	c, 0
	ld    	a, CHAR_BOTTOM_LEFT
	call    print_char_at
	ld    	b, 26
	ld    	c, 78
	ld    	a, CHAR_BOTTOM_RIGHT
	call    print_char_at
	ld    	b, 3
	ld    	c, 78
	ld    	a, CHAR_TOP_RIGHT
	call    print_char_at
show_war_field_info_box:
	call draw_war_field_info_box
; --- INIT GAME VARIABLES ---
init_game_variables:
	ld		hl, HUMAN_EXPLOSION_FLAG
	ld		(hl), 0											; Reset human explosion type
	call    reset_matians_info								; Reset all martians info
	ld		hl, HUMANS_COUNTER								; Set humans counter to 19
	ld		(hl), 19
	call	set_selected_level_parameters					; Set selected level prameters
	ld		hl, HUMAN_SHIP_INFO+1							; Human ship position set to 38
	ld		(hl), 38
	ld		hl, HUMAN_SHIP_INFO+2							; Reset human ship movement direction
	ld		(hl), 0
	ld		hl, HUMAN_SHIP_INFO+4							; Reset human ship speed counter
	ld		(hl), 0
	ld		hl, HUMAN_SHIP_INFO+6							; Reset human ship bomp X positon
	ld		(hl), 0
	ld		hl, HUMAN_SHIP_INFO+7							; Reset human ship bomp Y positon
	ld		(hl), 0
	ld		(HUMAN_SHIP_INFO+8),bc
	ld		bc, 0
	ld		(hl), bc										; Reset human ship hidden time counter
	call	reset_martians_bombs_positions					; Reset all martian bomb positions
	ld		hl, HUMAN_SHIP_INFO								; Set human ship visible to true
	ld		(hl),1
	ld		hl, HUMAN_SHIP_INFO+3							; Enable human ship firing
	ld		(hl), 1
; --- SHOW COUNTERS ---
show_info:
	ld      hl, TXT_MARTIAN_WAR
	ld		c, 66
	ld		b, 0
	call    print_string_at
	ld      hl, TXT_HUMANS
	ld		c, 65
	ld		b, 1
	call    print_string_at
	ld      hl, TXT_MARTIANS
	ld		c, 65
	ld		b, 2
	call    print_string_at
	call 	refresh_human_counter
	call	refresh_martians_counter
; --- SHOW RUNNING HUMANS ---
show_running_humans:
	xor		0												; Put A registry to zer0
	ld		(LOOP_COUNTER), a								; Reset showed human counter
	ld		hl, RUNNING_HUMANS_INFO
	ld		(hl), 19										; Set number of remainin running humans to show
	ld		hl, RUNNING_HUMANS_INFO+1 						; Set stop position for human running from right
	ld		(hl), 44
	ld		hl, RUNNING_HUMANS_INFO+2 						; Set stop position for human running from left
	ld		(hl), 38
show_running_humans_next:
	ld		hl, RUNNING_HUMANS_INFO
	ld		a, (hl)
	cp		0												; Check remaining humans to show
	jp		z, show_human_ship								; All humans are on screen

	
	and 	1           									; Check if show the running human from left or right side
	jp		nz, show_running_humans_from_left_side  

show_running_humans_from_right:								; Show running human from right
	ld    	hl, RUNNING_HUMANS_INFO+3				
	ld    	(hl), 76										; Set current position to 76
show_running_humans_from_right_set_first_image:
	ld    	hl, RUNNING_HUMANS_INFO+4  	
	ld    	(hl), 4											; Set first human image
show_running_humans_from_right_loop: 	 					; Loop to show running human from right
	ld		hl, RUNNING_HUMANS_INFO+3				
 	ld   	b,(hl) 											; Get current position
	ld    	hl, RUNNING_HUMANS_INFO+1
 	ld   	a,(hl) 	  		
 	cp   	b												; Check if running human arrived to his position
 	jp   	z, show_running_humans_from_right_arrived		; Human arrived to his final position
	ld   	d,a
	ld 		hl, RUNNING_HUMANS_INFO+4						; Get image to print
	ld      a, (hl)
	ld 		h, 9
	call 	mult_8bit_values
	ld   	a, 128
	add  	a, l
	ld   	e, a
	ld 		hl,  RUNNING_HUMANS_INFO+3
 	ld   	a,(hl) 	
	ld		d, a
	call 	show_running_humans_from_right_draw				; Show human in new position
	ld   	bc,$0500										; Set sleeping duration
	call 	sleep											; sleep execution
	ld    	hl,  RUNNING_HUMANS_INFO+3							
	ld		a,(hl)									
 	dec  	a
	ld 		(hl),a											; Change human running position
	ld 		hl, RUNNING_HUMANS_INFO+4						; Change human image to show
	ld 		a, (hl)
	dec  	a
	ld 		(hl),a
	cp   	0
	jp   	z, show_running_humans_from_right_set_first_image		
 	jp   	show_running_humans_from_right_loop	
show_running_humans_from_right_arrived:	 					; Running human from right arrived to your position
	
	ld		hl, RUNNING_HUMANS_INFO							
	ld		a, (hl)
	dec		a
	ld		(hl), a											; Decrement the remaining human to display number
	ld		hl, RUNNING_HUMANS_INFO+1 						; Set new stop position from running human from right
	ld		e, CHAR_STATIC_HUMAN 							
	ld		d, (hl)

	call 	show_running_humans_save_static_position		; Save static human position

	call 	show_running_humans_from_right_draw				; Print static human
	ld		hl, RUNNING_HUMANS_INFO+1  						; Set new stop position from running human from right
	ld		a, (hl)
	add		a, 4
	ld		(hl), a											; Update next stop position for running human from right
	jp		show_running_humans_next 	          

show_running_humans_save_static_position:

	ld		(LOOP_COUNTER), a								; Update static human counter

	ld		hl, HUMANS_POSITIONS
	call	add_8bit_16bit_values
	ld		(hl), d											; Save human position
	ld		a, (LOOP_COUNTER)
	inc		a
	ld		(LOOP_COUNTER), a								; Increase counter
	ret														
show_running_humans_from_right_draw:						; Print all human characters and print spaces for clear previous characters printed
	push 	bc
	push  	de
	ld    	a, d
	sub   	2
	ld    	b, 23
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc	  	e
	dec   	a
	ld    	b, 23
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc	  	e
	inc	  	e
	ld    	b, 23
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

    push 	bc
	push  	de
	ld    	a, d
	sub		2
	inc	  	e
	inc	  	e
	inc   	e
	ld    	b, 24
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	dec   	a
	inc	  	e
	inc	  	e
	inc   	e
	inc   	e
	ld    	b, 24
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc	  	e
	inc	  	e
	inc	  	e
	inc   	e
	inc   	e
	ld    	b, 24
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	sub		2
	inc	  	e
	inc	  	e
	inc	  	e
	inc   	e
	inc   	e
	inc   	e
	ld    	b, 25
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	dec   	a
	inc	  	e
	inc	  	e
	inc	  	e
	inc   	e
	inc   	e
	inc   	e
	inc   	e
	ld    	b, 25
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc	  	e
	inc	  	e
	inc	  	e
	inc	  	e
	inc   	e
	inc   	e
	inc   	e
	inc   	e
	ld    	b, 25
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc
 
	push 	bc
	push  	de
	ld    	a, d
	inc   	a
	ld    	b, 23
	ld    	c, a
	ld    	a, CHAR_SPACE
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc   	a
	ld    	b, 24
	ld    	c, a
	ld    	a, CHAR_SPACE
	call  	print_char_at
	pop   	de
	pop  	bc
	
	push 	bc
	push  	de
	ld    	a, d
	inc   	a
	ld    	b, 25
	ld    	c, a
	ld    	a, CHAR_SPACE
	call  	print_char_at
	pop   	de
	pop  	bc

	ret


show_running_humans_from_left_side:							; Show running human from left
	ld    	hl, RUNNING_HUMANS_INFO+3
	ld    	(hl),2											; Set current position to 2
show_running_humans_from_left_set_first_image:
	ld    	hl, RUNNING_HUMANS_INFO+4  	
	ld    	(hl), 4											; Set first human image
show_running_humans_from_left_loop: 	 	
	ld		hl, RUNNING_HUMANS_INFO+2						; Loop to show running human from left
 	ld   	b,(hl) 
	ld    	hl, RUNNING_HUMANS_INFO+3
 	ld   	a,(hl) 	  		
 	cp   	b												; check if human is in your final destination
 	jp   	z, show_running_humans_from_left_arrived 		; Human arrived to his final position
	ld   	d,a
	ld 		hl, RUNNING_HUMANS_INFO+4						; Change human image to show
	ld      a, (hl)
	ld 		h, 9
	call 	mult_8bit_values
	ld   	a, 128
	add  	a, l
	ld   	e, a
	ld 		hl, RUNNING_HUMANS_INFO+3						; Change human running position
 	ld   	a,(hl) 	
	ld		d, a
	call 	show_running_humans_from_left_draw				; Show human in new position
	ld   	bc,$0500
	call 	sleep											; sleep execution
	ld    	hl, RUNNING_HUMANS_INFO+3						; Change running human position
	ld		a,(hl)
 	inc  	a
	ld 		(hl),a
	ld 		hl, RUNNING_HUMANS_INFO+4						; Change human image to show
	ld 		a, (hl)
	dec  	a
	ld 		(hl),a
	cp   	0
	jp   	z, show_running_humans_from_left_set_first_image
 	jp   	show_running_humans_from_left_loop

show_running_humans_from_left_arrived:
	ld		hl, RUNNING_HUMANS_INFO					
	ld		a, (hl)
	dec		a
	ld		(hl), a									
	ld		hl, RUNNING_HUMANS_INFO+2 						; Set new stop position from running human from right
	ld		e, CHAR_STATIC_HUMAN
	ld		d, (hl)
	call 	show_running_humans_save_static_position		; Save static human position
	call 	show_running_humans_from_left_draw	
	ld		hl, RUNNING_HUMANS_INFO+2 						; Set new stop position from running human from right
	ld		a, (hl)
	sub		4
	ld		(hl), a
	jp		show_running_humans_next 	
show_running_humans_from_left_draw:							; Print all human characters and print spaces for clear previous characters printed
	push 	bc
	push  	de
	ld    	a, d
	ld    	b, 23
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc	  	e
	inc   	a
	ld    	b, 23
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc	  	e
	inc	  	e
	inc		a
	inc		a
	ld    	b, 23
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

    push 	bc
	push  	de
	ld    	a, d
	inc		e
	inc		e
	inc		e
	ld    	b, 24
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc 
	push  	de
	ld    	a, d
	inc   	a
	inc		e
	inc		e
	inc		e
	inc		e
	ld    	b, 24
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc		a
	inc		a
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	ld    	b, 24
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	ld    	b, 25
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	inc   	a
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	ld    	b, 25
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc

	push	bc
	push  	de
	ld    	a, d
	inc		a
	inc		a
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	inc		e
	ld    	b, 25
	ld    	c, a
	ld    	a, e
	call  	print_char_at
	pop   	de
	pop  	bc
 
	push 	bc
	push  	de
	ld    	a, d
	dec   	a
	ld    	b, 23
	ld    	c, a
	ld    	a, CHAR_SPACE
	call  	print_char_at
	pop   	de
	pop  	bc

	push 	bc
	push  	de
	ld    	a, d
	dec   	a
	ld    	b, 24
	ld    	c, a
	ld    	a, CHAR_SPACE
	call  	print_char_at
	pop   	de
	pop  	bc
	
	push 	bc
	push  	de
	ld    	a, d
	dec   	a
	ld    	b, 25
	ld    	c, a
	ld    	a, CHAR_SPACE
	call  	print_char_at
	pop   de
	pop  	bc

	ret

; --- SHOW HUMAN SHIP ---
show_human_ship:
	call	print_human_ship

; --- SETUP TIMERHOOK ---
setup_timerhook:
		di											; Disable interrupts
		ld a,#c3									; JP instruction opcode
		ld (HTIMI),a								; Load into the hook memory adress
		ld hl, timerhook							; Load the adress of the hook routine that's invokedl
		ld (HTIMI+1), hl 							; Load adress into hook after the jp instruction
		ei              							; Enable interrupts

; --- MAIN LOOP ---
main_loop:
	ld		hl, HUMAN_SHIP_INFO
	ld		a,(hl)									; Get human ship visible status
	cp		0
	jp		z, main_loop_after_keys					; If human ship is not visible the keys reading is not enabled
	ld		a,(KEYS+8)								
	bit		0,a				
	call	z, start_human_ship_fire				; key 'SPACE' pressed
	ld		a,(KEYS+8)								
	bit		4,a				
	call	z, start_human_ship_move_left			; Key 'LEFT ARROW' pressed
	ld		a,(KEYS+8)								
	bit		7,a				
	call	z, start_human_ship_move_right			; Key 'RIGHT ARROW' pressed
	ld		a,(KEYS+8)		
	bit		5,a				
	call	z, stop_human_ship_movement				; Key 'UP ARROW' pressed
	ld		a,(NEWKEY+1)	
	bit		0,a
	call	z, start_human_ship_fire				; Key '8' pressed
	ld		a,(NEWKEY+0)	
	bit		4,a
	call	z, start_human_ship_move_left			; Key '4' pressed
	ld		a,(NEWKEY+0)	
	bit		6,a
	call	z, start_human_ship_move_right			; Key '6' pressed
	ld		a,(NEWKEY+0)	
	bit		5,a
	call	z, stop_human_ship_movement				; Key '5' pressed

main_loop_after_keys:
	ld		hl,	HUMANS_COUNTER
	ld  	a, (hl)									; Get humans counter
	cp		0
	jp		z, game_over_lost						; Game over (lost)

	ld		hl, MARTIANS_COUNTER
	ld  	a, (hl)									; Get martians counter
	cp		0
	jp		z, game_over_win									; Game over (win)


	call	move_martians_bombs									; Move martians bombs
	call	move_martians_ships									; Move martians ships
	ld		hl, HUMAN_SHIP_INFO
	ld		a, (hl)												; Get human ship visible status
	cp		0													
	call	z, check_human_ship_visible							; Check if is possible to set human ship visible status to true
main_loop_timed_actions:
	xor 	a													; Set a to 0			
	ld 		hl, VBLANK_FLAG
	cp 		(hl)												; Check if vblankFlag=0
	jp 		z, main_loop 										; Skip timed instructions if vblankflag=0
	ld		hl, HUMAN_SHIP_INFO+2				
	ld		a, (hl)
	cp		1
	call	z, move_human_ship_to_right							; Move human ship to right if direction set
	cp		2
	call	z, move_human_ship_to_left							; Move human ship to left if direction set

	ld		hl, HUMAN_SHIP_INFO+3
	ld		a, (hl)												; Get human ship fire status
	cp		0
	call	z,	move_human_ship_bomb							; Human ship fire in action and bomb movement needed

	ld		hl, MARTIANS_SHIPS_INFO+1							; Get number of martians ships displayed
	ld		a, (hl)
	cp		4
	call	nz, new_martian_ship_to_show_evaluation				; Evaluate if to show a new martian ship
	call	martian_bomb_fire_evaluation						; Evaluate martians ships fire
    ld 		hl, VBLANK_FLAG										; Reset the vblankFlag
    ld		(hl), 0
	jp		main_loop											; Repeat loop

; --- TIMERHOOK ---
timerhook:
	ld 		hl, VBLANK_FLAG 
    ld 		(hl), 1
	ret
; --- CUSTOM CALLS ---
check_human_ship_visible:
	; --> CHECK IF IS POSSIBLE TO SET HUMAN SHIP VISIBLE STATUS TO TRUE
	ld		bc, (HUMAN_SHIP_INFO+8)								; Get timer counter
	dec		bc
	ld		(HUMAN_SHIP_INFO+8), bc
	ld		a, b
	cp		0
	ret		nz
	ld		a, c
	cp		0
	ret		nz													; Human ship must been hide because the timer is not zero
	ld		hl, HUMAN_SHIP_INFO
	ld		(hl),1												; Set human ship visible flag to true
	ld		hl, HUMAN_SHIP_INFO+3								; Enable human ship firing
	ld		(hl), 1
	call	print_human_ship
	ret
print_explosion:
	; --> SHOW EXPLOSION ON SCREEN
	; INPUT: C=Position X, B=Position Y
	push	bc
	call	print_explosion_1
	pop		bc
	push	bc
	ld		bc, 0fffh
	call	sleep
	pop		bc
	push	bc
	ld		bc, 0fffh
	call	sleep
	pop		bc
	push	bc
	ld		bc, 0fffh
	call	sleep
	pop		bc

	push	bc
	call	remove_explosion
	pop		bc
	;call   	set_explosion_in_progress
	ret
print_explosion_1:
	push	bc										; Backup BC registry to stack		

	ld		a, CHAR_EXPLOSION
	call 	print_char_at

	ld		a, CHAR_EXPLOSION
	inc		a
	inc		c
	call 	print_char_at

	dec		c
	ld		a, CHAR_EXPLOSION
	inc		a
	inc		a
	inc		b
	call 	print_char_at


	ld		a, CHAR_EXPLOSION
	inc		a
	inc		a
	inc		a
	inc		c
	call 	print_char_at

	pop 	bc										; Restore BC registry from stack

	ld		hl, HUMAN_EXPLOSION_FLAG
	ld		a,(hl)
	cp		1
	call	z, print_explosion_2


	ret
print_explosion_2:
	push	bc										; Backup BC registry to stack	

	ld		a, CHAR_EXPLOSION
	inc		a
	inc		a
	inc		a
	inc     a
	inc		c
	inc		c
	call 	print_char_at


	ld		a, CHAR_EXPLOSION
	inc		a
	inc		a
	inc		a
	inc     a
	inc		a
	inc		b
	call 	print_char_at

	pop 	bc										; Restore BC registry from stack

	ret
remove_explosion:
	; --> REMOVE EXPLOSION FROM SCREEN
	; INPUT: C=Position X, Y=Position Y

	push	bc										; Backup BC registry to stack	
	ld		a, CHAR_SPACE
	call 	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call 	print_char_at


	inc		b
	dec		c
	ld		a, CHAR_SPACE
	call 	print_char_at



	inc		c
	ld		a, CHAR_SPACE
	call 	print_char_at

	pop 	bc										; Restore BC registry from stack


	ld		hl, HUMAN_EXPLOSION_FLAG
	ld		a,(hl)
	cp		1
	call	z, remove_explosion_2

	ret
remove_explosion_2:

	ld		hl, HUMAN_EXPLOSION_FLAG
	ld		(hl), 0										; Reset human explosion type

	push	bc										; Backup BC registry to stack	
	inc		c
	inc		c
	ld		a, CHAR_SPACE
	call 	print_char_at


	inc		b
	ld		a, CHAR_SPACE
	call 	print_char_at

	pop 	bc										; Restore BC registry from stack
	ret



game_over_lost:
	; --> GAME OVER (LOST)
	call	clear_all_humans

	ld		hl, TXT_LOSE_1
	ld		c, 34
	ld		b, 21
	call    print_string_at

	ld		hl, TXT_LOSE_2
	ld		c, 10
	ld		b, 23
	call    print_string_at

	ld		hl, TXT_PLAY_AGAIN
	ld		c, 27
	ld		b, 25
	call    print_string_at
	jp 		waiting_enter_on_presentation

game_over_win:
	; --> GAME OVER (WIN)
	call 	remove_human_ship
	call	clear_all_humans

	ld		hl, TXT_WIN_1
	ld		c, 32
	ld		b, 21
	call    print_string_at

	ld		hl, TXT_WIN_2
	ld		c, 20
	ld		b, 23
	call    print_string_at

	ld		hl, TXT_PLAY_AGAIN
	ld		c, 27
	ld		b, 25
	call    print_string_at
	jp 		waiting_enter_on_presentation
clear_all_humans:
	; --> CLEAR ALL CHARACTERS ON STATIC HUMANS SCREEN ROWS
clear_all_humans_21:
	ld		a, 0
	ld		b, 21
clear_all_humans_loop_21:
	inc		a
	ld		e, a
	cp		78
	jp		z, clear_all_humans_22
	ld		c, a
	ld		a, CHAR_SPACE
	call	print_char_at
	ld		a, e
	jp		clear_all_humans_loop_21
clear_all_humans_22:
	ld		a, 0
	ld		b, 22
clear_all_humans_loop_22:
	inc		a
	ld		e, a
	cp		78
	jp		z, clear_all_humans_23
	ld		c, a
	ld		a, CHAR_SPACE
	call	print_char_at
	ld		a, e
	jp		clear_all_humans_loop_22
clear_all_humans_23:
	ld		a, 0
	ld		b, 23
clear_all_humans_loop_23:
	inc		a
	ld		e, a
	cp		78
	jp		z, clear_all_humans_24
	ld		c, a
	ld		a, CHAR_SPACE
	call	print_char_at
	ld		a, e
	jp		clear_all_humans_loop_23
clear_all_humans_24:
	ld		a, 0
	ld		b, 24
clear_all_humans_loop_24:
	inc		a
	ld		e, a
	cp		78
	jp		z, clear_all_humans_25
	ld		c, a
	ld		a, CHAR_SPACE
	call	print_char_at
	ld		a, e
	jp		clear_all_humans_loop_24
clear_all_humans_25:
	ld		a, 0
	ld		b, 25
clear_all_humans_loop_25:
	inc		a
	ld		e, a
	cp		78
	ret		z
	ld		c, a
	ld		a, CHAR_SPACE
	call	print_char_at
	ld		a, e
	jp		clear_all_humans_loop_25




remove_human_ship:
	; MODIFY: HL, DE, BC
	ld		hl, HUMAN_SHIP_INFO
	ld		(hl),0								; Set human ship visible flag to false
	ld		a, 1								; Reset column counter
remove_human_ship_loop:				
	cp		78
	ret		z									; end of remove ship action
	push	de
	push	bc
	ld		e, a
	ld		c, a
	ld		b, 22
	ld		a, CHAR_SPACE
	call	print_char_at
	ld		a, e
	pop		bc
	pop		de

	push	de
	push	bc
	ld		e, a
	ld		c, a
	ld		b, 21
	ld		a, CHAR_SPACE
	call	print_char_at
	ld		a, e
	pop		bc
	pop		de

	inc		a
	jp		remove_human_ship_loop
	ret
move_martians_bombs:
	; --> MOVE MARTIANS BOMBS ON SCREEN
	ld		hl, LOOP_COUNTER
	ld		(hl), 0												; Reset counter

move_martians_bombs_loops:
	ld		hl, LOOP_COUNTER
	ld		a, (hl)
	cp		100
	ret 	z 													; All bombs processed
	ld		hl, MARTIAN_BOMBS									; Get first X element address of bombs array
	call	add_8bit_16bit_values								; Get current X element address of bombs array
	ld		a, 100												; Add 100 positions to X element address for to find Y element address
	call	add_8bit_16bit_values
	ld		a, (hl)												; Get current bomb Y position
	cp		0
	call	nz, move_martians_bombs_ok							; Move martians bomb
	ld		hl, LOOP_COUNTER
	ld		a, (hl)												; Get current bomb array index
	inc		a													; Increment array index
	ld		(hl), a												; Save new counter of array index position
	jp 		move_martians_bombs_loops
move_martians_bombs_ok:
	ld		hl, LOOP_COUNTER	
	ld		a, (hl)												; Get current array index
	ld		hl, MARTIAN_BOMBS									; Get first X element address of bombs array
	call	add_8bit_16bit_values								; Get current X element address of bombs array
	ld		c, (hl)
	ld		a, 100												; Add 100 positions to X element address for to find Y element address
	call	add_8bit_16bit_values
	ld		b, (hl)	
	call	remove_martian_ship_bomb							; Remove bomb from actual position
	ld		a, b
	inc		a													; Increment Y position
	ld		(hl), a												; Save new Y position in array
	cp		26
	jp		z, move_martians_bombs_clear_array					; Clear array for no printed bomb
	ld		hl, LOOP_COUNTER
	ld		a, (hl)
	call	check_martian_ship_bomb_collision					; Collision verify
	cp		1
	ret		z													; Collision detected (exit without print bomb)
	call	print_martian_ship_bomb
	ret
move_martians_bombs_clear_array:
	ld		hl, LOOP_COUNTER	
	ld		a, (hl)												; Get current array index
	ld		hl, MARTIAN_BOMBS									; Get first X element address of bombs array
	call	add_8bit_16bit_values								; Get current X element address of bombs array
	ld		(hl), 0												; Reset X position
	ld		a, 100												; Add 100 positions to X element address for to find Y element address
	call	add_8bit_16bit_values
	ld		(hl), 0												; Reset Y position
	ret
martian_bomb_fire_evaluation:
	ld		hl, MARTIANS_SHIPS_INFO+22
	ld		(hl), -1											; Reset martian ship counter	
martian_bomb_fire_evaluation_loop:
	ld		hl, MARTIANS_SHIPS_INFO+22
	ld		a, (hl)												; Get martian ship counter	
	inc		a													; Increase counter
	cp		4
	ret		z 													; Return after loop of all potential martians ships on screen
	ld		hl, MARTIANS_SHIPS_INFO+22
	ld		(hl), a												; Set martian ship counter	
	ld		hl, MARTIANS_SHIPS_INFO+2
	call	add_8bit_16bit_values
	ld		a, (hl)
	cp		0
	jp		z, martian_bomb_fire_evaluation_loop				; No martian ship presen on screen with currend index
	call	generate_new_random_martian_bomb_number				; Get random number
	ld		hl, MARTIANS_SHIPS_INFO								; Get bomb fire ratio
	cp		(hl)
	call	c, martian_bomb_fire_evaluation_ok					; Fire bomb
	jp		martian_bomb_fire_evaluation_loop
martian_bomb_fire_evaluation_ok:
	ld		hl, MARTIANS_SHIPS_INFO+22
	ld		a, (hl)												; Get martian ship id	
	ld		hl, MARTIANS_SHIPS_INFO+2
	call	add_8bit_16bit_values
	ld		c, (hl)												; Get X martian ship position												; Invalid X martian ship position
	ld		hl, MARTIANS_SHIPS_INFO+22
	ld		a, (hl)												; Get martian ship id
	ld		hl, MARTIANS_SHIPS_INFO+6
	call	add_8bit_16bit_values
	ld		b, (hl)												; Get Y martian ship position
	call	martian_bomb_fire_evaluation_first_index_avaible
	cp		100
	ret		z 													; No free bomb array index found
	inc		b													; Increase Y pos 2 times for display bomb under the ship
	inc		b
	inc 	c													; Increase X pos for display bomb at half ship position
	call	upgrade_martian_bomb_position
	call	print_martian_ship_bomb
	ret

martian_bomb_fire_evaluation_first_index_avaible:
	push	bc
	ld		a,0
martian_bomb_fire_evaluation_first_index_avaible_loop:
	cp		100
	jp		z, martian_bomb_fire_evaluation_first_index_avaible_no_found
	ld		c, a
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		a,(hl)
	cp		0
	jp		z, martian_bomb_fire_evaluation_first_index_avaible_loop_end
	ld		a, c 
	inc		a
	jp		martian_bomb_fire_evaluation_first_index_avaible_loop
martian_bomb_fire_evaluation_first_index_avaible_loop_end:
	ld		a,c
	pop		bc
	ret
martian_bomb_fire_evaluation_first_index_avaible_no_found:
	ld		c, 100
	jp 		martian_bomb_fire_evaluation_first_index_avaible_loop_end
reset_martians_bombs_positions:
	xor		a												; Reset counter
	ld		hl, MARTIAN_BOMBS
reset_martians_bombs_positions_loop:
	cp		100
	ret		z 												; All positions reset
	push	af												; Backup AF registry to stack
	push	hl												; Backup HL registry to stack
	ld		(hl), 0
	ld		a, 100
	call	add_8bit_16bit_values
	ld		(hl), 0
	pop 	hl												; Restore HL registry from stack
	pop 	af												; Restore AF registry from stack
	inc		hl
	inc    	a
	jp		reset_martians_bombs_positions_loop
remove_martian_ship_bomb:
	; --> REMOVE MARTIAN SHIP BOMB
	; 	  INPUT: C=X position, B=Y position
	;	  MODIFY: AF						
	ld		a, b
	cp		0
	ret		z								 ; No valid Y position
	push	bc								; Backup BC registry to stack
	ld		a, CHAR_SPACE
	call	print_char_at					; Print space at bomb position
	inc		c
	ld		a, CHAR_SPACE					; Print space at bomb position (X+1)
	call	print_char_at
	pop		bc								; Restore BF registry from stack
	ret
print_martian_ship_bomb:
	; --> PRINT MARTIAN SHIP BOMB
	; 	  INPUT: A=ArrayPosition
	push	bc								; Backup BC registry to stack
	push	af								; Backup AF registry to stack
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		c,(hl)							; Get X position
	pop 	af								; Restore AF registry from stack
	add		a, 100
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		b,(hl)							; Get Y position
	ld		a, b
	cp		0
	jp		z, print_martian_ship_bomb_end ; No valid Y position
	ld		a, CHAR_BOMB
	call	print_char_at
	inc		c
	ld		a, CHAR_BOMB
	inc		a
	call	print_char_at
print_martian_ship_bomb_end:
	pop		bc							; Restore BF registry from stack
	ret
upgrade_martian_bomb_position:
	; --> UPGRADE MARTIAN SHIP BOMB POSITION
	;	  INPUT: C=Position X, B=Position Y, A=Array index
	push	af								; Backup AF registry to stack
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		(hl), c							; Save X position

	pop 	af								; Restore AF registry from stack
	push	af								; Backup AF registry to stack

	add		a, 100	
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	
	ld		(hl), b							; Save Y position

	pop 	af								; Restore AF registry from stack
	ret
draw_war_field_left_line:
	ld    	c, 0
	ld		b, 25
draw_war_field_left_line_loop:
	ld    	a, CHAR_VERTICAL
	call  	print_char_at
	dec		b
	ld		a, b
	cp		0
	ret		z
	jp		draw_war_field_left_line_loop
draw_war_field_right_line:
	ld    	c, 78
	ld		b, 25
draw_war_field_right_line_loop:
	ld    	a, CHAR_VERTICAL
	call  	print_char_at
	dec		b
	ld		a, b
	cp		3
	ret		z
	jp		draw_war_field_right_line_loop
	ret
move_martians_ships:
	ld		hl, MARTIANS_SHIPS_INFO+24
	ld		a, (hl) 										; Get martians ships speed counter
	inc		a												; Increment martian speed counter
	ld		(hl), a											; Save new martian speed counter
	ld		hl, MARTIANS_SHIPS_INFO+23						; Get martian ship speed
	cp		(hl)
	ret		nz												; No time to move

	ld		hl, MARTIANS_SHIPS_INFO+24
	ld		(hl), 0 										; Reset martians ships speed counter
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		(hl), 0											; Reset martians ship index
	xor		a												; reset A registry
move_martians_ships_loop:
	cp		4
	ret		z												; No more ships to move
	ld 		hl, MARTIANS_SHIPS_INFO+6						
	call	add_8bit_16bit_values
	ld		b,(hl)											; Get Y position
	ld		a,b
	cp		0
	jp		z, move_martians_ships_next
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld 		hl, MARTIANS_SHIPS_INFO+14						
	call	add_8bit_16bit_values
	ld		a,(hl)											; Get if direction is changhed
	cp		0
	call	z, move_martians_ships_change_direction_verify
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld 		hl, MARTIANS_SHIPS_INFO+2						
	call	add_8bit_16bit_values
	ld		c,(hl)											; Get X position
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld 		hl, MARTIANS_SHIPS_INFO+10						
	call	add_8bit_16bit_values
	ld		d,(hl)											; Get current direction
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	call	move_martians_ships_execute						; move ship
	
	call	update_martian_ship_position_info				; Put new coordinates into info array

	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld		hl, MARTIANS_SHIPS_INFO+18						
	call	add_8bit_16bit_values
	ld		d, (hl)											; Get martians ship type

	call	move_martian_ship_change_type					; change ship type

	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld		hl, MARTIANS_SHIPS_INFO+18						
	call	add_8bit_16bit_values
	ld		(hl), d											; Set martians ship type

	
	call	print_martian_ship
move_martians_ships_next:
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	inc 	a
	ld		(hl), a											; Save new martians ship index
	jp		move_martians_ships_loop
move_martian_ship_change_type:
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld		hl, MARTIANS_SHIPS_INFO+18									
	call	add_8bit_16bit_values		
	ld		a, (hl)											; Get martian ship type from array index found

	cp		CHAR_MARTIAN_SHIP_1_A
	jp		z, move_martian_ship_change_type_1_B
	cp		CHAR_MARTIAN_SHIP_1_B
	jp		z, move_martian_ship_change_type_1_A
	cp		CHAR_MARTIAN_SHIP_2_A
	jp		z, move_martian_ship_change_type_2_B
	cp		CHAR_MARTIAN_SHIP_2_B
	jp		z, move_martian_ship_change_type_1_B
	cp		CHAR_MARTIAN_SHIP_3_A
	jp		z, move_martian_ship_change_type_3_B
	cp		CHAR_MARTIAN_SHIP_3_B
	jp		z, move_martian_ship_change_type_3_A

move_martian_ship_change_type_1_A:
	ld		d, CHAR_MARTIAN_SHIP_1_A
	ret
move_martian_ship_change_type_1_B:
	ld		d, CHAR_MARTIAN_SHIP_1_B
	ret
move_martian_ship_change_type_2_A:
	ld		d, CHAR_MARTIAN_SHIP_2_A
	ret
move_martian_ship_change_type_2_B:
	ld		d, CHAR_MARTIAN_SHIP_2_B
	ret
move_martian_ship_change_type_3_A:
	ld		d, CHAR_MARTIAN_SHIP_3_A
	ret
move_martian_ship_change_type_3_B:
	ld		d, CHAR_MARTIAN_SHIP_3_B
	ret
move_martians_ships_change_direction_verify:
	ld		a, c
	cp		20
	jp		z,move_martians_ships_change_direction_pre_evaluation
	cp		35
	jp		z,move_martians_ships_change_direction_pre_evaluation
	cp		42
	jp		z,move_martians_ships_change_direction_pre_evaluation
	cp		63
	jp		z,move_martians_ships_change_direction_pre_evaluation
	ret
move_martians_ships_change_direction_pre_evaluation:
	ld		a, b
	cp		2
	ret		z
move_martians_ships_change_direction_evaluation:
	call	generate_new_random_number
	cp		50
	ret		nc
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld 		hl, MARTIANS_SHIPS_INFO+14						
	call	add_8bit_16bit_values
	ld		(hl),1											; Update flag direction changed
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld 		hl, MARTIANS_SHIPS_INFO+10
	call	add_8bit_16bit_values							
	ld		a,(hl)											; Get actual direction
	cp		1
	call	z, move_martians_ships_change_direction_change_left
	call	nz, move_martians_ships_change_direction_change_right
	ret
move_martians_ships_change_direction_change_left:
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld 		hl, MARTIANS_SHIPS_INFO+10
	call	add_8bit_16bit_values		
	ld		(hl), 2											; Update martian ship direction
	ret
move_martians_ships_change_direction_change_right:
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index
	ld 		hl, MARTIANS_SHIPS_INFO+10
	call	add_8bit_16bit_values		
	ld		(hl), 1											; Update martian ship direction
	ret

move_martians_ships_execute:
	ld		a,d
	cp		2
	jp		z, move_martians_ships_execute_to_right
move_martians_ships_execute_to_left:
	dec		c												; Decrement X position
	ld		a,c
	cp		0
	jp		z, move_martians_ships_execute_remove			; Remove ship because it is on left limit
	ret
move_martians_ships_execute_to_right:	
	ld		d,74											; Right limit X position to check
	ld		a,b
	cp		2
	call	z, move_martians_ships_execute_to_right_change	; If Y position is 2 the X right limit become 58
	ld		a,c
	cp		d	
	jp		z, move_martians_ships_execute_remove			; Remove ship because it is on right limit
	inc		c												; Increase X position
	ret
move_martians_ships_execute_to_right_change:
	ld		d, 58
	ret
move_martians_ships_execute_remove:
	call	remove_martian_ship
	ld		c,0
	ld		b,0
	ret
remove_martian_ship:
	; --> REMOVE MARTIAN SHIP FROM SCREEN
	; 	  INPUT: c=Pos X, b=Pos Y
	;     MODIFY: AF
	push	bc											; Backup BC registry to stack
	ld		a, CHAR_SPACE							
	call	print_char_at								; Remove position 1_1
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 1_2
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 1_3
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 1_4
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 1_4+1
	inc		b
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 2_4+1
	dec		c
	ld		a, CHAR_SPACE								
	call	print_char_at								; Remove position 2_4
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 2_3
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 2_2
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 2_1
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 2_1-1
	dec		b
	ld		a, CHAR_SPACE
	call	print_char_at								; Remove position 2_1-1
	ld		hl, MARTIANS_SHIPS_INFO+1
	ld		a, (hl)
	dec		a
	ld		(hl), a										; Decrement amount of showed ships
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)										; Get martians ship index
	ld		hl, MARTIANS_SHIPS_INFO+14
	call	add_8bit_16bit_values
	ld		(hl), 0										; Reset flag change direction
	pop 	bc											; Restore BC registry from stack
	ret
update_martian_ship_position_info:
	; --> UPDATE MARTIAN SHIP POSITION INFO
	;     INPUT: A=Array index, B=Position Y, C=Position X
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship index										; Put counter into stack
	ld 		hl, MARTIANS_SHIPS_INFO+6						
	call	add_8bit_16bit_values
	ld		(hl), b
	ld		hl, MARTIANS_SHIPS_INFO+22						
	ld		a, (hl)											; Get martians ship inremove_martian_shipdex
	ld 		hl, MARTIANS_SHIPS_INFO+2						
	call	add_8bit_16bit_values
	ld		(hl), c											; Get X position
	ret
get_first_free_martian_ship_aray_index:
	; --> GET FIRST FREE MARTIAN SHIP ARRAY POSITION
	;     OUTPUT: A=position found
	;     MODIFY: AF
	push	hl															; Backup HL registry to stack
	ld		a,0
get_first_free_martian_ship_aray_index_loop:
	push	af															; Put AF registry to stack for save the counter
	ld		hl, MARTIANS_SHIPS_INFO+2
	call	add_8bit_16bit_values
	ld		a,(hl)
	cp		0
	jp		z, get_first_free_martian_ship_aray_index_loop_end
	pop		af															; Restore AF for to retrieve the counter
	inc		a
	jp		get_first_free_martian_ship_aray_index_loop
get_first_free_martian_ship_aray_index_loop_end:
	pop		af															; Restore AF for to retrieve the counter
	pop		hl															; Restore HL registry from stack
	ret
 
new_martian_ship_to_show_evaluation:
	; --> NEW MARTIAN SHIP TO SHOW EVALATION
	;	  MODIFY: DE, HL, BC, AF
	ld		hl, MARTIANS_SHIPS_INFO+1							; Get number of martians ships displayed
	ld		a, (hl)
	
	ld		hl, MARTIANS_COUNTER
	cp		(hl)
	
	ret		nc															; return because remain martians ships are less 

	ld		a,	r
	cp		6
	ret		nc															; No new martian ship needed to display
	
	call 	get_first_free_martian_ship_aray_index

	ld		c, 74														; New martian ship start position
	ld		d, 1														; New martian ship start direction from right
	call	generate_new_random_number
	cp		125
	call	nc, new_martian_ship_to_show_evaluation_from_left			; Change new martian ship start position and direction

	call 	get_first_free_martian_ship_aray_index						; Get free array index
	push	af															; Save array index found
	ld		hl, MARTIANS_SHIPS_INFO+10									
	call	add_8bit_16bit_values
	ld		(hl),d														; Put direction into array index found
	pop		af															; Restore array index found
	push	af															; Save array index found												
	ld		d, 0
	call	generate_new_random_number									; Type of martians ship to show determination
	cp		255
	call	c, new_martian_ship_to_show_evaluation_ship_1
	cp		150
	call	c, new_martian_ship_to_show_evaluation_ship_2
	cp		80
	call	c, new_martian_ship_to_show_evaluation_ship_3
	pop		af															; Restore array index found
	push	af															; Save array index found
	ld		hl, MARTIANS_SHIPS_INFO+18									
	call	add_8bit_16bit_values		
	ld		(hl), d														; Put martian ship type into array index found

	call	generate_new_random_number 									; Y position of martians ship to show determination
	ld		b,2
	cp		200
	call	c, new_martian_ship_to_show_evaluation_row_4				; Row 4 selected
	cp		150
	call	c, new_martian_ship_to_show_evaluation_row_6				; Row 6 selected
	cp		100
	call	c, new_martian_ship_to_show_evaluation_row_8				; Row 8 selected
	cp		50
	call	c, new_martian_ship_to_show_evaluation_row_10				; Row 10 selected

	
	pop		af															; Restore array index found
	push	af															; Save array index found
	ld		hl, MARTIANS_SHIPS_INFO+10									
	call	add_8bit_16bit_values
	ld		d,(hl)														; Get direction from array index found (because if row is busy and new proposed row changed to 2 the start position will be from left)
	pop		af															; Restore array index found
	push	af															; Save array index found

	call	new_martian_ship_to_show_evaluation_ver_pos					; Change Y position if it's busy from another ship
	
	ld		a, b
	cp		2
	jp		z, new_martian_ship_to_show_valid_row	
	cp		4
	jp		z, new_martian_ship_to_show_valid_row	
	cp		6
	jp		z, new_martian_ship_to_show_valid_row	
	cp		8
	jp		z, new_martian_ship_to_show_valid_row	
	cp		10
	jp		z, new_martian_ship_to_show_valid_row	
	jp		new_martian_ship_to_show_invalid_row						; No valid row for martian ship
new_martian_ship_to_show_valid_row:
	pop		af															; Restore array index found
	push	af															; Save array index found
	ld		hl, MARTIANS_SHIPS_INFO+2									
	call	add_8bit_16bit_values		
	ld		(hl), c														; Put X position into array index found
	pop		af															; Restore array index found
	push	af															; Save array index found
	ld		hl, MARTIANS_SHIPS_INFO+6									
	call	add_8bit_16bit_values		
	ld		(hl), b														; Put Y position into array index found
	pop		af															; Restore array index found
	push	af															; Save array index found
	ld		hl, MARTIANS_SHIPS_INFO+10									
	call	add_8bit_16bit_values		
	ld		(hl), d														; Put direction from array index found
	pop		af															; Restore array index found
	push	af															; Save array index found
	ld		hl, MARTIANS_SHIPS_INFO+18									
	call	add_8bit_16bit_values		
	ld		d, (hl)														; Get martian ship type from array index found
	pop		af															; Restore array index found
	call	print_martian_ship
	ld		hl, MARTIANS_SHIPS_INFO+1
	ld		a, (hl)														; Get number of martians ships on screen
	inc		a															; Increment number of martians ships on screen
	ld		(hl), a														; Save new number of martians ships on screen
	ret								
new_martian_ship_to_show_evaluation_from_left:
	ld		c, 1														; New martian ship start position
	ld		d, 2														; New martian ship start direction from left
	ret
new_martian_ship_to_show_evaluation_ship_1:
	ld d, CHAR_MARTIAN_SHIP_1_A
	ret
new_martian_ship_to_show_evaluation_ship_2:
	ld d, CHAR_MARTIAN_SHIP_2_A
	ret
new_martian_ship_to_show_evaluation_ship_3:
	ld d, CHAR_MARTIAN_SHIP_3_A
	ret
new_martian_ship_to_show_evaluation_row_4:
	ld		b, 4
	ret
new_martian_ship_to_show_evaluation_row_6:
	ld		b, 6
	ret
new_martian_ship_to_show_evaluation_row_8:
	ld		b, 8
	ret
new_martian_ship_to_show_evaluation_row_10:
	ld		b, 10
	ret
new_martian_ship_to_show_evaluation_ver_pos:
	ld		a,	0
new_martian_ship_to_show_evaluation_ver_pos_loop:
	cp		4
	jp		z,new_martian_ship_to_show_evaluation_ver_pos_row2			; Proposed Y position is free
	push	af															; Backup conter to stack
	ld		hl, MARTIANS_SHIPS_INFO+6
	call	add_8bit_16bit_values
	ld		a, (hl)
	cp		b
	jp		z, new_martian_ship_to_show_evaluation_ver_pos_busy			; Proposed Y position is busy
	pop		af															; Restore counter from stack
	inc		a
	jp 		new_martian_ship_to_show_evaluation_ver_pos_loop
new_martian_ship_to_show_evaluation_ver_pos_busy:
	pop		af															; Restore counter from stack
	ld		a, 0					
new_martian_ship_to_show_evaluation_ver_pos_busy_loop:	
	push	af															; Backup conter to stack	
	ld		e, a																			
	ld		hl, MARTIANS_SHIPS_INFO+6
	call	add_8bit_16bit_values
	ld		a, (hl)
	cp		0
	jp		z, new_martian_ship_to_show_evaluation_ver_pos_busy_end		; Avaible free Y position found
	pop		af															; Restore counter from stack
	inc		a
	jp 		new_martian_ship_to_show_evaluation_ver_pos_busy_loop
new_martian_ship_to_show_evaluation_ver_pos_busy_end:
	ld		b, e
	pop		af															; Restore counter from stack
	ld		a, 2
	cp		b
	ret		nz															; if not new proposet Y position is equals 2 then it's valid
	ld		d, 2														; Force direction for row 2 from left
new_martian_ship_to_show_evaluation_ver_pos_row2:
	ld		a, b
	cp		2
	ret		nz															; If not Y is 2 each X position is ok
	ld		a, c
	cp		1
	ret		z															; If not Y is 2 and X=1 position is ok
	ld		c, 58														; Set X position on row 2 for direction from right
	ret
new_martian_ship_to_show_invalid_row:
	pop		af
	ret
add_8bit_16bit_values:
	; --> ADD 8 BIT REGISTRY VALUE TO A 16 BIT REGISTRY VALUE
	; 	  INPUT: HL=destination registry, A=Value to add
	add   a, l   
	ld    l, a    
	adc   a, h    
	sub   l       
	ld    h, a    
	ret
print_martian_ship:
	; INPUT: c=Pos X, b=Pos Y, d=First character code
	; MODIFY: AF



	push	hl													; Backup HL registry to stack
	push	de													; Backup DE registry to stack
	push	bc													; Backup BC registry to stack

	
	ld		a, c
	cp		0
	jp		z, print_martian_ship_end							; Invalid X position

	ld		a, b
	cp		0
	jp		z, print_martian_ship_end							; Invalid Y position

	dec		c
	ld		a, CHAR_SPACE										; Clear space before
	call	print_char_at

	inc		b
	ld		a, CHAR_SPACE										; Clear space before
	call	print_char_at

	dec		b													; Restore initial Y coordinate
	inc		c													; Restore initial X coordinate

	inc		c
	inc		c
	inc		c
	inc		c
	ld		a, CHAR_SPACE										; Clear space after
	call	print_char_at

	inc		b
	ld		a, CHAR_SPACE										; Clear space after
	call	print_char_at

	dec		b													; Restore initial Y coordinate
	dec		c
	dec		c
	dec		c
	dec		c													; Restore initial X coordinate

	


	ld		a, d
	call	print_char_at										; Print character 1_1 of martian ship


	inc     d
	inc		c
	ld		a, d
	call	print_char_at										; Print character 2_1 of martian ship

	inc     d
	inc		c
	ld		a, d
	call	print_char_at										; Print character 3_1 of martian ship

	inc     d
	inc		c
	ld		a, d
	call	print_char_at										; Print character 4_1 of martian ship


	inc     d
	dec		c
	dec		c
	dec		c
	inc		b
	ld		a, d
	call	print_char_at										; Print character 2_1 of martian ship

	inc     d
	inc		c
	ld		a, d
	call	print_char_at										; Print character 2_2 of martian ship

	inc     d
	inc		c
	ld		a, d
	call	print_char_at										; Print character 2_3 of martian ship

	inc     d
	inc		c
	ld		a, d
	call	print_char_at										; Print character 2_4 of martian ship

print_martian_ship_end:
	call	draw_war_field_left_line							; Restore left vertical borders
	call	draw_war_field_right_line							; Restore right vertical borders
	call	draw_war_field_info_box								; Restore info box borders

	pop		bc													; Restore HL registry from stack
	pop		de													; Restore DE registry from stack
	pop		hl													; Restore BC registry from stack
	ret

generate_new_random_number:
	; --> GENERATE A RANDOM NUMBER
	; OUTPUT: A=Generated random number (0<=a<=255)
	; MODIFY: AF
	push	bc
	ld		a,(RANDOM_SEED)
	ld		b, a
	add		a, a
	add		a, a
	add		a, b
	inc		a
	ld		(RANDOM_SEED),a
	pop	bc
	ret
generate_new_random_martian_bomb_number:
	; --> GENERATE A RANDOM NUMBER (FOR MARTIAN SHIP FIRE EVALUATION ONLY
	; OUTPUT: A=Generated random number (0<=a<=255)
	; MODIFY: AF
	push	bc
	ld		a, r
	ld		b, a
	add		a, a
	add		a, a
	add		a, b
	inc		a
	pop	bc
	ret
reset_matians_info:
	; --> RESET ALL SHIPS MARTINS INFO
	;     MODIFY: AF, HL
	ld		hl, MARTIANS_SHIPS_INFO
	ld		a, 0
reset_matians_info_loop:
	cp		25
	ret		z
	ld		(hl), 0
	inc		hl
	inc 	a
	jp		reset_matians_info_loop
move_human_ship_bomb:
	; --> MOVE HUMAN SHIP BOMB
	;     MODIFY: BC, HL, AF
	 
	call    move_human_ship_bomb_detect_top_side
	cp		0
	jp		z, move_human_ship_bomb_x							
	call	remove_human_ship_bomb								; Bomb arrived to top of screen and its removing needed
	ld		hl, HUMAN_SHIP_INFO+6								
	ld		(hl), 0												; Reset human ship bomb current X position
	ld		hl, HUMAN_SHIP_INFO+7								
	ld		(hl), 0												; Reset human ship bomb current Y position
	ld		hl, HUMAN_SHIP_INFO+3								
	ld		(hl), 1												; Set human ship "can fire" flag status to true
	ret
move_human_ship_bomb_x:
	ld		hl, HUMAN_SHIP_INFO+7
	ld		b, (hl) 											; Get human ship bomb current Y position
	ld		hl, HUMAN_SHIP_INFO+6
	ld		c, (hl)												; Get human ship bomb current X position
	ld		a, b
	cp		0
	ret		z													; No valid X position
	call	check_human_ship_bomb_collision						; Collision detecting
	cp		CHAR_SPACE
	ret		nz													; Bomb destroyed
	call	remove_human_ship_bomb								; Remove human ship bomb from current position											; Decrement bomb Y position
	ld		hl, HUMAN_SHIP_INFO+7								
	ld		(hl), b												; Save human ship bomb current Y position
	call	print_human_ship_bomb								; Print human ship bomb into a new position
	ret
move_human_ship_bomb_detect_top_side:
	ld		hl, HUMAN_SHIP_INFO+7
	ld		a, (hl) 											; Get human ship bomb current Y position
	cp		1
	ret		z													; Top border detected
	cp		4
	jp		nz, move_human_ship_bomb_detect_top_side_end		; Not in info box top level
	ld		hl, HUMAN_SHIP_INFO+6
	ld		a, (hl) 											; Get human ship bomb current X position
	cp		63
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		64
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		65
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		66
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		67
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		68
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		69
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		70
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		71
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		72
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		73
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		74
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		75
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		76
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
	cp		77
	jp		z, move_human_ship_bomb_detect_top_side_detected		; It's a info box top level
move_human_ship_bomb_detect_top_side_end:
	ld		a, 0												; No top border detected
	ret
move_human_ship_bomb_detect_top_side_detected:
	ld		a, 1												; Top border detected
	ret
check_human_ship_bomb_collision:
	; --> HUMAN SHIP BOMB COLLISION DETECTION
	ld		hl, HUMAN_SHIP_INFO+6
	ld		c, (hl)												; Get human bomb X position
	ld		a, c
	cp		0
	ret     z													; No human ship bomb present on screen
	ld		hl, HUMAN_SHIP_INFO+7
	ld		b, (hl)												; Get human bomb Y position
	dec		b													; Check next Y position
	call	read_char_at
	cp		CHAR_SPACE
	ret		z													; No collision detected
	cp		CHAR_BOMB									
	jp		z, check_human_ship_bomb_collision_mrtz_bomb		; Collision with martian bomb detected
	ld		hl, LOOP_COUNTER
	ld		(hl), 0												; Reset martian ships counter
check_human_ship_bomb_collision_martian_ship_loop:
	ld		hl, LOOP_COUNTER
	ld		a, (hl)
	cp		4
	ret		z													; Martian ship not found (why????)
	ld		hl, MARTIANS_SHIPS_INFO+6
	call	add_8bit_16bit_values
	ld		a, (hl)		
	inc		a													; Get martian ship Y-1 position
	cp		b
	jp		z, check_human_ship_bomb_collision_martian_ship		; Remove martian ship
	ld		hl, LOOP_COUNTER
	ld		a, (hl)												; Put current counter in A registry
	inc 	a													; A registry increment
	ld		(hl), a												; Update corrent counter
	jp 		check_human_ship_bomb_collision_martian_ship_loop
	
check_human_ship_bomb_collision_martian_ship:
	push	bc													; Backup BC registry to stack
	
	ld		hl, LOOP_COUNTER									; Get martian ship array index
	ld		a, (hl)												; Put martian ship array index in A registry
	ld		hl, MARTIANS_SHIPS_INFO+2
	call	add_8bit_16bit_values
	ld		c, (hl)												; Get martian ship X position
	ld		(hl), 0												; Reset martian ship X position
	ld		hl, LOOP_COUNTER
	ld		a, (hl)												; Get martian ship array index
	ld		hl, MARTIANS_SHIPS_INFO+6
	call	add_8bit_16bit_values
	ld		b, (hl)												; Get martian ship Y position
	ld		(hl), 0												; Reset martian ship Y position
	ld		hl, MARTIANS_SHIPS_INFO+6
	call	remove_martian_ship									; Remove martian ship
	ld		hl, MARTIANS_SHIPS_INFO+6
	pop		bc													; Restore BC registry from stack
	call	print_explosion
	ld		hl, MARTIANS_COUNTER
	ld		a, (hl)												; Get martian ships counter
	dec		a													; Decrease martians ships counter
	ld		(hl), a												; Save new martians ship counter
	call	refresh_martians_counter							; Refresh screen martians ships info

check_human_ship_bomb_collision_end:
	call	remove_human_ship_bomb
	ld		hl, HUMAN_SHIP_INFO+3
	ld		(hl), 1												; Set human ship fire flag enabled to true
	call	print_explosion
	ld		hl, HUMAN_SHIP_INFO+6
	ld		(hl), 0												; Reset human bomb X position
	ld		hl, HUMAN_SHIP_INFO+7								; Reset human bomb Y position
	ld		(hl), 0				
	ret
check_human_ship_bomb_collision_mrtz_bomb:				
	call	remove_human_ship_bomb								; Remove human bomb
	ld		hl, BOMB_COUNTER
	ld		(hl), 0												; Reset martian bombs index
check_human_ship_bomb_collision_mrtz_bomb_loop:
	ld		hl, BOMB_COUNTER
	ld		a, (hl)												; Get current martian bomb index
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		e, (hl)												; Get current martian bomb X position
	ld		hl, BOMB_COUNTER
	ld		a, (hl)												; Get current martian bomb index
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		a, 100
	call	add_8bit_16bit_values
	ld		d, (hl)												; Get current martian bomb Y position

	ld		hl, bc												; Human bomb positions in HL
	or 		a 													; Compare human bomb position (BC) with martian bomb position (HL)
	sbc 	hl, de
	add 	hl, de
	jp		z, check_human_ship_bomb_collision_mrtz_bomb_expl	; Print explosion and remove martian bomb
	ld		hl, BOMB_COUNTER
	ld		a, (hl)												; Get current martian bomb index
	inc		a													; Increment martian bomb index
	ld		(hl), a												; Save new martian bomb index
	jp		check_human_ship_bomb_collision_mrtz_bomb_loop

check_human_ship_bomb_collision_mrtz_bomb_expl:
	push	bc													; Backup BC registry to stack
	push	hl
	pop		bc													; Put martian bomb position to BC registry
	call	remove_martian_ship_bomb							; Remove martian bomb
	pop		bc													; Restore BC registry from stack

	ld		hl, BOMB_COUNTER
	ld		a, (hl)												; Get current martian bomb index
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		(hl), 0												; Reset current martian bomb X position
	ld		hl, BOMB_COUNTER
	ld		a, (hl)												; Get current martian bomb index
	ld		hl, MARTIAN_BOMBS
	call	add_8bit_16bit_values
	ld		a, 100
	call	add_8bit_16bit_values
	ld		(hl), 0												; Reset current martian bomb Y position

	call	print_explosion										; Show explosion
	jp 		check_human_ship_bomb_collision_end
check_martian_ship_bomb_collision:
	; --> MARTIAN SHIP BOMB COLLISION DETECTION
	;     INPUT: A=martian ship bomb array index
	; 	  OUTPUT: A=status (1=Collision detected, 0=Collision not detected)
	push	de													; Backup DE registry to stack
	ld		(LOOP_COUNTER), a									; Save array index to E registry
	push	bc													; Backup BC registry to stack
	push	af													; Backup AF registry to stack
	ld		hl, MARTIAN_BOMBS									; Get first X element address of bombs array
	call	add_8bit_16bit_values								; Get current X element address of bombs array
	ld		c, (hl)												; Get bomb X position
	ld		a, 100												; Add 100 positions to X element address for to find Y element address
	call	add_8bit_16bit_values
	ld		b, (hl)												; Get bomb Y position
	ld		a, 6												; Put in A registry the character width points 
	ld		h, c												; Put in H registry the bomb X position
	call	mult_8bit_values
	inc		hl													; Add 4 points to bomb X position because the bomb char has the first 4 points empty
	inc		hl
	inc		hl
	inc		hl										
	ld		(MARTIAN_BOMB_COLLISIONS_CHECK), hl					; Save X bomb screen point 
	ld		a, 8												; Put in A registry the character width points 
	ld		h, b												; Put in H registry the bomb Y position
	call	mult_8bit_values									; Put Y bomb screen point in HL registry
	inc		hl													; Add 1 point to bomb Y position because the bomb char has the first point empty
	ld		(MARTIAN_BOMB_COLLISIONS_CHECK+1), hl							; Save Y bomb screen point
	ld		a, b												; Put bomb Y position to A registry for cases evaluation
	cp		23
	jp		z, check_martian_ship_bomb_collision_human			; The bomb is in human zone
	cp		24
	jp		z, check_martian_ship_bomb_collision_human			; The bomb is in human zone
	cp		25
	jp		z, check_martian_ship_bomb_collision_human			; The bomb is in human zone
	cp		21
	jp		z, check_martian_ship_bomb_collision_human_ship		; The bomb is in human ship zone
	cp		22
	jp		z, check_martian_ship_bomb_collision_human_ship		; The bomb is in human ship zone
	jp		check_martian_ship_bomb_collision_human_bomb		; the martian bomb is in potential human bomb zone
check_martian_ship_bomb_collision_end:
	pop		af													; Restore AF registry from stack
	pop		bc													; Restore BC registry from stack
	pop		de													; Restore DE registry from stack
	ret
check_martian_ship_bomb_collision_human:
	call	read_char_at
	cp		CHAR_SPACE
	jp		z, check_martian_ship_bomb_collision_human_check_2	; No collision (check second bom character)
check_martian_ship_bomb_collision_human_yes:
	call	remove_static_human
	ld		a, 1
	jp		check_martian_ship_bomb_collision_end
check_martian_ship_bomb_collision_human_check_2:
	inc		c
	call	read_char_at
	cp		CHAR_SPACE
	jp		z, check_martian_ship_bomb_collision_human_no
	jp		check_martian_ship_bomb_collision_human_yes

check_martian_ship_bomb_collision_human_no:
	ld  	a, 0
	jp		check_martian_ship_bomb_collision_end

check_martian_ship_bomb_collision_human_bomb:
	jp 		check_martian_ship_bomb_collision_end
check_martian_ship_bomb_collision_human_ship:
	call	read_char_at
	cp		CHAR_SPACE
	jp		z, check_martian_ship_bomb_collision_human_ship_2	; No collision (check second bom character)
	jp 		check_martian_ship_bomb_collision_human_ship_yes
check_martian_ship_bomb_collision_human_ship_2:
	inc		c
	call	read_char_at
	cp		CHAR_SPACE
	jp		z, check_martian_ship_bomb_collision_human_ship_no
	jp		check_martian_ship_bomb_collision_human_ship_yes
check_martian_ship_bomb_collision_human_ship_no:
	ld  	a, 0
	jp		check_martian_ship_bomb_collision_end
check_martian_ship_bomb_collision_human_ship_yes:
	call	move_martians_bombs_clear_array
	call	remove_martian_ship_bomb
	call	print_explosion
	ld		bc, HUMAN_SHIP_HIDE_TIME
	ld		(HUMAN_SHIP_INFO+8),bc				; Set timer
	call	stop_human_ship_movement			; Stop human ship movement

	call	remove_human_ship
	ld		hl,(HUMAN_SHIP_INFO)
	ld		(hl), 0								; Set human ship visible flag to false
	ld		a, 1
	jp		check_martian_ship_bomb_collision_end
remove_static_human:
	ld		hl, HUMAN_EXPLOSION_FLAG
	ld		(hl), 1								; Set human expanded explosion type
	ld		e, a
	cp		205
	jp		z, remove_static_human_left
	cp		206
	jp		z, remove_static_human_center
	cp		207
	jp		z, remove_static_human_right
	ret		nz
remove_static_human_exit:
	call	print_explosion
	ld		hl,HUMANS_COUNTER
	ld  	a, (hl)								; Get human counter
	dec		a									; Decrease human counter
	ld		(hl), a								; Save new humans counter
	call	refresh_human_counter				; refresh human counter on screen
	ret
remove_static_human_left:
	push	bc							; Backup BC registry to stack

	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		b
	dec		c
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at
 
	inc		b
	dec		c
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	pop		bc							; Restore BC registry from stack

	jp		remove_static_human_exit
remove_static_human_left_exit:
	pop		bc							; Restore BC registry from stack
	jp		remove_static_human_exit

remove_static_human_center:

	push	bc							; Backup BC registry to stack
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at


	inc		b
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at


	inc		b
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	pop		bc							; Restore BC registry from stack
	dec		c							; Decrease C registry for print exlosion in good position
	jp		remove_static_human_exit
remove_static_human_right:
	ld		hl, HUMAN_EXPLOSION_FLAG
	ld		(hl), 0								; Reset human expanded explosion type
	push	bc									; Backup BC registry to stack

	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		b
	inc		c
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	inc		b
	inc		c
	inc		c
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	dec		c
	ld		a, CHAR_SPACE
	call	print_char_at

	pop		bc							; Restore BC registry from stack
	dec		c							; Decrease C registry for print exlosion in good position
	dec		c							; Decrease C registry for print exlosion in good position
	jp		remove_static_human_exit
remove_human_ship_bomb:
	; --> REMOVE HUMAN SHIP BOMB
	;	  MODIFY: AF
	push	bc													; Backup BC registry to stack
	push	hl													; Backup BC registry to stack
	ld		hl, HUMAN_SHIP_INFO+7
	ld		b, (hl) 											; Get human ship bomb current Y position
	ld		hl, HUMAN_SHIP_INFO+6
	ld		c, (hl)												; Get human ship bomb current X position
	ld		a, CHAR_SPACE										
	call	print_char_at										; Print space character at bomb position
	inc		c
	ld		a, CHAR_SPACE										
	call	print_char_at										; Print space character at next right place near bomb position
	call	draw_war_field_info_box								; Write info box left side
	pop		hl													; Restore HL registry from stack
	pop		bc													; Restore BC registry from stack
	ret
print_human_ship_bomb:
	; -->  PRINT HUMAN SHIP BOMB
	;      MODIFY: AF
	push	bc													; Backup BC registry to stack
	push	hl													; Backup BC registry to stack
	ld		hl, HUMAN_SHIP_INFO+3
	ld		(hl), 0												; Disable human ship "can fire" flag status
	ld		hl, HUMAN_SHIP_INFO+7
	ld		b, (hl) 											; Get human ship bomb current Y position
	ld		hl, HUMAN_SHIP_INFO+6
	ld		c, (hl)												; Get human ship bomb current X position
	ld		a, CHAR_BOMB
	call	print_char_at										; Print first bomb character at bomb position
	inc		c
	ld		a, CHAR_BOMB
	inc		a
	call	print_char_at										; Print second bomb character at bomb position
	call	draw_war_field_info_box								; Write info box left side
	pop		hl													; Restore HL registry from stack
	pop		bc													; Restore BC registry from stack
	ret	
draw_war_field_info_box:
	push	bc													; Backup BC registry in stack
	ld    	b, 0
	ld    	c, 63
	ld    	a, CHAR_TOP_RIGHT									
	call  	print_char_at										
	ld    	b, 1
	ld    	c, 63
	ld    	a, CHAR_VERTICAL
	call    print_char_at										; Write info box left side (it'd can if a bomb is near to it)
	ld    	b, 2
	ld    	c, 63
	ld    	a, CHAR_VERTICAL
	call    print_char_at										; Write info box left side (it'd can if a bomb is near to it)
	ld    	b, 3
	ld    	c, 63
	ld    	a, CHAR_BOTTOM_LEFT									; Write info box left side (it'd can if a bomb is near to it)
	call    print_char_at
	pop 	bc													; Restore BC registry from stack
	ret
move_human_ship_to_right:
	ld		hl, HUMAN_SHIP_INFO+4								; Get speed counter
	ld		a, (hl)
	inc 	a
	ld		(hl), a
	cp		5
	ret		nz													; Exit if speed counter is not ok
	ld		(hl), 0												; Reset speed counter
	ld		hl, HUMAN_SHIP_INFO+1
	ld		a, (hl)												; Get actual position
	cp		74
	jp		z, start_human_ship_move_left						; Change direction
	inc		a
	ld		hl, HUMAN_SHIP_INFO+1								; Increment position
	ld		(hl), a
	call 	print_human_ship
	ret
move_human_ship_to_left:
	ld		hl, HUMAN_SHIP_INFO+4								; Get speed counter
	ld		a, (hl)
	inc 	a
	ld		(hl), a
	cp		5
	ret		nz													; Exit if speed counter is not ok
	ld		(hl), 0												; Reset speed counter
	ld		hl, HUMAN_SHIP_INFO+1
	ld		a, (hl)												; Get actual position
	cp		1
	jp		z, start_human_ship_move_right						; Change direction
	dec		a
	ld		hl, HUMAN_SHIP_INFO+1								; Decrement position
	ld		(hl), a
	call 	print_human_ship
	ret
start_human_ship_fire:
	ld		hl, HUMAN_SHIP_INFO
	ld		a,(hl)
	cp		0
	ret		z										; Human ship not visible: return to main loop
	ld		hl, HUMAN_SHIP_INFO+3
	ld		a, (hl)									; Get fire status
	cp		0
	ret		z										; Exit because fire is not allowed
	ld		(hl), 0									; Set fire not allowed

	ld		hl, HUMAN_SHIP_INFO+1					; Get current human ship position
	ld		c, (hl)
	inc		c
	ld		hl, HUMAN_SHIP_INFO+6
	ld		(hl), c									; Save human ship bomb X position
	ld		hl, HUMAN_SHIP_INFO+7
	ld		(hl), 20								; Save human ship bomb Y position
	call	print_human_ship_bomb
	ret												; Return to main loop
start_human_ship_move_left:
	ld		hl, HUMAN_SHIP_INFO
	ld		a,(hl)
	cp		0
	ret		z										; Human ship not visible: return to main loop
	ld		hl, HUMAN_SHIP_INFO+2					; Set human ship movement direction
	ld		(hl), 2
	ret												; Return to main loop
start_human_ship_move_right:
	ld		hl, HUMAN_SHIP_INFO
	ld		a,(hl)
	cp		0
	ret		z										; Human ship not visible: return to main loop
	ld		hl, HUMAN_SHIP_INFO+2					; Set human ship movement direction
	ld		(hl), 1
	ret												; Return to main loop
stop_human_ship_movement:
	ld		hl, HUMAN_SHIP_INFO+2					; Reset human ship movement direction
	ld		(hl), 0
	ret												; Return to main loop
print_human_ship:
	; --> PRINT HUMAN SHIP TO SCREEN

	push	bc											; Put BC registry to stack
	push	hl											; Put HL registry to stack
	push  	de											; Put DE registry to stack
	push	af											; Put AF registry to stack

	ld		hl, HUMAN_SHIP_INFO					
	ld		a,(hl)
	cp		0
	jp		z, print_human_ship_end					; Human ship not visble
	ld		hl, HUMAN_SHIP_INFO+1
	ld		c, (hl)										; Put in C registry the human ship current position
	ld		b, 21
	ld		a, CHAR_HUMAN_SHIP					
	call 	print_char_at								; Print sector 1_1

	inc		c
	ld		b, 21
	inc     a
	call 	print_char_at								; Print sector	1_2

	inc		c
	ld		b, 21
	inc     a
	call 	print_char_at								; Print sector	1_3

	inc		c
	ld		b, 21
	inc     a
	call 	print_char_at								; Print sector	1_4

	dec		c
	dec		c
	dec		c
	ld		b, 22								
	inc		a
	call 	print_char_at								; Print sector	2_1

	inc		c
	ld		b, 22
	inc		a			
	call 	print_char_at								; Print sector	2_2

	inc		c
	ld		b, 22
	inc		a
	call 	print_char_at								; Print sector	2_3

	inc		c
	ld		b, 22
	inc		a
	call 	print_char_at								; Print sector	2_4

	dec		c								
	dec		c
	dec		c

	ld		a, c
	cp		1
	call    nz, print_human_ship_clear_left			; Clear character before new human ship position
	
	ld		a, c
	cp		74
	call    nz, print_human_ship_clear_right			; Clear character after new human ship position

print_human_ship_end:
	pop		af											; Restore AF registry from stack
	pop		bc											; Restore BC registry from stack
	pop		de											; Restore DE registry from stack
	pop		hl											; Restore HL registry from stack
	ret
print_human_ship_clear_left:							; Clear character before new human ship position
	dec		c
	ld		b, 21
	ld		a, CHAR_SPACE
	call 	print_char_at								
	ld		b, 22
	ld		a, CHAR_SPACE
	call 	print_char_at	
	inc		c
	ret
print_human_ship_clear_right:						; Clear character after new human ship position
	inc		c
	inc		c
	inc		c
	inc		c
	ld		b, 21
	ld		a, CHAR_SPACE
	call 	print_char_at								
	ld		b, 22
	ld		a, CHAR_SPACE
	call 	print_char_at	
	dec		c
	dec		c
	dec		c
	dec		c
	ret
set_selected_level_parameters:
	; --> SET PARAMETER IN FUNCTION OF SELECTED LEVEL
	;	  MODIFY: HL, AF
	ld		hl, SELECTED_LEVEL
	ld		a,(hl)
	cp		2
	jp		z, set_selected_level_parameters_2
	cp		3
	jp		z, set_selected_level_parameters_3
set_selected_level_parameters_1:
	ld		hl, MARTIANS_COUNTER						
	ld		(hl), 20									; Set martians ships number
	ld		hl, MARTIANS_SHIPS_INFO						
	ld		(hl), 1	     								; Set martian bombs frequency ratio
	ld		hl, HUMAN_SHIP_INFO+5						
	ld		(hl), 3										; Set human ship speed
	ld		hl, MARTIANS_SHIPS_INFO+23
	ld		(hl), 4										; Martians ships speed
	ret
set_selected_level_parameters_2:
	ld		hl, MARTIANS_COUNTER						
	ld		(hl), 25									; Set martians ships number
	ld		hl, MARTIANS_SHIPS_INFO		
	ld		(hl), 2 									; Set martian bombs frequency ratio
	ld		hl, HUMAN_SHIP_INFO+5						
	ld		(hl), 4										; Set human ship speed
	ld		hl, MARTIANS_SHIPS_INFO+23
	ld		(hl), 4										; Martians ships speed
	ret
set_selected_level_parameters_3:
	ld		hl, MARTIANS_COUNTER						
	ld		(hl), 29									; Set martians ships number
	ld		hl, MARTIANS_SHIPS_INFO
	ld		(hl), 3										; Set martian bombs frequency ratio
	ld		hl, HUMAN_SHIP_INFO+5					
	ld		(hl), 3										; Set human ship speed
	ld		hl, MARTIANS_SHIPS_INFO+23
	ld		(hl), 4										; Martians ships speed
	ld		hl, HUMAN_SHIP_HIDE_TIME
	ret
sleep:
	; --> SLEEP EXECUTION
	;     INPUT: BC=Duration
	push	bc
sleep_loop:
	nop
	dec 	bc
	ld 		a,b
	or 		c
	jp 		z, sleep_end
	jp 		sleep_loop
sleep_end:
	pop		bc
	ret
clear_screen:
	; --> CLEAR SCREEN (Use this routine because BIOS CLS call not clear 26.5 row)
	;     MODIFY: AF, DE, HL
	ld    	hl, #4000						; Init begin WRAM address to write into HL registry
	ld		de, #870						; Put into BC registry the total amount of character present into screen
clear_screen_loop:
	ld		a, CHAR_SPACE							
	call	WRTVRM							; Write character to video writing it into WRAM memory address
	inc		hl
	dec		de
	push	hl								; Preserve HL registry value putting it into stack
	ld		hl, 0							; Using HL registry to compare DE counter
	or 		a 								; Clear carry flag
	sbc 	hl, de							; Check if DE counter is zero  
	add 	hl, de
	pop		hl								; Restore HL registry from stack
	jp		c, clear_screen_loop
	ret
print_string_at:
	; --> PRINT A STRING TO SCREEN AT POSITION X,Y
	; 	  INPUT: HL=String to print, C=Position X, B=Position Y
	ld		a, (hl) 
	cp		0 
	ret		z
	call    print_char_at
	inc		c
	inc     hl 
	jp		print_string_at 
print_char_at:
	; --> PRINT A CHARACTER TO SCREEN AT POSITION X,Y
	;     INPUT: A=Character, C=Position X, B=Position Y
	;	  MODIFY: AF
	push	bc								; Put BC registry to stack
	push	hl								; Put HL registry to stack
	push  	de								; Put DE registry to stack
	push	af								; Put AF registry to stack
	ld		d, a							; Put character code to print into D registry
	ld    	a,b								; Next rows are for calculate VRAM memory address to write
	ld    	h,80
	call  	mult_8bit_values				 
	ld    	a,c 
	add   	a, l    
    ld    	l, a    
    adc   	a, h    
    sub   	l       
    ld    	h, a    
	ld    	bc,#4000
	add   	hl,bc 							; VRAM address position to write
	ld	  	a,(VDP_DW)						; Next rows are for write character to VRAM
	ld	  	c,a
	inc   	c
	ld    	a,l
	di
	out   	(c),a
	ld    	a,h
	ei
	out   	(c),a
	ld	  	a,(VDP_DR)	
	ld	  	c,a
	ld    	a,d
	out  	(c),a
	pop		af								; Restore AF registry
	pop		de								; Restore DE registry
	pop		hl								; Restore HL registry
	pop		bc								; Restore BC registry
	ret

mult_8bit_values:
	; --> 8bit value x 8bit value with 16bit value result
	; 	  INPUT: H=Factor, A=Second factori 2
	; 	  OUTPUT: HL
	push	de
	push	bc
	ld		e, a
	ld 		d,0
	ld 		l,d
	ld 		b,8
mult_8bit_values_loop:
	add 	hl,hl
	jp 		nc,mult_8bit_values_noadd
	add 	hl,de
mult_8bit_values_noadd:
	djnz mult_8bit_values_loop
	pop		bc
	pop		de
	ret

mult_8bit_16bit_values:
	; --> 8bit value x 8bit value with 16bit value result	
	;     INPUT: A=8bit factor, DE=16 bit factor 2
	; 	  OUTPUT: HL
	push	bc
	ld		l,0
	ld 		b,8
mult_8bit_16bit_values_loop:
	add 	hl,hl
	add 	a,a
	jp 		nc,mult_8bit_16bit_values_noadd
	add 	hl,de
mult_8bit_16bit_values_noadd:
	djnz	mult_8bit_16bit_values_loop
	pop		bc
	ret

refresh_martians_counter:
	; --> REFRESH MARTIAN COUNTER
	push	hl									; Backup HL registry to stack
	push	de									; Backup DE registry to stack
	push	bc									; Backup BC registry to stack
	push	af									; Backup AF registry to stack
	ld		hl, MARTIANS_COUNTER
	push	hl
	ld		a,(hl)
	cp		10
    jp      c, refresh_martians_counter_less_10
	cp		20
	jp      c, refresh_martians_counter_less_20
	pop		hl
	ld		a,(hl)
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a	
	add		a, 48
	ld    	b, 2
	ld    	c, 78
	call    print_char_at
	ld    	b, 2
	ld    	c, 77
	ld    	a, 50
	call    print_char_at
	jp		refresh_martians_counter_end
refresh_martians_counter_less_20:
	pop		hl
	ld		a,(hl)
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	dec		a
	add		a, 48
	ld    	b, 2
	ld    	c, 78
	call    print_char_at
	ld    	b, 2
	ld    	c, 77
	ld    	a, 49
	call    print_char_at
	jp		refresh_martians_counter_end
refresh_martians_counter_less_10:
	ld    	b, 2
	ld    	c, 77
	ld    	a, CHAR_SPACE
	call  	print_char_at
	pop 	hl
	ld		a,(hl)
	add		a, 48
	ld		b, 2
	ld    	c, 78
	call    print_char_at
refresh_martians_counter_end:
	pop		af									; Restore AF registry from stack
	pop		bc									; Restore BC registry from stack
	pop		de									; Restore DE registry from stack
	pop		hl									; Restore HL registry from stack
	ret
refresh_human_counter:
	; --> REFRESH MARTIAN COUNTER
	push	hl									; Backup HL registry to stack
	push	de									; Backup DE registry to stack
	push	bc									; Backup BC registry to stack
	push	af									; Backup AF registry to stack
	ld		hl, HUMANS_COUNTER
	push	hl
	ld		a,(hl)
	cp		10
    jp      c, refresh_human_counter_less_10
	pop		hl
	ld		a,(hl)
	sub 	10
	add		a, 48
	ld    	b, 1
	ld    	c, 78
	call  	print_char_at
	ld    	b, 1
	ld    	c, 77
	ld    	a, 49
	call    print_char_at
	jp		refresh_human_counter_end
refresh_human_counter_less_10:
	ld    	b, 1
	ld    	c, 77
	ld    	a, CHAR_SPACE
	call    print_char_at
	pop 	hl
	ld		a,(hl)
	add		a, 48
	ld		b, 1
	ld    	c, 78
	call    print_char_at
refresh_human_counter_end:
	pop		af								; Restore AF registry from stack
	pop		bc								; Restore BC registry from stack
	pop		de								; Restore DE registry from stack
	pop		hl								; Restore HL registry from stack
	ret

read_char_at:
	; --> READ CHARACTER ON SCREEN AT POSITION
	; INPUT: c=Position X, b=Position Y
	; OUPUT: a=Character
	; MODIFY: AF
	push	hl									; Backup HL registry to stack
	push	de									; Backup DE registry to stack
	push	bc									; Backup BC registry to stack
	ld    	h,b
	ld    	a,80
	call  	mult_8bit_values
	ld    	a,c
	add   	a, l    
    ld    	l, a    
    adc   	a, h    
    sub   	l       
    ld    	h, a    
	ld    	bc, #4000
	add   	hl,bc 
	call  	RDVRM
	pop		bc											; Restore BC registry from stack
	pop		de											; Restore DE registry from stack
	pop		hl											; Restore HL registry from stack
	ret
; --- CONSTANTS ---
HUMAN_SHIP_HIDE_TIME:	equ 500				; Human ship base hide duration
WAR_FIELD_MATRIX_SIZE:  equ 12960			; War field matrix RAM size
CHAR_MAP_BLOCK_LEN:		equ 992			    ; Char map bytes block length to copy into VRAM
CHAR_SPACE:				equ 32				; Space character
CHAR_BOTTOM_LEFT:		equ 203				; Bottom left border char
CHAR_HORIZONTAL:  		equ 201				; Horizontal border char
CHAR_VERTICAL:    		equ 200				; Vertical border char
CHAR_TOP_RIGHT:    		equ 202				; Top right border char
CHAR_TOP_LEFT:     		equ 199				; Top left border char
CHAR_BOTTOM_RIGHT: 		equ 204				; Bottom right border char
CHAR_EMPTY:				equ 252				; Empty char
CHAR_STATIC_HUMAN:		equ 205				; First static human character
CHAR_HUMAN_SHIP:		equ 191				; First human ship character
CHAR_BOMB:				equ 189				; First human ship character
CHAR_MARTIAN_SHIP_1_A:	equ 173				; First martian ship nr. 1a character
CHAR_MARTIAN_SHIP_2_A:	equ 214				; First martian ship nr. 2a character
CHAR_MARTIAN_SHIP_3_A:	equ 230				; First martian ship nr. 3a character
CHAR_MARTIAN_SHIP_1_B:	equ 181				; First martian ship nr. 1b character
CHAR_MARTIAN_SHIP_2_B:	equ 222				; First martian ship nr. 2b character
CHAR_MARTIAN_SHIP_3_B:	equ 238				; First martian ship nr. 3b character
CHAR_EXPLOSION:			equ 246				; First Explosion character
BOOTAD:					equ	#0C000			; Where boot sector is executed
BOTTOM:					equ	#0FC48			; Pointer to bottom of RAM
HIMEM:					equ	#0FC4A			; Top address of RAM which can be used
MEMSIZ:					equ	#0F672			; Pointer to end of string space
STKTOP:					equ	#0F674			; Pointer to bottom of stack
SAVSTK:					equ	#0F6B1			; Pointer to valid stack bottom
MAXFIL:					equ	#0F85F			; Maximum file number
FILTAB:					equ	#0F860			; Pointer to file pointer table
NULBUF:					equ	#0F862			; Pointer to buffer #0

TXT_MARTIAN_WAR: 		db 'MARTIAN WAR',0
TXT_PRES_1: 			db 'There is one weapon remaining on Earth.',0
TXT_KEYS:				db 'This weapon is controlled with the following keys:',0
TXT_KEY_4:				db '4/Left arrow  - Move to left',0
TXT_KEY_5:				db '5/Up arrow    - Stop',0
TXT_KEY_6:				db '6/Right arrow - Move to right',0
TXT_KEY_8:				db '8/Space       - Fire a missile',0
TXT_PRES_2:				db 'There will be martian spaceships flying all over the place and dropping',0
TXT_PRES_3:				db 'bombs down on you and the human population.',0
TXT_PRES_4:				db 'Your mission is quite simple. There are a limited number of martian',0
TXT_PRES_5:				db 'ships and if you destroy all of them before they destroy the whole',0
TXT_PRES_6:				db 'population of Earth then you win.',0
TXT_PRES_7:				db 'If your weapon is hit it will have to be repaired and the refore',0
TXT_PRES_8:				db 'will be unusable for a period of time.',0
TXT_PRES_9:				db 'HIT \'RETURN\' TO CONTINUE',0
TXT_LEVELS:				db 'WHAT LEVEL OF PLAY WOULD YOU LIKE (1 - 3) ? _',0
TXT_LEVEL_1:			db '1  -  Beginner',0
TXT_LEVEL_2:			db '2  -  Intermediate',0
TXT_LEVEL_3:			db '3  -  Advanced',0
TXT_SOUNDS:   			db 'IF YOU WANT SOUND EFFECTS THEN TYPE \'Y\' ELSE TYPE \'N\'',0
TXT_HUMANS:				db 'Humans   - ',0
TXT_MARTIANS:			db 'Martians - ',0
TXT_LOSE_1:				db 'SORRY GUY',0
TXT_LOSE_2:				db 'THE MARTIANS HAVE SUCCESSFULLY DESTROYED ALL LIFE ON EARTH!',0
TXT_PLAY_AGAIN:		  	db 'HIT \'RETURN\' TO PLAY AGAIN',0
TXT_WIN_1: 				db 'CONGRATULATIONS',0
TXT_WIN_2: 			  	db 'YOU HAVE SAVED EARTH FROM THE MARTIAN ATTACK!!',0
TXT_RAM:				db 'RAM memory allocation error',0
TXT_MSX1:				db 'THIS GAME IS FOR MSX 2 SYSTEMS ONLY',0
; --- CHAR MAP DEFINITIONS ----
RunningHuman1_11_128:
	db 00000100b
	db 00000100b
	db 00000100b
	db 00000100b
	db 00000100b
	db 00000100b
	db 00000100b
	db 00000000b
RunningHuman1_12_129:
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 01111100b
RunningHuman1_13_130:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 10000000b
RunningHuman1_21_131:
	db 00000000b
	db 01111000b
	db 01111100b
	db 01111100b
	db 01111100b
	db 00001100b
	db 00000000b
	db 00000000b
RunningHuman1_22_132:
	db 01111100b
	db 01111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 01111100b
	db 01111100b
RunningHuman1_23_133:
	db 10000000b
	db 10000000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 11111100b
	db 11111100b
	db 10111100b
RunningHuman1_31_134:
	db 00000000b
	db 00000100b
	db 00000100b
	db 00000100b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00011100b
RunningHuman1_32_135:
	db 11111100b
	db 11111100b
	db 11101100b
	db 11101100b
	db 11101100b
	db 10000000b
	db 10000000b
	db 10000000b
RunningHuman1_33_136:
	db 10111100b
	db 10000000b
	db 11000000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 11111100b
	db 00111100b
RunningHuman2_11_137:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
RunningHuman2_12_138:
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 11111000b
RunningHuman2_13_139:
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 00000000b
RunningHuman2_21_140:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00011100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11100000b
RunningHuman2_22_141:
	db 11111000b
	db 11111000b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111000b
	db 11111000b
RunningHuman2_23_142:
	db 01111000b
	db 01111000b
	db 11111000b
	db 11111000b
	db 11000000b
	db 11000000b
	db 00000000b
	db 00000000b
RunningHuman2_31_143:
	db 00001100b
	db 00001100b
	db 00001100b
	db 00111100b
	db 00111100b
	db 01111100b
	db 01111000b
	db 01111000b
RunningHuman2_32_144:
	db 11111000b
	db 11111100b
	db 11011100b
	db 11011100b
	db 00011100b
	db 00001100b
	db 00001100b
	db 00001100b
RunningHuman2_33_145:
	db 00000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 11000000b
	db 11000000b
	db 11000000b
RunningHuman3_11_146:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000100b
RunningHuman3_12_147:
	db 01111100b
	db 01111100b
	db 01111100b
	db 01111100b
	db 01111100b
	db 01111100b
	db 01111100b
	db 11111000b
RunningHuman3_13_148:
	db 10000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 00000000b
RunningHuman3_21_149:
	db 00000100b
	db 00000100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 11111100b
	db 11111100b
	db 11110100b
RunningHuman3_22_150:
	db 11111000b
	db 11111000b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111000b
	db 11111000b
RunningHuman3_23_151:
	db 00000000b
	db 01111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11000000b
	db 00000000b
	db 00000000b
RunningHuman3_31_152:
	db 11110100b
	db 00000100b
	db 00001100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 11111100b
	db 11110000b
RunningHuman3_32_153:
	db 11111100b
	db 11111100b
	db 11011100b
	db 11011100b
	db 11011100b
	db 00000100b
	db 00000100b
	db 00000100b
RunningHuman3_33_154:
	db 00000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
RunningHuman4_11_155:
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00000000b
RunningHuman4_12_156:
	db 11110000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 01111100b
RunningHuman4_13_157:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
RunningHuman4_21_158:
	db 01111000b
	db 01111000b
	db 01111100b
	db 01111100b
	db 00001100b
	db 00001100b
	db 00000000b
	db 00000000b
RunningHuman4_22_159:
	db 01111100b
	db 01111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 01111100b
	db 01111100b
RunningHuman4_23_160:
	db 00000000b
	db 00000000b
	db 00000000b
	db 11100000b
	db 11111100b
	db 11111100b
	db 11111100b
	db 00011100b
RunningHuman4_31_161:
	db 00000000b
	db 00000100b
	db 00000100b
	db 00000100b
	db 00000100b
	db 00001100b
	db 00001100b
	db 00001100b
RunningHuman4_32_162:
	db 01111100b
	db 11111100b
	db 11101100b
	db 11101100b
	db 11100000b
	db 11000000b
	db 11000000b
	db 11000000b
RunningHuman4_33_163:
	db 11000000b
	db 11000000b
	db 11000000b
	db 11110000b
	db 11110000b
	db 11111000b
	db 01111000b
	db 01111000b
RunningHuman5_11_164:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
RunningHuman5_12_165:
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 11111000b
	db 00111100b
RunningHuman5_13_166:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 10000000b
RunningHuman5_21_167:
	db 00000000b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
RunningHuman5_22_168:
	db 00111100b
	db 00111100b
	db 11111100b
	db 11111100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b
RunningHuman5_23_169:
	db 10000000b
	db 10000000b
	db 10000000b
	db 10000000b
	db 11100000b
	db 11100000b
	db 11111000b
	db 10111000b
RunningHuman5_31_170:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
RunningHuman5_32_171:
	db 00111100b
	db 01110100b
	db 01110100b
	db 01110000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
RunningHuman5_33_172:
	db 10111000b
	db 10000000b
	db 11100000b
	db 11100000b
	db 11110000b
	db 01110000b
	db 00111000b
	db 00111000b
MartianShip1a_11_173:
	db 00000000b
	db 00000000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 00011111b
	db 00011111b
MartianShip1a_12_174:
	db 00000000b
	db 00000000b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 11111111b
	db 11111111b
MartianShip1a_13_175:
	db 00000000b
	db 00000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11111111b
	db 11111111b
MartianShip1a_14_176:
	db 00000000b
	db 00000000b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
	db 11100000b
	db 11100000b
MartianShip1a_21_177:
	db 00011111b
	db 00011111b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 00000000b
	db 00000000b
MartianShip1a_22_178:
	db 11111111b
	db 11111111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00000000b
	db 00000000b
MartianShip1a_23_179:
	db 11111111b
	db 11111111b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 00000000b
	db 00000000b
MartianShip1a_24_180:
	db 11100000b
	db 11100000b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00000000b
	db 00000000b
MartianShip1b_11_181:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00011111b
	db 00011111b
MartianShip1b_12_182:
	db 00000000b
	db 00000000b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 11111111b
	db 11111111b
MartianShip1b_13_183:
	db 00000000b
	db 00000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11111111b
	db 11111111b
MartianShip1b_14_184:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11100000b
	db 11100000b
MartianShip1b_21_185:
	db 00011111b
	db 00011111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
MartianShip1b_22_186:
	db 11111111b
	db 11111111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00000000b
	db 00000000b
MartianShip1b_23_187:
	db 11111111b
	db 11111111b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 00000000b
	db 00000000b
MartianShip1b_24_188:
	db 11100000b
	db 11100000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
Bomb_189:
	db 00000000b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00000000b
Bomb_190:
	db 00000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 00000000b
HumanShip_11_191:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000111b
	db 00000111b
	db 00000111b
HumanShip_12_192:
	db 00000000b
	db 00000000b
	db 00011111b
	db 00011111b
	db 00011111b
	db 11111111b
	db 11111111b
	db 11111111b
HumanShip_13_193:
	db 00000000b
	db 00000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11111000b
	db 11111000b
	db 11111000b
HumanShip_14_194:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
HumanShip_21_195:
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
HumanShip_22_196:
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
HumanShip_23_197:
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
HumanShip_24_198:
	db 11110000b
	db 11110000b
	db 11110000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
BorderTopLeft_199:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00011111b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
BorderVertical_200:
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
BorderHorizontal_201: 
	db 00000000b
	db 00000000b
	db 00000000b
	db 11111111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
BorderTopRight_202:
	db 00000000b
	db 00000000b
	db 00000000b
	db 11110000b
	db 00010000b
	db 00010000b
	db 00010000b
	db 00010000b
BorderBottomLeft_203:
	db 00010000b
	db 00010000b
	db 00010000b
	db 00011111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
BorderBottomRight_204:
	db 00010000b
	db 00010000b
	db 00010000b
	db 11110000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
StaticHuman11_205:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 01111100b
	db 01111100b
	db 01111100b
StaticHuman12_206:
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
StaticHuman13_207:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11111000b
	db 11111000b
	db 11111000b
StaticHuman21_208:
	db 01110000b
	db 01110000b
	db 01110000b
	db 01110000b
	db 01110000b
	db 01110000b
	db 01110000b
	db 01110000b
StaticHuman22_209:
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
StaticHuman23_210:
	db 00111000b
	db 00111000b
	db 00111000b
	db 00111000b
	db 00111000b
	db 00111000b
	db 00111000b
	db 00111000b
StaticHuman31_211:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00011100b
	db 00011100b
	db 00011100b
StaticHuman32_212:
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
	db 11111100b
StaticHuman33_213:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11100000b
	db 11100000b
	db 11100000b
MartianShip2a_11_214:
	db 00000000b
	db 00000000b
	db 11100111b
	db 11100111b
	db 11100111b
	db 11100111b
	db 11100000b
	db 11100000b
MartianShip1a_12_215:
	db 00000000b
	db 00000000b
	db 11111111b
	db 11111111b
	db 11111111b
	db 11111111b
	db 00001111b
	db 00001111b
MartianShip2a_13_216:
	db 00000000b
	db 00000000b
	db 11111111b
	db 11111111b
	db 11111111b
	db 11111111b
	db 11000000b
	db 11000000b
MartianShip2a_14_217:
	db 00000000b
	db 00000000b
	db 10011100b
	db 10011100b
	db 10011100b
	db 10011100b
	db 00011100b
	db 00011100b
MartianShip2a_21_218:
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 00000000b
	db 00000000b
MartianShip2a_22_219:
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00000000b
	db 00000000b
MartianShip2a_23_220:
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 00000000b
	db 00000000b
MartianShip2a_24_221:
	db 00011100b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00000000b
	db 00000000b
MartianShip2b_11_222:
	db 00000000b
	db 00000000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
MartianShip2b_12_223:
	db 00000000b
	db 00000000b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
MartianShip2b_13_224:
	db 00000000b
	db 00000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
MartianShip2b_14_225:
	db 00000000b
	db 00000000b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00011100b
	db 00011100b
MartianShip2b_21_226:
	db 11100000b
	db 11100000b
	db 11100111b
	db 11100111b
	db 11100111b
	db 11100111b
	db 00000000b
	db 00000000b
MartianShip2b_22_227:
	db 00001111b
	db 00001111b
	db 11111111b
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
MartianShip2b_23_228:
	db 11000000b
	db 11000000b
	db 11111111b
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
MartianShip2b_24_229:
	db 00011100b
	db 00011100b
	db 10011100b
	db 10011100b
	db 10011100b
	db 10011100b
	db 00000000b
	db 00000000b
MartianShip3a_11_230:
	db 00000000b
	db 00000000b
	db 11110000b
	db 11111000b
	db 11111100b
	db 11111110b
	db 11101111b
	db 11100111b
MartianShip3a_12_231:
	db 00000000b
	db 00000000b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 10001111b
	db 11001111b
MartianShip3a_13_232:
	db 00000000b
	db 00000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000001b
	db 11000011b
	db 11000111b
MartianShip3a_14_233:
	db 00000000b
	db 00000000b
	db 00011111b
	db 00111111b
	db 01111111b
	db 01111111b
	db 11011111b
	db 11011111b
MartianShip3a_21_234:
	db 11100110b
	db 11100010b
	db 11100010b
	db 11100011b
	db 11100011b
	db 11100011b
	db 00000000b
	db 00000000b
MartianShip3a_22_235:
	db 11001111b
	db 01101111b
	db 01111111b
	db 00011111b
	db 00011111b
	db 00001111b
	db 00000000b
	db 00000000b
MartianShip3a_23_236:
	db 11001100b
	db 11011100b
	db 11111000b
	db 11110000b
	db 11100000b
	db 11000000b
	db 00000000b
	db 00000000b
MartianShip3a_24_237:
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00000000b
	db 00000000b
MartianShip3b_11_238:
	db 00000000b
	db 00000000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
	db 11100000b
MartianShip3b_12_239:
	db 00000000b
	db 00000000b
	db 00001111b
	db 00011111b
	db 00111111b
	db 01111111b
	db 01101111b
	db 11001111b
MartianShip3b_13_240:
	db 00000000b
	db 00000000b
	db 11100000b
	db 11110000b
	db 11110000b
	db 11111000b
	db 11011100b
	db 11001110b
MartianShip3b_14_241:
	db 00000000b
	db 00000000b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
	db 00011111b
MartianShip3b_21_242:
	db 11111100b
	db 11111100b
	db 11111000b
	db 11110000b
	db 11110000b
	db 11100000b
	db 00000000b
	db 00000000b
MartianShip3b_22_243:
	db 11001111b
	db 10001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00000000b
	db 00000000b
MartianShip3b_23_244:
	db 11000111b
	db 11000011b
	db 11000011b
	db 11000001b
	db 11000000b
	db 11000000b
	db 00000000b
	db 00000000b
MartianShip3b_24_245:
	db 11111111b
	db 01111111b
	db 01111111b
	db 00111111b
	db 00111111b
	db 00011111b
	db 00000000b
	db 00000000b
Explosion_11_246:
	db 11110000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
Explosion_12_247:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11000000b
	db 11000000b
	db 11000000b
	db 11000000b
Explosion_13_248:
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b
	db 00000000b
	db 00000000b
	db 11000000b
	db 11000000b
Explosion_21_249:
	db 00000000b
	db 00000000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 11110000b
	db 00000000b
	db 00000000b
Explosion_22_250:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00001100b
	db 00001100b
	db 00001100b
	db 00001100b
Explosion_23_251:
	db 11000000b
	db 11000000b
	db 00000000b
	db 00000000b
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b
; --- ROM 16KB ---
    ds #8000 - $  										; Fill the rest of the ROM (up to 16KB with 0s)

; --- RAM ---
    org #0c000  										; RAM address

; --- VARIABLES ---
BOMB_COUNTER:			db 0							; Bomb counter for looping
HUMAN_EXPLOSION_FLAG:	db 0							; Flag for detect static human explosion
RANDOM_SEED:			db 0							; Random generation seed
VBLANK_FLAG:			db 0							; vBlankFlag
SELECTED_LEVEL:			db 0							; Selected level 
SOUND_EFFECTS:			db 0							; Sounds effects yes (1) or no (0)
HUMANS_COUNTER:			db 0							; Martians counter
MARTIANS_COUNTER:		db 0							; Martians counter
MARTIAN_BOMBS:											; 100 X positions, 100 Y positions, speed, speed counter
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  
	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
HUMAN_SHIP_INFO:										; visible,position,direction (0=none - 1=right - 2=left),can fire,movement speed waiting,speed,bomb pos X,bomb Y pos, hidden time left
	.byte 0, 0, 0, 0, 0, 0, 0, 0
	.word 0
MARTIANS_SHIPS_INFO:									; Bomb frequency ratio, number of displayd ships, XPos1, Xpos2, XPos3, XPos4, YPos1, YPos2, YPos3, YPos4, Direction 1, Direction 2, Direction 3, Direction 4, Direction changed 1, Direction changed 2, Direction changed 3, Direction changed 4, Type 1, Type 2, Type 3, Type 4, Refreshing ship, Ship speed timer, Ship speed timer counter
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
RUNNING_HUMANS_INFO:									; Remaining to show, last position from right, last position from left, current position, current image
	.byte 0, 0, 0, 0, 0
LOOP_COUNTER:			db 0							; Generic counter used into loops
MARTIAN_BOMB_COLLISIONS_CHECK:							; Martian bomb collision check: martian X screen point, martian Y screen point, 
	.word 0, 0
HUMANS_POSITIONS:										; Static humans X position
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

