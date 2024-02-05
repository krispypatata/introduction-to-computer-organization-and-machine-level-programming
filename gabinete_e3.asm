; Gabinete, Keith Ginoel S.
; CMSC 131 - U9L
; Exercise 3: Unconditional and Conditional Transfer

global _start

section .data
	SYS_EXIT equ 60
	
	; input Numbers
	aNum db 60
	bNum db 40
	cNum db 20
	
	largestNum db 0			; will store the largest number from the given inputs
	largestInput db 0		; will store the letter of the input name of the largest number
	
	
section .text
_start:
	mov al, byte[aNum]		; move the value of the memory variable aNum to register al
	cmp al, byte[bNum]		; compare the value of register al and memory variable bNum
	jb bIsLargest			; check if aNum is below bNum
					; jump to bIsLargest label if aNum is below bNum
	
	cmp al, byte[cNum]		; compare the current value of the al register to the value of memory variable cNum
	jb cIsLargest			; check if the value of aNum is below cNum
					; jump to cIsLargest label if aNum is below cNum
	
	mov byte[largestNum], al	; move the final value of al register to memory variable largestNum
	mov byte[largestInput], "A"	; move "A" to memory variable largestInput as the letter of the input name of the largest number
	
	jmp exit_here			; jump to the end of the program to skip other labels that were defined
	
bIsLargest:
	mov al, byte[bNum]		; move the value of memory variable bNum to register al
	
	cmp al, byte[cNum]		; compare the values of al register and memory variable cNum
	jb cIsLargest			; check if bNum is below cNum
					; jump to cIsLargest label if bNum is below cNum
	
	mov byte[largestNum], al	; move the final value of al register to memory variable largestNum
	mov byte[largestInput], "B"	; move "B" to memory variable largestInput as the letter of the input name of the largest number
	jmp exit_here			; jump to exit code

cIsLargest:
	mov al, byte[cNum]		; move the value of memory variable cNum to register al
	
	mov byte[largestNum], al	; move the final value of al register to memory variable largestNum 
	mov byte[largestInput], "C"	; move "C" to memory variable largestInput as the letter of the input name of the largest number
	
; exit code
exit_here:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
