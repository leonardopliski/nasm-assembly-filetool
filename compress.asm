; Assembly compress
; Criado por: Leonardo Pliskieviski
; Área de código
section .text
	global comprime
comprime:
    push ebp                             ; Set up stack frame for debugger
    mov ebp,esp

    push ebx                             ; Program must preserve ebp, ebx, esi, & edi
    push esi
    push edi

	xor     eax, eax                     ; clean eax register

	mov eax, dword [ebp+8]               ; mov eax to first parameter of function (+8)
	mov [read_file_descriptor], eax
	mov eax, dword [ebp+12]              ; mov eax to second parameter (+12)
	mov [write_file_descriptor], eax 

; start compressing
startCompression:
                                         ; start clearing buffer
    mov ecx,len                          ; buffer size
    lea edx,[buffer]                     ; point edx to the start of the block to be cleared.  
    xor eax,eax                          ; xor reg,reg is the same as mov reg,0, but faster.
loop:
    mov [edx+ecx*1],eax                  ; fill the buffer starting at the end.
    dec ecx                              ; decrease the counter; also moving the destination.   
    jnz loop                             ; if ecx <> 0 (Non-Zero) then repeat.

    xor     eax, eax                     ; clear registers
    xor     ecx, ecx
    xor     edx, edx
                                         ; start reading the file
	mov eax, 3                           ; set read file instruction
	mov ebx, [read_file_descriptor]      ; set read file descriptor
	mov ecx, buffer                      ; save to buffer
	mov edx, len
	int 80h

    cmp eax, -1                          ; verify read errors
    je end_error

    cmp eax, 0                           ; verify if file is empty
    je end_error

    mov [bytesReaded], eax               ; mov number of bytes readed to bytes readed

    lea ecx, [buffer]

verifyBuffer:                            ; verify all buffer characters searching for an invalid char
    
    mov ebx, [ecx]

    cmp bl, 0                          
    je startProccess

    cmp bl, 0x30
    je increase
    cmp bl, 0x31
    je increase
    cmp bl, 0x32
    je increase
    cmp bl, 0x33
    je increase
    cmp bl, 0x34
    je increase
    cmp bl, 0x35
    je increase
    cmp bl, 0x36
    je increase
    cmp bl, 0x37
    je increase
    cmp bl, 0x38
    je increase
    cmp bl, 0x39
    je increase
    cmp bl, 0x2E
    je increase
    cmp bl, 0x2D
    je increase
    cmp bl, 0x20
    je increase
    cmp bl, 0x0a
    jne end_jump
    jmp increase

increase:                                ; increase to next position                 
    inc ecx
    jmp verifyBuffer

startProccess:
    xor     eax, eax                     ; clear registers
    xor     ecx, ecx
    xor     ebx, ebx
    lea     ecx, [buffer]                ; load buffer first position into ecx
    jecxz end_jump                       ; only jump if file descriptor is zero

;#######################
;#   Read the buffer   #
;#######################
readBuffer:
	mov byte [character], 0h             ; clear character

    mov     edx, [ecx]                   ; character
    mov     ebx, [ecx+1]                 ; next character

                                         ; end of buffer comparasions
    cmp     dl, 0                        ; compare with zero
    jz      end                          ; '\0' null terminator if ecx is zero, we're done.

    cmp     bl, 0                        ; compare with zero
    jz      endInSecond                  ; '\0' null terminator if ecx is zero, we're done.

    cmp dl, '0'
    je fetchData
    cmp dl, '1'
    je fetchData

    jmp readBuffer_jump_n2
readBuffer_jump_n:
	jmp readBuffer
readBuffer_jump_n2:

    cmp dl, '2'
    je fetchData
    cmp dl, '3'
    je fetchData
    cmp dl, '4'
    je fetchData

    jmp afterEndJump
end_jump:
	jmp end_error
afterEndJump:

    cmp dl, '5'
    je fetchData
    cmp dl, '6'
    je fetchData
    cmp dl, '7'
    je fetchData
    cmp dl, '8'
    je fetchData
    cmp dl, '9'
    je fetchData
    cmp dl, '.'
    je pointSpecialChar
    cmp dl, '-'
    je traceSpecialChar
    cmp dl, ' '
    je spaceSpecialChar
    cmp dl, 0ah
    je newlineSpecialChar

fetchData:
                                         ; fix dl: dl << 4
    shl dl, 4                            ; |1|1|1|1|0|0|0|0|

fixBLtoStore:

	cmp bl, '0'
    je start_bl_fix
    cmp bl, '1'
    je start_bl_fix
	cmp bl, '2'
    je start_bl_fix
    cmp bl, '3'
    je start_bl_fix
    cmp bl, '4'
    je start_bl_fix
    cmp bl, '5'
    je start_bl_fix
    cmp bl, '6'
    je start_bl_fix
    cmp bl, '7'
    je start_bl_fix
    cmp bl, '8'
    je start_bl_fix
    cmp bl, '9'
    je start_bl_fix
    cmp bl, '.'
    je pointBLSpecialChar
    cmp bl, '-'
    je traceBLSpecialChar
    cmp bl, ' '
    je spaceBLSpecialChar
    cmp bl, 0ah                          ; end of line
    je newlineBLSpecialChar

start_bl_fix:
                                         ; clear trash
    shl bl, 4                            ; bl << 4
    shr bl, 4                            ; bl >> 4 |0|0|0|0|1|1|1|1|
    or  dl, bl                           ; union
    jmp setCharacterToData

pointSpecialChar:
	xor dl, dl                           ; clear register 
	mov dl, 0xA
	shl dl, 4

    cmp bl, '.'                          ; point
    je pointBLSpecialChar
    cmp bl, '-'                          ; trace
    je traceBLSpecialChar
    cmp bl, ' '                          ; space
    je spaceBLSpecialChar
    cmp bl, 0ah                          ; end of line
    jne fixBLtoStore
    jmp newlineBLSpecialChar

traceSpecialChar:
	xor dl, dl
	mov dl, 0xB
	shl dl, 4

    cmp bl, '.'                          ; point
    je pointBLSpecialChar
    cmp bl, '-'                          ; trace
    je traceBLSpecialChar
    cmp bl, ' '                          ; space
    je spaceBLSpecialChar
    cmp bl, 0ah                          ; end of line
    jne fixBLtoStore
    jmp newlineBLSpecialChar

spaceSpecialChar:
	xor dl, dl
	mov dl, 0xC
	shl dl, 4

    cmp bl, '.'                          ; point
    je pointBLSpecialChar
    cmp bl, '-'                          ; trace
    je traceBLSpecialChar
    cmp bl, ' '                          ; space
    je spaceBLSpecialChar
    cmp bl, 0ah                          ; end of line
    jne fixBLtoStore
    jmp newlineBLSpecialChar

newlineSpecialChar:
	xor dl, dl
	mov dl, 0xD
	shl dl, 4
    
    cmp bl, '.'                          ; point
    je pointBLSpecialChar
    cmp bl, '-'                          ; trace
    je traceBLSpecialChar
    cmp bl, ' '                          ; space
    je spaceBLSpecialChar
    cmp bl, 0ah                          ; end of line
    jne fixBLtoStore
    jmp newlineBLSpecialChar

pointBLSpecialChar:
	xor bl, bl
	mov bl, 0xA
	or  dl, bl
    jmp setCharacterToData

traceBLSpecialChar:
	xor bl, bl
	mov bl, 0xB
	or  dl, bl
    jmp setCharacterToData

spaceBLSpecialChar:
	xor bl, bl
	mov bl, 0xC
	or  dl, bl
    jmp setCharacterToData

newlineBLSpecialChar:
	xor bl, bl
	mov bl, 0xD
	or  dl, bl
    jmp setCharacterToData

setCharacterToData:
    mov [character], dl

    jmp readBuffer_jump_n4

readBuffer_jump_n3:                      ; returning loop
	jmp readBuffer_jump_n

readBuffer_jump_n4:

; write content to file descriptor
writeToFD:
	push ecx                             ; save ecx to write 

	mov eax, 4                           ; syscall 4 - write()
	mov ebx, [write_file_descriptor]     ; file desc 1 - stdout
	mov ecx, character                   ; character to be written
	mov edx, 1                           ; length of message
	int 80h                              ; syscall interupt

	xor edx, edx                         ; clear edx for security
	pop ecx                              ; return ecx to the previous value (counter)

    cmp eax, 0                           ; verification for security
    je end_error

	add     ecx, 2                       ; jump 2 positions ahead, (looping by 2 and 2)
	jmp     readBuffer_jump_n3           ; if ecx isn't zero, loop until it is.

endWithoutSecondValue:
    cmp dl, '.'
    je pointLastSpecialChar
    cmp dl, '-'
    je traceLastSpecialChar
    cmp dl, ' '
    je spaceLastSpecialChar
    cmp dl, 0ah
    je nlLastSpecialChar
    jne lastNormal

pointLastSpecialChar:
    mov dl, 0xA
    jmp lastNormal
traceLastSpecialChar:
    mov dl, 0xB
    jmp lastNormal
spaceLastSpecialChar:
    mov dl, 0xC
    jmp lastNormal
nlLastSpecialChar:
    mov dl, 0xD
    jmp lastNormal

lastNormal:
	shl dl, 4
	mov bl, 0xF                          ; last positions to 'F'
	or  dl, bl
	mov [character], dl
	jmp writeToFD

endInSecond:
    cmp     dl, 0                        ; compare with zero
    jnz     endWithoutSecondValue        ; '\0' null terminator if ecx is zero, we're done.

end_error:                               ; function to return a minus one (error)	
	mov ebx,[read_file_descriptor]       ; file descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; Kernel call

    mov ebx,[write_file_descriptor]      ; file descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; kernel call

    pop edi                              ; restore saved registers
    pop esi
    pop ebx

    mov eax, -1                          ; destroy stack frame before returning
    mov esp,ebp
    pop ebp

    ret                                  ; Return control to Linux

;################
;# Exit Program #
;################
end:
    cmp dword [bytesReaded], len         ; compare with len, if buffer is out of space, then there is a possibility to read more characters
    je startCompression
end_continue:
    xor eax, eax

    mov ebx,[read_file_descriptor]       ; file descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; Kernel call

    cmp eax, 0                           ; verify result of fclose()
    jne end_error

    mov ebx,[write_file_descriptor]      ; file descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; Kernel call
                                         
    cmp eax, 0                           ; verify result of fclose()
    jne end_error

    xor eax, eax                         ; clear registers
    pop edi                              ; Restore saved registers
    pop esi
    pop ebx
    mov eax, 0                           ; return successs

    mov esp,ebp                          ; Destroy stack frame before returning
    pop ebp

    ret                                  ; Return control to Linux

; Área para ariáveis não inicializadas (Aqui é o melhor lugar para se colocar constantes)
; É alocado o espaço na RAM e em FLASH/ROM da mesma, no mesmo tamanho
section .data

len equ 1000

; Área para guardar variáveis não inicializadas, todos os valores colocados em .bss
; Recebem zero em sua composição, e são carregados em Memória, exemplo: "int valor = 0"
section .bss

buffer resb 1024

read_file_descriptor resd 1              ; 32 bit for read file descriptor
write_file_descriptor resd 1             ; 32 bit for write file descriptor

character: resb 1
next_character: resb 1

bytesReaded: resb 11

