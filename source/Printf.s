global Printf, C_printf


extern itoa, itoa10, printf

EOL  equ 00

;================================================
section .text

Msg1 db "Y",0x0a

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;Print str RSI buffer in cmd 
;Input: RSI - str buffer
;Dest:RDI, RDX, RSI
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;------------------------------------------------

Print_in_cmd:
        push rax

        mov rax, 0x01      ; write64 (rdi, rsi, rdx) ... r10, r8, r9
        sub rdi, out_buffer
        mov rdx, rdi       ; len of buffer
        mov rdi, 1         ; stdout
        mov rsi, out_buffer        
        
        syscall
        
        pop rax
        ret

;------------------------------------------------



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;Translate System V AMD 64 calling convention into
;cdecl calling convention for Printf function
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;------------------------------------------------
C_printf:
        pop rax         ; save return address
        mov [retr_addr], rax

        push r9         ;
        push r8         ;
        push rcx        ; save args in stack
        push rdx        ;
        push rsi        ;
        push rdi        ;

        push rbp
        mov  rbp, rsp ; stack frame

        call Printf

        pop rbp

        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9

        xor rax, rax   ; number of float params for standart C Printf func

        call printf

        push qword [retr_addr]

        ret
;------------------------------------------------



;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;
;  Prints a string according to the format
;  Upgrading C Printf function
;  CDECL - argument passing and naming convention
;
;  Input:
;       rsi - format string (address)
;       out_buffer - buffer print into before writing to screen
;       stack - arguments
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;------------------------------------------------

Printf:
        push rbx
        
        mov rsi, [rbp + 8]

        xor rbx, rbx          ; arguments counter
        mov rdi, out_buffer


.loop:

        xor rax, rax
        mov al, [rsi]
        inc rsi

        cmp al, '%'
        je .percent

        cmp al, EOL
        je .end_line

        mov [rdi], al
        inc rdi 
        ; CHECK_OVERFLOW
        jmp .loop

.percent:

        xor rax, rax
        mov al, [rsi]

        cmp al, '%'
        je .dpercent

        cmp al, 'x'
        ja .NAsym

        sub al, 'b' 
        jb .NAsym

        mov rax, [.arg_sym + 8 * rax]  ; jump into address from jmp table (arg_sym)
        jmp rax                              ;



;================================================

[section .data]

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.arg_sym:
        dq .b_sym
        dq .c_sym
        dq .d_sym
        times('n' - 'd')  dq .NAsym
        dq .o_sym
        times('r' - 'o')  dq .NAsym
        dq .s_sym    
        times('w' - 's')  dq .NAsym
        dq .x_sym 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


__SECT__
;================================================

.dpercent:
        mov [rdi], al
        inc rdi

        ;CHECK_OVERFLOW

        inc rsi
        jmp .loop


.NAsym:
        mov byte [rdi], '%'
        inc rdi

        mov al, [rsi]
        mov [rdi], al
        inc rdi

        inc rsi
        jmp .loop


.s_sym:
        push rsi ; save rsi address

        inc rbx
        mov rsi, [rbp + rbx * 8 + 8] ; take arg from stack

        call cpybuff  ; cpy buffer 

        pop rsi

        inc rsi         ; CHECK_OVERFLOW
        jmp .loop

.c_sym:
        inc rbx
        xor rax, rax
        mov al, [rbp + rbx * 8 + 8]

        mov byte [rdi], al
        inc rdi

        inc rsi  ; check stackoverflow
        jmp .loop

.d_sym:
        mov cl, 0

        jmp .number

        jmp .loop

.o_sym:
        mov cl, 3
        jmp .number

        jmp .loop

.x_sym:
        mov cl, 4
        jmp .number
        
        jmp .loop

.b_sym:
        mov cl, 1
        jmp .number

        jmp .loop

.number:

        inc rbx
        mov eax, [rbp + rbx * 8 + 8]
        movsx rax, eax 

        cmp cl, 00h
        jne .itoa_2pw
        

        call itoa10
        
        ;stackoverflow
        inc rsi
        jmp .loop

        .itoa_2pw:
            call itoa

            inc rsi
            jmp .loop

.end_line:
        pop rbx
        call Print_in_cmd
        ret

;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;  copy bytes from the first buff (rsi) into the second
;  buff (rdi)
;  Input: RSI - address of string
;  Output: RDI - the second buffer is copied into.
;  Destr: RAX
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;------------------------------------------------
cpybuff:

.one_byte:
        lodsb ; save in AL 1 byte and inc RSI
        cmp al, EOL
        je .taverna
        stosb       ; put in [RDI] = AL
        jmp .one_byte

.taverna: 
        ret
;------------------------------------------------


;================================================
section .bss

out_buffer  resb 256
retr_addr   resb 8

;================================================
