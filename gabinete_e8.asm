; Gabinete, Keith Ginoel S.
; CMSC 131 U-9L
; Exer 8: Records/Structures

global _start

section .data
	; call codes
    SYS_EXIT equ 60
    SYS_READ equ 0
    SYS_WRITE equ 1

    ; file descriptors
	STDIN equ 0
    STDOUT equ 1

	; for printing
	; ********************************************************************************************************************
	menuHeading db "====== MENU ======"
	menuHeadingLength equ $-menuHeading

	menu db 10, "[1] Add Patient", 10, "[2] Edit Patient", 10, "[3] Print Patients", 10, "[4] Exit", 10, "Enter choice: "
	menuLength equ $-menu

	invalidChoice db 10, "Invalid choice!", 10, 10
	invalidChoiceLength equ $-invalidChoice

	fullPrompt db 10, "Record is already full!", 10, 10
	fullPromptLength equ $-fullPrompt

	addCase db 10, "Enter caseID: "		;Use this prompt for add and edit
	addCaseLength equ $-addCase

	addSex db "Enter sex (F - Female, M - Male): "
	addSexLength equ $-addSex

	addStatus db "Enter status (0 - deceased, 1 - admitted, 2 - recovered): " ;Use this prompt for add and edit
	addStatusLength equ $-addStatus

	addDate db "Enter date admitted (mm/dd/yyyy): "
	addDateLength equ $-addDate

	printRecordHeading db 10, "==== DATABASE ===="
	printRecordHeadingLength equ $-printRecordHeading

	printPatientCounter db 10, "No. of Patients: "
	printPatientCounterLength equ $-printPatientCounter

	printCase db 10, "CaseID: "
	printCaseLength equ $-printCase

	printSex db 10, "Sex: "
	printSexLength equ $-printSex

	sexMale db "Male"
	sexMaleLength equ $-sexMale

	sexFemale db "Female"
	sexFemaleLength equ $-sexFemale

	printStatus db 10, "Status: "
	printStatusLength equ $-printStatus

	statusDeceased db "Deceased"
	statusDeceasedLength equ $-statusDeceased

	statusAdmitted db "Admitted"
	statusAdmittedLength equ $-statusAdmitted

	statusRecovered db "Recovered"
	statusRecoveredLength equ $-statusRecovered

	printDate db 10, "Date Admitted: "
	printDateLength equ $-printDate

	cannotEdit db "Cannot edit records of a deceased patient.", 10, 10
	cannotEditLength equ $-cannotEdit

	cannotFind db "Patient not found!", 10, 10
	cannotFindLength equ $-cannotFind

	emptyPrompt db 10, "Record is empty!", 10, 10
	emptyPromptLength equ $-emptyPrompt

	exitProgram db "==================", 10, "Program exits... Bye!", 10
	exitProgramLength equ $-exitProgram
	; ********************************************************************************************************************

	; misc
    NULL equ 0          ; end of string
	newLine db 10 		; line feed (new line)
	newLineLength equ $-newLine
	patientCounter db 0 ; for checking (if the database is already full)
	pcLength equ $-patientCounter
	arraysize equ 5 	
	
	; constants for patient's status
	DECEASED equ 0
	ADMITTED equ 1
	RECOVERED equ 2

	; variables for storing inputs from the user
    newLineCatcher db 0 ; for fetching new line character from the input of the user
    choice db 0

	; structure for CoVid-19 patients
	patient equ 35 		; total size of the structure
	caseID equ 0 		; starting address of caseID
	caseIDLength equ 20 ; starting address of caseID's length
	sex equ 21 			; starting address of sex
	status equ 22		; starting address of status
	date equ 23 		; starting address of date
	dateLength equ 34 	; starting address of date's length  	

section .bss
	patient_database resb patient*arraysize 	; array declaration
	caseIDToSearch resb caseIDLength 			; will be used to store input from the user (search caseID for option 2: Edit Patient Record)

section .text
_start:
; ******************************************************************************************************************
; for printing the Main Menu
main_menu:
	; print the heading for the main menu
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, menuHeading
	mov rdx, menuHeadingLength
	syscall

	; print the main menu
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, menu
	mov rdx, menuLength
	syscall

; ask a choice input from the user
ask_choice:
	mov byte[choice], 0     ; resets the value of variable choice

	; get an input from the user
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
    cmp byte[choice], 4
    je exit_here

	; add patient if the user enters 1 as an input (for choice)
    cmp byte[choice], 1
    je add_patient

	; edit patient's record if the user enters 2 as an input (for choice)
	cmp byte[choice], 2
	je edit_patient_record

	; print patients' records if the user enters 3 as an input (for choice)
	cmp byte[choice], 3
	je print_patients

	; inform the user if he/she enters an invalid choice input
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, invalidChoice
	mov rdx, invalidChoiceLength
	syscall

	; loop until the user provides a valid choice input
	jmp main_menu


; ******************************************************************************************************************
; option 1 (Add Patient)
add_patient:
	; check if the database is not full yet
	cmp byte[patientCounter], 5
	je is_full


	; (1) ask for the caseID of the patient
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, addCase
	mov rdx, addCaseLength
	syscall

	; track the index of the patient
	mov rax, 0
	mov rbx, 0
	mov bl, byte[patientCounter]
	mov rax, patient
	mul rbx 		; patientCounter*patient (index * size_of_structure)
	mov rbx, rax 	; can't use rax since it will be used to read input

	; get input from the user	
	mov rax, SYS_READ
	mov rdi, STDOUT
	lea rsi, [patient_database + rbx + caseID] 				; store the input to caseID
	mov rdx, 20
	syscall

	dec rax 	; remove the fetched new line
	mov byte[patient_database + rbx + caseIDLength], al 	; store the length of caseID


	; (2) ask for the sex of the patient
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, addSex
	mov rdx, addSexLength
	syscall

	; get input from the user
	; F - female, M - male
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, [patient_database + rbx + sex]
	mov rdx, 1
	syscall

	; fetch new line
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, newLineCatcher
	mov rdx, 1
	syscall

	; (3) ask for patient status
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, addStatus
	mov rdx, addStatusLength
	syscall

	; get input from the user
	; 0 - deceased, 1 - admitted, 2 - recovered
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, [patient_database + rbx + status]
	mov rdx, 1
	syscall

	; fetch new line
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, newLineCatcher
	mov rdx, 1
	syscall

	; convert the value of patient status to its decimal equivalent
	sub byte[patient_database + rbx + status], 30h

	; (4) ask for the admission date
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, addDate
	mov rdx, addDateLength
	syscall

	; get input from the user
	; FORMAT: mm/dd/yyyy
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, [patient_database + rbx + date]
	mov rdx, 11
	syscall

	mov byte[patient_database + rbx + dateLength], 10 	; store the length of admission date


	; increment the counter for the number of patients stored in the database
	inc byte[patientCounter]

	; print new line (for readability)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, newLine
	mov rdx, newLineLength
	syscall

	; go back to main menu
	jmp main_menu

; inform the user if the database is already full
is_full:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, fullPrompt
	mov rdx, fullPromptLength
	syscall

	; go back to main menu
	jmp main_menu


; ******************************************************************************************************************
; option 2 (Edit Patient Record)
edit_patient_record:
	; (1) check if the database is empty or not
	cmp byte[patientCounter], 0
	je is_empty

	; (2) ask the user for the caseID of the patient
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, addCase
	mov rdx, addCaseLength
	syscall

	; get input from the user
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, caseIDToSearch 		; store to the uninitialized variable declared in bss
	mov rdx, 20
	syscall

	; (3) loop through the patients' caseID in the database and compare each to the caseID entered by the user (until a match is found)
	mov r10, 0
	mov r10b, byte[patientCounter] ; will be used to loop through the patients in the database
find_loop:
	; track the index of the patient
	mov rax, 0
	mov rbx, 0
	mov bl, r10b
	dec bl
	mov rax, patient
	mul rbx 		; patientCounter*patient (index * size_of_structure)
	mov rbx, rax 	; can't use rax since it will be used to read input


	; compare the fetched input to the strings stored in caseIDs in the database
	mov rcx, 0
	mov cl, byte[patient_database + rbx + caseIDLength] 	; length of recorded patients' caseID will be used as the value of rcx needed in a loop

	mov rsi, 0
	mov rdi, 0
	lea rsi, [patient_database + rbx + caseID + rcx-1] 		; locate the last character of patient's caseID in the database
	lea rdi, [caseIDToSearch + rcx-1] 						; locate the last character of patient's caseID (to search) entered by the user

	std ; backward (direction)

; compare the two strings (caseID from the database and caseID inputted by the user)
compare_strings:
	cmpsb
	jne update_find_counter 	; if there's a mismatch in the two strings' characters, then, end the compare_strings loop and proceed to check the other patients' caseIDs in the database
	loop compare_strings

; if the two strings are equal (there's a match found)
is_found:
	; check the patient status
	; 0 - deceased, 1 - admitted, 2 - recovered
	; cannot edit the record if the patient is already deceased (status == 0)
	cmp byte[patient_database + rbx + status], 0
	je is_deceased

	; if not deceased, give the user permission to edit the patient status
	; ask for patient status
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, addStatus
	mov rdx, addStatusLength
	syscall

	; get input from the user
	; 0 - deceased, 1 - admitted, 2 - recovered
	mov rax, SYS_READ
	mov rdi, STDIN
	lea rsi, [patient_database + rbx + status]
	mov rdx, 1
	syscall

	; fetch new line
	mov rax, SYS_READ
	mov rdi, STDIN
	mov rsi, newLineCatcher
	mov rdx, 1
	syscall

	; convert the value of patient status to its decimal equivalent
	sub byte[patient_database + rbx + status], 30h

	; print new line (for readability)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, newLine
	mov rdx, newLineLength
	syscall
	
	; go back to main menu
	jmp main_menu

; inform the user that he/she cannot edit the record if the patient is already deceased
is_deceased:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, cannotEdit
	mov rdx, cannotEditLength
	syscall

	; go back to main menu
	jmp main_menu

; update the counter being used to loop through the patients in the database (loop through structures in the array of structures)
update_find_counter:
	dec r10b
	cmp r10b, 0
	jne find_loop

; (5) inform the user if the caseID entered by the user doesn't match any of the caseID stored in the database
patient_not_found:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, cannotFind
	mov rdx, cannotFindLength
	syscall

	; go back to main menu
	jmp main_menu

; inform the user if the database is still empty
is_empty:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, emptyPrompt
	mov rdx, emptyPromptLength
	syscall

	; go back to main menu
	jmp main_menu


; ******************************************************************************************************************
; option 3 (Print Patients)
print_patients:
	; (1) check if the database is empty or not
	cmp byte[patientCounter], 0
	je is_empty

	; heading for printing patients' records
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, printRecordHeading
	mov rdx, printRecordHeadingLength
	syscall

	; print the number of patients recorded
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, printPatientCounter
	mov rdx, printPatientCounterLength
	syscall

	; convert the value of patientCounter to its character equivalent
	add byte[patientCounter], 30h

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, patientCounter
	mov rdx, 1
	syscall

	; convert the value of patientCounter back to its decimal equivalent
	sub byte[patientCounter], 30h

	; (2) loop through the elements of the array of structures (patients' records in the database)
	mov r10, 0
	mov r10b, byte[patientCounter] ; will be used to loop through the patients in the database	
access_loop_through:
	; track the index of the patient
	mov rax, 0
	mov rbx, 0
	mov bl, r10b
	dec bl
	mov rax, patient
	mul rbx 		; patientCounter*patient (index * size_of_structure)
	mov rbx, rax 	; can't use rax since it will be used to read input

	mov rax, 0
	mov rdi, 0
	mov rsi, 0
	mov rdx, 0

	; print the patient's caseID
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, printCase
	mov rdx, printCaseLength
	syscall

	mov rdx, 0
	; patient's caseID (in database)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, [patient_database + rbx + caseID]
	mov dl, byte[patient_database + rbx + caseIDLength]
	syscall

	; print the patient's sex
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, printSex
	mov rdx, printSexLength
	syscall

	; patient's sex (in database)
	; if sex is Female
	; if char is 'F'
	cmp byte[patient_database + rbx + sex], 70
	je print_female
	; if sex is 'f'
	cmp byte[patient_database + rbx + sex], 102
	je print_female

	; if sex is Male
	; if char is 'M'
	cmp byte[patient_database + rbx + sex], 77
	je print_male
	; if char is 'm'
	cmp byte[patient_database + rbx + sex], 109
	je print_male

	; ; for printing still (if inputted value isn't 'F', 'f', 'M' or 'm', just print still)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, [patient_database + rbx + sex]
	mov rdx, 1
	syscall

	jmp continue_one

; print the string "Female"
print_female:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, sexFemale
	mov rdx, sexFemaleLength
	syscall

	jmp continue_one

; print the string "Male"
print_male:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, sexMale
	mov rdx, sexMaleLength
	syscall

continue_one:
	; print the patient's status
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, printStatus
	mov rdx, printStatusLength
	syscall
	
	; patient's status (in database)
	; if patient's status is deceased
	cmp byte[patient_database + rbx + status], 0
	je print_deceased

	; if patient's status is admitted
	cmp byte[patient_database + rbx + status], 1
	je print_admitted

	; if patient's status is recovered
	cmp byte[patient_database + rbx + status], 2
	je print_recovered

	; for printing still (if inputted value isn't 0, 1 or 2, just print still)
	; convert the value of patient status to its character equivalent
	add byte[patient_database + rbx + status], 30h
	
	; patient's status (in database)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, [patient_database + rbx + status]
	mov rdx, 1
	syscall

	; convert the value of patient status back to its decimal equivalent
	sub byte[patient_database + rbx + status], 30h

	jmp continue_two

; print the string "Deceased"
print_deceased:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, statusDeceased
	mov rdx, statusDeceasedLength
	syscall

	jmp continue_two

; print the string "Admitted"
print_admitted:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, statusAdmitted
	mov rdx, statusAdmittedLength
	syscall

	jmp continue_two

; print the string "Recovered"
print_recovered:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, statusRecovered
	mov rdx, statusRecoveredLength
	syscall

continue_two:
	; print the date the patient was admitted
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, printDate
	mov rdx, printDateLength
	syscall

	; patient's admission date (in database)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	lea rsi, [patient_database + rbx + date]
	mov rdx, 10
	syscall

	; print new line (for readability)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, newLine
	mov rdx, newLineLength
	syscall

; update the counter being used to loop through the patients in the database (loop through structures in the array of structures)
update_loop_through_counter:
	dec r10b
	cmp r10b, 0
	jne access_loop_through

	; print new line (for readability)
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, newLine
	mov rdx, newLineLength
	syscall

	; go back to main menu when printing is finished
	jmp main_menu


; ******************************************************************************************************************
exit_here:
	; exit message
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, exitProgram
	mov rdx, exitProgramLength
	syscall

	; system exit (internal)
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
