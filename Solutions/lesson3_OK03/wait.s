.globl delay
delay:
    waitVal .req r0
    waitLoop$:
        sub waitVal,#1 // Subtract 1
        teq waitVal,#0 // Check if the value has become 0
        bne waitLoop$ // Repeat subtraction and check if not at 0 yet
    mov pc,lr
