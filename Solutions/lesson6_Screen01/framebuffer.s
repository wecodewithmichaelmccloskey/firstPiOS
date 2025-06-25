.section .data
.align 4
.globl FrameBufferInfo
FrameBufferInfo:
    .int 1024 /* #0 Physical Width */
    .int 768 /* #4 Physical Height */
    .int 1024 /* #8 Virtual Width */
    .int 768 /* #12 Virtual Height */
    .int 0 /* #16 GPU - Pitch */
    .int 16 /* #20 Bit Depth */
    .int 0 /* #24 X */
    .int 0 /* #28 Y */
    .int 0 /* #32 GPU - Pointer */
    .int 0 /* #36 GPU - Size */

.section .text
.globl InitializeFrameBuffer
InitializeFrameBuffer:

    // Validate inputs
    width .req r0
    height .req r1
    bitDepth .req r2
    cmp width,#4096 // width must be less than 4096
    cmpls height,#4096 // height must be less than 4096
    cmpls bitDepth,#32 // bit depth must be less than 32

    // Invalid inputs
    result .req r0
    movhi result,#0
    movhi pc,lr

    // Write to Frame Buffer
    fbInfoAddr .req r3
    push {lr}
    ldr fbInfoAddr,=FrameBufferInfo
    str width,[fbInfoAddr,#0] // physical width
    str height,[fbInfoAddr,#4] // physical height
    str width,[fbInfoAddr,#8] // virtual width
    str height,[fbInfoAddr,#12] // vitual height
    str bitDepth,[fbInfoAddr,#20] // bit depth
    .unreq width
    .unreq height
    .unreq bitDepth

    // Send framebuffer info address to gpu
    mov r0,fbInfoAddr
    add r0,#0x40000000
    mov r1,#1
    bl MailboxWrite

    // Read the reply
    mov r0,#1
    bl MailboxRead

    // check if the reply is 0 (successful), returns 0 if not (unsuccessful)
    teq result,#0
    movne result,#0
    popne {pc}

    // return the fram buffer info address if successful
    mov result,fbInfoAddr
    pop {pc}
    .unreq result
    .unreq fbInfoAddr
