// Returns the address of the GPIO controller 
// so that GPIO register addresses can be addressed relative
// to this address
.globl GetGpioAddress
GetGpioAddress:
    ldr r0,=0x20200000 // Load the address of the GPIO controller into the return register
    mov pc,lr // branches back to where the function was called

// Sets a Gpio Pin to a specified function
// Inputs: r0 - Pin number, r1 - Function
.globl SetGpioFunction
SetGpioFunction:
    pinNum .req r0
    pinFunc .req r1

    // Check if inputs are valid
    cmp pinNum,#53 // Pin number <= 53
    cmpls pinFunc,#7 // Function <= 7
    movhi pc,lr // Returns if inputs are not valid

    // Gets GPIO controller address
    push {lr} // pushes lr onto the stack because lr will be updates when making the functions call
    mov r2,pinNum // moves r0 to r2 becuase r0 will be updated by the functions call
    .unreq pinNum
    pinNum .req r2
    bl GetGpioAddress // calls the GetGpioAddress Function
    gpioAddr .req r0

    // Determines the address of the GPIO Function Select Register for the specied pin and its
    // pin number relative to that Function select Register.
    // Each Function Select Register selects for 10 pins and addresses increase by 4 from the
    // GPIO controller address starting at the least significant pin.
    functionLoop$:
        cmp pinNum,#9 // checks if the relative pin number is valid (<= 9)
        subhi pinNum,#10 // if invalid subtract 10
        addhi gpioAddr,#4 // if invalid move to the next register
        bhi functionLoop$ // loop until relative pin number is valid
    add pinNum, pinNum,lsl #1 // mulitplication by 3 to get function select bit for relative pin number because each pin gets 3 bits to specify function

    // Shift pin function to correct bits for the pinNum
    lsl pinFunc,pinNum // shift function value to correct bit placement

    // Create mask
    mask .req r3
    mov mask,#7
    lsl mask,pinNum
    .unreq pinNum
    mvn mask,mask

    // use mask to delete existing function for the selected pin
    oldFunc .req r2
	ldr oldFunc,[gpioAddr] // load existing gpio functions
	and oldFunc,mask // use mask to delete existing function for the selected pin
	.unreq mask

    // set the determined function select register
	orr pinFunc,oldFunc // set the function bits for the selected pin
	.unreq oldFunc
    str pinFunc,[gpioAddr] // set the determined function select register
    .unreq pinFunc
    .unreq gpioAddr

    // Return
    pop {pc} // the lr was previously put onto the stack so we pop and put it into the pc to return

// Turns a GPIO pin on or off.
// Inputs: r0 - Pin number, r1 - on/off
.globl SetGpio
SetGpio:
    pinNum .req r0 // Sets an alias for r0
    pinVal .req r1 // Sets an alias for r1

    // check for valid input
    cmp pinNum,#53 // Invalid if pin number >53
    movhi pc,lr

    push {lr} // preserve lr before making another function call

    // preserve pinNum before making another function call
    mov r2,pinNum // save the value in unused r2
    .unreq pinNum // remove the alias from r0
    pinNum .req r2 // put the alias on r2

    // Get the gpio controller address
    bl GetGpioAddress
    gpioAddr .req r0 // give the gpio controller address an alias

    // Determine if the pin output set/clear is in register 0 or 1
    pinBank .req r3
    lsr pinBank,pinNum,#5 // Divide by 32 to determine register 0 or 1
    lsl pinBank,#2 // multiply by 4 to get relative address
    add gpioAddr,pinBank // add to gpioaddr to get address of set/clear register - 
    .unreq pinBank

    // Determine the relative pin number to the set/clear register
    and pinNum,#31 // remainder after dividing by 32
    setBit .req r3
    mov setBit,#1
    lsl setBit,pinNum // move a 1 into the position of the pin number
    .unreq pinNum

    // Sets the value in the set or clear register depending if the pin should be on or off
    teq pinVal,#0 // checks if the pinVal is 0 - off, or 1 - on
    .unreq pinVal
    streq setBit,[gpioAddr,#40] // if on use the clear register
    strne setBit,[gpioAddr,#28] // if off use the set register
    .unreq setBit
    .unreq gpioAddr

    // return
    pop {pc}
