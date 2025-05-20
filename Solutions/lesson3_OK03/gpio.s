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
    // Check if inputs are valid
    cmp r0,#53 // Pin number <= 53
    cmpls r1,#7 // Function <= 7
    movhi pc,lr // Returns if inputs are not valid

    // Gets GPIO controller address
    push {lr} // pushes lr onto the stack because lr will be updates when making the functions call
    mov r2,r0 // moves r0 to r2 becuase r0 will be updated by the functions call
    bl GetGpioAddress // calls the GetGpioAddress Function

    // Determines the address of the GPIO Function Select Register for the specied pin and its
    // pin number relative to that Function select Register.
    // Each Function Select Register selects for 10 pins and addresses increase by 4 from the
    // GPIO controller address starting at the least significant pin.
    functionLoop$:
        comp r2,#9 // checks if the relative pin number is valid (<= 9)
        subhi r2,#10 // if invalid subtract 10
        addhi r0,#4 // if invalid move to the next register
        bhi functionLoop$ // loop until relative pin number is valid

    // Set the determined function select register with the specified function
    add r2, r2,lsl #1 // mulitplication by 3 to get function select bit for relative pin number because each pin gets 3 bits to specify function
// UPDATE ME!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    lsl rl, r2 // shift function value to correct bit placement
    str rl,[r0] // set the determined function select register

    // Return
    pop {pc} // the lr was previously put onto the stack so we pop and put it into the pc to return