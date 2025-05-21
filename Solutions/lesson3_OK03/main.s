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
    pinFunc .req r5
    mov pinFunc,#1 // 0b001 is output mode
    pinVal .req r6
    mov pinVal,#0 // 0 sets pin to off, turning on led
    waitVal .req r7
    mov waitVal,#0x3F0000 // Large number that will take some real world time to subtract 1 to get to 0

    // Sets led pin to output mode
    mov r0,pinNum
    mov r1,pinFunc
    bl SetGpioFunction

    // Infinite loop
    loop$:
        // toggles between on and off
        mvn pinVal,pinVal

        // Sets to the pin to on or off based on pinVal
        mov r0,pinNum
        mov r1,pinVal
        bl SetGpio

        // Wait
        mov r0,waitVal
        bl delay

        b loop$
