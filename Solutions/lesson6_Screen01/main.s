.section .init
.global _start
_start:
    b main

.section .text

main:
    mov sp,#0x8000

    