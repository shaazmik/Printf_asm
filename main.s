section .text

global _start

extern Printf, C_printf


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;
;       MAIN
;               LAUNCH
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


_start:

    mov rdi, Msg
    mov rsi, 5
    ;mov rdx, 8
    ;mov byte rcx, '!'
    ;mov r8, Kek
    ;mov r9, 3802
    ;push 255
    ;push 8
    ;push 100

    call  C_printf
    
;    mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
;    mov rdi, 1         ; stdout
;    mov rsi, Msg
;    mov rdx, MsgLen    ; strlen (Msg)
;    syscall

    mov rax, 0x3c ; exit (rdi)
    xor rdi, rdi
    syscall


section .data

;Msg        db "I love %x na %b%%%c I %s %x %d%%%c%b \n",00h
Msg         db "Hello world%d!\n",00h
MsgLen      equ $ - Msg
Kek        db "love",00h
