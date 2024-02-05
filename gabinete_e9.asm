; Gabinete, Keith Ginoel S.
; CMSC 131 U-9L
; Exer 09: Input/Output System Services

global _start

section .data
    ; call codes
    SYS_EXIT equ 60
    SYS_READ equ 0
    SYS_WRITE equ 1

    ; file descriptors
    STDOUT equ 1
    STDIN equ 0
    
    ; misc
    NULL equ 0          ; end of string
    LF equ 10           ; line feed (new line)
    newLine db LF, NULL ; for printing
    newLineLen equ $-newLine
    
    ; Main Menu
    msg1 db "************MENU***********", LF, NULL
    msgLen1 equ $-msg1
    msg2 db "[1] Convert to Minutes", LF, NULL
    msgLen2 equ $-msg2
    msg3 db "[2] Convert to Hours", LF, NULL
    msgLen3 equ $-msg3
    msg4 db "[0] Exit", LF, NULL
    msgLen4 equ $-msg4
    msg5 db "**************************", LF, NULL
    msgLen5 equ $-msg5

    ; message for asking input (choice) from the user
    choiceMsg db "Choice: ", NULL
    choiceMsgLen equ $-choiceMsg

    ; message for asking input (time in seconds) from the user
    timeMsg db "Enter time in seconds (5-digits): ", NULL
    timeMsgLen equ $-timeMsg

    ; message for informing the user if he/she enters an invalid input
    invalidMsg db "Invalid Input!", LF, NULL
    invalidMsgLen equ $-invalidMsg

    ; variables for storing inputs from the user
    newLineCatcher db 0 ; for fetching new line character from the input of the user
    choice db 0
    timeInSec dq 0
    timeConverted dq 0
    
    ; for place values
    timeOnes db 0           ; 00001
    timeTens db 0           ; 00010
    timeHundreds db 0       ; 00100
    timeThousands db 0      ; 01000
    timeTenThousands db 0   ; 10000

section .text
_start:

; for printing the Main Menu
main_menu:
    ; resets the values of the used variables
    mov qword[timeInSec], 0
    mov qword[timeConverted], 0

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg1
    mov rdx, msgLen1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg2
    mov rdx, msgLen2
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg3
    mov rdx, msgLen3
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg4
    mov rdx, msgLen4
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, msg5
    mov rdx, msgLen5
    syscall

ask_choice:
    mov byte[choice], 0     ; resets the value of variable choice

    ; display message for asking choice input from the user
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, choiceMsg
    mov rdx, choiceMsgLen
    syscall

    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, choice
    mov rdx, 1
    syscall

    ; fetch new line
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, newLineCatcher
    mov rdx, 1
    syscall

    ; convert the value of choice(variable) to its decimal equivalent
    sub byte[choice], 30h

    ; terminate the program if the user enters 0 as an input (for choice); otherwise, continue
    cmp byte[choice], 0
    je exit_here

    ; ask for a 5-digit integer from the user if he/she enters 0 or 1 as an input
    cmp byte[choice], 1
    je ask_time
    cmp byte[choice], 2
    je ask_time

    ; inform the user if he/she enters an invalid input
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, invalidMsg
    mov rdx, invalidMsgLen
    syscall

    ; loop until the user provides a valid input
    jmp ask_choice

; ask for a five-digit integer from the user
ask_time:
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, timeMsg
    mov rdx, timeMsgLen
    syscall

    ; ten thousands
    ; fetch the input for the ten thousands place of the 5-digit integer
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, timeTenThousands
    mov rdx, 1
    syscall

    ; convert the value of timeTenThousands(variable) to its decimal equivalent
    sub byte[timeTenThousands], 30h
    mov rax, 0
    mov al, byte[timeTenThousands]
    mov rbx, 10000
    mul rbx
    add qword[timeInSec], rax

    ; thousands
    ; fetch the input for the thousands place of the 5-digit integer
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, timeThousands
    mov rdx, 1
    syscall

    ; convert the value of timeThousands(variable) to its decimal equivalent
    sub byte[timeThousands], 30h
    mov rax, 0
    mov al, byte[timeThousands]
    mov rbx, 1000
    mul rbx
    add qword[timeInSec], rax

    ; hundreds
    ; fetch the input for the hundreds place of the 5-digit integer
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, timeHundreds
    mov rdx, 1
    syscall

    ; convert the value of timeHundreds(variable) to its decimal equivalent
    sub byte[timeHundreds], 30h
    mov rax, 0
    mov al, byte[timeHundreds]
    mov rbx, 100
    mul rbx
    add qword[timeInSec], rax

    ; tens
    ; fetch the input for the tens place of the 5-digit integer
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, timeTens
    mov rdx, 1
    syscall

    ; convert the value of timeTens(variable) to its decimal equivalent
    sub byte[timeTens], 30h
    mov rax, 0
    mov al, byte[timeTens]
    mov rbx, 10
    mul rbx
    add qword[timeInSec], rax

    ; ones
    ; fetch the input for the ones place of the 5-digit integer
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, timeOnes
    mov rdx, 1
    syscall

    ; convert the value of timeOnes(variable) to its decimal equivalent
    sub byte[timeOnes], 30h
    mov rax, 0
    mov al, byte[timeOnes]
    add qword[timeInSec], rax


    ; fetch new line
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rsi, newLineCatcher
    mov rdx, 1
    syscall

    ; convert to minutes
    cmp byte[choice], 1
    je convert_to_minutes

    ; convert to hours
    cmp byte[choice], 2
    je convert_to_hours


; convert the given time (in seconds) to minutes
convert_to_minutes:
    mov rax, 0
    mov rdx, 0
    mov rax, qword[timeInSec]
    mov rbx, 60
    div rbx
    mov qword[timeConverted], rax

    ; print the resulting converted time
    jmp print_result

; convert the given time (in seconds) to hours
convert_to_hours:
    mov rax, 0
    mov rdx, 0
    mov rax, qword[timeInSec]
    mov rbx, 3600
    div rbx
    mov qword[timeConverted], rax

; convert the value of timeConverted (variable) to a string for printing
print_result:
    mov rax, 0
    mov rdx, 0
    mov rax, qword[timeConverted]
    mov rbx, 1000
    div rbx
    mov byte[timeThousands], al     ; reuse timeThousands to store thousands
    add byte[timeThousands], 30h    ; convert to its character equivalent

    mov rax, rdx
    mov rdx, 0
    mov rbx, 100
    div rbx
    mov byte[timeHundreds], al      ; reuse timeHundreds to store hundreds
    add byte[timeHundreds], 30h     ; convert to its character equivalent

    mov rax, rdx
    mov rdx, 0
    mov rbx, 10
    div rbx
    mov byte[timeTens], al          ; reuse timeTens to store tens
    add byte[timeTens], 30h         ; convert to its character equivalent
    mov byte[timeOnes], dl          ; reuse timeOnes to store ones
    add byte[timeOnes], 30h         ; convert to its character equivalent

    ; display the results
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, timeThousands
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, timeHundreds
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, timeTens
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, timeOnes
    mov rdx, 1
    syscall

    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, newLine
    mov rdx, newLineLen
    syscall

repeat_main_menu:
    ; loop until the user chooses to terminate the program (enters 0 as an input)
    jmp main_menu

exit_here:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
