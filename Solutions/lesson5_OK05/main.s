.section .init
.global _start
_start:
    b main

.section .text

main:
    mov sp,#0x8000

    // Set up variables
    pinNum .req r4
    mov pinNum,#47 // 47 is led pin
    waitVal .req r5
    ldr waitVal,=250000 // time to wait in microseconds
    ptrn .req r6
    ldr ptrn,=pattern
    ldr ptrn,[ptrn] // Load pattern
    seq .req r7
    mov seq,#0 // Start at 0th bit of sequence
    pinVal .req r8 // pinVal will be determined by the pattern 

    // Sets led pin to output mode
    pinFunc .req r9
    mov pinFunc,#1 // 0b001 is output mode
    mov r0,pinNum
    mov r1,pinFunc
    bl SetGpioFunction
    .unreq pinFunc

    // Infinite loop
    loop$:
        // set pinVal based on sequence number and pattern
        mov pinVal,#1
        lsl pinVal,seq
        and pinVal,ptrn

        // Sets to the pin to on or off based on pinVal
        mov r0,pinNum
        mov r1,pinVal
        bl SetGpio

        // Wait
        mov r0,waitVal
        bl delay

        // Get next sequence number
        add seq,#1
        and seq,#0b11111

        b loop$

.section .data
.align 2
pattern:
    .int 0b11111111101010100010001000101010 // read in reverse order, 0 is on, 1 is off
