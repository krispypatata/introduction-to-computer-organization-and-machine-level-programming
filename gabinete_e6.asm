; Gabinete, Keith Ginoel S.
; Week 07 - Strings

global _start
global get_strlen
global find

section .data
	NULL equ 0
	SYS_EXIT equ 60

 	strlen dq 0
	string1 db 'boredgirl', NULL
	string2 db 'robedgirl', NULL

	anagram db "Y" 					; will contain the result

section .text

_start:
	mov rdi, string1
	mov rsi, strlen
	call get_strlen 				; get string length

	mov rcx, qword[strlen]
	mov rsi, string1
	mov rdi, string2

	cld								; forward

loop1:
	lodsb 							; load string1

	call find						; check if 
	cmp r11, 1
	jne not_anagram

	loop loop1

is_anagram:
	jmp exit_here

not_anagram:
	mov al, "N"
	mov byte[anagram], al

exit_here:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

get_strlen:
	len_loop:
		mov al, byte[rdi]
		cmp al, NULL
		je return

		inc rdi
		inc byte[rsi]
		jmp len_loop

	return:
		ret

find:
	mov r10, rcx
	mov rcx, qword[strlen]

	mov r11, 1
	
	repne scasb
	je is_found

not_found:
	mov rcx, r10
	mov r11, 0
	ret

is_found:
	mov rcx, r10
	ret