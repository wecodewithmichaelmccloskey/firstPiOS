.section .init
.global _start
_start:
    b main

.section .text

main:
    mov sp,#0x8000

    // Sets led pin to output mode
    pinNum .req r0
    pinFunc .req r1
    mov pinNum,#47 // 47 is led pin
    mov pinFunc,#1 // 0b001 is output mode
    bl SetGpioFunction
    .unreq pinNum
    .unreq pinFunc

    // Turns led pin on
    pinNum .req r0
    pinVal .req r1
    mov pinNum,#47 // 47 is led pin
    mov pinVal,#0 // 0 sets pin to off, turning on led
    bl SetGpio
    .unreq pinNum
    .unreq pinVal

    // Infinite loop
    loop$:
    b loop$
