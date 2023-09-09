.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "                                                                          Minion Rush Game",0
area_width EQU 600
area_height EQU 750
area DD 0

minion_location DD 277
minion_y DD 0

counter_banana1 DD 0 ; numara evenimentele de tip timer
counter2 DD 0 ; numara evenimentele de tip timer
counter1 DD 0
counter DD 0
counter_obs DD 0
counter_obs2 DD 0
counter_o2 DD 0
counter_pro DD 0
points DD 0


arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

viteza DD 0
stop DD 0
banana DD 157
banana_pro DD 517
obstacol DD 37
obstacol2 DD 397
inm DD 8
five DD 5
ten DD 10

LIFE DD 0

copie_eax DD 0
copie_ecx DD 0

symbol_width EQU 10
minion_width EQU 45
symbol_height EQU 20
minion_height EQU 80

include digits.inc
include letters.inc
include minion.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, '!'    ; miniom
	jz make_minion
	cmp eax, '"'    ; obstacol
	jz make_minion
	cmp eax, '#'    ; banana simpla
	jz make_minion
	cmp eax, '$'    ; patrat albastru simplu
	jz make_minion
	cmp eax, '%'
	jz make_minion  ; banana pro
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	
	sub eax, 'A'
	lea esi, letters
	jmp draw_text

make_minion:
	;cmp eax, '!'
    sub eax, '!'
	lea esi, minion
	jmp draw_minion
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
	jmp bucla_simbol_linii
;                                                                                                          MAKE MINION
draw_minion:
	mov ebx, minion_width
	mul ebx
	mov ebx, minion_height
	mul ebx
	add esi, eax
	mov ecx, minion_height
bucla_simbol_linii_minion:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, minion_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, minion_width
bucla_simbol_coloane_minion:  ;																		CHOOSE THE COLORS FOR MINION AND ;BANANAS																
	cmp byte ptr [esi], 0
	je simbol_pixel_alb_minion
	cmp byte ptr [esi], 2
	je simbol_pixel_albastru_minion
	cmp byte ptr [esi], 3
	je simbol_pixel_white_minion
	cmp byte ptr [esi], 4
	je simbol_pixel_black_minion
	cmp byte ptr [esi], 5
	je simbol_pixel_gray_minion
	cmp byte ptr [esi], 6
	je simbol_pixel_brown_minion

	mov dword ptr [edi], 0FFF700h
	jmp simbol_pixel_next_minion
	
simbol_pixel_brown_minion:
	mov dword ptr [edi], 47260Bh
	jmp simbol_pixel_next_minion
simbol_pixel_gray_minion:
	mov dword ptr [edi], 737676h
	jmp simbol_pixel_next_minion
simbol_pixel_black_minion:
	mov dword ptr [edi], 0
	jmp simbol_pixel_next_minion
simbol_pixel_white_minion:
	mov dword ptr [edi], 9FFFFFFh
	jmp simbol_pixel_next_minion
simbol_pixel_albastru_minion:
	mov dword ptr [edi], 02304E0h
	jmp simbol_pixel_next_minion
simbol_pixel_alb_minion:
	mov dword ptr [edi], 1DAAF8h
	jmp simbol_pixel_next_minion
	
simbol_pixel_next_minion:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane_minion
	pop ecx
	loop bucla_simbol_linii_minion
	popa
	mov esp, ebp
	pop ebp
	ret
	jmp final
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 1DAAF8h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
final:
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
line_vertical macro x, y, len, color
local bucla_line
    
    mov eax, y; eax=y
	mov ebx, area_width
	mul ebx ; eax = y*area_width
	add eax, x ; eax = y*area_width + x
	shl eax, 2 ; eax = (y*area_width +x)*4
	add eax, area
	mov ecx, len
	bucla_line:
	mov dword ptr[eax], color
	add eax, 4*area_width 
	loop bucla_line
endm
finish macro
local color_background

	mov stop,1 
	mov eax, 0
	 add eax, area
	 mov ecx, 450000
	 color_background:	    
	    mov dword ptr[eax], 0F7F70Bh
	    add eax, 4
	 loop color_background
	 
	
	make_text_macro 'G', area, 250, 300
	make_text_macro 'A', area, 260, 300
	make_text_macro 'M', area, 270, 300
	make_text_macro 'E', area, 280, 300
	make_text_macro ' ', area, 290, 300
	make_text_macro 'O', area, 300, 300
	make_text_macro 'V', area, 310, 300
	make_text_macro 'E', area, 320, 300
	make_text_macro 'R', area, 330, 300
	
	make_text_macro 'P', area, 220, 330
	make_text_macro 'O', area, 230, 330
	make_text_macro 'I', area, 240, 330
	make_text_macro 'N', area, 250, 330
	make_text_macro 'T', area, 260, 330
	make_text_macro 'S', area, 270, 330
	make_text_macro ' ', area, 280, 330
	;afisare puncte la finalul jocului
	mov ebx, 10
	mov eax, points
	;cifra sutelor de mii
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 340, 330
	;cifra zeciilor de mii
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 330, 330
	;cifra miilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 320, 330
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 310, 330
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 300,330	
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 290, 330	
endm

line_horizontal macro x, y, len, color
local bucla_line
    
    mov eax, y; eax=y
	mov ebx, area_width
	mul ebx ; eax = y*area_width
	add eax, x ; eax = y*area_width + x
	shl eax, 2 ; eax = (y*area_width +x)*4
	add eax, area
	mov ecx, len
	bucla_line:
	mov dword ptr[eax], color
	add eax, 4 
	loop bucla_line
endm
build_square macro x, y, len, color
 
endm


play_game proc														;										PLAY PROC	
	push ebp
	mov ebp, esp
	pusha
	
	cmp stop, 1
	jne here
	finish
	here:
	cmp stop, 0   ; pentru a nu se executa instructiunile cand se da click dupa ce s-a ajuns la GAME OVER
	jne final_play
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click_play
	cmp eax, 2
	jz evt_timer_play ; nu s-a efectuat click pe nimic
	jmp final_play
	
evt_click_play:

	
	mov eax, [ebp+arg2]
	cmp eax, 250
	jl nvm
	cmp eax, 350
	jg nvm
	mov eax, [ebp+arg3]
	cmp eax, 70
	jg nvm
    finish
	
	nvm:
	mov eax,[ebp+arg2] 
	cmp eax, minion_location
	jl left
	
	cmp minion_location, 460
	jg final_play
	mov eax, minion_location
	add eax, 120
	make_text_macro '$', area, minion_location, 650
	mov minion_location, eax
	make_text_macro '!', area, eax, 650
	
	jmp final_play
	
 left:
	cmp minion_location, 130
	jl final_play
	mov eax, minion_location
	sub eax, 120
	make_text_macro '$', area, minion_location, 650
	mov minion_location, eax	
	make_text_macro '!', area, eax, 650
	jmp final_play
	
evt_timer_play:	
		
																						;PLAY TIMER
	inc counter2
	inc counter2
	inc counter2
	inc counter_obs
	inc counter_obs
	inc counter_obs
	inc counter_obs
	inc counter_obs2
	inc counter_obs2


; SPEED	
	mov ecx, counter_banana1
	add ecx, viteza
	mov counter_banana1, ecx
	
	mov ecx, counter
	add ecx, viteza
	mov counter, ecx
	
	mov ecx, counter_pro
	add ecx, viteza
	mov counter_pro, ecx
	
	mov ecx, counter1
	add ecx, viteza
	mov counter1, ecx
	
	mov ecx, counter_o2
	add ecx, viteza
	mov counter_o2, ecx
	inc counter_o2
	inc counter_o2
	
; generarea bananelor																					; GENERAREA BANANELOR

gen:

	mov eax, banana
	cmp eax, minion_location
	jne go
	cmp counter_banana1, 580
	jl go
	make_text_macro '$', area, minion_location, 570
	make_text_macro '!', area, minion_location, 650
	mov counter_banana1, 650
	go:
	
	cmp counter_banana1, 650   									                                              
	jl next
	
	mov eax, banana
	cmp eax, minion_location
	jne nopoint
	make_text_macro '!', area, banana, 650
	mov eax, points
	add eax, 10
	mov points, eax
	
	
	nopoint:
	mov ecx, banana
	cmp ecx, minion_location
	je do
	make_text_macro '$', area, banana, counter_banana1
	do:
	mov edx, 0
	add eax, counter_banana1
	add eax, counter2
	add eax, 13
	div five
	mov eax, 120
	mul edx
	add eax, 37
	mov banana, eax
	mov counter_banana1, 0
	
	next:
	make_text_macro '#', area, banana, counter_banana1
	
	;BANANE 2   																						; BANANE PRO
	
	mov eax, banana_pro
	cmp eax, minion_location
	jne gob2
	cmp counter_pro, 570
	jl gob2
	make_text_macro '$', area, minion_location, 570
	make_text_macro '!', area, minion_location, 650
	mov counter_pro, 650
	gob2:
	
	cmp counter_pro, 650   									                                              
	jl nextb2
	
	mov eax, banana_pro
	cmp eax, minion_location
	jne nopointb2
	make_text_macro '!', area, banana_pro, 650
	mov eax, points
	add eax, 25
	mov points, eax
	
	nopointb2:
	mov ecx, banana_pro
	cmp ecx, minion_location
	je dob2
	make_text_macro '$', area, banana_pro, counter_pro
	dob2:
	mov edx, 0
	add eax, counter_pro
	add eax, counter2
	add eax, 7
	div five
	mov eax, 120
	mul edx
	add eax, 37
	mov banana_pro, eax
	mov counter_pro, 0
	cmp eax, banana
	je obs
	
	
	nextb2:
	mov eax, counter_pro
	add eax, 2
	mov counter_pro, eax
	make_text_macro '%', area, banana_pro, counter_pro
	
;generarea obstacolelor																					; GENERAREA OBSTACOLELOR
obs:
	mov eax, obstacol
	cmp eax, minion_location
	jne go1
	cmp counter1, 580
	jl go1
	make_text_macro '$', area, minion_location, 580
	make_text_macro '!', area, minion_location, 650
	mov counter1, 650
	go1:
	
	cmp counter1, 650   									                                              
	jl next_obs
	
	;game over
	mov eax, obstacol
	cmp eax, minion_location
	jne cont
	inc LIFE
	cmp life, 3
	jne redo
	 finish
	jmp final_play
	redo:
	make_text_macro '!', area, obstacol, counter1
	jmp dont_redo
	cont:
	make_text_macro '$', area, obstacol, counter1
	dont_redo:
	mov edx, 0
	add eax, counter_obs
	add eax, counter1
	add eax, 19
	inc eax
	div five
	mov eax, 120
	mul edx
	add eax, 37
	mov obstacol, eax
	mov counter1, 0
	
	next_obs:

	make_text_macro '"', area, obstacol, counter1
	
; obstacol 2
	mov eax, obstacol2
	cmp eax, minion_location
	jne go12
	cmp counter_o2, 580
	jl go12
	make_text_macro '$', area, minion_location, 580
	make_text_macro '!', area, minion_location, 650
	mov counter_o2, 650
	go12:
	
	cmp counter_o2, 650   									                                              
	jl next_obs12
	
	;POINTS
	
	mov eax, obstacol2
	cmp eax, minion_location
	jne cont12
	inc LIFE
	cmp life, 3
	jne redo12
	finish
	jmp final_play

	redo12:
	make_text_macro '!', area, obstacol2, counter_o2
	jmp dont_redo2
	
	cont12:
	make_text_macro '$', area, obstacol2, counter_o2
	dont_redo2:
	mov edx, 0
	add eax, counter_obs2
	add eax, counter_o2
	add eax, 19
	inc eax
	div five
	mov eax, 120
	mul edx
	add eax, 37
	mov obstacol2, eax
	mov counter_o2, 0
	
	next_obs12:

	 make_text_macro '"', area, obstacol2, counter_o2

	make_text_macro 'L', area, 10, 10
	make_text_macro 'I', area, 20, 10
	make_text_macro 'V', area, 30, 10
	make_text_macro 'E', area, 40, 10
	make_text_macro 'S', area, 50, 10
	make_text_macro ' ', area, 60, 10
	;make_text_macro ' ', area, 70, 10
	mov eax, 3
	mov ebx, 10
	sub eax, LIFE
	
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 70, 10
	; ; cifra zecilor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 20, 10
	; ; cifra sutelor
	; mov edx, 0
	; div ebx
	; add edx, '0'
	; make_text_macro edx, area, 10, 10	
	
	make_text_macro 'C', area, 260, 10
	make_text_macro 'A', area, 270, 10
	make_text_macro 'N', area, 280, 10
	make_text_macro 'C', area, 290, 10
	make_text_macro 'E', area, 300, 10
	make_text_macro 'L', area, 310, 10
	
	make_text_macro 'P', area, 470, 10
	make_text_macro 'O', area, 480, 10
	make_text_macro 'I', area, 490, 10
	make_text_macro 'N', area, 500, 10
	make_text_macro 'T', area, 510, 10
	make_text_macro 'S', area, 520, 10
	make_text_macro ' ', area, 530, 10
	;afisare puncte
	mov ebx, 10
	mov eax, points
	;cifra sutelor de mii
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 590, 10
	;cifra zeciilor de mii
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 580, 10
	;cifra miilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 570, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 560, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 550, 10	
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 540, 10	
	
	 line_vertical 1, 0, 750, 0
	 line_vertical 0, 0, 750, 0
	 line_vertical 599, 0, 750, 0
	 line_vertical 598, 0, 750, 0
	 line_horizontal 0, 0, 600, 0
	 line_horizontal 0, 1, 600, 0
	 line_horizontal 0, 748, 600, 0
	 line_horizontal 0, 749, 600, 0
	
	
	
final_play:

	popa
	mov esp, ebp
	pop ebp
	ret
play_game endp




; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	
	; BACKGROUND INITIAL
	 mov eax, 0
	 add eax, area
	 mov ecx, 450000
	 color_background:	    
	    mov dword ptr[eax], 1DAAF8h
	    add eax, 4
	 loop color_background
	 
	
	make_text_macro '!', area, 283, 400
	;make_text_macro '"', area, 260, 120; obstacol
	make_text_macro '#', area, 31, 74 
	make_text_macro '#', area, 100, 274 
	make_text_macro '#', area, 149, 150 
	make_text_macro '#', area, 3, 200 
	make_text_macro '#', area, 7, 470 
	make_text_macro '#', area, 40, 600 
	make_text_macro '#', area, 127, 650 
	make_text_macro '#', area, 70, 408 
	make_text_macro '#', area, 102, 553 
	make_text_macro '#', area, 169, 498
	make_text_macro '#', area, 213, 35
	make_text_macro '#', area, 362, 99
	make_text_macro '#', area, 284, 187
	make_text_macro '#', area, 228, 342
	make_text_macro '#', area, 286, 84
	make_text_macro '#', area, 430, 41
	make_text_macro '#', area, 330, 10
	make_text_macro '#', area, 362, 667
	make_text_macro '#', area, 241, 648
	make_text_macro '#', area, 123, 37
	make_text_macro '#', area, 433, 623
	make_text_macro '#', area, 436, 524
	make_text_macro '#', area, 520, 650
	make_text_macro '#', area, 542, 586
	make_text_macro '#', area, 380, 460
	make_text_macro '#', area, 511, 450
	make_text_macro '#', area, 184, 267
	make_text_macro '#', area, 331, 315
	make_text_macro '#', area, 418, 400
	make_text_macro '#', area, 380, 282
	make_text_macro '#', area, 500, 366
	make_text_macro '#', area, 523, 153
	make_text_macro '#', area, 414, 217
	make_text_macro '#', area, 516, 307
	make_text_macro '#', area, 525, 44
	make_text_macro '#', area, 42, 342
	make_text_macro '#', area, 162, 436
	
	make_text_macro 'S', area, 240, 520
	make_text_macro 'E', area, 250, 520
	make_text_macro 'L', area, 260, 520
	make_text_macro 'E', area, 270, 520
	make_text_macro 'C', area, 280, 520
	make_text_macro 'T', area, 290, 520
	make_text_macro ' ', area, 300, 520
	make_text_macro 'S', area, 310, 520
	make_text_macro 'P', area, 320, 520
	make_text_macro 'E', area, 330, 520
	make_text_macro 'E', area, 340, 520
	make_text_macro 'D', area, 350, 520
	line_horizontal 240, 540, 120, 0
	line_horizontal 240, 541, 120, 0
	
	build_square 160, 550, 30, 0FF0000h
	make_text_macro 'S', area, 290, 560
	make_text_macro 'L', area, 300, 560
	make_text_macro 'O', area, 310, 560
	make_text_macro 'W', area, 320, 560
	line_horizontal 290, 580, 40, 0
	line_horizontal 290, 581, 40, 0
	
	build_square 160, 580, 30, 0FF0000h
	make_text_macro 'N', area, 280, 595
	make_text_macro 'O', area, 290, 595
	make_text_macro 'R', area, 300, 595
	make_text_macro 'M', area, 310, 595
	make_text_macro 'A', area, 320, 595
	make_text_macro 'L', area, 330, 595
	line_horizontal 280, 615, 60, 0
	line_horizontal 280, 616, 60, 0
	
	build_square 160, 650, 30, 0FF0000h
	make_text_macro 'F', area, 290, 630
	make_text_macro 'A', area, 300, 630
	make_text_macro 'S', area, 310, 630
	make_text_macro 'T', area, 320, 630
	line_horizontal 290, 650, 40, 0
	line_horizontal 290, 651, 40, 0
	jmp afisare_litere
	

	
evt_click:


	mov eax, [ebp + arg2]
	;slow 
	cmp eax, 260
	jl button_fail
	cmp eax, 340
	jg button_fail
	mov eax, [ebp+arg3]
	cmp eax, 550
	jl button_fail
	cmp eax, 580
	jg normal_mode_compare

	
slow_mode:	;																								SLOW MODE
	make_text_macro 'S', area, 234, 456
	mov eax, 12   ; pentru viteza
	mov viteza, 10
	jmp play
	
normal_mode_compare:
	cmp eax, 620
	jg fast_mode_compare
	mov eax, [ebp +arg2]
	cmp eax, 260
	jl button_fail
	cmp eax, 360
	jg button_fail
	
normal_mode: ; 																								NORMAL MODE
	make_text_macro 'N', area, 234, 456
	mov eax, 12   ; pentru viteza
	mov viteza, 15
	jmp play
	
fast_mode_compare:
	cmp eax, 650
	jg button_fail
	mov eax, [ebp+arg2]
	cmp eax, 265
	jl button_fail
	cmp eax, 340
	jg button_fail
	
fast_mode: ; 																								FAST MODE
	make_text_macro 'F', area, 234, 456
	mov eax, 12   ; pentru viteza
	mov viteza, 21
	jmp play
	
button_fail:
	jmp afisare_litere

play:
	; BACKGROUND JOC
	 mov eax, 0
	 add eax, area
	 mov ecx, 450000
	 color_background_play:	    
	    mov dword ptr[eax], 1DAAF8h
	    add eax, 4
	 loop color_background_play
	 
	 line_vertical 120, 0, 750, 02304E0h
	 line_vertical 121, 0, 750, 02304E0h
	 line_vertical 240, 0, 750, 02304E0h
	 line_vertical 241, 0, 750, 02304E0h
	 line_vertical 360, 0, 750, 02304E0h
	 line_vertical 361, 0, 750, 02304E0h
	 line_vertical 480, 0, 750, 02304E0h
	 line_vertical 481, 0, 750, 02304E0h
	 
	 make_text_macro '!', area, 277, 650

	 
	
	push offset play_game
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	
evt_timer:
	inc counter


	
afisare_litere:
	
	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
