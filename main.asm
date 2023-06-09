.INCLUDE "tn26def.inc"
.LIST

; **** REGISTERS *************************************************

.DEF  PC_HISTORY  = r19

; **** LABLES ****************************************************

.EQU  LED_PORT    = PORTA
.EQU  LED_PIN     = PINA
.EQU  LED_0_PIN   = PA7
.EQU  LED_1_PIN   = PA6
.EQU  LED_2_PIN   = PA5

.EQU  SW_PORT     = PORTA
.EQU  SW_PIN      = PINA
.EQU  SW_0_PIN    = PA4
.EQU  SW_1_PIN    = PA3
.EQU  SW_2_PIN    = PA2

; **** CODE SEGMENT **********************************************

.CSEG

; **** VECTORS ***************************************************
.ORG 0x00

rjmp  RESET_vect

.ORG 0x02

rjmp PIN_CHANGE_vect

PIN_CHANGE_vect:
  push  r16
  push  r17
  in    r17, SREG

  in    r18, PINA
  eor   r18, PC_HISTORY
  in    PC_HISTORY, PINA

  _sw_0_check:
    sbrs    r18, SW_0_PIN
    rjmp    _sw_1_check
    rjmp    _sw_0_handler

  _sw_0_handler:
    rcall   DEBOUNCE_SW
    ldi     r16, LED_0_PIN
    sbis    SW_PIN, SW_0_PIN
    rcall   TOGGLE_LED
    rjmp    _sw_exit

  _sw_1_check:
    sbrs    r18, SW_1_PIN
    rjmp    _sw_2_check
    rjmp    _sw_1_handler

  _sw_1_handler:
    rcall   DEBOUNCE_SW
    ldi     r16, LED_1_PIN
    sbis    SW_PIN, SW_1_PIN
    rcall   TOGGLE_LED
    rjmp    _sw_exit

  _sw_2_check:
    sbrs    r18, SW_2_PIN
    rjmp    _sw_exit

  _sw_2_handler:
    rcall   DEBOUNCE_SW
    ldi     r16, LED_2_PIN
    sbis    SW_PIN, SW_2_PIN
    rcall   TOGGLE_LED

  _sw_exit:
    out   SREG, r17

  pop   r17
  pop   r16
reti

RESET_vect:
  ldi   r16,    RAMEND
  out   SP,     r16

MCU_INIT:
  ldi   r16,    (1<<LED_0_PIN) | (1<<LED_1_PIN) | (1<<LED_2_PIN) | (0<<SW_0_PIN) | (0<<SW_1_PIN) | (0<<SW_2_PIN)
  out   DDRA,   r16

  ldi   r16,    (1<<SW_0_PIN) | (1<<SW_1_PIN) | (1<<SW_2_PIN)
  out   PORTA,  r16

  ldi   r16,    (1<<PCIE0)
  out   GIMSK,  r16

  ldi   PC_HISTORY, 0xff

  sei

LOOP:
  nop
rjmp    LOOP

DEBOUNCE_SW:              ; FOR 1 MHz
  push    r16
  push    r17

  ldi     r17, 255
  _loop_0:
    ldi     r16, 150
    _dec_0:
    dec     r16
    brne    _dec_0
  _loop_1:
    dec     r17
    brne    _loop_0

  pop r17
  pop r16
ret

TOGGLE_LED:
  push  r16
  push  r17
  push  r18

  in    r17,    PINA

  mov   r18,    r16
  ldi   r16,    0x01
  _toggle_led_shift:
    lsl   r16
    dec   r18
    brne  _toggle_led_shift

  eor   r17,    r16
  out   PORTA,  r17
  
  pop   r18
  pop   r17
  pop   r16
ret