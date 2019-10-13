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

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data
	x: .quad 0
	y: .quad 0

.section .game.text

gameInit:
	ret

gameLoop:
	# 80x25
	xor %rcx, %rcx
lx:
	movq	%rcx, (x)
	movb	$'X', %dl
	movq	%rcx, %rdi
	movq	$0, %rsi
	movb	(x), %cl
	call	putChar
	movq	(x), %rcx
	incq %rcx
	cmpq	$80, %rcx 
	jl lx

	xor %rcx, %rcx
ly:
	movq	%rcx, (y)
	movb	$'Y', %dl
	movq	$0, %rdi
	movq	%rcx, %rsi
	movb	(y), %cl
	call	putChar
	movq	(y), %rcx
	incq %rcx
	cmpq	$25, %rcx 
	jl ly

	ret
