.INCLUDE "tn26def.inc"
.LIST

; **** LABLES ****************************************************

.DEF  SW_FLAGS    = r20
.DEF  PC_HISTORY  = r19

.EQU  LED_PORT    = PA7
.EQU  SW_PORT     = PA6


; **** CODE SEGMENT **********************************************

.CSEG

; **** VECTORS ***************************************************
.ORG 0x00

rjmp  RESET_vect

.ORG 0x02

rjmp PIN_CHANGE_vect

PIN_CHANGE_vect:
  push  r17
  in    r17, SREG

  in r18, PINA
  eor r18, PC_HISTORY
  in PC_HISTORY, PINA

  sbrs  r18, SW_PORT
  rjmp  _sw_exit
  rjmp  _sw_0_handler

  _sw_0_handler:
  sbis  PINA, SW_PORT
  rcall TOGGLE_LED
  ; then exit

  _sw_exit:
  out   SREG, r17
  pop   r17
reti

RESET_vect:
  ldi   r16,    RAMEND
  out   SP,     r16


MCU_INIT:
  ldi   r16,    (1<<LED_PORT) | (0<<SW_PORT)
  out   DDRA,   r16

  ldi   r16,    (1<<SW_PORT)
  out   PORTA,  r16

  ; First, turn off comparator to enable pin change interrupt (only for tiny26l)
  ldi   r16,    (1<<ACD)
  out   ACSR,   r16

  ; Enable pin change interrupt
  ldi   r16,    (1<<PCIE1)
  out   GIMSK,  r16

  ldi   PC_HISTORY, 0xff

  sei

LOOP:
  nop
rjmp LOOP

delay:              ; FOR 1 MHz
  push r16
  push r17

  ldi r17, 255
    _loop_0:
      ldi r16, 100
      _dec_0:
      dec r16
      brne _dec_0
    _loop_1:
      dec r17
      brne _loop_0

  pop r17
  pop r16
ret

TOGGLE_LED:
  push  r16
  push  r17

  in    r17,    PINA

  ldi   r16,    (1<<LED_PORT)
  eor   r17,    r16
  out   PORTA,  r17
  
  pop   r17
  pop   r16
ret
