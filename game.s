#every 17th color from zero is fully drawn (no character seen)
.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
	#Game State Codes
	# 0 - MENU
	# 1 - IN GAME PLAYER VS PLAYER
	# 2 - IN GAME PLAYER VS COMPUTER
	game_state: .quad 1
	
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
	#1 +1 +2
	#2 +2 +1
	#3 +2  0
	#4 +2 -1
	#5 +1 -2

	#6 -1 +2
	#7 -2 +1
	#8 -2  0
	#9 -2 -2
	#10-1 -2
	ball_direction: .quad 3
	#1-5 going right 6-10 going left

	player1_life: .quad 11
	player2_life: .quad 11

	x: .quad 0
	y: .quad 0

	i: .quad 0
	j: .quad 0

.section .game.text

gameInit:
#set timer to 4hz
	movq $298295, %rdi
	call setTimer

	call clear_screen
	call draw_board
	call draw_ball
	call draw_pads
	call draw_life_bars
	ret

gameLoop:
	call handleGameControls
	call calculate_pad_pos
	call reset_board
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

handleGameControls:
	call readKeyCode
	#arrow up check
	cmpq $72, %rax
	jne _handleGameControls_ad
	jmp handleArrowUp
	#arrow down check
_handleGameControls_ad:
	cmpq $80, %rax
	jne _handleGameControls_w
	jmp handleArrowDown

	cmpq $1, (game_state)
	jne _handleGameControls_end
	#W check
_handleGameControls_w:
	cmpq $17, %rax
	jne _handleGameControls_s
	jmp handleW

	#S check
_handleGameControls_s:
	cmpq $31, %rax
	jne _handleGameControls_end
	jmp handleS

_handleGameControls_end:
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