.section .init
.global _start
_start:

// Load the address of the GPIO controller in to register 0
// so that GPIO register addresses can be addressed relative
// to this address
ldr r0,=0x20200000

// Put GPIO 47 (ACT LED) into output mode
mov r1,#1 // 0b001 is output mode for any GPIO
lsl r1,#21 // GPIO 47 is at bits 23-21 in GPIO Function Select Register 4
str r1,[r0,#16] // Function Select Register 4 is at address 0x2020010

// Clear GPIO 47 (ACT LED) to turn it on
mov r1,#1 // 0b1 sets GPIO pins
lsl r1,#15 // GPIO 47 is at bit 15 in GPIO Output Clear Register 1
str r1,[r0,#44] // GPIO Clear Register 1 is at address 0x2020002C

// Infinite loop
loop$:
b loop$
