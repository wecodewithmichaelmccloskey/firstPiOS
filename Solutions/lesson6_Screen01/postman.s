.globl GetMailboxBase
GetMailboxBase:
    ldr r0,=0x2000B880
    mov pc,lr

.globl MailboxWrite
MailboxWrite:
    // input validation
    tst r0,#0b1111 // lower 4 bits in message must be 0
    movne pc,lr
    cmp r1,#15 // channel can only by four bits
    movhi pc,lr

    // Get base address
    channel .req r1
    value .req r2
    mov value,r0
    push {lr}
    bl GetMailboxBase
    mailbox .req r0
        
    wait1$:
        // Load status
        status .req r3
        ldr status,[mailbox,#0x18]

        // check status, if busy retry
        tst status,#0x80000000
        .unreq status
        bne wait1$

    // combine channel and value
    add value,channel
    .unreq channel

    // store the result to the write field
    str value,[mailbox,#20]
    .unreq value
    .unreq mailbox
    pop {pc}

.globl MailboxRead
MailboxRead:
    // validate input
    cmp r0,#15 // channel can only by four bits
    movhi pc,lr

    // get base address
    channel .req r1
    mov channel,r0
    push {lr}
    bl GetMailboxBase
    mailbox .req r0

    rightmail$:
        wait2$:
            // load status
            status .req r2
            ldr status,[mailbox,#0x18]

            // check status
            tst status,0x40000000
            .unreq status
            bne wait2$
        
        // read from read field
        mail .req r2
        ldr mail,[mailbox,#0]

        // check if channel is correct
        ischan .req r3
        and inchan,mail,#0b1111
        teq inchan,channel
        .unreq inchan
        bne rightmail$
    .unreq mailbox
    .unreq channel

    and r0,mail,0xfffffff0
    .unreq mail
    pop {pc}