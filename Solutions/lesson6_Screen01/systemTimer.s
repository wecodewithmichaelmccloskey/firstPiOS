// Returns the base address of the System Timer
// so that Timer and comparison registers can be addressed relative
// to this address
.global getSystemTimerBase
getSystemTimerBase:
    systemTimerBase .req r0
    ldr systemTimerBase,=0x20003000 // Load the base address of the system timer into the return register
    .unreq systemTimerBase
    mov pc,lr // branches back to where the function was called

.global getTimeStamp
getTimeStamp:
    systemTimerBase .req r2
    push {lr}
    bl getSystemTimerBase
    mov systemTimerBase,r0

    counterHigh .req r1
    counterLow .req r0
    ldrd r0,r1,[systemTimerBase,#4]
    .unreq counterHigh
    .unreq counterLow

    pop {pc}

.globl delay
delay:
    waitVal .req r3
    mov waitVal,r0

    counterLow .req r0
    push {lr}
    bl getTimeStamp
    
    add waitVal,waitVal,counterLow

    waitLoop$:
        bl getTimeStamp
        cmp counterLow,waitVal
        bls waitLoop$
    
    .unreq waitVal
    .unreq counterLow
    pop {pc}
