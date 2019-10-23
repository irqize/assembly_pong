#every 17th color from zero is fully drawn (no character seen)
.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data

	#Game State Codes
	# 0 - MENU
	# 1 - IN GAME PLAYER VS PLAYER
	# 2 - IN GAME PLAYER VS COMPUTER
	game_state: .quad 0

	menu_option: .quad 0
	
	window_height: .quad 25
	window_width: .quad 80

	pad1_y: .quad 13
	pad2_y: .quad 13

	pad1_speed: .quad 0 #0-4
	pad2_speed: .quad 0 #0-4


	#TODO: ball_speed

	ball_x: .quad 40
	ball_y: .quad 13

	
	#n  x  y

	#1 +2 +1
	#2 +2  0
	#3 +2 -1

	#4 -2 +1
	#5 -2  0
	#6 -2 -1

	ball_direction: .quad 2
	#1-3 going right 4-6 going left
	last_ball_direction: .quad 2

	player1_life: .quad 11
	player2_life: .quad 11

	x: .quad 0
	y: .quad 0

	i: .quad 0
	j: .quad 0

.section .game.text
exit:
     movq $60, %rax # set syscall code to 60 (sys_exit)
     movq $0, %rdi # set program's return code to 0 (no error)
     syscall

menu_item1:
    movq $38, %rdi
    movq $10, %rsi
    movb $'P', %dl
    movb $23, %cl
    call putChar
    movq $39, %rdi
    movq $10, %rsi
    movb $'l', %dl
    movb $23, %cl
    call putChar
    movq $40, %rdi
    movq $10, %rsi
    movb $'a', %dl
    movb $23, %cl
    call putChar
    movq $41, %rdi
    movq $10, %rsi
    movb $'y', %dl
    movb $23, %cl
    call putChar
    movq $38, %rdi
    movq $12, %rsi
    movb $'Q', %dl
    movb $4, %cl
    call putChar
    movq $39, %rdi
    movq $12, %rsi
    movb $'u', %dl
    movb $4, %cl
    call putChar
    movq $40, %rdi
    movq $12, %rsi
    movb $'i', %dl
    movb $4, %cl
    call putChar
    movq $41, %rdi
    movq $12, %rsi
    movb $'t', %dl
    movb $4, %cl
    call putChar
    ret

menu_item2:
    movq $38, %rdi
    movq $10, %rsi
    movb $'P', %dl
    movb $4, %cl
    call putChar
    movq $39, %rdi
    movq $10, %rsi
    movb $'l', %dl
    movb $4, %cl
    call putChar
    movq $40, %rdi
    movq $10, %rsi
    movb $'a', %dl
    movb $4, %cl
    call putChar
    movq $41, %rdi
    movq $10, %rsi
    movb $'y', %dl

    call putChar
    movq $38, %rdi
    movq $12, %rsi
    movb $'Q', %dl
    movb $23, %cl
    call putChar
    movq $39, %rdi
    movq $12, %rsi
    movb $'u', %dl
    movb $23, %cl
    call putChar
    movq $40, %rdi
    movq $12, %rsi
    movb $'i', %dl
    movb $23, %cl
    call putChar
    movq $41, %rdi
    movq $12, %rsi
    movb $'t', %dl
    movb $23, %cl
    call putChar
    ret

handle_menu_controls:
    call readKeyCode
	#enter check
	cmpq $28, %rax
	jne _handle_menu_controls_up_down
	jmp _handle_enter

#	#arrow up check
_handle_menu_controls_up_down:
	cmpq $72, %rax
	je _arrow
	cmpq $80, %rax
	jne _other_key
_arrow:
    cmpq $0, (menu_option)
    je _select_quit
    jmp _select_play

_other_key:
	ret
	#jmp handle_menu_controls

_handle_enter:
    cmpq $1, (menu_option)
    je exit
    jmp _start
	ret

_select_quit:
    movq $1, (menu_option)
    call menu_item2
    ret

_select_play:
    movq $0, (menu_option)
    call menu_item1
    ret

gameInit:
    call clear_screen
    movq $0, (menu_option)
    call menu_item1
	ret

_start:
	#set timer to 18hz (smallest value possible)
	movq $65534, %rdi
	call setTimer

	call clear_screen
	call draw_board
	call draw_ball
	call draw_pads
	call draw_life_bars
	movq $1, (game_state)
	ret

doNothing:
    call handle_menu_controls
	ret
gameLoop:
    cmpq $0, (game_state)
    je doNothing
	call handle_game_controls
	call handle_ball
	call calculate_pad_pos
	call reset_board

	ret

newPoint:
	movq $40, (ball_x)
	movq $13, (ball_y)
	movq $13, (pad1_y)
	movq $13, (pad2_y)
	movq $0, (pad1_speed)
	movq $0, (pad2_speed)
	movq (last_ball_direction), %rax
	incq %rax
	cmp $6, %rax
	jle _newPoint
	movq $1, %rax
_newPoint: 
	movq %rax, (last_ball_direction)
	movq %rax, (ball_direction)
	call draw_life_bars
	ret


# void()/makes screen black
clear_screen:
	movq $0, %r8
	movq $0, %r9
_clear_screen:
	movq %r8, (x)
	movq %r9, (y)

	movb $' ', %dl
	movq (x), %rdi
	movq (y), %rsi
	movb $0, %cl
	call putChar

	movq (x), %r8
	incq %r8
	cmpq $80, %r8
	jl _clear_screen

	movq $0, (x)
	movq $0, %r8

	movq (y), %r9
	incq %r9
	cmpq $24, %r9
	jl _clear_screen

	ret

# void()/makes board black
reset_board:
	movq $2, %r8
	movq $2, %r9
_reset_board:
	movq %r8, (x)
	movq %r9, (y)

	movb $' ', %dl
	movq (x), %rdi
	movq (y), %rsi
	movb $0, %cl
	call putChar

	movq (x), %r8
	incq %r8
	cmpq $78, %r8
	jl _reset_board

	movq $3, (x)
	movq $3, %r8

	movq (y), %r9
	incq %r9
	cmpq $23, %r9
	jl _reset_board

	call draw_ball
	call draw_pads

	ret

# void()/draws pong's board
draw_board:
	#horizontal lines
	movq $1, %r8
_draw_board_h:
	movq %r8, (x)
	movb $' ', %dl
	movq (x), %rdi
	movq $1, %rsi
	movb $255, %cl
	call putChar

	movb $' ', %dl
	movq (x), %rdi
	movq $23, %rsi
	movb $255, %cl
	call putChar

	movq (x), %r8
	incq %r8
	cmpq $79, %r8
	jl _draw_board_h

	movq $2, %r9
_draw_board_v:
	movq %r9, (y)
	movb $' ', %dl
	movq $1, %rdi
	movq (y), %rsi
	movb $153, %cl
	call putChar

	movb $'0', %dl
	movq $78, %rdi
	movq (y), %rsi
	movb $68, %cl
	call putChar

	movq (y), %r9
	incq %r9
	cmpq $23, %r9
	jl _draw_board_v

	ret
# void()/draws ball at position (ball_x, ball_y), ball size is 1x2
draw_ball:
	movq (ball_x) ,%rdi
	movq (ball_y) ,%rsi

	movb $' ', %dl
	movb $255, %cl
	call putChar

	movq (ball_x) ,%rdi
	movq (ball_y) ,%rsi
	incq %rdi

	movb $' ', %dl
	movb $255, %cl
	call putChar

	ret

# void()/draw pads at (3, pad1_y) and (76, pad2_y) width 3
draw_pads:
	#left pad
	movb $' ', %dl
	movq $3, %rdi
	movq (pad1_y), %rsi
	movb $255, %cl
	call putChar
	movb $' ', %dl
	movq $3, %rdi
	movq (pad1_y), %rsi
	decq %rsi
	movb $255, %cl
	call putChar
	movb $' ', %dl
	movq $3, %rdi
	movq (pad1_y), %rsi
	incq %rsi
	movb $255, %cl
	call putChar

	#right pad
	movb $' ', %dl
	movq $76, %rdi
	movq (pad2_y), %rsi
	movb $255, %cl
	call putChar
	movb $' ', %dl
	movq $76, %rdi
	movq (pad2_y), %rsi
	decq %rsi
	movb $255, %cl
	call putChar
	movb $' ', %dl
	movq $76, %rdi
	movq (pad2_y), %rsi
	incq %rsi
	movb $255, %cl
	call putChar
	ret

# void()/
draw_life_bars:
	movq $1, %r8
	movq $1, (x)
_draw_life_bars_left:
	movq (x), %r8

	movq (player1_life), %rdi
	movq %r8, %rsi
	call life_to_color
	movq %r8, %rdi
	movq $0, %rsi
	movb %al, %cl
	call putChar

	incq %r8
	movq %r8, (x)
	cmpq $11, %r8
	jle _draw_life_bars_left

	movq $1, %r8
	movq $1, (x)
_draw_life_bars_right:
	movq (x), %r8

	movq (player2_life), %rdi
	movq %r8, %rsi
	call life_to_color
	movq $79, %rdi
	subq %r8, %rdi
	movq $0, %rsi
	movb %al, %cl
	call putChar

	incq %r8
	movq %r8, (x)
	cmpq $11, %r8
	jle _draw_life_bars_right
	ret

# int(int life, int pos)
life_to_color:
	cmpq %rdi, %rsi
	jg _life_to_color_black

	cmpq $0, %rdi
	je _life_to_color_black

	cmpq $2, %rsi
	jle _life_to_color_red

	cmpq $4, %rsi
	jle _life_to_color_lred

	cmpq $6, %rsi
	jle _life_to_color_yellow

	cmpq $8, %rsi
	jle _life_to_color_lgreen

	jmp _life_to_color_green

_life_to_color_red:
	movb $68, %al
	ret

_life_to_color_lred:
	movb $204, %al
	ret

_life_to_color_yellow:
	movb $238, %al
	ret

_life_to_color_lgreen:
	movb $170, %al
	ret

_life_to_color_green:
	movb $34, %al
	ret

_life_to_color_black:
	movb $0, %al
	ret

handle_game_controls:
	call readKeyCode
	#arrow up check
	cmpq $72, %rax
	jne _handle_game_controls_ad
	jmp handleArrowUp
	#arrow down check
_handle_game_controls_ad:
	cmpq $80, %rax
	jne _handle_game_controls_w
	jmp handleArrowDown

	cmpq $1, (game_state)
	jne _handle_game_controls_end
	#W check
_handle_game_controls_w:
	cmpq $17, %rax
	jne _handle_game_controls_s
	jmp handleW

	#S check
_handle_game_controls_s:
	cmpq $31, %rax
	jne _handle_game_controls_end
	jmp handleS

_handle_game_controls_end:
	jmp handleNoControlsUsed

handleArrowUp:
	decq (pad2_speed)
	cmpq $-4, (pad2_speed)
	jge _handleArrowUp
	movq $-4, (pad2_speed) 
_handleArrowUp:
	ret

handleArrowDown:
	incq (pad2_speed)
	cmpq $4, (pad2_speed)
	jle _handleArrowDown
	movq $4, (pad2_speed) 
_handleArrowDown:
	ret


handleW:
	decq (pad1_speed)
	cmpq $-4, (pad1_speed)
	jge _handleW
	movq $-4, (pad1_speed) 
_handleW:
	ret

handleS:
	incq (pad1_speed)
	cmpq $4, (pad1_speed)
	jle _handleS
	movq $4, (pad1_speed) 
_handleS:
	ret

#void()
handleNoControlsUsed:
	cmpq $0, (pad1_speed)
	je _handleNoControlsUsed_pad2
	cmpq $0, (pad1_speed)
	jl _handleNoControlsUsed_pad1_a
	decq (pad1_speed)
	jmp _handleNoControlsUsed_pad2
_handleNoControlsUsed_pad1_a:
	incq (pad1_speed)
_handleNoControlsUsed_pad2:
	cmpq $0, (pad2_speed)
	je _handleNoControlsUsed_end
	cmpq $0, (pad2_speed)
	jl _handleNoControlsUsed_pad2_a
	decq (pad2_speed)
	jmp _handleNoControlsUsed_end
_handleNoControlsUsed_pad2_a:
	incq (pad2_speed)
_handleNoControlsUsed_end:
	ret

#void()
calculate_pad_pos:
	movq (pad1_speed), %rax
	movq (pad1_y), %rdi
	addq %rax, %rdi
	movq %rdi, (pad1_y)
	movq (pad2_speed), %rax
	movq (pad2_y), %rdi
	addq %rax, %rdi
	movq %rdi, (pad2_y)
	
	

	cmpq $21 ,(pad1_y)
	jl calculate_pad_pos_1up
	movq $21, (pad1_y)
	movq $0, (pad1_speed)
calculate_pad_pos_1up:
	cmpq $3 ,(pad1_y)
	jg calculate_pad_pos_2down
	movq $3, (pad1_y)
	movq $0, (pad1_speed)
calculate_pad_pos_2down:
	cmpq $21 ,(pad2_y)
	jl calculate_pad_pos_2up
	movq $21, (pad2_y)
	movq $0, (pad2_speed)
calculate_pad_pos_2up:
	cmpq $3 ,(pad2_y)
	jg calculate_pad_pos_end
	movq $3, (pad2_y)
	movq $0, (pad2_speed)
calculate_pad_pos_end:
	ret

#void()
handle_ball:
	cmpq $1, (ball_direction)
	je _handle_ball_1
	cmpq $2, (ball_direction)
	je _handle_ball_2
	cmpq $3, (ball_direction)
	je _handle_ball_3
	cmpq $4, (ball_direction)
	je _handle_ball_4
	cmpq $5, (ball_direction)
	je _handle_ball_5
	cmpq $6, (ball_direction)
	je _handle_ball_6


	ret


_handle_ball_1: #+2 +1
	incq (ball_x)
	incq (ball_x)
	incq (ball_y)
	jmp ball_check

_handle_ball_2: #+2 0
	incq (ball_x)
	incq (ball_x)
	jmp ball_check

_handle_ball_3:#+2 -1
	incq (ball_x)
	incq (ball_x)
	decq (ball_y)
	jmp ball_check

_handle_ball_4: #-2 +1
	decq (ball_x)
	decq (ball_x)
	incq (ball_y)
	jmp ball_check

_handle_ball_5: #-2 0
	decq (ball_x)
	decq (ball_x)
	jmp ball_check

_handle_ball_6:#-2 -1
	decq (ball_x)
	decq (ball_x)
	decq (ball_y)
	jmp ball_check



ball_check:
	call bounce_check_pads
	call bounce_check_walls
	ret



bounce_check_pads:
	#check pad1
	cmpq $4, (ball_x)
	jne _bounce_check_pad2
	#switch(direction)
	#case(4)↙
	_bounce_check_pad1_case4:
	cmpq $4, (ball_direction)
	jne _bounce_check_pad1_case5

	movq (pad1_y), %rdi
	movq (pad1_y), %rsi
	decq %rdi
	incq %rsi
	addq (pad1_speed), %rdi
	addq (pad1_speed), %rsi
	
	call align_registers

	movq (ball_y), %rcx
	incq %rcx

	cmpq %rdi, %rcx
	jl _bounce_check_pad1_case4_nobounce
	cmpq %rsi, %rcx
	jg _bounce_check_pad1_case4_nobounce
	_bounce_check_pad1_case4_bounce:
		movq $1, (ball_direction)
		ret
	_bounce_check_pad1_case4_nobounce:
		decq (player1_life)
		call newPoint 
		ret
	#case(5)⇽
	_bounce_check_pad1_case5:
	cmpq $5, (ball_direction)
	jne _bounce_check_pad1_case6

	movq (pad1_y), %rdi
	movq (pad1_y), %rsi
	decq %rdi
	incq %rsi
	addq (pad1_speed), %rdi
	addq (pad1_speed), %rsi
	
	call align_registers

	movq (ball_y), %rcx

	cmpq %rdi, %rcx
	jl _bounce_check_pad1_case5_nobounce
	cmpq %rsi, %rcx
	jg _bounce_check_pad1_case5_nobounce
	_bounce_check_pad1_case5_bounce:
		cmpq $0, (pad1_speed)
		jne _bounce_check_pad1_case5_bounce_nonstatic
		movq $2, (ball_direction)
		ret
		_bounce_check_pad1_case5_bounce_nonstatic:
		cmpq $0, (pad1_speed)
		jg _bounce_check_pad1_case5_bounce_nonstatic2
		movq $3, (ball_direction)
		ret 
		_bounce_check_pad1_case5_bounce_nonstatic2:
		movq $1, (ball_direction)
		ret
	_bounce_check_pad1_case5_nobounce:
		decq (player1_life)
		call newPoint 
		ret
	#case(6)↖
	_bounce_check_pad1_case6:
	cmpq $6, (ball_direction)
	jne _bounce_check_pad2
	movq (pad1_y), %rdi
	movq (pad1_y), %rsi
	decq %rdi
	incq %rsi
	addq (pad1_speed), %rdi
	addq (pad1_speed), %rsi
	
	call align_registers

	movq (ball_y), %rcx
	decq %rcx

	cmpq %rdi, %rcx
	jl _bounce_check_pad1_case6_nobounce
	cmpq %rsi, %rcx
	jg _bounce_check_pad1_case6_nobounce
	_bounce_check_pad1_case6_bounce:
		movq $3, (ball_direction)
		ret
	_bounce_check_pad1_case6_nobounce:
		decq (player1_life)
		call newPoint 
		ret
	
	#check pad2
_bounce_check_pad2:
	cmpq $74, (ball_x)
	jne _bounce_check_pads_end
	#switch(direction)
	#case(1)↘
	cmpq $1, (ball_direction)
	jne _bounce_check_pad2_case2

	movq (pad2_y), %rdi
	movq (pad2_y), %rsi
	decq %rdi
	incq %rsi
	addq (pad2_speed), %rdi
	addq (pad2_speed), %rsi

	call align_registers

	movq (ball_y), %rcx
	incq %rcx

	cmpq %rdi, %rcx
	jl _bounce_check_pad2_case1_nobounce
	cmpq %rsi, %rcx
	jg _bounce_check_pad2_case1_nobounce
	_bounce_check_pad2_case1_bounce:
		movq $4, (ball_direction)
		ret
	_bounce_check_pad2_case1_nobounce:
		decq (player2_life)
		call newPoint 
		ret
	#case(2)➙
	_bounce_check_pad2_case2:
	cmpq $2, (ball_direction)
	jne _bounce_check_pad2_case3

	movq (pad2_y), %rdi
	movq (pad2_y), %rsi
	decq %rdi
	incq %rsi
	addq (pad2_speed), %rdi
	addq (pad2_speed), %rsi

	movq (ball_y), %rcx

	cmpq %rdi, %rcx
	jl _bounce_check_pad2_case2_nobounce
	cmpq %rsi, %rcx
	jg _bounce_check_pad2_case2_nobounce
	_bounce_check_pad2_case2_bounce:
		cmpq $0, (pad2_speed)
		jne _bounce_check_pad2_case2_bounce_nonstatic
		movq $5, (ball_direction)
		ret
		_bounce_check_pad2_case2_bounce_nonstatic:
		cmpq $0, (pad2_speed)
		jg _bounce_check_pad2_case2_bounce_nonstatic2
		movq $6, (ball_direction)
		ret 
		_bounce_check_pad2_case2_bounce_nonstatic2:
		movq $4, (ball_direction)
		ret
	_bounce_check_pad2_case2_nobounce:
		decq (player2_life)
		call newPoint 
		ret
	_bounce_check_pad2_case3:
	#case(3)↗
	cmpq $3, (ball_direction)
	jne _bounce_check_pads_end

	movq (pad2_y), %rdi
	movq (pad2_y), %rsi
	decq %rdi
	incq %rsi
	addq (pad2_speed), %rdi
	addq (pad2_speed), %rsi
	
	call align_registers

	movq (ball_y), %rcx
	decq %rcx

	cmpq %rdi, %rcx
	jl _bounce_check_pad2_case3_nobounce
	cmpq %rsi, %rcx
	jg _bounce_check_pad2_case3_nobounce
	_bounce_check_pad2_case3_bounce:
		movq $6, (ball_direction)
		ret
	_bounce_check_pad2_case3_nobounce:
		decq (player2_life)
		call newPoint 
		ret
	_bounce_check_pads_end:
		ret


bounce_check_walls:
	#top wall
	cmpq $1, (ball_y)
	jne _bounce_check_walls_bottom
	#switch(direction)
	#case(3)↗ -> case(1)↘
	cmpq $3, (ball_direction)
	jne _bounce_check_walls_top_6
	incq (ball_y)
	incq (ball_y)
	movq $1, (ball_direction)
	ret
	#case(6)↖ -> case(4)↙
	_bounce_check_walls_top_6:
	cmpq $6, (ball_direction)
	jne _bounce_check_walls_end
	incq (ball_y)
	incq (ball_y)
	movq $4, (ball_direction)
	ret
	#bottom wall
	_bounce_check_walls_bottom:
	cmpq $22, (ball_y)
	jne _bounce_check_walls_end
	#switch(direction)
	#case(1)↘ -> case(3)↗
	cmpq $1, (ball_direction)
	jne _bounce_check_walls_bottom_4
	decq (ball_y)
	decq (ball_y)
	movq $3, (ball_direction)
	ret
	#case(4)↙ -> case(6)↖
	_bounce_check_walls_bottom_4:
	cmpq $4, (ball_direction)
	jne _bounce_check_walls_end
	decq (ball_y)
	decq (ball_y)
	movq $6, (ball_direction)
	_bounce_check_walls_end:
	ret


align_registers: #rsi - bottom ,rdi - top
	cmpq $2, %rdi
	jge _align_registers_2case
	movq $2, %rdi
	movq $4, %rsi
	ret
_align_registers_2case:
	cmpq $22, %rsi
	jle _align_registers_end
	movq $20, %rdi
	movq $22, %rsi
	ret
_align_registers_end:
	ret
