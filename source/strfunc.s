section .text

EOL equ 00h

global Pstrlen, itoa, itoa10

;------------------------------------------------
;OUTPUT len of str,  
;	RSI = offset str
;
;Entry: Stack frame
;Dest: RCX
;Output: LEN OF STR IN RCX 
;------------------------------------------------
Pstrlen:
	push rsi

	xor rcx, rcx		

.findeol:
	cmp byte [rsi], EOL	
	je .taverna

	inc rcx
	inc rsi
	jmp .findeol
	
.taverna:
	
	pop rsi
	ret									
;------------------------------------------------


;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
[section .data]

HEX db '0123456789ABCDEF'

__SECT__
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


;------------------------------------------------
;Translates integer value in string
;Puts number in buffer RDI
;
;Input:
;	CL  - base ( power of 2)
;	RAX - integer value 
;	RDI - buffer to write str into (address)
;
;       Destr:RDX, RAX, RCX, R8, R9
;------------------------------------------------
itoa:

    call bytes_counter

    add rdi, rdx            ; save space for elder bits in buffer: _ _ _ RDI: _
	dec   rdi 				; number of bytes excluding the last EOL symbol

	mov r8, rdx    			; save number of bytes
    mov r9, 01b             ; mask <0..01b>
    shl r9, cl              ; mask <0..010..0b>
    dec r9                  ; mask <0..001..1b>

	.loop:

        mov rdx, r9

        and rdx, rax                    ; apply mask to rdx
        shr rax, cl                     ; cut off masked bits: 01010011 -> 00101|0011

        mov dl, [rdx + HEX]			
        mov [rdi], dl

        dec rdi                        	; _ _ _ _ | _ _ _ _
        cmp rax, 00h                    ; check if the whole value has been printed
        ja  .loop

	inc rdi	
	add rdi, r8

    ret

;------------------------------------------------
;Count amount of bytes for translating int value
;into buffer 
;
;Input: RAX - value
;	CL - base
;Output: RDX - amount of bytes 
;------------------------------------------------
bytes_counter:

	mov rdx, rax
	xor ch, ch

	.loop1:
		inc ch
		shr rdx, cl 
		jnz .loop1

	mov dl, ch

	ret
;------------------------------------------------



;------------------------------------------------
;converts integer number into buffer ( string ) 
; Input: RAX - value 					
; 	 RDI - buffer (address) 
;
;Destr: RDX, RCX, R10, R9
;------------------------------------------------
itoa10:

    mov rcx, 10d	; basa!												!!!CHECK СТАРШИЙ БИТ MSB, ЕСЛИ РАВЕН 1, то 
																	; напечатать минус и neg rax

	test rax, 80000000h
	jz .next 
	neg rax
	mov byte [rdi], '-'
	inc rdi

	.next:
	xor r9, r9 		; number of bytes
	mov r10, rax	; saved value for counter
		

	.counter:                             ; save space for elder bits
        xor rdx, rdx                      ; reset remaining
        div rcx                           ; rax = rax / 10; rdx = rax % 10

		inc r9
        inc rdi							  ; * * *  ; * * ; * ; 
        cmp rax, 00h; 					  ; * *    ; *   ; 0
        ja .counter						  ;

    mov rax, r10                          ; ax = value


	.print:
		dec rdi 
        xor rdx, rdx
        div rcx                          ; rax = rax / 10; rdx = rax % 10


        add dl, '0'                   
        mov byte [rdi], dl
        cmp rax, 00h
        ja .print

	add rdi, r9

    ret
;------------------------------------------------