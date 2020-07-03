/** @file uartloop.S
 *  @brief UART Loopback Program
 *
 * Test UART loopback
 * Echo what is sent to the UART to the output
 * The input is also displayed on the LCD text terminal
 *
 * This file must be processed using cpp before assembly.
 */

/* Copyright (C) 2007-2011 the NxOS developers
 *
 * See AUTHORS for a full list of the developers.
 *
 * Redistribution of this file is permitted under
 * the terms of the GNU Public License (GPL) version 2.
 */

#define __ASSEMBLY__
#include "base/interwork.h"
#include "base/debug_stub.h"
#include "base/lib/scaffolding/scaffolding.h"
#include "base/boards/DE1-SoC/address_map_arm.h"


/* Reference C functions which do not have ASM headers */
	.extern nx_uart_read_avail
	.extern nx_uart_write_avail
	.extern	nx_uart_getchar
	.extern nx_uart_putchar
	.extern nx_uart_readbuf
	.extern nx_uart_writebuf
	.equ	UART_RXBUFSIZE, 64

#define ESC_CHAR	0x1B			/**< Escape Character ASCII value */

#define USE_BUFFEREDIO				/* Use buffered reads/writes instead of character read/write */

/* To disable Manual Breakpoints, change the following to #undef ENABLE_BREAKPOINTS */
#define ENABLE_BREAKPOINTS

	.extern	nx_systick_wait_ms

	.equ	SYSTICK_1500MS, 1500
	.equ	SYSTICK_1000MS, 1000
	.equ	SYSTICK_500MS, 500
	.equ	LOOPCNT, 3

.data
.align 4


#ifdef USE_BUFFEREDIO

buflen:  .word 0
charbuf: .space UART_RXBUFSIZE, 0

#endif

title:	 .asciz "Morse Code Trainer\n"
prompt:	 .asciz "Type into the UART panel\n" //\nESC to exit\n

bye:	 .asciz "\nGoodbye!\n"
uartchr: .asciz "_"				// dummy string for output

.code 32
.text
.align 	4


// WARNING: Don't put any routines here between the .text and the main: label.
// CPUlator will point the starting PC to the beginning of the .text section and start executing from there.

/** main
 *    Main Program
 */
	.global	main
main:
/* Needed to support CPUlator system init
 * since it starts execution from main() and does not go through the system reset handler
 */
#include "cpulator_stub.inc"

	push	{r4-r12,lr}			// Preserve all AAPCS registers to avoid CPUlator warnings.

	bl		nx_proginit

	ldr		r4, =title
	//bl		nx_progtitle
	mov		r0, r4
	mov		r1, #19
	bl		nx_uart_writebuf

#ifdef __CPULATOR__
	// Allow CPUlator to execute ISR before hitting the breakpoint
	mov		r0, #SYSTICK_500MS
	bl		nx_systick_wait_ms
#endif

#ifdef ENABLE_BREAKPOINTS
	dbg__bkpt_arm
#else
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
#endif

break:
	nop		/* Provide GDB with a safe instruction to breakpoint at */

/********************* Begin Customization Here *********************/

	ldr		r4, =prompt				/*doesn't do anything*/
	mov		r0, r4
	mov		r1, #26

	bl		nx_uart_writebuf

	mov		r0, #SYSTICK_500MS		/* Wait 500 ms */
	bl		nx_systick_wait_ms


loop:
	bl		nx_uart_getchar			/* get input from UART */
	mov		r4, r0					/* keep for LCD display */

// Input is in r0

// place values in register
	mov     r5 , #97 		/* ASCII for 'a'*/
	mov     r8, #065        /* ASCII for 'A'*/



// Check for top row symbolss
	cmp     r0,#33
	bleq    loop
	cmp     r0,#64
	bleq    loop
	cmp     r0,#35
	bleq    loop
	cmp     r0,#36
	bleq    loop
	cmp     r0,#37
	bleq    loop
	cmp     r0,#94
	bleq    loop
	cmp     r0,#38
	bleq    loop
	cmp     r0,#42
	bleq    loop
	cmp     r0,#40
	bleq    loop
	cmp     r0,#41
	bleq    loop
	cmp     r0,#43
	bleq    loop
	cmp     r0,#45
	bleq    loop
	cmp     r0,#46
	bleq    loop
	cmp     r0,#47
	bleq    loop
	cmp     r0,#34
	bleq    loop
	cmp     r0,#61
	bleq    loop
// end

//Other symbols

	cmp     r0,#58
	bleq    loop
	cmp     r0,#59
	bleq    loop
	cmp     r0,#60
	bleq    loop
	cmp     r0,#62
	bleq    loop
	cmp     r0,#63
	bleq    loop
	cmp     r0,#91
	bleq    loop
	cmp     r0,#92
	bleq    loop
	cmp     r0,#93
	bleq    loop
	cmp     r0,#95
	bleq    loop
	cmp     r0,#96
	bleq    loop
	cmp     r0,#123
	bleq    loop
	cmp     r0,#124
	bleq    loop
	cmp     r0,#125
	bleq    loop
	cmp     r0,#126
	bleq    loop


	cmp		r0, #ESC_CHAR			/* exit? */
	beq		exit_loop



/*Check alphabets */

	cmp     r0 ,r5 					/*Check if slowercase a condition*/
	ittt     ge                      /*Condition if greater than or equal to 'a' */
	subge   r0 , r0 , #32   		/*Subtract if lowercase detected*/
	movge  r8,r0                     // Move reigster value of r0 to r8 for later cmp
	bl	nx_uart_putchar			    /* echo it to th UART */

	cmp  	r8, #0x20 			 	/*Check if input='5'*/
	bleq    loop

// Tone generation

// Compare input value of ascii to its hex counterpart

// num check start
	cmp  	r8, #0x35 			 	/*Check if input='5'*/
	bleq    sound_5

	cmp  	r8, #0x30 			 	/*Check if input='0'*/
	bleq    sound_0

	cmp  	r8, #0x31 			 	/*Check if input='1'*/
	bleq    sound_1

	cmp  	r8, #0x32 			 	/*Check if input='2'*/
	bleq    sound_2

	cmp  	r8, #0x33 				/*Check if input='3'*/
	bleq    sound_3

	cmp  	r8, #0x34 			 	/*Check if input='4'*/
	bleq    sound_4

	cmp  	r8, #0x36  			 	/*Check if input='6'*/
	bleq    sound_6

	cmp  	r8, #0x37  			 	/*Check if input='7'*/
	bleq    sound_7

	cmp  	r8, #0x38 	 			 /*Check if input='8'*/
	bleq    sound_8

	cmp  	r8, #0x39 			  	/*Check if input='9'*/
	bleq    sound_9

// num check end

//alphabet  check start start
	cmp  r8 , #0x41 			     /*Check if input='A'*/
	bleq  sound_a


	cmp  r8, #0x42 			    	 /*Check if input='B'*/
	bleq    sound_b

	cmp  r8, #0x43 			     	/*Check if input='C'*/
	bleq    sound_c

	cmp  r8 , #0x44 			 	/*Check if input='D'*/
	bleq    sound_d

	cmp  r8 , #0x45 			 	/*Check if input='E'*/
	bleq    sound_e

	cmp  	r8, #0x46 			 	/*Check if input='F'*/
	bleq    sound_f

	cmp  	r8, #0x47  			 	/*Check if input='G'*/
	bleq    sound_g

	cmp  	r8, #0x48  			 	/*Check if input='H'*/
	bleq    sound_h

	cmp  	r8, #0x49 	 			/*Check if input='I'*/
	bleq    sound_i

	cmp  	r8, #0x4a  			 	/*Check if input='J'*/
	bleq    sound_j

	cmp  	r8, #0x4b 			 	/*Check if input='K'*/
	bleq    sound_k

	cmp  	r8, #0x4c 	 			 /*Check if input='L'*/
	bleq    sound_l

	cmp  	r8, #0x4d 			 	/*Check if input='M'*/
	bleq    sound_m

	cmp  	r8, #0x4e 			  	/*Check if input='N'*/
	bleq    sound_n

	cmp  	r8, #0x4f 			 /*Check if input='O'*/
	bleq    sound_o

	cmp  	r8, #0x50 			 /*Check if input='P'*/
	bleq    sound_p

	cmp  	r8, #0x51 			 /*Check if input='Q'*/
	bleq    sound_q

	cmp  	r8, #0x52 			 /*Check if input='R'*/
	bleq    sound_r

	cmp  	r8, #0x53 			 /*Check if input='S'*/
	bleq    sound_s

	cmp  	r8, #0x54 			/*Check if input='T'*/
	bleq    sound_t

	cmp  	r8, #0x55 			 /*Check if input='U'*/
	bleq    sound_u

	cmp  	r8, #0x56 			 /*Check if input='V'*/
	bleq    sound_v

	cmp  	r8, #0x57 			 /*Check if input='V'*/
	bleq    sound_w

	cmp  	r8, #0x58 			/*Check if input='X'*/
	bleq    sound_x

	cmp  	r8, #0x59 			 /*Check if input='Y'*/
	bleq    sound_y

	cmp  	r8, #0x5a 			 /*Check if input='Z'*/
	bleq    sound_z

echo_display:
	ldr		r0, =uartchr
	strb	r4, [r0]				/* setup display string (char) */
	bl		nx_display_string		/* Display it on the LCD */
	cmp		r4, #ESC_CHAR			/* exit? */
	bne		loop


// Single beep for dot
single_beep:
	LDR   r0, =500
	LDR   r1 ,=350
    b    nx_sound_freq

// Longer beep for dash
dash_beep:
	LDR   r0, =500
	LDR   r1 ,=1000
    b    nx_sound_freq



// Tone unit silence added to every letter after sound completition


// R7 will be used for LED
// R10 to load correspinding LED value

sound_a:

	bl  single_beep

	ldr  	r7, =0xff200000
	mov     r10, #0xb8000000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl  	dash_beep

// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_b:


	bl    dash_beep
	ldr  	r7, =0xff200000
	ldr     r10, =#0xea800000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    single_beep
	mov		r0, #SYSTICK_500MS
	bl		nx_systick_wait_ms
	bl    single_beep
	mov		r0, #SYSTICK_500MS
	bl		nx_systick_wait_ms
	bl    single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop


// Single dot beep sound start
sound_e:

	bl    	single_beep

	ldr  	r7, =0xff200000
	mov     r10, #0x80000000
	str     r10,[r7]

// 3units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_i:

	bl    	single_beep
	ldr  	r7, =0xff200000
	mov     r10, #0xa0000000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_s:

	bl    	single_beep
	ldr  	r7, =0xff200000
	mov     r10, #0xa8000000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop


sound_h:

	bl    	single_beep
	ldr  	r7, =0xff200000
	mov     r10, #0xaa000000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop


// Dash beep sound start

sound_t:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep
	ldr  	r7, =0xff200000
	mov     r10, #0xe0000000
	str     r10,[r7]

// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_m:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep
	ldr  	r7, =0xff200000
	mov     r10, #0xee000000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_o:

    ldr  	r7, =0xff200000
	ldr     r10, =#0xEEE00000
	str     r10,[r7]
	bl    	dash_beep

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop


// dash beep sound end

// three sound combo start

sound_d:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep
	ldr  	r7, =0xff200000
	mov     r10, #0xea000000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_g:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xee800000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b	loop

sound_k:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeb800000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_r:
                    /*Condition if greater than or equal to 'a' */
	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xba000000
	str     r10,[r7]

	ldr  	r7, =0xff200000
	mov     r10, #0xba00000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_u:
                    /*Condition if greater than or equal to 'a' */
	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xae000000
	str     r10,[r7]

	ldr  	r7, =0xff200000
	mov     r10, #0xae00000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b		loop

sound_w:
                    /*Condition if greater than or equal to 'a' */
	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xbb800000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b		loop

// three combo beep end



// num beeps sounds


sound_0:

	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr		r8, =0xeeeee000
	str     r8, [r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

    b		loop


sound_1:

	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xbbbb8000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_2:

	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xaeee0000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b	loop


sound_3:

	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xabb80000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_4:

	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xaae00000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b		loop

sound_5:

	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xaa800000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b		loop

sound_6:

	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeaa00000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_7:

	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeea80000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b	loop

sound_8:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeeea0000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_9:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeeee8000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms

	b	loop

// num end



sound_y:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xebb80000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop


sound_x:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep
	ldr  	r7, =0xff200000
	ldr     r10, =#0xeae00000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_z:
                    /*Condition if greater than or equal to 'a' */
	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeea00000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_v:
                    /*Condition if greater than or equal to 'a' */
	bl    	single_beep
	ldr  	r7, =0xff200000
	ldr     r10, =#0xab800000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_f:

	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xae800000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_c:

	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeba00000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_q:

	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xeeb80000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_p:
                    /*Condition if greater than or equal to 'a' */
	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xbba00000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_n:

	bl    	dash_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xea000000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_j:
                    /*Condition if greater than or equal to 'a' */
	bl    	single_beep

	ldr  	r7, =0xff200000
	ldr     r10, =#0xbbb80000
	str     r10,[r7]

	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

sound_l:
                    /*Condition if greater than or equal to 'a' */
	bl    	single_beep
	ldr  	r7, =0xff200000
	ldr     r10, =#0xba800000
	str     r10,[r7]
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	dash_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	bl    	single_beep

	// 3 units of silence
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	mov		r0, #SYSTICK_1000MS
	bl		nx_systick_wait_ms
	b	loop

exit_loop:
	ldr		r4, =bye
	mov		r0, r4
	mov		r1, #12
	bl		nx_uart_writebuf

/********************** End Customization Here **********************/
exit_main:
	bl		nx_progshutdown
	pop		{r4-r12,pc}			// Restore all AAPCS registers to avoid CPUlator warnings.


.end
