/*
This file is part of gamelib-x64.

Copyright (C) 2014 Tim Hegeman

gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/
#every 17th color from zero is fully drawn (no character seen)
.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
	window_height: .quad 25
	window_width: .quad 80

	pad1_y: .quad 13
	pad2_y: .quad 13

	ball_x: .quad 40
	ball_y: .quad 13

	x: .quad 0
	y: .quad 0

	

	i: .quad 0
	j: .quad 0

.section .game.text

gameInit:
	call clear_screen
	call draw_board
	call draw_ball
	call draw_pads
	ret

gameLoop:
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
# void(int x, int y)/draws ball at position (x, y), ball size is 1x2
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

# void()/draw pads at given heights
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