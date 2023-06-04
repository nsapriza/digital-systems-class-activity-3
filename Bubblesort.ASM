;**********************************************************************
;   This file is a basic code template for assembly code generation   *
;   on the PIC16F877A. This file contains the basic code              *
;   building blocks to build upon.                                    *  
;                                                                     *
;   Refer to the MPASM User's Guide for additional information on     *
;   features of the assembler (Document DS33014).                     *
;                                                                     *
;   Refer to the respective PIC data sheet for additional             *
;   information on the instruction set.                               *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Filename:	    Bubblesort.asm                                    *
;    Date:          03/06/2023                                                  *
;    File Version:  1                                                  *
;                                                                     *
;    Author:        Grupo xx				                          *
;    Company:       Sistemas Digitales II				              *
;                                                                     * 
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files Required: P16F877A.INC                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


	list		p=16f877A	; list directive to define processor
	#include	<p16f877A.inc>	; processor specific variable definitions
	
	__CONFIG _CP_OFF & _WDT_OFF & _BODEN_OFF & _PWRTE_OFF & _HS_OSC & _WRT_OFF & _LVP_OFF & _CPD_OFF

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.



;***** VARIABLE DEFINITIONS
w_temp		EQU	0x7D		; variable used for context saving 
status_temp	EQU	0x7E		; variable used for context saving
pclath_temp	EQU	0x7F		; variable used for context saving			


;***** Bubblesort subroutine variables
; void Bubblesort (char Address_reg, char Length_reg); C code example
Address_reg	EQU	0x20	;Bank0: 0x00 - 0x7F (128 registros), GPR: 0x20 - 0x7F, SFR: 0x00 - 0x1F (32 registros)
Length_reg	EQU	0x21
Counter		EQU 0x22	
i			EQU 0x23
f			EQU d'1'
w			EQU d'0'
Flag		EQU 0x24	;1 = true and 0 = false
Current		EQU 0x25
Swap_a		EQU 0x26
Swap_b		EQU 0x27
Swap_reg_a	EQU 0x28
Swap_reg_b	EQU 0x29
gpr0		EQU 0x2A

;**********************************************************************
	ORG     0x000           ; processor reset vector

	nop			  			; nop required for icd
  	goto    main            ; go to beginning of program


	ORG     0x004           ; interrupt vector location

	movwf   w_temp          ; save off current W register contents
	movf	STATUS,w        ; move status register into W register
	movwf	status_temp     ; save off contents of STATUS register
	movf	PCLATH,w	  	; move pclath register into w register
	movwf	pclath_temp	  	; save off contents of PCLATH register

; isr code can go here or be located as a call subroutine elsewhere

	movf	pclath_temp,w	; retrieve copy of PCLATH register
	movwf	PCLATH		  	; restore pre-isr PCLATH register contents
	movf    status_temp,w   ; retrieve copy of STATUS register
	movwf	STATUS          ; restore pre-isr STATUS register contents
	swapf   w_temp,f
	swapf   w_temp,w        ; restore pre-isr W register contents
	retfie                  ; return from interrupt



main

;	call	Load_TestVector0
	call	Load_TestVector1
;	call	Load_TestVector2

	call	Bubblesort


loop
	goto	loop


; Bubblesort subroutine - begin
Bubblesort
	;set "not done" flag to true
	bcf Flag, 0 	;clear flag
	bsf Flag, 0 	;set flag to true
Whileloop
	;subroutine termination check
	btfss Flag, 0	;bit test flag at bit 0, skip if set
	return			;flag is false -> list is sorted -> return
	
	;set counter to array length - 1
	movf  Length_reg, w ;Length -> W
	movwf Counter		;W -> Counter
	decf Counter,f		;set Counter to Counter -1

	;set i to 1
	clrf i				;clear i
	incf i,f				;set i to i + 1

Forloop	
	goto i_is_at_Length_reg ;check if i is at array Length -1
i_is_at_less_Length_reg
	;set Current to array value at position array start + i 
	movf Address_reg,w	;Address_reg -> W
	addwf i,w   		;add i to W
	movwf FSR			;W -> FSR
	movf INDF,w			;(first vector + i) value -> W
	movwf Current 		;W -> Current

	;set W to array value at position array start + i -1
	movf Address_reg,w	;Address_reg -> W
	addwf i,w   		;add i to w
	movwf FSR			;W -> FSR
	decf FSR,f			;subtract 1 from FSR
	movf INDF,w			;(first vector - 1) value -> W
	
	;test if Current > W
	subwf Current, f	;subtract w from Current
	btfss Current, 7	;test MSB, skip if Current is +
	goto Decrement_counter
	
	;swap Current and W																			(needs work)
	movf Address_reg,w	;Address_reg -> W
	addwf i,w   		;add i to W
	movwf Swap_a		;W -> Swap_a	
	movf Address_reg,w	;Address_reg -> W
	addwf i,w   		;add i to w	
	movwf Swap_b		;W -> Swap_b
	decf Swap_b,f		;decriment Swap_b	
	call Swap_a_and_b	;call subroutine SwapAB
	incf i,f			;set i to i + 1
	goto Forloop


	
Decrement_counter
	incf i,f			;set i to i + 1
	decfsz Counter,f	;decrement Counter 
	goto Forloop		;if Counter is 0 go to Forloop
	goto fail			;else go to faill

fail
	bcf Flag,0			;set "not done" flag to false
	goto Whileloop		;go to Whileloop to terminate subroutine

i_is_at_Length_reg
	;set gpr to Length_reg
	movf Length_reg,w	
	movwf gpr0		
	;decf gpr0,f
	
	;subtract i from gpr0
	movf i,w		
	subwf gpr0,f	
	
	;test if gpr0 is clear
	btfsc gpr0,0																;(needs work) (can change to add1 decfsz)
	goto i_is_at_less_Length_reg			
	btfsc gpr0,1	
	goto i_is_at_less_Length_reg			
	btfsc gpr0,2	
	goto i_is_at_less_Length_reg			
	btfsc gpr0,3	
	goto i_is_at_less_Length_reg			
	btfsc gpr0,4
	goto i_is_at_less_Length_reg
	btfsc gpr0,5
	goto i_is_at_less_Length_reg
	btfsc gpr0,6
	goto i_is_at_less_Length_reg
	btfsc gpr0,7
	goto i_is_at_less_Length_reg
	goto Whileloop
; Bubblesort subroutine - end

;swap subroutine - start
Swap_a_and_b
	movf Swap_a,w		; Swap_a -> W
	movwf FSR			; W -> FSR
	movf INDF,w			; Swap_a value -> W
	movwf Swap_reg_a	; W -> Swap_reg
	movf Swap_b,w
	movwf FSR
	movf INDF,w
	movwf Swap_reg_b
	movf Swap_reg_a,w
	movwf INDF
	movf Swap_a,w		; Swap_a -> W
	movwf FSR			; W -> FSR
	movf Swap_reg_b,w
	movwf INDF
	return


; Load TestVector0 - begin
Load_TestVector0
	movlw	d'1'			; W <- d'1'
	movwf	0x40			; (0x40) <- W
	movlw	d'23'			; W <- d'23'
	movwf	0x41			; (0x41) <- W
	movlw	d'42'			; W <- d'42'
	movwf	0x42			; (0x42) <- W
	movlw	d'0'			; W <- d'0'
	movwf	0x43			; (0x43) <- W
	movlw	d'77'			; W <- d'77'
	movwf	0x44			; (0x44) <- W
	movlw	d'39'			; W <- d'39'
	movwf	0x45			; (0x45) <- W
	movlw	d'120'			; W <- d'120'
	movwf	0x46			; (0x46) <- W
	movlw	d'127'			; W <- d'127'
	movwf	0x47			; (0x47) <- W

	movlw	0x40			; Address_reg is loadad with the address where the first data is positioned
	movwf	Address_reg
	movlw	d'8'			; Length_reg is loaded with the legnth of data
	movwf	Length_reg

	return
; Load TestVector0 - end


; Load TestVector1 - begin
Load_TestVector1
	movlw	d'1'			; W <- d'1'
	movwf	0x40			; (0x40) <- W
	movlw	d'23'			; W <- d'23'
	movwf	0x41			; (0x41) <- W
	movlw	d'42'			; W <- d'42'
	movwf	0x42			; (0x42) <- W
	movlw	d'0'			; W <- d'0'
	movwf	0x43			; (0x43) <- W
	movlw	d'70'			; W <- d'77'
	movwf	0x44			; (0x44) <- W
	movlw	d'39'			; W <- d'39'
	movwf	0x45			; (0x45) <- W
	movlw	d'120'			; W <- d'120'
	movwf	0x46			; (0x46) <- W
	movlw	d'127'			; W <- d'127'
	movwf	0x47			; (0x47) <- W
	movlw	d'15'			; W <- d'15'
	movwf	0x48			; (0x48) <- W
	movlw	d'93'			; W <- d'93'
	movwf	0x49			; (0x49) <- W
	movlw	d'14'			; W <- d'14'
	movwf	0x4A			; (0x4A) <- W
	movlw	d'70'			; W <- d'70'
	movwf	0x4B			; (0x4B) <- W
	movlw	d'85'			; W <- d'85'
	movwf	0x4C			; (0x4C) <- W
	movlw	d'15'			; W <- d'15'
	movwf	0x4D			; (0x4D) <- W
	movlw	d'32'			; W <- d'32'
	movwf	0x4E			; (0x4E) <- W
	movlw	d'120'			; W <- d'120'
	movwf	0x4F			; (0x4F) <- W

	movlw	0x40			; Address_reg is loadad with the address where the first data is positioned
	movwf	Address_reg
	movlw	d'16'			; Length_reg is loaded with the legnth of data
	movwf	Length_reg

	return
; Load TestVector1 - end


; Load TestVector2 - begin
Load_TestVector2
	movlw	d'32'			; W <- d'32'
	movwf	0x40			; (0x40) <- W

	movlw	0x40			; Address_reg is loadad with the address where the first data is positioned
	movwf	Address_reg
	movlw	d'1'			; Length_reg is loaded with the legnth of data
	movwf	Length_reg

	return
; Load TestVector2 - end

	END                       ; directive 'end of program'

