; Gabinete, Keith Ginoel
; Exercise 7 - Week 8 Arrays

global _start
global get_largest
global are_all_negative

section .data
	SYS_EXIT equ 60

	; input array
	;num_arr dw -7, -2, -3, -4, -5
	;num_arr dw -1, -2, 3, 4, -5
	;num_arr dw 0, -2, -3, -4, -5
	;num_arr dw 1,6,7,8,9
	num_arr times 5 dw 0

	all_negative db 0
	largest dw 0 		

section .text
_start:
	mov rdi, num_arr 				; pass the address of the first element of the array as the first argument of the next function call
	call get_largest
	mov word[largest], ax 			; store the return value of the get_largest function to the memory variable largest

	mov rdi, num_arr 				; pass the address of the first element of the array as the first argument of the next function call
	call are_all_negative
	mov byte[all_negative], al 		; store the return value of the are_all_negative function to the memory variable all_negative

	; change the value of the largest(memory variable) to negative 1 if all the elements in the array are negative numbers
	cmp byte[all_negative], 1
	je are_all_negative_condition

	; otherwise retain the value of the largest(memory variable) then terminate the program
	jmp exit_here

are_all_negative_condition:
	mov word[largest], -1 	


exit_here:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall


; first function
get_largest:
	mov rax, 0 			; will contain the result
	mov rcx, 5 			; will be used for a loop
	mov rdx, 0 			; will store the largest value among the elements of the array

	mov rsi, 0 			; will track the index of the array

	mov dx, word[rdi+rsi*2]  	; move the first element of the array to dx

	loop1:
		cmp dx, word[rdi+rsi*2] 	; compare the current largest to the current index of the array
		jl is_less 					; check if the value of dx is less than the value of the current element of the array
		 							; jump to is_less if current element's value is less than dx
		inc rsi 					; increment rsi/ index tracker			
		loop loop1

		jmp loop_done 				; if loop is done
	
	is_less:
		mov dx, word[rdi+rsi*2] 	; change the value of dx to the current largest number
		inc rsi 					; increment rsi/ index tracker
		loop loop1
		jmp loop_done 				; if loop is done

	loop_done:
		mov ax, dx 		; move the final value of dx to the return value rax
		ret

; second function
are_all_negative:
	mov al, 1 			; will contain the result
	mov rcx, 5 			; will be used for a loop
	mov rdx, 0 			; will store the largest value among the elements of the array

	mov rsi, 0 			; will track the index of the array

	; check if there's a positive number among the elements of the array
	; return 1 if there's none, otherwise return 0
	loop2:
		cmp word[rdi+rsi*2], 0
		jge found_positive
		inc rsi 		; increment rsi/ index tracker
		loop loop2

		jmp loop2_done 	; if loop is done

	found_positive:
		mov al, 0		; change the value of rax to 0

	loop2_done:
		ret
