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
;    Filename:	    Statistics.asm                                    *
;    Date:                                                            *
;    File Version:                                                    *
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


;***** Statistics subroutine variables
; Statst_struct Statistics(char Address_reg, char Length_reg); C code example, Stats_struct is an struct composed of Min_reg, Max_reg and Avg_reg.
Address_reg	EQU	0x20	;Bank0: 0x00 - 0x7F (128 registros), GPR: 0x20 - 0x7F, SFR: 0x00 - 0x1F (32 registros)
Length_reg	EQU	0x21	
Min_reg		EQU 0x22
Max_reg		EQU 0x23
Avg_reg		EQU 0x24
Current 	EQU 0x25
Gpr_0		EQU 0x26
w			EQU d'0'
f			EQU d'1'
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
	
	call	Statistics


loop
	goto	loop



; Statistics subroutine - begin
Statistics
	movf Address_reg,w
	movwf Current
	
	movf Current,w
	movwf FSR
	movf INDF,w
	movwf Min_reg
	movwf Max_reg
	movwf Avg_reg
	
	decfsz Length_reg,w
	goto Inner_loop
	return

Inner_loop	
	incf Current,f
	call Min_max
	
	movf Current,w
	movwf FSR
	movf INDF,w
	addwf Avg_reg,f

	movf Address_reg,w
	addwf Length_reg,w
	subwf Current,w
	btfss STATUS,C
	goto Inner_loop
	call AVG	
	return
; Statistics subroutine - end

; Min_max subroutine - begin
Min_max	
	movf Current,w
	movwf FSR
	movf INDF,w
	subwf Max_reg,w
	
	btfsc STATUS,C
	goto Min_max_0
	
	movf INDF,w
	movwf Max_reg
	return

Min_max_0
	movf INDF,w
	subwf Min_reg,w

	btfss STATUS,C
	return
	
	movf INDF,w
	movwf Min_reg
	return
	

; Min_max subroutine - end

; AVG subroutine - begin
AVG
	return
; AVG subroutine - end

	
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
	movlw	d'126'			; W <- d'120'
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

