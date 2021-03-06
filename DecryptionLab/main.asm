;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;Jarrod M Wooden, ECE382, M2, Dr. York, USAF Academy
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

            .data

ANSWER:		.space	100

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                           ; section
theMessage	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f
;theMessage	.string	"This is a String!"
stopOne		.byte	0xFF
theKey		.byte	0xAC

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------

     		mov.b	    theKey, r4
     		mov.w		#theMessage, r5
     		mov.w		#ANSWER, r6
     		mov 		#stopOne, r14

     		call	#findLength
     		;now r15 holds the length to the message
         									; load registers with necessary info for decryptMessage here
           									;

			mov		r5, r8
            call    #decryptMessage		;call doesn't change flags or registers

            mov		r6, r8
;            call	#decryptMessage

forever:    jmp     forever

;-------------------------------------------------------------------------------
                                            ; Subroutines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;Subroutine Name: decryptMessage
;Author: Jarrod M Wooden
;Function: Decrypts a string of bytes and stores the result in memory.  Accepts
;           the address of the encrypted message, address of the key, and address
;           of the decrypted message (pass-by-reference).  Accepts the length of
;           the message by value (r15).  Uses the decryptCharacter subroutine to decrypt
;           each byte of the message.  Stores theresults to the decrypted message
;           location.
;Inputs: r4, r5, r6, r15
;Outputs:	r6
;Registers destroyed:	r7, r8, r9, r10
;-------------------------------------------------------------------------------

decryptMessage:
			;hold all the values of the original registers into temp registers
			;so we don't destroy any registers.
			mov r4, r7		;the key
;			mov r5, r8		;the message
			mov r6, r9		;the Answer
			mov r15, r10	;the message Length

loopDecr
			mov.b	0(r8), r11
			inc		r8
			call	#decryptCharacter
			mov.b	r11, 0(r9)
			inc		r9
			dec 	r10
			jnz		loopDecr


            ret

;-------------------------------------------------------------------------------
;Subroutine Name: decryptCharacter
;Author: Jarrod M Wooden
;Function: Decrypts a byte of data by XORing it with a key byte.  Returns the
;           decrypted byte in the same register the encrypted byte was passed in.
;           Expects both the encrypted data and key to be passed by value.
;Inputs:	r7, r11
;Outputs:	r7
;Registers destroyed: r7, r8
;-------------------------------------------------------------------------------

decryptCharacter:
			xor r7, r11
            ret

;-------------------------------------------------------------------------------
;Subroutine Name: findLength
;Author: Jarrod M Wooden
;Function: Finds the lenth of the string before entering the the first main
;			subroutine. Takes in the message address and the stopOne address.
;			Once the pattern is found of stopOne then it will return and go
;			into the first main subroutine.
;	r15 -- will be the length of the message as a value
;
;
;Inputs:	r5, r14
;Outputs:	r15
;Registers destroyed: NONE
;-------------------------------------------------------------------------------
findLength:
			mov r5, r8   ;r8 will be a temp reg
			mov r14, r15 ; r13 will be a temp reg for the pointer to the

			sub	r8, r15 ;r15 is now the value of the length

			ret

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect    .stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
