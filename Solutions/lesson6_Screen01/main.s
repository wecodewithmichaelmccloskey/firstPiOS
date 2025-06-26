.section .init
.global _start
_start:
    b main

.section .text

main:
    mov sp,#0x8000

    // create frame buffer
    mov r0,#1024 // width
    mov r1,#768 // height
    mov r2,#16 // bit depth
    bl InitializeFrameBuffer

    // check if frame buffer returned
    teq r0,#0 // error if returns 0
    bne noError$

        // Turn on ACT LED if error
        mov r0,#47
        mov r1,#1
        bl SetGpioFunction
        mov r0,#47
        mov r1,#0
        bl SetGpio

        // end program if error
        error$:
            b error$

    // return is a frame buffer info address if not error
    noError$:
        fbInfoAddr .req r4
        mov fbInfoAddr,r0

        render$:
            fbAddr .req r3
            ldr fbAddr,[fbInfoAddr,#32]

            color .req r0
            y .req r1
            mov y,#768
            drawRow$:
                x .req r2
                mov x,#1024
                drawPixel$:
                    strh color,[fbAddr]
                    add fbAddr,#2
                    sub x,#1
                    teq x,#0
                    bne drawPixel$

                sub y,#1
                add color,#1
                teq y,#0
                bne drawRow$

            b render$

        .unreq fbAddr
        .unreq fbInfoAddr
