; Encender un LED
    
    LIST P = 18F4550
    INCLUDE <P18F4550.INC>
    
	CONFIG FOSC = INTOSCIO_EC ;Osc interno. RA6 como pin,
  
;	    Bits de configuración más usados
	CONFIG PWRT	= ON	
	CONFIG BOR	= OFF
	CONFIG WDT	= OFF
	CONFIG MCLRE	= ON
	CONFIG PBADEN	= OFF
	CONFIG LVP	= OFF
	CONFIG DEBUG	= OFF
	CONFIG XINST	= OFF
	
;	    Bits de protección
	CONFIG CP0 = OFF
	CONFIG CP1 = OFF
	CONFIG CPB = OFF
	
;	    Definición de variables
	CBLOCK 0x00
	CANT_MS:2	;Variable para generar 65535 ms
	STATUS_TEMP	;Variable clon para el STATUS
	WREG_TEMP	;Variable clon para el WREG
	ENDC
	
;	    Vector de Reset
	ORG	0x0000
	goto	INICIO
	
; Vector de interrupción de baja prioridad y rutina
	ORG	0x0018
	goto INICIO
	
; Subrutina que configura la base de tiempo del MCU
CONF_BASE_TIEMPO
	 movlw	B'01100010'
	 movwf	OSCCON		;Oscilador interno a 4 MHz
	 return

;Subrutina que configura todo el puerto B
;como puerto de salida y deshabilita comparadores
CONF_PUERTOB
	 clrf LATB, 0
	 movlw 0Fh
	 movwf ADCON1, 0
	 clrf TRISB, 0
	 movlw 0x04
	 movwf LATB, 0
	 return
ROTADER
	rrncf	LATB, f, .0
	movff	STATUS, STATUS_TEMP
	movff	WREG, WREG_TEMP
	rcall	RETARDO_MEDIO_SEG
	movff	STATUS_TEMP, STATUS
	movff	WREG_TEMP, WREG
	return
	
RETARDO_MEDIO_SEG
	movlw	0x03
	movwf	CANT_MS+1, .0
	movlw	0xE8
	movwf	CANT_MS, .0
	RCALL	RETARDO_VAR_MS
	return
	
RETARDO_VAR_MS
	rcall	RETARDO_UN_MS
	decfsz	CANT_MS, F, .0
	bra	RETARDO_VAR_MS
	movf	CANT_MS+1, W, .0
	btfsc	STATUS, Z
	return
	decf	CANT_MS+1, F, .0
	bra	RETARDO_VAR_MS
	
RETARDO_UN_MS
	movlw		.249
OTRO
	addlw	0xFF
	btfss	STATUS, Z, .0
	bra	OTRO
	return
	
INICIO
	call	CONF_BASE_TIEMPO
	call	CONF_PUERTOB
AGAIN	
	call	ROTADER
	bra	AGAIN
	
	END