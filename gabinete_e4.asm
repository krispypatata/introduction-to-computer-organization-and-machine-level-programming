; Gabinete, Keith Ginoel S.
; CMSC 131 - U9L
; Implementing Iterative Statements
; This is a simple program that checks if a given positive integer is a prime number

global _start

section .data
	SYS_EXIT equ 60
	isPrime db 0 			; value is 1 if the number is prime, otherwise, its value is 0
	num db 97				; will store the number to be checked (2-255)

section .text
_start:
	mov cl, 2 				; will store the temporary divisor
	mov ax, 0

is_prime:
	cmp cl, byte[num]		; compare the values of the given input and the current divisor
	je if_prime			    ; jump to if_prime if the incremented value of the current divisor is already equal to the given input
							; if the loop reaches this point then it is safe to assume that the given input number doesn't have any other factors other than 1 and itself

	mov al, byte[num]		; move the value of the given input to register al for division
	mov ah, 0 				; move 0 to register ah since the division operation whose divisor is of size byte requires a dividend of size word (ax)

	div cl					; divide the given input by the current divisor
	cmp ah, 0 				; check the resulting remainder and compare it to 0
	je exit_here			; if there's no remainder then the given input number has a factor other than 1 and itself, therefore, it isn't a prime number
							; jump to exit_here to terminate the program since we already know that the given input number isn't a prime number

	inc cl 					; increment the value of the current divisor
	jmp is_prime

if_prime:
	mov byte[isPrime], 1 	; change the value of the isPrime variable to 1

exit_here:
	mov rdx, SYS_EXIT
	xor rdi, rdi
	syscall
