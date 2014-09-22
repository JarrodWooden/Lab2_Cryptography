Lab2_Cryptography
=================

Encoding and Decoding a message using a Key and the MSP430

##Prelab

First I made a flowchart to orgnaize my ideas for decrypting the first message.

The only mistake with my flowchart is that the line that will jump back up to the main method should be coming from the first
subroutine, not the second.

The first subroutine goes through each byte of the message and sends the second subroutine each byte of the message and the key
to xor the two bytes together.

There is a picture of the flowchart below:

![alt text](https://github.com/JarrodWooden/Lab2_Cryptography/blob/master/PreLab_Two.jpg "Prelab 2 Flowchart")

##Required Functionality

Required Functionality needed to meet these objectives

-The encrypted and decrypted message will be in memory locations. The encrypted message and key will be stored in ROM - any 
location in ROM is acceptable. The message will be of arbitrary length, but the key will be one byte long. The decrypted 
message will be stored in RAM starting at 0x0200. Labels shall be used to to refer to the location of the encrypted message, 
decrypted message, and key.

-The key and encrypted message will be given to you. You can tell how long the message is by counting the bytes.

-Good coding standards, in accordance with the Lab guidelines, must be used throughout.

First I stored the message, a stop key, and the key in ROM... shown below:

```
theMessage	.byte	0xef,0xc3,0xc2,0xcb,0xde,0xcd,0xd8,0xd9,0xc0,0xcd,0xd8,0xc5,0xc3,0xc2,0xdf,0x8d,0x8c,0x8c,0xf5,0xc3,0xd9,0x8c,0xc8,0xc9,0xcf,0xde,0xd5,0xdc,0xd8,0xc9,0xc8,0x8c,0xd8,0xc4,0xc9,0x8c,0xe9,0xef,0xe9,0x9f,0x94,0x9e,0x8c,0xc4,0xc5,0xc8,0xc8,0xc9,0xc2,0x8c,0xc1,0xc9,0xdf,0xdf,0xcd,0xcb,0xc9,0x8c,0xcd,0xc2,0xc8,0x8c,0xcd,0xcf,0xc4,0xc5,0xc9,0xda,0xc9,0xc8,0x8c,0xde,0xc9,0xdd,0xd9,0xc5,0xde,0xc9,0xc8,0x8c,0xca,0xd9,0xc2,0xcf,0xd8,0xc5,0xc3,0xc2,0xcd,0xc0,0xc5,0xd8,0xd5,0x8f
;theMessage	.string	"This is a String!"
stopOne		.byte	0xFF
theKey		.byte	0xAC
```

Then I created a subroutine that would find the length of the message. To find the length of the message I simply subtracted 
the address of the stop key that I put in ROM after the message from the address pointer of the message.

The subroutine for length is shown below:

```
;Inputs:	r5, r14
;Outputs:	r15
;Registers destroyed: NONE
;-------------------------------------------------------------------------------
findLength:
			mov r5, r8   ;r8 will be a temp reg
			mov r14, r15 ; r13 will be a temp reg for the pointer to the

			sub	r8, r15 ;r15 is now the value of the length

			ret
```


After I found the length of the message I sent the decryptMessage subroutine the Message, the length of the message, and they 
key.

###Decrypt Message

Function: Decrypts a string of bytes and stores the result in memory.  Accepts
           the address of the encrypted message, address of the key, and address
           of the decrypted message (pass-by-reference).  Accepts the length of
           the message by value (r15).  Uses the decryptCharacter subroutine to decrypt
           each byte of the message.  Stores theresults to the decrypted message
           

I made Decrypt Message have an internal loop that would keep looping and xor'ing each byte of the message to the key, until the
length of message was completed in which case it would jump out of the loop. The whole subroutine is shown below (in case you
don't feel like looking at the actual "main.asm"):

```
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
```

###Decrypt Character

It is a very simple subroutine. It only xor's two bytes together.

The function of the subroutine: Decrypts a byte of data by XORing it with a key byte.  Returns the
           decrypted byte in the same register the encrypted byte was passed in.
           Expects both the encrypted data and key to be passed by value.


The only line of code that decrypt character has is below:

```
decryptCharacter:
			xor r7, r11
            ret
```

When I ran the code it worked. *I recieved full functionality credit from my instructor Dr. York

##B Functionality

The requried objectives to recieve B-Funtionality are below:

-In addition to the Required Functionality, your program must decrypt messages with arbitrarily long keys. The keys are 
arbitrarily long series of bytes.

-The length of the key should be a parameter passed into your subroutine. You know the length of the key in advance.

-Your subroutines don't have to exclusively pass-by-reference or pass-by-value - it's perfectly acceptable to make a 
subroutine that uses both.

To help get started with B-Functionality, I asked for help from my instructor Dr. York. He helped me figure out 
B-Functionality by describing that the first byte of the message will correspond with the first byte of the key. The second
byte with the second byte, the third with the third (lets say the key is 3 bytes long) the fourth byte of the message would
then correspond to the first byte of the key. So now there are two checkers ( one for the length of the message, the other for
the length of the key)

Length Subroutine - Function: Finds the lenth of the string before entering the the first main
			subroutine. Takes in the message address and the stopOne address.
			Once the pattern is found of stopOne then it will return and go
			into the first main subroutine. Register r14 is destroyed.
			


The new length subroutine is below:

```
findLength:
			mov r5, r8   			;r8 will be a temp reg
			mov r14, r15

			mov.w	#stopTwo, r14
			sub	r12, r14			;r14 is now length of key



			sub	r8, r15 			;r15 is now the value of the length

			ret
```


Once the program is done finding the length of the message and of the key it can go into the first MAIN subroutine
decryptMessage to begin decryption.

decryptMessage now keeps track of at which point in the key we are in and it keeps track of at what point of the message we
are in.

decryptMessage first initializes the the lengths of the message and the key in different registers so that we don't destroy 
the old ones

Then it goes into its main loop which will get the byte of the message we are on; the byte of the key we are on; pass those
values to decryptcharacter which will xor the two together; then increment both of the pointers to the message and the key; 
decrement the values for the lengths of both the key and the message in the temporary registers; check to see if we reached 
the end of the message or the key; if we reached the end of the message we are done and the program will end; if we reached 
the end of the message the pointer will be set back to its original value and the length will be set back to its original 
value and the decryption will continue.

The full subroutine is shown below:

```
decryptMessage:
			;hold all the values of the original registers into temp registers
			;so we don't destroy any registers.
;			mov r5, r8		;the message
			mov r6, r9		;the Answer
			mov r15, r10	;the message Length
			mov r14, r13	; the key length

loopDecr
			mov.b	0(r8), r11
			inc		r8
			mov.b	0(r12), r7
			inc		r12
			call	#decryptCharacter
			mov.b	r11, 0(r9)
			inc		r9
			dec		r13
			jnz		moveOn
			mov 	r14, r13
			sub		r13, r12
moveOn
			dec 	r10
			jnz		loopDecr


            ret
```

##A Functionality

The objectives of A Functionality are below:

-In addition to B Functionality, you must decrypt the following message without knowledge of its key:

-There are many ways to attack this problem. Some techniques require substantially more CPU time than others. Some techniques 
can be done by hand. Take the time to think through your approach before you begin coding.

The nice thing about A Functionality is that we don't need to change the program we made for B Functionality... all we have
to do it do Frequency Analysis to find the correct answer.

First what I did is though of a couple of characters that might be common in the message. I used a space " " and a vowel "e".

I set the key in the program equal to these values and ran the program. I copy-pasted the results in byte form to an excel 
sheet and counted the number of times each byte appeared in the results from the two keys.

Once I had a count I inserted the value that came up the most for the Key and my results were characters that made sense for
every odd value in the message, which told me the key was two bytes long. For the second byte I inserted the value that 
appeared the second most when working with the space the the e. The results was a message that made sense to USAFA Cadets!


The Excel File used can be seen in the picture below:


![alt text](https://raw.githubusercontent.com/JarrodWooden/Lab2_Cryptography/master/ExcellTestFreq.PNG "Frequency Analysis")

The answer when I ran my program with the correct values for the key can be seen below:

![alt text](https://raw.githubusercontent.com/JarrodWooden/Lab2_Cryptography/master/A_FunctionalityMessage.PNG "A Functionality Results")




Documentation: Dr. York explained the idea of Frequency Analysis to me before I started working on A Functionality.



#Have a Great Air Force Day!
