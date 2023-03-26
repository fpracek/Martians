; *** BIOS CALLS ***
CHGMOD: 			equ 005fh   ; BIOS routine used to initialize the screen
CHPUT:				equ	00a2h	; Address of character output routine of BIOS
EXPTBL:				equ	0FCC1h  ; Extended slot flags table (4 bytes)
RDSLT:				equ	000Ch	; Read slot routine
CHGET:				equ 009fh	; Get character from keyboard buffer (wait)
CLS:				equ 00c3h	; Clear screen
DCOMPR:				equ 146ah	; Compare 16bit values
RDVRM:				equ 004ah	; Read VRAM
WRTVRM:				equ 004dh   ; Write WRAM

; *** CONSTANTS ***
LINL40: 			equ #F3ae   ; Screen 0 screen width
VDP_DW:				equ	0007h	; VDP data write port
VDP_DR:				equ	0006h	; VDP data read port
REG3SAV: 			equ 0F3E2h	; VDP reg 3
REG4SAV: 			equ 0F3E3h	; VDP reg 4
REG9SAV:			equ	0FFE8h  ; VDP reg 9
REG10SAV:			equ	0FFE9h  ; VDP reg 10
CLIKSW:   			equ 0f3dbh	; Key Press Click Switch: 0=Off 1=On
KEYS:				equ	0fbe5h	; NEWKEY memory area 0xFBE5-0xFBEF 
OLDKEY:				equ #fbda
NEWKEY:				equ #fbe5

MartianMissile:		equ	91
RunningHuman1:		equ 128
RunningHuman2:		equ 137
RunningHuman3:		equ 146
RunningHuman4:		equ 155
RunningHuman5:		equ 164
MartianShip1a:		equ 173
MartianShip1b:		equ 181
MartianShip2a:		equ 214
MartianShip2b:		equ 222
MartianShip3a:		equ 230
MartianShip3b:		equ 238
HumanMissile:		equ 189
HumanShip:			equ 191
StaticHuman:		equ 205
BrdBottomLeft:  	equ 203
BrdHorizontal:  	equ 201
BrdVertical:    	equ 200
BrdTopRight:    	equ 202
BrdTopLeft:     	equ 199
BrdBottomRight: 	equ 204
Explosion:			equ 246

; *** INIT ROM ***
	org #4000
	db "AB"					; ID for auto-executable ROM
	dw StartProgram			; Main program execution address.
	db 00,00,00,00,00,00 	; unused


; *** PROGRAM START ***
StartProgram:	

    ; HL points too allocated space  
	call 	InitScreen								; Init screen 0, width 80, height 26.5
	call  	DefineCustomCharacters					; Load custom characters into VRAM

show_presentation:

	ld		hl, Msg_MartianWar
	ld		c, 30
	ld		b, 0
	call    PrintStringAtPosition
	ld		hl, Msg_OnlyOneWapon
	ld		c, 5
	ld		b, 2
	call    PrintStringAtPosition
	ld		hl, Msg_Keys
	ld		c, 5
	ld		b, 4
	call    PrintStringAtPosition

	ld		hl, Msg_Key4
	ld		c, 20
	ld		b, 6
	call    PrintStringAtPosition
	ld		hl, Msg_Key5
	ld		c, 20
	ld		b, 7
	call    PrintStringAtPosition
	ld		hl, Msg_Key6
	ld		c, 20
	ld		b, 8
	call    PrintStringAtPosition

	ld		hl, Msg_Key8
	ld		c, 20
	ld		b, 9
	call    PrintStringAtPosition

	ld		hl, Msg_Ships
	ld		c, 5
	ld		b, 11
	call    PrintStringAtPosition

	ld		hl, Msg_Bombs
	ld		c, 5
	ld		b, 12
	call    PrintStringAtPosition

	ld		hl, Msg_Mission
	ld		c, 5
	ld		b, 14
	call    PrintStringAtPosition

	ld		hl, Msg_Destroy
	ld		c, 5
	ld		b, 15
	call    PrintStringAtPosition

	ld		hl, Msg_Population
	ld		c, 5
	ld		b, 16
	call    PrintStringAtPosition

	ld		hl, Msg_Repaired
	ld		c, 5
	ld		b, 18
	call    PrintStringAtPosition

	ld		hl, Msg_Unusable
	ld		c, 5
	ld		b, 19
	call    PrintStringAtPosition

	ld		hl, Msg_Enter
	ld		c, 5
	ld		b, 21
	call    PrintStringAtPosition

	


hit_enter:
	ld		a,(NEWKEY+7)	;space
	bit		7,a
	jp		z,enterpressed
	jp		hit_enter
	
enterpressed:



	call    ClearScreen

	ld		hl, Msg_MartianWar
	ld		c, 30
	ld		b, 0
	call    PrintStringAtPosition

	ld		hl, Msg_Levels
	ld		c, 5
	ld		b, 7
	call    PrintStringAtPosition

	ld		hl, Msg_Level1
	ld		c, 5
	ld		b, 9
	call    PrintStringAtPosition

	ld     hl, Msg_Level2
	ld		c, 5
	ld		b, 10
	call    PrintStringAtPosition

	ld      hl, Msg_Level3
	ld		c, 5
	ld		b, 11
	call    PrintStringAtPosition

level_selection:
	ld		a,(NEWKEY+0)	;space
	bit		1,a
	jp		z,level1_selected
	bit     2,a
	jp		z,level2_selected
	bit     3,a
	jp		z,level3_selected
	jp		level_selection
level1_selected:
	ld		c, 49
	ld		b, 7
	ld		d, 49
	call	PrintCharacterAtPosition
	ld		hl, SelectedLevel
	ld		(hl), 1
	jp		sound_selection
level2_selected:
	ld		c, 49
	ld		b, 7
	ld		d, 50
	call	PrintCharacterAtPosition
	ld		hl, SelectedLevel
	ld		(hl), 2
	jp		sound_selection
level3_selected:
	ld		c, 49
	ld		b, 7
	ld		d, 51
	call	PrintCharacterAtPosition
	ld		hl, SelectedLevel
	ld		(hl), 3

sound_selection:
	ld      hl, Msg_SoundEffects
	ld		c, 5
	ld		b, 15
	call    PrintStringAtPosition

	ld		hl, SoundYN
	ld		(hl),0

sound_yn:
	ld		a,(NEWKEY+5)	
	bit		6,a
	jp		z,sound_y
	ld		a,(NEWKEY+4)	
	bit     3,a
	jp		z,sound_n
	jp		sound_yn
sound_y:
	ld		hl, SoundYN
	ld		(hl),1
sound_n:
	call	CLS

border_drawing:
	

	ld		hl, Counter
	ld		(hl),63
border_drawing_upper_line:
	ld		hl, Counter
	ld    	c, (hl)
	ld    	b, 0
	ld    	d, BrdHorizontal
	call  PrintCharacterAtPosition
	
	ld		hl, Counter
	ld		a,(hl)
	dec		a
	ld		(hl),a
	cp		0
	jp		z, border_drawing_bottom_line
	jp		border_drawing_upper_line

border_drawing_bottom_line:
	ld		hl, Counter
	ld		(hl),78
border_drawing_bottom_line_loop:
	ld		hl, Counter
	ld    	c, (hl)
	ld    	b, 26
	ld    	d, BrdHorizontal
	call  PrintCharacterAtPosition
	ld		hl, Counter
	ld		a,(hl)
	dec		a
	ld		(hl),a
	cp		0
	jp		z, border_drawing_right_line
	jp		border_drawing_bottom_line_loop
border_drawing_right_line:
	ld		hl, Counter
	ld		(hl),25
border_drawing_right_line_loop:
	ld		hl, Counter
	ld    	c, 78
	ld    	b, (hl)
	ld    	d, BrdVertical
	call  PrintCharacterAtPosition
	ld		hl, Counter
	ld		a,(hl)
	dec		a
	ld		(hl),a
	cp		3
	jp		z, border_drawing_left_line
	jp		border_drawing_right_line_loop
border_drawing_left_line:
	ld		hl, Counter
	ld		(hl),25
border_drawing_left_line_loop:
	ld		hl, Counter
	ld    	c, 0
	ld    	b, (hl)
	ld    	d, BrdVertical
	call  PrintCharacterAtPosition
	ld		hl, Counter
	ld		a,(hl)
	dec		a
	ld		(hl),a
	cp		0
	jp		z, border_drawing_right_top
	jp		border_drawing_left_line_loop


border_drawing_right_top:
	ld		hl, Counter
	ld		(hl),78
border_drawing_right_top_loop:
	ld		hl, Counter
	ld    	c,  (hl)
	ld    	b, 3
	ld    	d, BrdHorizontal
	call  PrintCharacterAtPosition
	ld		hl, Counter
	ld		a,(hl)
	dec		a
	ld		(hl),a
	cp		62
	jp		z, border_drawing_single_characters
	jp		border_drawing_right_top_loop

border_drawing_single_characters:
	ld    	b, 0
	ld    	c, 0
	ld    	d, BrdTopLeft
	call  PrintCharacterAtPosition

	call	DrawInfoBox

	ld    	b, 26
	ld    	c, 0
	ld    	d, BrdBottomLeft
	call  PrintCharacterAtPosition

	ld    	b, 26
	ld    	c, 78
	ld    	d, BrdBottomRight
	call  PrintCharacterAtPosition

	ld    	b, 3
	ld    	c, 78
	ld    	d, BrdTopRight
	call  PrintCharacterAtPosition

	ld      hl, Msg_MartianWar
	ld		c, 66
	ld		b, 0
	call    PrintStringAtPosition

	ld      hl, Msg_Humans
	ld		c, 65
	ld		b, 1
	call    PrintStringAtPosition

draw_info:
	ld      hl, Msg_Martians
	ld		c, 65
	ld		b, 2
	call    PrintStringAtPosition



init_variables:
	ld		hl, HumanExplosionFlag
	ld		(hl),0

	ld		hl, HumanShipCurrentPosition
	ld		(hl), 38
	ld		hl,0
	ld		(HumanShipStopTime),hl
	ld		hl, HumanShipVisible
	ld		(hl),1
	call	ResetMartiansMissilesPositions
	call	SetLevelParameters
	ld		hl, MartiansShipsSpeed
	ld		(hl),0
	ld		hl, MartiansMissilesSpeed
	ld		(hl),0
	ld		hl, Humans
	ld		(hl), 19
	call 	RefreshHumansCounters
	call 	RefreshMartiansCounters
	call	ResetFiredMissilesPositions
	call	ResetMartiansPositions



humans_showing:

	ld		hl, HumanRunningCounter
	ld		(hl), 19								; Set number of humans to display
	ld		hl, RunningHumanFromRightStopPosition 	; Set stop position for human running from right
	ld		(hl), 44
	ld		hl, RunningHumanFromLeftStopPosition 	; Set stop position for human running from left
	ld		(hl), 40

single_human_running:
	ld		hl, HumanRunningCounter
	ld		a, (hl)
	cp		0
	jp		z, show_human_ship

	
	and 	1           ;
	jp		nz, odd_human     
									; show human from right

	ld    	hl, CounterFromRight
	ld    	(hl),76	
clearCurrentRightHumanPosition:
	ld    	hl, RunningHumanFromRightCurrentImage	; 
	ld    	(hl), 4
move_right_human_loop: 	 	
	ld		hl, RunningHumanFromRightStopPosition
 	ld   	b,(hl) 
	ld    	hl, CounterFromRight
 	ld   	a,(hl) 	  		
 	cp   	b						; check if human is in your final destination
 	jp   	z, runningHumanFromRightArrived 
	ld   	d,a
	ld 		hl, RunningHumanFromRightCurrentImage
	ld      a, (hl)
	ld      e, a
	ld 		h, 9
	call 	Mult8
	ld   	a, 128
	add  	a, l
	ld   	e, a
	ld 		hl, CounterFromRight
 	ld   	a,(hl) 	
	ld		d, a
	call 	MoveHumanFromRight	
	ld   	bc,$0500
	call 	Delay
	ld    	hl, CounterFromRight
	ld		a,(hl)
 	dec  	a
	ld 		(CounterFromRight),a
	ld 		hl, RunningHumanFromRightCurrentImage
	ld 		a, (hl)
	dec  	a
	ld 		(hl),a
	cp   	0
	jp   	z, clearCurrentRightHumanPosition
 	jp   	move_right_human_loop	
runningHumanFromRightArrived:	 
	ld		hl, HumanRunningCounter					
	ld		a, (hl)
	dec		a
	ld		(hl), a
	ld		hl, RunningHumanFromRightStopPosition 	; Set new stop position from running human from right
	ld		e,StaticHuman
	ld		d, (hl)
	call 	MoveHumanFromRight	
	ld		hl, RunningHumanFromRightStopPosition 	; Set new stop position from running human from right
	ld		a, (hl)
	inc		a
	inc		a
	inc		a
	inc		a
	ld		(hl), a
	jp		single_human_running 	          

runningHumanFromLeftArrived:	 
	ld		hl, HumanRunningCounter					
	ld		a, (hl)
	dec		a
	ld		(hl), a
	ld		hl, RunningHumanFromLeftStopPosition 	; Set new stop position from running human from right
	ld		e,StaticHuman
	ld		d, (hl)
	call 	MoveHumanFromRight	
	ld		hl, RunningHumanFromLeftStopPosition 	; Set new stop position from running human from right
	ld		a, (hl)
	dec		a
	dec		a
	dec		a
	dec		a
	ld		(hl), a
	jp		single_human_running 	

odd_human:							; show human from left
	ld    	hl, CounterFromLeft
	ld    	(hl),2	
clearCurrentLeftHumanPosition:
	ld    	hl, RunningHumanFromLeftCurrentImage	; 
	ld    	(hl), 4
move_left_human_loop: 	 	
	ld		hl, RunningHumanFromLeftStopPosition
 	ld   	b,(hl) 
	ld    	hl, CounterFromLeft
 	ld   	a,(hl) 	  		
 	cp   	b						; check if human is in your final destination
 	jp   	z, runningHumanFromLeftArrived 
	ld   	d,a
	ld 		hl, RunningHumanFromLeftCurrentImage
	ld      a, (hl)
	ld      e, a
	ld 		h, 9
	call 	Mult8
	ld   	a, 128
	add  	a, l
	ld   	e, a
	ld 		hl, CounterFromLeft
 	ld   	a,(hl) 	
	ld		d, a
	call 	MoveHumanFromLeft	
	ld   	bc,$0500
	call 	Delay
	ld    	hl, CounterFromLeft
	ld		a,(hl)
 	inc  	a
	ld 		(CounterFromLeft),a
	ld 		hl, RunningHumanFromLeftCurrentImage
	ld 		a, (hl)
	dec  	a
	ld 		(hl),a
	cp   	0
	jp   	z, clearCurrentLeftHumanPosition
 	jp   	move_left_human_loop

end_check_odd_even_human:
	ld		hl, HumanRunningCounter	
	ld		a, (hl)
	dec		a
	ld		(hl), a					; pass to next human to show
	jp		single_human_running








show_human_ship:
	ld		hl, HumanShipMovingDirection
	ld		(hl), 0
	ld		hl, HumanShipCurrentPosition
	ld		(hl), 38
	call 	PrintHumanShip
main_loop_init_variables:
	ld		hl, 255
	ld		(MissilesRefreshPositionTime),hl



main_loop:

	call    ScreenRefresh
	ld		hl,Martians
	ld		a,(hl)
	cp		0
	jp		z, GameOver
	ld		a,(NEWKEY+1)	;key '8'
	bit		0,a
	jp		z, start_human_ship_fire

	ld		a,(NEWKEY+0)	;key '4'
	bit		4,a
	jp		z, start_move_human_ship_to_left

	ld		a,(NEWKEY+0)	; key '6'
	bit		6,a
	jp		z, start_move_human_ship_to_right

	ld		a,(NEWKEY+0)	; key '5'
	bit		5,a
	jp		z, stop_human_ship

	ld		hl,HumanShipMovingDirection
	ld		a, (hl)
	cp		1
	jp		z, move_human_ship_to_right

	ld		hl,HumanShipMovingDirection
	ld		a, (hl)
	cp		2
	jp		z, move_human_ship_to_left


	jp main_loop

; *** CALLS ***
GameOver:
	ld		hl, Martians
	ld		a,(hl)
	cp		0
	jp		nz, GameOver_MartiansWin

	call	GameOver_HumansWin_Message

	jp		hit_enter

GameOver_MartiansWin:

	call	GameOver_MartiansWin_Message

	;call	GenerateRandomNumber
	;ld		e, a
	;cp		2
	;jp		z, GameOver_Ok_Y
	;cp		4
	;jp		z, GameOver_Ok_Y
	;cp		6
	;jp		z, GameOver_Ok_Y
	;cp		8
	;jp		z, GameOver_Ok_Y
	;cp		10
	;jp		z, GameOver_Ok_Y
	;cp		12
	;jp		z, GameOver_Ok_Y
	;cp		14
	;jp		z, GameOver_Ok_Y
	;cp		16
	;jp		z, GameOver_Ok_Y
	;cp		18
	;jp		z, GameOver_Ok_Y
	;cp		20
	;jp		z, GameOver_Ok_Y
	;cp		22
	;jp		z, GameOver_Ok_Y
	;cp		24
	;jp		z, GameOver_Ok_Y
	;cp		26
	;jp		z, GameOver_Ok_Y
	
	jp		hit_enter		
	
GameOver_Ok_Y:
	call	GenerateRandomNumber
	cp		1
	jp		z, GameOver_Ok_X
	cp		2
	jp		z, GameOver_Ok_X
	cp		3
	jp		z, GameOver_Ok_X
	cp		4
	jp		z, GameOver_Ok_X
	cp		5
	jp		z, GameOver_Ok_X
	cp		6
	jp		z, GameOver_Ok_X
	cp		7
	jp		z, GameOver_Ok_X
	cp		8
	jp		z, GameOver_Ok_X
	cp		9
	jp		z, GameOver_Ok_X
	cp		10
	jp		z, GameOver_Ok_X
	cp		11
	jp		z, GameOver_Ok_X
	cp		12
	jp		z, GameOver_Ok_X
	cp		13
	jp		z, GameOver_Ok_X
	cp		14
	jp		z, GameOver_Ok_X
	cp		15
	jp		z, GameOver_Ok_X
	cp		16
	jp		z, GameOver_Ok_X
	cp		17
	jp		z, GameOver_Ok_X
	cp		18
	jp		z, GameOver_Ok_X
	cp		19
	jp		z, GameOver_Ok_X
	cp		20
	jp		z, GameOver_Ok_X
	cp		21
	jp		z, GameOver_Ok_X
	cp		22
	jp		z, GameOver_Ok_X
	cp		23
	jp		z, GameOver_Ok_X
	cp		24
	jp		z, GameOver_Ok_X
	cp		25
	jp		z, GameOver_Ok_X
	cp		26
	jp		z, GameOver_Ok_X
	cp		27
	jp		z, GameOver_Ok_X
	cp		28
	jp		z, GameOver_Ok_X
	cp		29
	jp		z, GameOver_Ok_X
	cp		30
	jp		z, GameOver_Ok_X
	cp		31
	jp		z, GameOver_Ok_X
	cp		32
	jp		z, GameOver_Ok_X
	cp		33
	jp		z, GameOver_Ok_X
	cp		34
	jp		z, GameOver_Ok_X
	cp		35
	jp		z, GameOver_Ok_X
	cp		36
	jp		z, GameOver_Ok_X
	cp		37
	jp		z, GameOver_Ok_X
	cp		38
	jp		z, GameOver_Ok_X
	cp		39
	jp		z, GameOver_Ok_X
	cp		40
	jp		z, GameOver_Ok_X
	cp		41
	jp		z, GameOver_Ok_X
	cp		42
	jp		z, GameOver_Ok_X
	cp		43
	jp		z, GameOver_Ok_X
	cp		44
	jp		z, GameOver_Ok_X
	cp		45
	jp		z, GameOver_Ok_X
	cp		46
	jp		z, GameOver_Ok_X
	cp		47
	jp		z, GameOver_Ok_X
	cp		48
	jp		z, GameOver_Ok_X
	cp		49
	jp		z, GameOver_Ok_X
	cp		50
	jp		z, GameOver_Ok_X
	cp		51
	jp		z, GameOver_Ok_X
	cp		52
	jp		z, GameOver_Ok_X
	cp		53
	jp		z, GameOver_Ok_X
	cp		54
	jp		z, GameOver_Ok_X
	cp		55
	jp		z, GameOver_Ok_X
	cp		56
	jp		z, GameOver_Ok_X
	cp		57
	jp		z, GameOver_Ok_X
	cp		58
	jp		z, GameOver_Ok_X

	ld		d, a
	ld		a,e
	cp		59
	jp		c, GameOver_MartiansWin
	ld		a, d
	cp		59
	jp		z, GameOver_Ok_X
	cp		60
	jp		z, GameOver_Ok_X
	cp		61
	jp		z, GameOver_Ok_X
	cp		62
	jp		z, GameOver_Ok_X
	cp		63
	jp		z, GameOver_Ok_X
	cp		64
	jp		z, GameOver_Ok_X
	cp		65
	jp		z, GameOver_Ok_X
	cp		66
	jp		z, GameOver_Ok_X
	cp		67
	jp		z, GameOver_Ok_X
	cp		68
	jp		z, GameOver_Ok_X
	cp		69
	jp		z, GameOver_Ok_X
	cp		70
	jp		z, GameOver_Ok_X
	cp		71
	jp		z, GameOver_Ok_X
	cp		72
	jp		z, GameOver_Ok_X
	cp		73
	jp		z, GameOver_Ok_X
	cp		74
	jp		z, GameOver_Ok_X

	jp		GameOver_MartiansWin

GameOver_Ok_X:
	ld		c, a
	ld		b, e

	call	GenerateRandomNumber	
	cp		255
	call	c, MartianShipsManagment_martian1
	cp		150
	call	c, MartianShipsManagment_martian2
	cp		80
	call	c, MartianShipsManagment_martian3

	add		d, 8

	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	dec		c
	dec		c
	dec		c
	inc		b
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	ld		bc, 0fffh
	call	Delay
	ld		bc, 0fffh
	call	Delay
	ld		bc, 0fffh
	call	Delay

	jp		GameOver_MartiansWin
GameOver_MartiansWin_Message:

	call	ClearHumans

	ld		hl, Msg_Sorry
	ld		c, 34
	ld		b, 21
	call    PrintStringAtPosition

	ld		hl, Msg_Martians_Win
	ld		c, 10
	ld		b, 23
	call    PrintStringAtPosition

	ld		hl, Msg_HintPlayAgain
	ld		c, 27
	ld		b, 25
	call    PrintStringAtPosition

	ret
GameOver_HumansWin_Message:
	call	RemoveHumanShip

	call	ClearHumans

	ld		hl, Msg_Congratulation
	ld		c, 32
	ld		b, 21
	call    PrintStringAtPosition

	ld		hl, Msg_YouHaveSaved
	ld		c, 20
	ld		b, 23
	call    PrintStringAtPosition

	ld		hl, Msg_HintPlayAgain
	ld		c, 27
	ld		b, 25
	call    PrintStringAtPosition

	ret
PrintExplosion:
	; INPUT: C=Position X, Y=Position Y
	push	de


	push 	bc
	ld		d, Explosion
	call 	PrintCharacterAtPosition
	pop 	bc

	push 	bc
	inc		d
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc

	

	push 	bc
	inc		d
	inc		b
	call 	PrintCharacterAtPosition
	pop 	bc

	push 	bc
	inc		d
	inc		b
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc

	ld		hl, HumanExplosionFlag
	ld		a,(hl)
	call	z, PrintExplosion_expanded

	pop		de
	ret
PrintExplosion_expanded:
	push 	bc
	inc		d
	inc		c
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc

	push 	bc
	inc		d
	inc		b
	inc		c
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc

	ret
ClearExplosion:
	; INPUT: C=Position X, Y=Position Y
	push	de

	push 	bc
	ld		d, 32
	call 	PrintCharacterAtPosition
	pop 	bc

	push 	bc
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc

	push 	bc
	inc		b
	call 	PrintCharacterAtPosition
	pop 	bc

	push 	bc
	inc		b
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc


	ld		hl, HumanExplosionFlag
	ld		a,(hl)
	call	z, ClearExplosion_expanded

	pop		de
	ret
ClearExplosion_expanded:

	push 	bc
	inc		c
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc

	push 	bc
	inc		b
	inc		c
	inc		c
	call 	PrintCharacterAtPosition
	pop 	bc

	ret
CheckHumanShipMissileOnTarget:
	; INPUT: D=MissileArrayPosition
	ld		hl, HumanMissileArrayPosition
	ld		(hl), d
	push	bc
	push	de
	call	GetMissileLocationByArrayPosition	
	ld		a, b				
	cp		0
	ret		z
	push	bc
	push	de
	ld		d, HumanMissile
	call	PrintCharacterAtPosition
	pop		de
	pop		bc

	push	bc
	push	de
	ld		d, HumanMissile
	inc		d
	inc		c
	call	PrintCharacterAtPosition
	pop		de
	pop		bc



	ld		a, -1
	ld		d, a
CheckHumanShipMissileOnTarget_search_martian_missile_loop:
	ld		a,d
	inc		a
	cp		100
	ld		d,a
	jp		z, CheckHumanShipMissileOnTarget_continue
	ld		hl, MartianMissilesPosX
	ld		a, d
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		c

	jp		nz, CheckHumanShipMissileOnTarget_search_martian_missile_loop

	ld		hl, MartianMissilesPosY
	ld		a, d
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		b
	jp		nz, CheckHumanShipMissileOnTarget_search_martian_missile_loop

	push	bc
	ld		hl, MartianMissilesPosX
	ld		a, d
	call	Add8BitTo16Bit
	ld		c,(hl)
	ld		(hl),0

	ld		hl, MartianMissilesPosY
	ld		a, d
	call	Add8BitTo16Bit
	ld		b,(hl)
	ld		(hl),0

	push	bc
	push	de
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		de
	pop		bc

	push	bc
	push	de
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		de
	pop		bc


	pop		bc
	jp		MissilesCrash


CheckHumanShipMissileOnTarget_continue:	
	ld		a, b
	cp		2
	jp		z, CheckHumanShipMissileOnTarget_search_martian_ship
	cp		4
	jp		z, CheckHumanShipMissileOnTarget_search_martian_ship
	cp		6
	jp		z, CheckHumanShipMissileOnTarget_search_martian_ship
	cp		8
	jp		z, CheckHumanShipMissileOnTarget_search_martian_ship
	cp		10
	jp		z, CheckHumanShipMissileOnTarget_search_martian_ship
	pop		de
	pop		bc
	ld		a, 0
	ret
CheckHumanShipMissileOnTarget_search_martian_ship:
	ld		a, 0
CheckHumanShipMissileOnTarget_search_martian_ship_loop:
	ld		d, a
	cp		4
	jp		z, CheckHumanShipMissileOnTarget_search_martian_ship_exit
	ld		hl, MartiansShipsPositionY
	ld		a, d
	call	Add8BitTo16Bit
	ld		a,(hl)
	ld		hl, MartianShipToRemoveY
	ld		(hl),a
	cp		b
	jp		nz, CheckHumanShipMissileOnTarget_search_martian_ship_checkx
	ld		a, d
	inc 	a
	jp		CheckHumanShipMissileOnTarget_search_martian_ship_loop
CheckHumanShipMissileOnTarget_search_martian_ship_checkx:
	ld		a, d
	ld		hl, MartiansShipsPositionX
	ld		a, d
	call	Add8BitTo16Bit
	ld		a,(hl)
	ld		hl, MartianShipToRemoveX
	ld		(hl),a
	cp		c
	jp		z, MartianShipCrash
	inc		a
	cp 		c
	jp		z, MartianShipCrash
	inc		a
	cp 		c
	jp		z, MartianShipCrash
	inc		a
	cp 		c
	jp		z, MartianShipCrash
	ld		a, d
	inc 	a
	jp		CheckHumanShipMissileOnTarget_search_martian_ship_loop

CheckHumanShipMissileOnTarget_search_martian_ship_exit:
	pop		de
	pop		bc
	ld		a, 0
	ret
MissilesCrash:
	push	bc
	push	de
	ld		hl, HumanMissileArrayPosition
	ld		d,(hl)
	call	z, RemoveHumanMissile
	pop		de
	pop		bc


	push	bc
	call	DisplayExplosion
	pop		bc

	pop		de
	pop		bc
	ret
MartianShipCrash:
	push	de
	ld		hl, HumanMissileArrayPosition
	ld		d,(hl)
	call	z, RemoveHumanMissile
	pop		de

	push	bc
	push	de
	ld		e, d
	ld		c,0
	ld		b,0
	call	UpdateMartianShipArrayPosition
	pop		de
	pop		bc

	push	bc
	push	de
	ld		hl, MartianShipToRemoveX
	ld		c,(hl)
	ld		hl, MartianShipToRemoveY
	ld		b,(hl)
	call	RemoveMartianShip
	pop		de
	pop		bc

	push	bc
	push	de
	ld		hl, Martians
	ld		a,(hl)
	dec		a
	ld		(hl),a
	call	RefreshMartiansCounters
	pop		de
	pop		bc


	push	bc
	ld		hl, MartianShipToRemoveX
	ld		c,(hl)
	ld		hl, MartianShipToRemoveY
	ld		b,(hl)
	call	DisplayExplosion
	pop		bc

	

	pop		de
	pop		bc
	ret
ClearHumans:
ClearHumans_21:
	ld		a, 0
	ld		b, 21
ClearHumans_loop_21:
	inc		a
	ld		e, a
	cp		78
	jp		z, ClearHumans_22
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearHumans_loop_21
ClearHumans_22:
	ld		a, 0
	ld		b, 22
ClearHumans_loop_22:
	inc		a
	ld		e, a
	cp		78
	jp		z, ClearHumans_23
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearHumans_loop_22
ClearHumans_23:
	ld		a, 0
	ld		b, 23
ClearHumans_loop_23:
	inc		a
	ld		e, a
	cp		78
	jp		z, ClearHumans_24
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearHumans_loop_23
ClearHumans_24:
	ld		a, 0
	ld		b, 24
ClearHumans_loop_24:
	inc		a
	ld		e, a
	cp		78
	jp		z, ClearHumans_25
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearHumans_loop_24
ClearHumans_25:
	ld		a, 0
	ld		b, 25
ClearHumans_loop_25:
	inc		a
	ld		e, a
	cp		78
	ret		z
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearHumans_loop_25




ClearScreen:
	call	CLS
ClearScreen_23:
	ld		a, -1
	ld		b, 24
ClearScreen_loop_23:
	inc		a
	ld		e, a
	cp		81
	jp		z, ClearScreen_24
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearScreen_loop_23
ClearScreen_24:
	ld		a, -1
	ld		b, 24
ClearScreen_loop_24:
	inc		a
	ld		e, a
	cp		81
	jp		z, ClearScreen_25
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearScreen_loop_24
ClearScreen_25:
	ld		a, -1
	ld		b, 25
ClearScreen_loop_25:
	inc		a
	ld		e, a
	cp		81
	jp		z, ClearScreen_26
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearScreen_loop_25
ClearScreen_26:
	ld		a, -1
	ld		b, 26
ClearScreen_loop_26:

	inc		a
	ld		e, a
	cp		80
	ret		z
	push	bc
	ld		c, a
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, e
	jp		ClearScreen_loop_26
	ret
DisplayExplosion:
	; INPUT: C=Position X, B=Position Y
	push	bc
	call	PrintExplosion
	pop		bc

	push	bc
	ld		bc, 0fffh
	call	Delay
	ld		bc, 0fffh
	call	Delay
	ld		bc, 0fffh
	call	Delay
	pop		bc

	push	bc
	call	ClearExplosion
	pop		bc

	ld		hl, HumanExplosionFlag
	ld		(hl),0

	ret
MartianShipFireManagement:
	; INPUT: C=Position X, B=Position Y
	push	de
	ld		hl, MartiansMissilesRatio
	ld		d, (hl)
	call	GenerateRandomNumber
	cp		d
	call	c, MartianShipFireManagement_fire
	pop		de
	ret
MartianShipFireManagement_fire:
	call	GetFirstFreeMartianMissileArrayPosition
	cp		100
	ret		z
	push	de
	
	ld		d, a
	inc		b
	inc		b
	inc 	c


	call	UpgradeMartianMissilePosition

	call	PrintMartianMissile
	pop		de
	ret
UpgradeMartianMissilePosition:
	;		INPUT: C=Position X, B=Position Y, D=ArrayPosition
	push	de

	ld		hl, MartianMissilesPosX
	ld		a, d
	call	Add8BitTo16Bit
	ld		(hl),c

	ld		hl, MartianMissilesPosY
	ld		a, d
	call	Add8BitTo16Bit
	ld		(hl),b

	pop		de
	ld		a, d
	ret
ResetMartiansMissilesPositions:
	ld		e, 0
ResetMartiansMissilesPositions_loop:
	ld		a, e
	cp		100
	ret     z
	ld		c,0
	ld		b,0
	ld		d, a
	call 	UpgradeMartianMissilePosition
	inc		e
	jp		ResetMartiansMissilesPositions_loop
RefreshMartiansMissilesPositions:
	ld		a, 0
RefreshMartiansMissilesPositions_loop:
	cp		100
	ret     z

	push	de
	push	bc
	ld		e, a

	ld		hl, Humans
	ld		a,(hl)
	cp		0
	jp		z, GameOver
	ld		hl, MartianMissilesPosX
	ld		a, e
	call	Add8BitTo16Bit
	ld		c,(hl)
	ld		a, c
	cp		0
	jp		z, RefreshMartiansMissilesPositions_next
	ld		hl, MartianMissilesPosY
	ld		a, e
	call	Add8BitTo16Bit
	ld		b,(hl)
	push	bc
	ld		d, 32
	call	PrintCharacterAtPosition
	ld		d, e
	pop		bc
	push	bc
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	inc		b
	ld		d, e
	ld		a, b
	cp		23
	jp		z, RefreshMartiansMissilesPositions_check_human
	cp		21
	jp		z, RefreshMartiansMissilesPositions_check_human_ship
	cp		22
	jp		z, RefreshMartiansMissilesPositions_check_human_ship
RefreshMartiansMissilesPositions_loop_continue:
	cp		26
	jp		z, RefreshMartiansMissilesPositions_remove
	call	UpgradeMartianMissilePosition
	call	PrintMartianMissile
RefreshMartiansMissilesPositions_next:
	ld		a, e
	inc  	a
	pop		bc
	pop		de
	jp		RefreshMartiansMissilesPositions_loop

RefreshMartiansMissilesPositions_remove:
	ld		c,0
	ld		b,0
	call	UpgradeMartianMissilePosition
	jp		RefreshMartiansMissilesPositions_next
RefreshMartiansMissilesPositions_check_human:
	ld		hl,MartianMissileCollisionSecCharacter
	ld		(hl),0
	push	de
	push	bc
	ld		d, a
	push	bc
	call	ReadCharacterFromVramAtPosition
	ld		a, c
	cp		32
	pop		bc
	jp		z, RefreshMartiansMissilesPositions_check_human_second_character

RefreshMartiansMissilesPositions_check_human_continue:
	call	RemoveHuman


	ld		a, d
	pop		bc
	pop		de

	ld		hl, HumanExplosionFlag
	ld		(hl),1
	push	bc
	call	DisplayExplosion
	pop		bc

	ld		hl, Humans
	ld		a,(hl)
	dec		a
	ld		(hl),a
	push	bc
	push	de
	call	RefreshHumansCounters
	pop		de
	pop		bc
	
	jp		RefreshMartiansMissilesPositions_remove
RefreshMartiansMissilesPositions_check_human_second_character:
	push	bc
	inc		c
	call	ReadCharacterFromVramAtPosition
	ld		a, c
	cp		32
	pop		bc
	jp		z, RefreshMartiansMissilesPositions_check_human_no
	ld		hl,MartianMissileCollisionSecCharacter
	ld		(hl),1
	jp		RefreshMartiansMissilesPositions_check_human_continue
RefreshMartiansMissilesPositions_check_human_no:
	
	ld		a, d
	pop		bc
	pop		de
	jp		RefreshMartiansMissilesPositions_loop_continue
RemoveHuman:
	push	de
	ld		e, a

	cp		205
	jp		z, RemoveHuman_left
	cp		206
	jp		z, RemoveHuman_center
	cp		207
	jp		z, RemoveHuman_right
RemoveHuman_exit:
	pop		de
	ret
RemoveHuman_left:

	push	bc
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	ld		hl,MartianMissileCollisionSecCharacter
	ld		a,(hl)
	cp		0
	jp		z, RemoveHuman_exit

	push	bc
	inc		c
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		c
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc 	b
	inc		c
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	jp		RemoveHuman_exit

RemoveHuman_center:

	push	bc
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc


	push	bc
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	jp		RemoveHuman_exit
RemoveHuman_right:

	push	bc
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	dec		c
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	dec		c
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		b
	inc		b
	dec		c
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	jp		RemoveHuman_exit
RefreshMartiansMissilesPositions_check_human_ship:
	ld		hl,MartianMissileCollisionSecCharacter
	ld		(hl),0
	push	de
	push	bc
	ld		d, a
	push	bc
	call	ReadCharacterFromVramAtPosition
	ld		a, c
	cp		32
	pop		bc
	jp		z, RefreshMartiansMissilesPositions_check_ship_second_character
RefreshMartiansMissilesPositions_check_human_ship_continue:
	call	RemoveHumanShip
	push	bc
	call	DisplayExplosion
	pop		bc
	ld		a, d
	pop		bc
	pop		de
	jp		RefreshMartiansMissilesPositions_remove
RefreshMartiansMissilesPositions_check_ship_second_character:
	push	bc
	inc		c
	call	ReadCharacterFromVramAtPosition
	ld		a, c
	cp		32
	pop		bc
	jp		z, RefreshMartiansMissilesPositions_check_human_ship_no
	ld		hl,MartianMissileCollisionSecCharacter
	ld		(hl),1
	jp		RefreshMartiansMissilesPositions_check_human_ship_continue
RefreshMartiansMissilesPositions_check_human_ship_no:
	
	ld		a, d
	pop		bc
	pop		de
	jp		RefreshMartiansMissilesPositions_loop_continue

RemoveHumanShip:
	; MODIFY: HL, DE, BC
	ld		hl, HumanShipVisible
	ld		(hl),0

	ld		hl, HumanShipStopTimeCicle
	ld		(hl),4
	ld		hl, 30000
	ld		(HumanShipStopTime),bc

	ld		hl,HumanShipMovingDirection
	ld		(hl),0

	ld		a,1

RemoveHumanShip_loop:
	cp		78
	ret		z
	push	de
	push	bc
	ld		e, a
	ld		c, a
	ld		b,22
	ld		d, 32
	call	PrintCharacterAtPosition
	ld		a, e
	pop		bc
	pop		de

	push	de
	push	bc
	ld		e, a
	ld		c, a
	ld		b,21
	ld		d, 32
	call	PrintCharacterAtPosition
	ld		a, e
	pop		bc
	pop		de

	inc		a
	jp		RemoveHumanShip_loop
	ret
PrintMartianMissile:
	; INPUT: D=ArrayPosition
	push	bc
	push	de
	ld		hl, MartianMissilesPosX
	ld		a, d
	call	Add8BitTo16Bit
	ld		c,(hl)

	ld		hl, MartianMissilesPosY
	ld		a, d
	call	Add8BitTo16Bit
	ld		b,(hl)

	push	bc
	ld		d, MartianMissile
	call	PrintCharacterAtPosition
	pop		bc

	push	bc
	inc		c
	ld		d,MartianMissile
	inc		d
	inc		d
	call	PrintCharacterAtPosition
	pop		bc

	pop		de
	pop		bc
	ret
GetFirstFreeMartianMissileArrayPosition:
	; OUTPUT: a=Array position (100 if none)
	push	bc
	ld		a,0
GetFirstFreeMartianMissileArrayPosition_loop:
	cp		100
	jp		z, GetFirstFreeMartianMissileArrayPosition_loop_end
	ld		c, a
	ld		hl, MartianMissilesPosX
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		0
	jp		z, GetFirstFreeMartianMissileArrayPosition_loop_end
	ld		a, c
	inc		a
	jp		GetFirstFreeMartianMissileArrayPosition_loop
GetFirstFreeMartianMissileArrayPosition_loop_end:
	ld		a,c
	pop		bc
	ret


SetLevelParameters:
	ld		hl, SelectedLevel
	ld		a,(hl)
	cp		2
	jp		z, SetLevelParameters_level2
	cp		3
	jp		z, SetLevelParameters_level3
SetLevelParameters_level1:
	ld		hl, Martians
	ld		(hl), 20
	ld		hl, MartiansMissilesRatio
	ld		(hl), 15
	ret
SetLevelParameters_level2:
	ld		hl, Martians
	ld		(hl), 25
	ld		hl, MartiansMissilesRatio
	ld		(hl), 25
	ret
SetLevelParameters_level3:
	ld		hl, Martians
	ld		(hl), 29
	ld		hl, MartiansMissilesRatio
	ld		(hl), 35
	ret
ClearEmptyRowsFromMatriansShips:
	ld		a,2
ClearEmptyRowsFromMatriansShips_loop:
	ld		b, a
	cp		12
	ret		z
	call	ClearEmptyRowsFromMatriansShips_check_row
	ld		a, d
	cp		1
	call	z, ClearEmptyRowsFromMatriansShips_remove_ship
	ld		a, b
	inc		a
	inc		a
	jp		ClearEmptyRowsFromMatriansShips_loop
ClearEmptyRowsFromMatriansShips_check_row:
	ld		c, a
	ld		a, 0
ClearEmptyRowsFromMatriansShips_check_row_loop:
	ld		d, 0
	ld		e, a
	cp		4
	ret		z
	ld		hl, MissilesPosY
	call	Add8BitTo16Bit
	ld		a, (hl)
	cp		b
	jp		z, ClearEmptyRowsFromMatriansShips_check_row_found
	ld		a, e
	inc		a
	jp		ClearEmptyRowsFromMatriansShips_check_row_loop
ClearEmptyRowsFromMatriansShips_check_row_found:
	ld		d, 1
	ret
ClearEmptyRowsFromMatriansShips_remove_ship
	ld		c,1
	call	RemoveMartianShip
	ret
MartiansShipsShowedCounter:
	ld		hl, Martians:
	push	bc
	ld		a,0
	ld		b, 0
MartiansShipsShowedCounter_loop:
	cp		4
	jp		z, MartiansShipsShowedCounter_loop_end
	ld		c, a
	ld		hl, MartiansShipsPositionX
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		0
	call	nz, MartiansShipsShowedCounter_ship_found
	ld		a, c
	inc		a
	jp		MartiansShipsShowedCounter_loop
MartiansShipsShowedCounter_loop_end:
	ld		a,b
	pop		bc
	ret
MartiansShipsShowedCounter_ship_found:
		inc		b
		ret

MartianShipsManagment:
	push	bc
	push	hl
	push	de
	call	MartiansShipsShowedCounter
	ld		hl, Martians
	ld		b, (hl)
	cp		b
	jp		nc, MartianShipsManagment_end
	call 	GetFirstMartianShipsArrayFreePosition
	cp		4
	jp		z, MartianShipsManagment_end
	ld		e, a
	ld		a,	r
	cp		6
	jp		nc, MartianShipsManagment_end ; Se esce numero 10 (su 20 possibili) genero una nuova nave marziana
	
	ld		c, 74		
	ld		d, 1
	call	GenerateRandomNumber
	cp		125
	call	nc, MartianShipsManagment_direction_from_left
	ld		hl, MartiansShipsDirection
	ld		a, e
	call	Add8BitTo16Bit
	ld		(hl),d

	ld		d, 0
	call	GenerateRandomNumber	; Trovo la nave da visualizzare
	cp		255
	call	c, MartianShipsManagment_martian1
	cp		150
	call	c, MartianShipsManagment_martian2
	cp		80
	call	c, MartianShipsManagment_martian3
	call	GenerateRandomNumber ; Trovo la riga
	ld		b,2
	cp		200
	call	c, MartianShipsManagment_row_4
	cp		150
	call	c, MartianShipsManagment_row_6
	cp		100
	call	c, MartianShipsManagment_row_8
	cp		50
	call	c, MartianShipsManagment_row_10
	call	MartianShipsManagment_verify_position
	ld		a, b
	cp		100
	jp		z,MartianShipsManagment_end
	ld		a,b
	cp		2
	call	z, MartianShipsManagment_right_start_position
	call	UpdateMartianShipArrayPosition
	ld 		hl, MartiansShipType
	ld		a, e
	call	Add8BitTo16Bit
	ld		(hl),d
	ld		hl,	MartiansDirectionChanged
	ld		a, e
	call	Add8BitTo16Bit
	ld		(hl),0
	call	ShowMartianShip

MartianShipsManagment_end: 
	pop		de
	pop		hl
	pop		bc
	ret
MartianShipsManagment_martian1:
	ld d, MartianShip1a
	ret
MartianShipsManagment_martian2:
	ld d, MartianShip2a
	ret
MartianShipsManagment_martian3:
	ld d, MartianShip3a
	ret
MartianShipsManagment_dx:
	ld		c, 1
	ret
MartianShipsManagment_direction_from_left:
	ld		d,2
	ld		c, 1
	ret
MartianShipsManagment_row_4:
	ld		b, 4
	ret
MartianShipsManagment_row_6:
	ld		b, 6
	ret
MartianShipsManagment_row_8:
	ld		b, 8
	ret
MartianShipsManagment_row_10:
	ld		b, 10
	ret
MartianShipsManagment_right_start_position:
	ld		a, c
	cp		74
	ret		nz
	ld		c,58
	ret
MartianShipsManagment_verify_position:
	push	hl
	push	de
	ld		a,	0
	ld		d, 	b
MartianShipsManagment_verify_position_loop:
	cp		4
	jp		z, MartianShipsManagment_verify_position_end
	ld		e, a
	
	ld 		hl, MartiansShipsPositionX
	call	Add8BitTo16Bit
	ld		a, (hl)
	cp		0
	jp      z, MartianShipsManagment_verify_position_return_to_loop

	ld		a, e
	ld 		hl, MartiansShipsPositionY
	call	Add8BitTo16Bit
	ld		a, (hl)
	cp		b
	jp		z, MartianShipsManagment_verify_position_invalid

	ld		a, e
	inc     a
	jp		MartianShipsManagment_verify_position_loop
MartianShipsManagment_verify_position_end
	pop		de
	pop		hl
	ret
MartianShipsManagment_verify_position_invalid:
	ld		b, 100
	jp		MartianShipsManagment_verify_position_end
MartianShipsManagment_verify_position_return_to_loop:
	ld		a, e
	inc     a
	jp		MartianShipsManagment_verify_position_loop	
GetFirstMartianShipsArrayFreePosition:
		; OUTPUT: a=Array position (4 if none)
	push	bc
	ld		a,0
GetFirstMartianShipsArrayFreePosition_loop:
	cp		4
	jp		z, GetFirstMartianShipsArrayFreePosition_loop_end
	ld		c, a
	ld		hl, MartiansShipsPositionX
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		0
	jp		z, GetFirstMartianShipsArrayFreePosition_loop_end
	ld		a, c
	inc		a
	jp		GetFirstMartianShipsArrayFreePosition_loop
GetFirstMartianShipsArrayFreePosition_loop_end:
	ld		a,c
	pop		bc
	ret
GenerateRandomNumber:
	; INPUT: L=Max value
	; OUTPUT: A=Generate random number (0<=a<=255)
	push	bc
	ld	a,(RndSeed)
	ld	b,a
	add	a,a
	add	a,a
	add	a,b
	inc	a; another possibility is ADD A,7
	ld	(RndSeed),a
	pop	bc
	ret
ResetMartiansPositions:
	ld		hl, Counter
	ld		(hl),0
	ld		a,(hl)
ResetMartiansPositions_loop:
	cp		4
	jp		z, ResetMartiansPositions_exit
	ld		e, a
	ld		c, 0
	ld		b, 0
	call	UpdateMartianShipArrayPosition
	ld		hl, Counter
	ld		a,(hl)
	inc		a
	ld		(hl),a
	jp		ResetMartiansPositions_loop
ResetMartiansPositions_exit:
	ret
MartiansRefreshPositions:
	ld		hl, Counter
	ld		(hl),0
MartiansRefreshPositions_loop:
	ld		hl, Counter
	ld		a,(hl)
	cp		4
	jp		z, MartiansRefreshPositions_end
	ld 		hl, MartiansShipsPositionX
	call	Add8BitTo16Bit
	ld		c,(hl)
	ld		a,c
	cp		0
	jp		z, MartiansRefreshPositions_next
	ld		hl, Counter
	ld		a,(hl)
	ld		hl,	MartiansDirectionChanged
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		0
	call	z, MartiansRefreshPositions_change_direction_verify
	ld		hl, Counter
	ld		a,(hl)
	ld 		hl, MartiansShipsPositionY
	call	Add8BitTo16Bit
	ld		b,(hl)
	ld		hl, Counter
	ld		a,(hl)
	ld		hl, MartiansShipsDirection
	call	Add8BitTo16Bit
	ld		d,(hl)
	ld		hl, Counter
	ld		e,(hl)
	call	UpdateMartianShipArrayPosition
	call	MoveMartianShip
MartiansRefreshPositions_next:
	ld		hl, Counter
	ld		a,(hl)
	inc 	a
	ld		(hl),a
	jp		MartiansRefreshPositions_loop
MartiansRefreshPositions_end:
	ret 
MartiansRefreshPositions_change_direction_verify:
	ld		a, c
	cp		20
	jp		z,MartiansRefreshPositions_change_direction_evaluation
	cp		35
	jp		z,MartiansRefreshPositions_change_direction_evaluation
	cp		42
	jp		z,MartiansRefreshPositions_change_direction_evaluation
	cp		63
	jp		z,MartiansRefreshPositions_change_direction_pre_evaluation
	ret
MartiansRefreshPositions_change_direction_pre_evaluation:
	ld		a, b
	cp		2
	ret		z
MartiansRefreshPositions_change_direction_evaluation:
	call	GenerateRandomNumber
	cp		50
	ret		nc
	ld		hl, Counter
	ld		a,(hl)
	ld		hl,	MartiansDirectionChanged
	call	Add8BitTo16Bit
	ld		(hl),1
	ld		hl, Counter
	ld		a,(hl)
	ld		hl,	MartiansShipsDirection
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		1
	call	z, MartiansRefreshPositions_change_direction_change_left
	call	nz, MartiansRefreshPositions_change_direction_change_right
	ld		(hl),a
	ret
MartiansRefreshPositions_change_direction_change_left:
	ld		a, 2
	ret
MartiansRefreshPositions_change_direction_change_right:
	ld		a, 1
	ret
MoveMartianShip:
	; INPUT: C=Position X, B=Position Y, D=Direction, E=ArrayPosition
	ld		a,d
	cp		2
	jp		z, MoveMartianShip_move_to_right
	ld		a,c
	cp		0
	dec		c
	jp		z, MoveMartianShip_remove
	push	bc
	call	UpdateMartianShipArrayPosition
	call	ChangeMartianType
	call    ShowMartianShip
	pop		bc
	call	MartianShipFireManagement
	ret
MoveMartianShip_move_to_right:
	ld		d,74
	ld		a,b
	cp		2
	call	z, MoveMartianShip_move_to_right_change
	ld		a,c
	cp		d
	jp		z, MoveMartianShip_remove
	inc		c
	call	UpdateMartianShipArrayPosition
	call	ChangeMartianType
	call	ShowMartianShip
	ret
MoveMartianShip_move_to_right_change:
	ld		d, 58
	ret
MoveMartianShip_remove:
	call	RemoveMartianShip
	ld		c,0
	ld		b,0
	call	UpdateMartianShipArrayPosition

	ret
UpdateMartianShipArrayPosition:
	; INPUT: e=ArrayPosition, c=PositionX, b=PositionY
	push	bc 
	push	hl
	ld 		hl, MartiansShipsPositionX
	ld		a, e
	call	Add8BitTo16Bit
	ld		(hl),c
	ld 		hl, MartiansShipsPositionY
	ld		a, e
	call	Add8BitTo16Bit
	ld		(hl),b
	pop		hl
	pop		bc
	ret
ChangeMartianType:
	; INPUT: E=ArrayPosition
	; OUPUT: D=Ship type
	ld		hl, MartiansShipType
	ld		a, e
	call	Add8BitTo16Bit
	ld		a,(hl)
	cp		MartianShip1a
	jp		z, ChangeMartianType_MartianShip1a
	cp		MartianShip1b
	jp		z, ChangeMartianType_MartianShip1b
	cp		MartianShip2a
	jp		z, ChangeMartianType_MartianShip2a
	cp		MartianShip2b
	jp		z, ChangeMartianType_MartianShip2b
	cp		MartianShip3a
	jp		z, ChangeMartianType_MartianShip3a
	cp		MartianShip3b
	jp		z, ChangeMartianType_MartianShip3b
ChangeMartianType_MartianShip1a:
	ld 		d,MartianShip1b
	jp		ChangeMartianType_Update
ChangeMartianType_MartianShip1b:
	ld 		d,MartianShip1a
	jp		ChangeMartianType_Update
ChangeMartianType_MartianShip2a:
	ld 		d,MartianShip2b
	jp		ChangeMartianType_Update
ChangeMartianType_MartianShip2b:
	ld 		d,MartianShip2a
	jp		ChangeMartianType_Update
ChangeMartianType_MartianShip3a:
	ld 		d,MartianShip3b
	jp		ChangeMartianType_Update
ChangeMartianType_MartianShip3b:
	ld 		d,MartianShip3a
	jp		ChangeMartianType_Update
ChangeMartianType_Update:
	ld		hl, MartiansShipType
	ld		a, e
	call	Add8BitTo16Bit
	ld		(hl),d
	ret

ResetFiredMissilesPositions:
	; MODIFY: A, HL
	ld		a,0
	ld		hl, MissilesPosX
ResetFiredMissilesPositions_xloop:
	cp		50
	jp		z, ResetFiredMissilesPositions_xend
	ld		(hl),0	
	inc		hl
	inc 	a
	jp 		ResetFiredMissilesPositions_xloop
ResetFiredMissilesPositions_xend:
	ld		a,0
	ld		hl, MissilesPosY
ResetFiredMissilesPositions_yloop:
	cp		50
	jp		z, ResetFiredMissilesPositions_yend
	ld		(hl),0	
	inc		hl
	inc     a
	jp 		ResetFiredMissilesPositions_yloop
ResetFiredMissilesPositions_yend:
	ret
Add8BitTo16Bit:
	; INPUT: HL=destination registry, A=Value to add
	add   a, l   
	ld    l, a    
	adc   a, h    
	sub   l       
	ld    h, a    
	ret
ScreenRefresh:
	ld		hl, MissilesRefreshPositionTime
	ld		a,(hl)
	cp		1
	jp		z, ScreenRefresh_refresh
	ld		hl, MissilesRefreshPositionTime
	dec		a
	ld		(hl),a

	ld		de,2
	ld		hl, (HumanShipStopTime)
	or a 
	sbc hl, de
	add hl, de
	jp		z, ScreenRefresh_set_human_ship_visible
	dec		hl
	ld		(HumanShipStopTime),hl
	ret
ScreenRefresh_set_human_ship_visible:
	ld		hl, HumanShipVisible
	ld		a,(hl)
	cp		1
	ret		z
	ld		hl, HumanShipStopTimeCicle
	ld		a, (hl)
	dec		a
	ld		(hl),a
	cp		255
	jp		nz, ScreenRefresh_set_human_ship_visible_cicle
	call   PrintHumanShip
	ld		hl, HumanShipVisible
	ld		(hl),1
	call	PrintHumanShip
	ret
ScreenRefresh_set_human_ship_visible_cicle:
	ld		hl, HumanShipStopTimeCicle
	ld		a, (hl)
	dec		a
	ld		(hl),a
	ld		bc, 30000
	ld		(HumanShipStopTime),bc
	ret
ScreenRefresh_refresh:
	ld		hl, MissilesRefreshPositionTime
	ld		a, 255
	ld		(hl),a
	ld		a,0
ScreenRefresh_loop:
	cp		1						; *** Set HERE HOW MANY SHOTS (+1) ARE POSSIBLE FROM HUMAN SHIP ***
	jp		z,	ScreenRefresh_exit		; 
	ld		d, a				; Memorizzo in d la posizione corrente
	call	GetMissileLocationByArrayPosition			; Trovo X e Y della posizione corrente
	ld		a, b				; Verifico che X corente non sia zero
	cp		0
	jp		z, ScreenRefresh_next
	ld		a, d				; Ripristino in A la posizione corrente
	push	de
	push	bc					; Metto nello stack BC (con X e Y correnti)
	ld		d, 32				; Pulisco video in X e Y
	call	PrintCharacterAtPosition
	pop		bc					; Recupero dallo stack BC (con X e Y correnti)
	push	bc					; Metto nello stack BC (con X e Y correnti)
	inc		c					; Icremento c per puntare alla X affiancata
	ld		d, 32				; Pulisco la posizione X,Y affiancata
	call	PrintCharacterAtPosition
	pop		bc					; Recupero dallo stack BC (con X e Y correnti)
	ld		d, a				; Memorizzo in D la posizione corrente
	ld		a, c				; Metto in A la posizione X da testare
	push	bc
	call	GetFirstGameAreaRow ; Trovo massimo bordo in alto
	ld		a,b
	cp		c					
	pop		bc
	pop		de
	jp		z, ScreenRefresh_clear	; Se ho raggiunto la posizione massima in alto non scrivo più nulla
	push	de
	push	bc
	dec		b
	ld		d, HumanMissile				
	call	PrintCharacterAtPosition
	pop		bc
	pop		de
	push	de
	push	bc
	dec		b
	inc		c
	ld		d, HumanMissile
	inc		d				
	call	PrintCharacterAtPosition
	pop		bc
	pop		de
	dec		b
	call  	SetMissileLocationAtArrayPosition
	push	bc
	push	de
	call	CheckHumanShipMissileOnTarget
	call	DrawInfoBox
	pop		de
	pop		bc
ScreenRefresh_next:
	ld		a, d
	inc		a
	inc		hl
	jp		ScreenRefresh_loop
ScreenRefresh_clear
	ld		b, 0
	ld		c, 0
	call  	SetMissileLocationAtArrayPosition
	jp		ScreenRefresh_next
ScreenRefresh_exit
	
	ld		hl, MartiansShipsSpeed
	ld		a,(hl)
	cp		2
	jp	 	z, ScreenRefresh_exit_martians_speed
	ld		hl, MartiansShipsSpeed
	ld		a,(hl)
	inc		a
	ld		(hl),a
	ret
ScreenRefresh_exit_martians_speed:
	ld		hl, MartiansShipsSpeed
	ld		(hl),0
	call    MartianShipsManagment
	call	MartiansRefreshPositions
	call	RefreshMartiansMissilesPositions
	ret

RemoveHumanMissile:
	push	bc
	ld		a, d
	ld		hl, MissilesPosX
	call	Add8BitTo16Bit
	ld		(hl),0

	ld		a, d
	ld		hl, MissilesPosY
	call	Add8BitTo16Bit
	ld		(hl),0

	push	bc
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc

	inc     c
	ld		d,32
	call	PrintCharacterAtPosition

	pop		bc
	ret
SetMissileLocationAtArrayPosition:
	; INPUT: D=Position, B=PosY, C=PosX
	ld		a,0
	ld		hl, MissilesPosX
SetMissileLocationAtArrayPosition_loop_x:
	cp		d
	jp		z, SetMissileLocationAtArrayPosition_end_x
	inc		a
	inc		hl 
	jp		SetMissileLocationAtArrayPosition_loop_x
SetMissileLocationAtArrayPosition_end_x:
	ld		(hl),c
	ld		a,0
	ld		hl, MissilesPosY
SetMissileLocationAtArrayPosition_loop_y:
	cp		d
	jp		z, SetMissileLocationAtArrayPosition_end_y
	inc		a
	inc		hl 
	jp		SetMissileLocationAtArrayPosition_loop_y
SetMissileLocationAtArrayPosition_end_y:
	ld		(hl),b
	ret
GetMissileLocationByArrayPosition:
	; INPUT: D=Position
	; OUTPUT: C=PosX, B=PosY
	; MODIFY: DE, HL, BC
	ld		a,0
	ld		hl, MissilesPosX
	ld		c,0
	ld		b,0
GetMissileLocationByArrayPosition_loop_x:
	cp		d
	jp		z, GetMissileLocationByArrayPosition_end_x
	inc		a
	inc		hl 
	jp		GetMissileLocationByArrayPosition_loop_x
GetMissileLocationByArrayPosition_end_x:
	ld		c,(hl)
	ld		a,0
	ld		hl, MissilesPosY
GetMissileLocationByArrayPosition_loop_y:
	cp		d
	jp		z, GetMissileLocationByArrayPosition_end_y
	inc		a
	inc		hl 
	jp		GetMissileLocationByArrayPosition_loop_y
GetMissileLocationByArrayPosition_end_y:
	ld		b,(hl)
	ret


GetFirstGameAreaRow:
	ld		a,c
	ld		c,1
	cp		62
	jp		z, GetFirstGameAreaRow_topright
	cp		63
	jp		z, GetFirstGameAreaRow_topright
	cp		64
	jp		z, GetFirstGameAreaRow_topright
	cp		64
	jp		z, GetFirstGameAreaRow_topright
	cp		65
	jp		z, GetFirstGameAreaRow_topright
	cp		66
	jp		z, GetFirstGameAreaRow_topright
	cp		67
	jp		z, GetFirstGameAreaRow_topright
	cp		68
	jp		z, GetFirstGameAreaRow_topright
	cp		69
	jp		z, GetFirstGameAreaRow_topright
	cp		70
	jp		z, GetFirstGameAreaRow_topright
	cp		71
	jp		z, GetFirstGameAreaRow_topright
	cp		72
	jp		z, GetFirstGameAreaRow_topright
	cp		73
	jp		z, GetFirstGameAreaRow_topright
	cp		74
	jp		z, GetFirstGameAreaRow_topright
	cp		75
	jp		z, GetFirstGameAreaRow_topright
	cp		76
	jp		z, GetFirstGameAreaRow_topright
	cp		77
	jp		z, GetFirstGameAreaRow_topright

	ret
GetFirstGameAreaRow_topright:
	ld		c,4
	ret
ReadCharacterFromVramAtPosition:
	; INPUT: c=Position X, b=Position Y
	; OUPUT: c=Character in VRAM
	; MODIFY: BC
	; RETURN c=character code
	ld    	a,c
	cp    	80
	jp    	z, PrintCharacterAtPosition_exit
	push  	de
	ld    	h,b
	ld    	e,80
	call  	Mult8
	pop   	de
	ld    	a,c
	add   	a, l    
    ld    	l, a    
    adc   	a, h    
    sub   	l       
    ld    	h, a    
	ld    	bc,4000h
	add   	hl,bc 
	call  	RDVRM
	ld		c, a
	ret
move_human_ship_to_left:

	ld		hl, MartiansShipsSpeed
	ld		a,(hl)
	cp		2
	jp		nz, main_loop
	call	ScreenRefresh_refresh
	ld		bc, 0fffh
	call	Delay
	ld		hl, HumanShipCurrentPosition
	ld		a, (hl)
	cp		1
	jp		z, move_human_ship_to_left_no_move_allowed
	dec		a
	ld		hl, HumanShipCurrentPosition
	ld		(hl), a
	call 	PrintHumanShip
	jp		main_loop
move_human_ship_to_left_no_move_allowed:
	jp		start_move_human_ship_to_right
move_human_ship_to_right:

	ld		hl, MartiansShipsSpeed
	ld		a,(hl)
	cp		2
	jp		nz, main_loop
	call	ScreenRefresh_refresh
	ld		bc, 0fffh
	call	Delay
	ld		hl, HumanShipCurrentPosition
	ld		a, (hl)
	cp		74
	jp		z, move_human_ship_to_right_no_move_allowed
	inc		a
	ld		hl, HumanShipCurrentPosition
	ld		(hl), a
	call 	PrintHumanShip
	jp		main_loop
move_human_ship_to_right_no_move_allowed:
	jp		start_move_human_ship_to_left
start_human_ship_fire:
	ld		hl, HumanShipVisible
	ld		a,(hl)
	cp		0
	jp		z, main_loop
	ld		hl, HumanShipCurrentPosition
	ld		c, (hl)
	inc		c
	ld		b, 20
	call	ReadCharacterFromVramAtPosition
	ld		a, c
	cp		HumanMissile
	jp		z, main_loop
	ld		a,0
	ld		hl, MissilesPosX
start_human_ship_fire_find_free_array_item:
	cp		1				; *** Set HERE HOW MANY SHOTS (+1) ARE POSSIBLE FROM HUMAN SHIP ***
	jp		z,	main_loop
	ld		b, a
	ld		a,(hl)
	cp		0
	jp		z, start_human_ship_fire_draw
	ld		a, b
	inc		hl		
	inc		a
	jp		start_human_ship_fire_find_free_array_item

start_human_ship_fire_draw:
	push	hl
	ld		hl, HumanShipCurrentPosition
	ld		c, (hl)
	inc		c

	ld		b, 20
	ld		d, HumanMissile
	call 	PrintCharacterAtPosition
	ld		hl, HumanShipCurrentPosition
	ld		c, (hl)
	inc		c
	inc		c
	ld		b, 20
	ld		d, HumanMissile
	inc		d
	call 	PrintCharacterAtPosition

	ld		hl, HumanShipCurrentPosition
	ld		c, (hl)
	inc		c

	pop		hl
	ld		(hl), c
start_human_ship_fire_draw_savey:
	ld		a,0
	ld		hl, MissilesPosY
start_human_ship_fire_draw_savey_find_free_array_item:
	cp		50
	jp		z,	main_loop
	ld		b, a
	ld		a,(hl)
	cp		0
	jp		z, start_human_ship_fire_draw_savey_end
	ld		a, b
	inc		hl		
	inc		a
	jp		start_human_ship_fire_draw_savey_find_free_array_item
start_human_ship_fire_draw_savey_end
	ld		(hl),20
	jp		main_loop
start_move_human_ship_to_right:
	ld		hl, HumanShipVisible
	ld		a,(hl)
	cp		0
	jp		z, main_loop
	ld		hl,HumanShipMovingDirection
	ld		(hl),1
	jp		main_loop
start_move_human_ship_to_left:
	ld		hl, HumanShipVisible
	ld		a,(hl)
	cp		0
	jp		z, main_loop
	ld		hl,HumanShipMovingDirection
	ld		(hl),2
	jp		main_loop
stop_human_ship:
	ld		hl,HumanShipMovingDirection
	ld		(hl),0
	jp		main_loop
PrintHumanShip:
	; MODIFY: HL, DE, BC
	ld		hl, HumanShipVisible
	ld		a,(hl)
	cp		0
	ret		z

	ld		hl, HumanShipCurrentPosition
	ld		c, (hl)
	push 	bc
	ld		b, 21
	ld		d, HumanShip
	call 	PrintCharacterAtPosition
	pop 	bc
	push 	bc
	inc		c

	ld		b, 21
	inc     d
	call 	PrintCharacterAtPosition
	pop 	bc
	push 	bc
	inc		c
	inc 	c
	ld		b, 21
	inc     d
	call 	PrintCharacterAtPosition
	pop 	bc
	push 	bc
	ld		b, 22
	inc		d
	call 	PrintCharacterAtPosition
	pop 	bc
	push 	bc
	inc		c
	ld		b, 22
	inc		d
	call 	PrintCharacterAtPosition
	pop 	bc
	push 	bc
	inc		c
	inc 	c
	ld		b, 22
	inc		d
	call 	PrintCharacterAtPosition
	pop 	bc
	
	push 	bc
	inc		c
	inc 	c
	inc		c
	ld		b, 21
	inc		d
	call 	PrintCharacterAtPosition
	pop 	bc
	push 	bc
	inc		c
	inc 	c
	inc		c
	ld		b, 22
	inc		d
	call 	PrintCharacterAtPosition
	pop 	bc

	ld		a, c
	cp		1
	jp      nz, PrintHumanShip_clear_left
	
	ld		a, c
	cp		74
	jp      nz, PrintHumanShip_clear_right

	ret
PrintHumanShip_clear_left:
	push	bc
	dec		c
	ld		b, 22
	ld		d, 32
	call 	PrintCharacterAtPosition
	pop 	bc
	push	bc
	dec		c
	ld		b, 21
	ld		d, 32
	call 	PrintCharacterAtPosition
	pop 	bc

	ld		a, c
	cp		74
	jp      nz, PrintHumanShip_clear_right

	ret
PrintHumanShip_clear_right:

	push	bc
	inc		c
	inc		c
	inc		c
	inc		c
	inc		c
	ld		b, 21
	ld		d, 32
	call 	PrintCharacterAtPosition
	pop 	bc
	push	bc
	inc		c
	inc		c
	inc		c
	inc		c
	ld		b, 22
	ld		d, 32
	call 	PrintCharacterAtPosition
	pop 	bc
	push	bc
	ld		b, 22
	ld		c, 78
	ld		d, BrdVertical
	call 	PrintCharacterAtPosition
	pop 	bc
	push	bc
	ld		b, 21
	ld		c, 78
	ld		d, BrdVertical
	call 	PrintCharacterAtPosition
	pop 	bc




	ret
DrawInfoBox:
	ld    	b, 0
	ld    	c, 63
	ld    	d, BrdTopRight
	call  PrintCharacterAtPosition

	ld    	b, 1
	ld    	c, 63
	ld    	d, BrdVertical
	call  PrintCharacterAtPosition

	ld    	b, 2
	ld    	c, 63
	ld    	d, BrdVertical
	call  PrintCharacterAtPosition

	ld    	b, 3
	ld    	c, 63
	ld    	d, BrdBottomLeft
	call  PrintCharacterAtPosition

	ld    	b, 3
	ld    	c, 78
	ld    	d, BrdTopRight
	call  PrintCharacterAtPosition

	ret
RefreshMartiansCounters:
	ld		hl, Martians
	push	hl
	ld		a,(hl)
	cp		10
    jp      c, RefreshMartiansCountersLess10
	cp		20
	jp      c, RefreshMartiansCountersLess20

	pop		hl
	ld		a,(hl)
	;sub		a, 10	
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
	ld    	d, a
	call  PrintCharacterAtPosition

	ld    	b, 2
	ld    	c, 77
	ld    	d, 50
	call  PrintCharacterAtPosition

	ret
RefreshMartiansCountersLess20
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
	ld    	d, a
	call  PrintCharacterAtPosition

	ld    	b, 2
	ld    	c, 77
	ld    	d, 49
	call  PrintCharacterAtPosition
	ret
RefreshMartiansCountersLess10
	ld    	b, 2
	ld    	c, 77
	ld    	d, 32
	call  PrintCharacterAtPosition

	pop 	hl
	ld		a,(hl)
	add		a, 48
	ld		b, 2
	ld    	c, 78
	ld    	d, a
	call  PrintCharacterAtPosition
	ret
RefreshHumansCounters:
	ld		hl, Humans
	push	hl
	ld		a,(hl)
	cp		10
    jp      c, RefreshCounterHumansLess10
	
	pop		hl
	ld		a,(hl)
	;sub		a, 10	
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
	ld    	b, 1
	ld    	c, 78
	ld    	d, a
	call  PrintCharacterAtPosition

	ld    	b, 1
	ld    	c, 77
	ld    	d, 49
	call  PrintCharacterAtPosition

	ret
RefreshCounterHumansLess10:
	ld    	b, 1
	ld    	c, 77
	ld    	d, 32
	call  PrintCharacterAtPosition

	pop 	hl
	ld		a,(hl)
	add		a, 48
	ld		b, 1
	ld    	c, 78
	ld    	d, a
	call  PrintCharacterAtPosition
	ret



Delay:
	; MODIFY: BC
	nop
	dec bc
	ld a,b
	or c
	ret z
	jp Delay
MoveHumanFromLeft:
	;INPUT: D=Position,E=First character code
	push bc
	push  de
	ld    a,d
	ld    b, 23
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  e
	inc   a
	ld    b, 23
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  e
	inc	  e
	inc   a  	
	inc	  a
	ld    b, 23
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

    push bc
	push  de
	ld    a,d
	inc	  e
	inc	  e
	inc   e
	ld    b, 24
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc   a
	inc	  e
	inc	  e
	inc   e
	inc   e
	ld    b, 24
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  a
	inc   a
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	ld    b, 24
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	inc   e
	ld    b, 25
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc   a
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	inc   e
	inc   e
	ld    b, 25
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc   a
	inc   a
	inc	  e
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	inc   e
	inc   e
	ld    b, 25
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc
 
	push bc
	push  de
	ld    a,d
	dec   a
	ld    b, 23
	ld    c, a
	ld    d, 32
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	dec   a
	ld    b, 24
	ld    c, a
	ld    d, 32
	call  PrintCharacterAtPosition
	pop   de
	pop  bc
	
	push bc
	push  de
	ld    a,d
	dec   a
	ld    b, 25
	ld    c, a
	ld    d, 32
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	ret
MoveHumanFromRight:
	;INPUT: D=Position,E=First character code
	push bc
	push  de
	ld    a,d
	dec   a
	dec   a
	ld    b, 23
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  e
	dec   a
	ld    b, 23
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  e
	inc	  e
	ld    b, 23
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

    push bc
	push  de
	ld    a,d
	dec   a
	dec   a
	inc	  e
	inc	  e
	inc   e
	ld    b, 24
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	dec   a
	inc	  e
	inc	  e
	inc   e
	inc   e
	ld    b, 24
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	ld    b, 24
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	dec   a
	dec   a
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	inc   e
	ld    b, 25
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	dec   a
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	inc   e
	inc   e
	ld    b, 25
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc	  e
	inc	  e
	inc	  e
	inc	  e
	inc   e
	inc   e
	inc   e
	inc   e
	ld    b, 25
	ld    c, a
	ld    d, e
	call  PrintCharacterAtPosition
	pop   de
	pop  bc
 
	push bc
	push  de
	ld    a,d
	inc   a
	ld    b, 23
	ld    c, a
	ld    d, 32
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	push bc
	push  de
	ld    a,d
	inc   a
	ld    b, 24
	ld    c, a
	ld    d, 32
	call  PrintCharacterAtPosition
	pop   de
	pop  bc
	
	push bc
	push  de
	ld    a,d
	inc   a
	ld    b, 25
	ld    c, a
	ld    d, 32
	call  PrintCharacterAtPosition
	pop   de
	pop  bc

	ret
SetBlinkingCharacter:
	; INPUT: C=Position X, B=Position Y
	; MODIFY: HL, DE
	push bc
	ld    a,(REG3SAV)
	ld    e, a
	ld    h, 40h
	call  Mult8
	ld    de, hl
	pop   bc
	push  de
	push  bc
	ld    h,b
	ld    e,80
	call  Mult8
	pop   bc
	pop   de
	ld    a,c
	add   a, l    
    ld    l, a    
    adc   a, h    
    sub   l       
    ld    h, a    
	pop   de
	push  hl
	pop   bc
	ld    hl, de
	add   hl, bc
	ld	  hl, de
	ld	  a,(VDP_DW)	
	ld	  c,a
	inc   c
	ld    a,l
	di
	out   (c),a
	ld    a,h
	ei
	out   (c),a
	ld	  a,(VDP_DR)	
	ld	  c,a
	ld    a,1
	out   (c),a
	ret

WriteByteToVdpRegister:
	; INPT: A = data, B = register number + 80h (to set the bit 7)
	; MODIFY: BC
	push	af
	ld	a,(VDP_DW)	
	ld	c,a
	inc	c	
	di			
	pop	af
	out	(c),a		
	out	(c),b		
	ei			
	ret

ReadVdpRegisterStatus:
	; INPUT: B = Status register number to read (MSX2~)
	; OUTPUT: B = Read value from the status register
	; MODIFY: AF, BC
	; -> Write the registre number in the r#15 (these 7 lines are specific MSX2 or newer)
	ld	a,(VDP_DW)	
	inc	a
	ld	c,a		
	di		
	out	(c),b
	ld	a,080h+15
	out	(c),a 
	ld	a,(VDP_DR)
	inc	a
	ld	c,a		
	in	b,(c)	
	ld	a,(VDP_DW)	
	inc	a
	ld	c,a		
	xor	a
	out	(c),a
	ld	a,080h+15
	out	(c),a
	ei		
	ret
PrintCharacterAtPosition:
	; INPUT: D=Character, C=Position X, B=Position Y
	; MODIFY: HL, DE, BC
	ld    a,c
	cp    80
	jp    z, PrintCharacterAtPosition_exit
	push  de
	ld    h,b
	ld    e,80
	call  Mult8
	pop   de
	ld    a,c
	add   a, l    
    ld    l, a    
    adc   a, h    
    sub   l       
    ld    h, a    
	ld    bc,4000h
	add   hl,bc 
	ld	  a,(VDP_DW)	
	ld	  c,a
	inc   c
	ld    a,l
	di
	out   (c),a
	ld    a,h
	ei
	out   (c),a
	ld	  a,(VDP_DR)	
	ld	  c,a
	ld    a,d
	out  (c),a
PrintCharacterAtPosition_exit:
	ret

PrintStringAtPosition:
	; INPUT: HL String to print, C=Position X, B=Position Y
	; MODIFY: HL, DE, BC
PrintStringAtPosition_loop:
	ld		a, (hl) 

	cp		0 
	jp		z, PrintStringAtPosition_end
	push	hl
	ld      d, a
	push	bc
	call    PrintCharacterAtPosition
	pop		bc
	inc		c
	pop		hl
	inc     hl 
	jp		PrintStringAtPosition_loop 
PrintStringAtPosition_end:
	ret
Mult8:
	; INPUT: H=Factor, E=Factor 2
	; OUTPUT: HL
	; MODIFY: DE
	ld d,0
	ld l,d
	ld b,8
Mult8_Loop:
	add hl,hl
	jp nc,Mult8_NoAdd
	add hl,de
Mult8_NoAdd:
	djnz Mult8_Loop
	ret

Mult12:	
	; INPUT: A=Factor, DE=Factor 2
	; OUTPUT: HL
	ld l,0
	ld b,8
Mult12_Loop:
	add hl,hl
	add a,a
	jp nc,Mult12_NoAdd
	add hl,de
Mult12_NoAdd:
	djnz Mult12_Loop
	ret

Mult16:	ld a,b
	; INPUT: BC=Factor, DE=Factor 2
	; OUTPUT: HL
	ld b,16
Mult16_Loop:
	add hl,hl
	sla c
	rla
	jp nc,Mult16_NoAdd
	add hl,de
Mult16_NoAdd:
	djnz Mult16_Loop
	ret
InitScreen:
	ld a,80              ; 80 columns 
    ld (LINL40),a
    xor a
    call CHGMOD          ; Screen 0  

	ld	a,(0fcc1h)
	ld	hl,002dh
	call	RDSLT
	or	a
	ret	z	; Back if MSX1

	ld	a,26
	ld	(0F3B1h),a

	ld	a,(0fcc1h)
	ld	hl,0007h
	call	RDSLT

	ld	c,a
	inc	c

	ld	a,(REG9SAV)
	or	080h
	di
	ld	(REG9SAV),a
	out (c),a
	ld a,80h+9
	ei
	out (c),a		
	ld a,080h
	di
	out (c),a
	ld a,047h
	out (c),a
	ei
	dec c
	ld a,32	
	ld b,240	
InitScreen_loop:
	out	(c),a
	djnz	InitScreen_loop
	ret
PrintNewLine:
	push af 			
	ld a,13				; Carriage return
	call CHPUT
	ld a,13				; Line feed
	call CHPUT
	
RemoveMartianShip:
	; INPUT: c=Pos X, b=Pos Y
	; MODIFY: BC,DE, HL

	push	bc
	push	de
	ld		e, 78
	ld		a, b
	cp		2
	call	z, RemoveMartianShip_row2
	ld		a,1
	
RemoveMartianShip_loop:
	cp		e
	jp		z, RemoveMartianShip_end
	ld		c, a
	push	bc
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	push	bc
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		bc
	ld		a, c
	inc		a
	jp 		RemoveMartianShip_loop
	
RemoveMartianShip_end:
	pop		de
	pop		bc
	;call	RestoreVerticalBorders
	ret
RemoveMartianShip_row2:
	ld		e, 62
	ret
RestoreVerticalBorders:


	push	de
	push	bc
	ld		d,BrdVertical
	ld		c,0
	call	PrintCharacterAtPosition
	pop		bc
	pop		de

	push	de
	push	bc
	ld		d,BrdVertical
	ld		c,0
	inc		b
	call	PrintCharacterAtPosition
	pop		bc
	pop		de

	ld		a, b
	cp		2
	ret		z
	push	de
	push	bc
	ld		d,BrdVertical
	ld		c,78
	call	PrintCharacterAtPosition
	pop		bc
	pop		de

	push	de
	push	bc
	ld		d,BrdVertical
	ld		c,78
	inc		b
	call	PrintCharacterAtPosition
	pop		bc
	pop		de

	ld		a, b
	cp		4
	ret		z

	push	de
	push	bc
	ld		d,BrdVertical
	ld		c,78
	dec		b
	call	PrintCharacterAtPosition
	pop		bc
	pop		de

	push	de
	push	bc
	call	DrawInfoBox
	pop		bc
	pop		de

	;call	RefreshHumansCounters
	;call	RefreshMartiansCounters

	ret
ShowMartianShip:
	; INPUT: c=Pos X, b=Pos Y, d=First character code
	; MODIFY: BC,DE, HL

	push	bc
	push	de
	dec		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		de
	pop		bc

	push	bc
	push	de
	dec		c
	inc		b
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		de
	pop		bc

	push	bc
	push	de
	inc		c
	inc		c
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		de
	pop		bc

	push	bc
	push	de
	inc		b
	inc		c
	inc		c
	inc		c
	inc		c
	ld		d, 32
	call	PrintCharacterAtPosition
	pop		de
	pop		bc

	call	RestoreVerticalBorders

	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	dec		c
	dec		c
	dec		c
	inc		b
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc

	inc     d
	inc		c
	push	bc
	call	PrintCharacterAtPosition
	pop		bc


	ret

PrintString:
	ld a,(hl)
	cp 255
	ret z
	inc hl
	call CHPUT
	jp PrintString
DefineCustomCharacters:
	
	ld a, (REG4SAV)
	ld de, 2048
	call Mult12
	ld bc,hl




	push bc
	ld h, 128
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_11_128
	add hl, bc
	call LoadCharacterDefinition

	ld h, 129
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_12_129
	add hl, bc
	call LoadCharacterDefinition

	ld h, 130
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_13_130
	add hl, bc
	call LoadCharacterDefinition

	ld h, 131
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_21_131
	add hl, bc
	call LoadCharacterDefinition

	ld h, 132
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_22_132
	add hl, bc
	call LoadCharacterDefinition

	ld h, 133
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_23_133
	add hl, bc
	call LoadCharacterDefinition

	ld h, 134
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_31_134
	add hl, bc
	call LoadCharacterDefinition

	ld h, 135
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_32_135
	add hl, bc
	call LoadCharacterDefinition

	ld h, 136
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman1_33_136
	add hl, bc
	call LoadCharacterDefinition

	ld h, 137
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_11_137
	add hl, bc
	call LoadCharacterDefinition

	ld h, 138
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_12_138
	add hl, bc
	call LoadCharacterDefinition

	ld h, 139
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_13_139
	add hl, bc
	call LoadCharacterDefinition

	ld h, 140
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_21_140
	add hl, bc
	call LoadCharacterDefinition

	ld h, 141
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_22_141
	add hl, bc
	call LoadCharacterDefinition

	ld h, 142
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_23_142
	add hl, bc
	call LoadCharacterDefinition

	ld h, 143
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_31_143
	add hl, bc
	call LoadCharacterDefinition

	ld h, 144
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_32_144
	add hl, bc
	call LoadCharacterDefinition

	ld h, 145
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman2_33_145
	add hl, bc
	call LoadCharacterDefinition


	ld h, 146
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_11_146
	add hl, bc
	call LoadCharacterDefinition

	ld h, 147
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_12_147
	add hl, bc
	call LoadCharacterDefinition

	ld h, 148
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_13_148
	add hl, bc
	call LoadCharacterDefinition

	ld h, 149
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_21_149
	add hl, bc
	call LoadCharacterDefinition

	ld h, 150
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_22_150
	add hl, bc
	call LoadCharacterDefinition

	ld h, 151
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_23_151
	add hl, bc
	call LoadCharacterDefinition

	ld h, 152
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_31_152
	add hl, bc
	call LoadCharacterDefinition

	ld h, 153
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_32_153
	add hl, bc
	call LoadCharacterDefinition

	ld h, 154
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman3_33_154
	add hl, bc
	call LoadCharacterDefinition

	ld h, 155
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_11_155
	add hl, bc
	call LoadCharacterDefinition

	ld h, 156
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_12_156
	add hl, bc
	call LoadCharacterDefinition

	ld h, 157
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_13_157
	add hl, bc
	call LoadCharacterDefinition

	ld h, 158
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_21_158
	add hl, bc
	call LoadCharacterDefinition

	ld h, 159
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_22_159
	add hl, bc
	call LoadCharacterDefinition

	ld h, 160
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_23_160
	add hl, bc
	call LoadCharacterDefinition

	ld h, 161
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_31_161
	add hl, bc
	call LoadCharacterDefinition

	ld h, 162
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_32_162
	add hl, bc
	call LoadCharacterDefinition

	ld h, 163
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman4_33_163
	add hl, bc
	call LoadCharacterDefinition

	ld h, 164
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_11_164
	add hl, bc
	call LoadCharacterDefinition

	ld h, 165
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_12_165
	add hl, bc
	call LoadCharacterDefinition

	ld h, 166
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_13_166
	add hl, bc
	call LoadCharacterDefinition

	ld h, 167
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_21_167
	add hl, bc
	call LoadCharacterDefinition

	ld h, 168
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_22_168
	add hl, bc
	call LoadCharacterDefinition

	ld h, 169
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_23_169
	add hl, bc
	call LoadCharacterDefinition

	ld h, 170
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_31_170
	add hl, bc
	call LoadCharacterDefinition

	ld h, 171
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_32_171
	add hl, bc
	call LoadCharacterDefinition

	ld h, 172
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,RunningHuman5_33_172
	add hl, bc
	call LoadCharacterDefinition

	ld h, 173
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_11_173
	add hl, bc
	call LoadCharacterDefinition

	ld h, 174
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_12_174
	add hl, bc
	call LoadCharacterDefinition

	ld h, 175
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_13_175
	add hl, bc
	call LoadCharacterDefinition

	ld h, 176
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_14_176
	add hl, bc
	call LoadCharacterDefinition

	ld h, 177
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_21_177
	add hl, bc
	call LoadCharacterDefinition

	ld h, 178
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_22_178
	add hl, bc
	call LoadCharacterDefinition

	ld h, 179
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_23_179
	add hl, bc
	call LoadCharacterDefinition

	ld h, 180
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_24_180
	add hl, bc
	call LoadCharacterDefinition

	ld h, 181
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_11_181
	add hl, bc
	call LoadCharacterDefinition

	ld h, 182
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_12_182
	add hl, bc
	call LoadCharacterDefinition

	ld h, 183
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_13_183
	add hl, bc
	call LoadCharacterDefinition

	ld h, 184
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_14_184
	add hl, bc
	call LoadCharacterDefinition

	ld h, 185
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_21_185
	add hl, bc
	call LoadCharacterDefinition

	ld h, 186
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_22_186
	add hl, bc
	call LoadCharacterDefinition

	ld h, 187
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_23_187
	add hl, bc
	call LoadCharacterDefinition

	ld h, 188
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1b_24_188
	add hl, bc
	call LoadCharacterDefinition

	ld h, 189
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Missile_189
	add hl, bc
	call LoadCharacterDefinition

	ld h, 190
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Missile_190
	add hl, bc
	call LoadCharacterDefinition

	ld h, 191
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_11_191
	add hl, bc
	call LoadCharacterDefinition

	ld h, 192
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_12_192
	add hl, bc
	call LoadCharacterDefinition

	ld h, 193
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_13_193
	add hl, bc
	call LoadCharacterDefinition

	ld h, 194
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_21_194
	add hl, bc
	call LoadCharacterDefinition

	ld h, 195
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_22_195
	add hl, bc
	call LoadCharacterDefinition

	ld h, 196
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_23_196
	add hl, bc
	call LoadCharacterDefinition

	ld h, 197
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_14_197
	add hl, bc
	call LoadCharacterDefinition

	ld h, 198
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,HumanShip_24_198
	add hl, bc
	call LoadCharacterDefinition

	ld h, 199
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,BorderTopLeft_199
	add hl, bc
	call LoadCharacterDefinition

	ld h, 200
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,BorderVertical_200
	add hl, bc
	call LoadCharacterDefinition

	ld h, 201
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,BorderHorizontal_201
	add hl, bc
	call LoadCharacterDefinition

	ld h, 202
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,BorderTopRight_202
	add hl, bc
	call LoadCharacterDefinition

	ld h, 203
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,BorderBottomLeft_203
	add hl, bc
	call LoadCharacterDefinition

	ld h, 204
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,BorderBottomRight_204
	add hl, bc
	call LoadCharacterDefinition

	ld h, 205
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman11_205
	add hl, bc
	call LoadCharacterDefinition

	ld h, 206
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman12_206
	add hl, bc
	call LoadCharacterDefinition

	ld h, 207
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman13_207
	add hl, bc
	call LoadCharacterDefinition

	ld h, 208
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman21_208
	add hl, bc
	call LoadCharacterDefinition

	ld h, 209
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman22_209
	add hl, bc
	call LoadCharacterDefinition

	ld h, 210
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman23_210
	add hl, bc
	call LoadCharacterDefinition

	ld h, 211
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman31_211
	add hl, bc
	call LoadCharacterDefinition
	
	ld h, 212
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman32_212
	add hl, bc
	call LoadCharacterDefinition

	ld h, 213
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,StaticHuman33_213
	add hl, bc
	call LoadCharacterDefinition




	ld h, 214
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2a_11_214
	add hl, bc
	call LoadCharacterDefinition

	ld h, 215
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip1a_12_215
	add hl, bc
	call LoadCharacterDefinition

	ld h, 216
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2a_13_216
	add hl, bc
	call LoadCharacterDefinition

	ld h, 217
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2a_14_217
	add hl, bc
	call LoadCharacterDefinition

	ld h, 218
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2a_21_218
	add hl, bc
	call LoadCharacterDefinition

	ld h, 219
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2a_22_219
	add hl, bc
	call LoadCharacterDefinition

	ld h, 220
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2a_23_220
	add hl, bc
	call LoadCharacterDefinition

	ld h, 221
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2a_24_221
	add hl, bc
	call LoadCharacterDefinition

	ld h, 222
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_11_222
	add hl, bc
	call LoadCharacterDefinition

	ld h, 223
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_12_223
	add hl, bc
	call LoadCharacterDefinition

	ld h, 224
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_13_224
	add hl, bc
	call LoadCharacterDefinition

	ld h, 225
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_14_225
	add hl, bc
	call LoadCharacterDefinition

	ld h, 226
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_21_226
	add hl, bc
	call LoadCharacterDefinition

	ld h, 227
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_22_227
	add hl, bc
	call LoadCharacterDefinition

	ld h, 228
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_23_228
	add hl, bc
	call LoadCharacterDefinition

	ld h, 229
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip2b_24_229
	add hl, bc
	call LoadCharacterDefinition

	ld h, 230
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_11_230
	add hl, bc
	call LoadCharacterDefinition

	ld h, 231
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_12_231
	add hl, bc
	call LoadCharacterDefinition

	ld h, 232
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_13_232
	add hl, bc
	call LoadCharacterDefinition

	ld h, 233
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_14_233
	add hl, bc
	call LoadCharacterDefinition

	ld h, 234
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_21_234
	add hl, bc
	call LoadCharacterDefinition

	ld h, 235
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_22_235
	add hl, bc
	call LoadCharacterDefinition

	ld h, 236
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_23_236
	add hl, bc
	call LoadCharacterDefinition

	ld h, 237
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3a_24_237
	add hl, bc
	call LoadCharacterDefinition

	ld h, 238
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_11_238
	add hl, bc
	call LoadCharacterDefinition

	ld h, 239
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_12_239
	add hl, bc
	call LoadCharacterDefinition

	ld h, 240
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_13_240
	add hl, bc
	call LoadCharacterDefinition

	ld h, 241
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_14_241
	add hl, bc
	call LoadCharacterDefinition

	ld h, 242
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_21_242
	add hl, bc
	call LoadCharacterDefinition

	ld h, 243
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_22_243
	add hl, bc
	call LoadCharacterDefinition

	ld h, 244
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_23_244
	add hl, bc
	call LoadCharacterDefinition

	ld h, 245
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,MartianShip3b_24_245
	add hl, bc
	call LoadCharacterDefinition

	ld h, 246
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Explosion_11_246
	add hl, bc
	call LoadCharacterDefinition

	ld h, 247
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Explosion_12_247
	add hl, bc
	call LoadCharacterDefinition


	ld h, 248
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Explosion_13_248
	add hl, bc
	call LoadCharacterDefinition

	ld h, 249
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Explosion_21_249
	add hl, bc
	call LoadCharacterDefinition

	ld h, 250
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Explosion_22_250
	add hl, bc
	call LoadCharacterDefinition

	ld h, 251
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Explosion_23_251
	add hl, bc
	call LoadCharacterDefinition

	ld h, 91
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Missile_189
	add hl, bc
	call LoadCharacterDefinition

	ld h, 93
	ld e, 8
	call Mult8
	pop bc
	push bc
	ld de,Missile_190
	add hl, bc
	call LoadCharacterDefinition

	ret
LoadCharacterDefinition:
	ld b,8        
	ld c,1       
	call RedefineVramCharacter
	ret
RedefineVramCharacter:

	ld   a,(de)    ; Loads into A the current value pointed by DE
    call WRTVRM    ; Calls the BIOS routine that loads the value from A into the VRAM at the position HL
    inc  de        ; Increments DE to fetch the next value from LetterA
    inc  hl        ; Increments HL to set the next position at the VRAM
    djnz RedefineVramCharacter    ; The djnz command decrements the value of B and compares to to 0, jumping to PrintLoop if the result is false
    ret

; *** CHARACTERS DATA ***
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11110000b
	db 11110000b
	db 11110000b
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

Missile_189:
	db 00000000b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
	db 00000000b
Missile_190:
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
HumanShip_21_194:
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
HumanShip_22_195:
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
HumanShip_23_196:
	db 11111111b
	db 11111111b
	db 11111111b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
HumanShip_14_197:
	db 00000000b
	db 00000000b
	db 00000000b
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
	db 01111111b
	db 01111111b
	db 01111111b
StaticHuman12_206:
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 11111111b
	db 11111111b
	db 11111111b
StaticHuman13_207:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11111110b
	db 11111110b
	db 11111110b
StaticHuman21_208:
	db 01111000b
	db 01111000b
	db 01111000b
	db 01111000b
	db 01111000b
	db 01111000b
	db 00000000b
	db 00000000b
StaticHuman22_209:
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111111b
StaticHuman23_210:
	db 00111110b
	db 00111110b
	db 00111110b
	db 00111110b
	db 00111110b
	db 00111110b
	db 00000000b
	db 00000000b
StaticHuman31_211:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00011111b
	db 00011111b
	db 00011111b
StaticHuman32_212:
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 01111110b
	db 11111111b
	db 11111111b
	db 11111111b
StaticHuman33_213:
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 00000000b
	db 11110000b
	db 11110000b
	db 11110000b
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
	db 00000011b
	db 00000011b
	db 00000011b
	db 00000011b
Explosion_12_247:
	db 00000000b
	db 00000000b
	db 00000011b
	db 00000011b
	db 11000011b
	db 11000011b
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
	db 00001111b
	db 00001111b
	db 00001111b
	db 00001111b
Explosion_23_251:
	db 11000000b
	db 11000000b
	db 00000000b
	db 00000000b
	db 00111100b
	db 00111100b
	db 00111100b
	db 00111100b

	db 11001100b
	db 01100110b
	db 10011001b
	db 11001100b
	db 00110000b
	db 00000011b
	db 00001100b
	db 11001111b
; *** MESSAGES ***
Msg_MartianWar: 	db 'MARTIAN WAR',0
Msg_OnlyOneWapon: 	db 'There is one weapon remaining on Earth.',0
Msg_Keys:			db 'This weapon is controlled with the following keys:',0
Msg_Key4:			db '4  - Move to left',0
Msg_Key5:			db '5  - Stop',0
Msg_Key6:			db '6  - Move to right',0
Msg_Key8:			db '8  - Fire a missile',0
Msg_Ships:			db 'There will be martian spaceships flying all over the place and dropping',0
Msg_Bombs:			db 'bombs down on you and the human population.',0
Msg_Mission:		db 'Your mission is quite simple. There are a limited number of martian',0
Msg_Destroy:		db 'ships and if you destroy all of them before they destroy the whole',0
Msg_Population:		db 'population of Earth then you win.',0
Msg_Repaired:		db 'If your weapon is hit it will have to be repaired and the refore',0
Msg_Unusable:		db 'will be unusable for a period of time.',0
Msg_Enter:			db 'HIT \'RETURN\' TO CONTINUE',0
Msg_Levels:			db 'WHAT LEVEL OF PLAY WOULD YOU LIKE (1 - 3) ? _',0
Msg_Level1:			db '1  -  Beginner',0
Msg_Level2:			db '2  -  Intermediate',0
Msg_Level3:			db '3  -  Advanced',0
Msg_SoundEffects:   db 'IF YOU WANT SOUND EFFECTS THEN TYPE \'Y\' ELSE TYPE \'N\'',0
Msg_Humans:			db 'Humans   - ',0
Msg_Martians:		db 'Martians - ',0
Msg_Sorry:			db 'SORRY GUY',0
Msg_Martians_Win:	db 'THE MARTIANS HAVE SUCCESSFULLY DESTROYED ALL LIFE ON EARTH!',0
Msg_HintPlayAgain:  db 'HIT \'RETURN\' TO PLAY AGAIN',0
Msg_Congratulation: db 'CONGRATULATIONS',0
Msg_YouHaveSaved:   db 'YOU HAVE SAVED EARTH FROM THE MARTIAN ATTACK!!',0





; *** ROM 16KB ***
    ds 8000h - $  ; fill the rest of the ROM (up to 16KB with 0s)

; *** RAM ***
    org 0c000h  
; *** VARIABLES ***
CounterFromRight:					db 0
CounterFromLeft:					db 0
RunningHumanFromRightCurrentImage:	db 0
RunningHumanFromLeftCurrentImage:	db 0
HumanRunningCounter:				db 0
RunningHumanFromRightStopPosition:	db 0
RunningHumanFromLeftStopPosition:	db 0
SelectedLevel:						db 0
SoundYN:							db 0
Counter:							db 0
Humans:								db 0
Martians:							db 0
HumanShipMovingDirection:			db 0
HumanShipCurrentPosition:			db 0
MissilesRefreshPositionTime:		db 0
RandData:							defw 0
FiredMissilesPositions:				ds 64
MissilesPosX:       				db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  
MissilesPosY:      					db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
MartiansShipsPositionX:				db 0,0,0,0
MartiansShipsPositionY:				db 0,0,0,0
MartiansShipsDirection:				db 0,0,0,0
MartiansShipType:					db 0,0,0,0
RndSeed:							db 0
MartiansDirectionChanged:			db 0,0,0,0
MartiansShipsSpeed					db 0 
MartiansMissilesRatio				db 0
MartianMissilesPosX:       			db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0  
MartianMissilesPosY:      			db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
MartiansMissilesSpeed				db 0 
MartianMissileCollisionSecCharacter	db 0
HumanShipVisible					db 0
HumanShipStopTime					dw 0
HumanShipStopTimeCicle:				db 0
MartianShipToRemoveX				db 0
MartianShipToRemoveY				db 0
HumanExplosionFlag					db 0
HumanMissileArrayPosition			db 0