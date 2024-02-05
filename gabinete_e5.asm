; Gabinete, Keith Ginoel S.
; Exercise 5: 

global _start
global division

section .data
	SYS_EXIT equ 60
	num1 dq 123456789 
	num2 dq 54321
	quo dq 0 				; will hold the computed quotient

section .text
_start:
	mov rdi, num1
	mov rsi, num2
	call div_op

	mov qword[quo], rax    ; move the return value of the function to the quotient variable

exit_here:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

div_op:
	mov r10, qword[rdi] 	; mov the value of num1 to temporary storage r10
	mov r11, 0 				; will store the quotient

; division by repeated subtraction
sub_loop:
	sub r10, qword[rsi] 	; perform the operation: num1-num2

	cmp r10, 0
	jl loop_done

	inc r11 				; increment the quotient

	jmp sub_loop 			; loop until the dividend is already a negative number

loop_done: 					
	mov rax, r11 			; mov the quotient to rax, since rax will contain the 
	ret