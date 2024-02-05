; Gabinete, Keith Ginoel S.
; Student ID: 2020-03670
; Lab Section: CMSC 131 U-9L

; Exercise 2: Basic Assembly Arithmetic Instructions
; This program converts the value of age in years (0-100) to its equivalent days and hours.

global _start

section .data
    SYS_EXIT equ 60
    age dw 25           ; age in years (0-100) / value to be converted
    days dd 0           ; will store the converted value of age in days (years -> days) 
    hours dq 0          ; will store the converted value of age in hours (days -> hours)

section .text
_start:
    ; convert age in years to age in days
    ; multiplicand and multiplier should be of the same size when performing integer multiplication instruction
    mov ax, 365                 ; there are 365 days in a year
    mul word[age]               ; product will be stored in dx:ax
    mov word[days], ax          ; access the lower 16 bits of the product and store it in the memory variable named days
    mov word[days+2], dx        ; access the upper 16 bits of the product and store it in the memory variable named days
    ; memory variable 'days' now contains the converted value of age in days (age in years * 365)

    ; convert age in days to age in hours
    mov eax, 24                 ; there are 24 hours in a single day
    mul dword[days]             ; product will be stored in edx:eax
    mov dword[hours], eax       ; access the lower 32 bits of the product and store it in the memory variable named hours
    mov dword[hours+4], edx     ; access the upper 32 bits of the product and store it in the memory variable named hours
    ; memory variable 'hours' now contains the converted value of age in hours (age in days * 24)

; exit code
exit_here:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
