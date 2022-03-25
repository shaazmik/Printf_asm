section .text

global _start

extern C_printf


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;
;       MAIN
;               LAUNCH
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


_start:

    mov rdi, Msg
    mov rsi, 5

    call  C_printf

    mov rax, 0x3c ; exit (rdi)
    xor rdi, rdi
    syscall


section .data

;Msg        db "I love %x na %b%%%c I %s %x %d%%%c%b \n",00h
Msg         db "Hello world%d!\n",00h
Kek         db "love",00h
