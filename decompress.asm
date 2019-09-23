; Assembly decompress
; Criado por: Leonardo Pliskieviski
; Área de código
section .text
    global descomprime
descomprime:
    push ebp                             ; set up stack frame
    mov ebp,esp
    
    push ebx                             ; Program must preserve ebp, ebx, esi, & edi
    push esi
    push edi

    xor     eax, eax                     ; clean eax register

    mov eax, dword [ebp+8]               ; mov eax to first parameter of function (+8)
    mov [read_file_descriptor], eax
    mov eax, dword [ebp+12]              ; mov eax to second parameter (+12)
    mov [write_file_descriptor], eax 

; start decompressing
startDecompression:
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

    lea ecx, [buffer]

    lea edi, [buffer+eax*1]              ; mov edi to the last element of buffer
    mov [bytesReaded], eax               ; mov number of bytes readed to bytesReaded

verifyBuffer:                            ; verify all buffer characters searching for an invalid char
    
    mov ebx, [ecx]

    cmp ecx, edi                         ; compare with end of buffer, if it reached the last element then exit
    je startProccess

    mov dl, bl                           ; verify first character
    shl dl, 4
    shr dl, 4

    cmp dl, 0x00
    je firstOK
    cmp dl, 0x01
    je firstOK
    cmp dl, 0x02
    je firstOK
    cmp dl, 0x03
    je firstOK
    cmp dl, 0x04
    je firstOK
    cmp dl, 0x05
    je firstOK
    cmp dl, 0x06
    je firstOK
    cmp dl, 0x07
    je firstOK
    cmp dl, 0x08
    je firstOK
    cmp dl, 0x09
    je firstOK
    cmp dl, 0xa
    je firstOK
    cmp dl, 0xb
    je firstOK
    cmp dl, 0xc
    je firstOK
    cmp dl, 0xd
    je firstOK
    cmp dl, 0xf
    jne end_error_jump
    jmp firstOK
firstOK:
    xor dl, dl                           ; verify second character
    mov dl, bl
    shr dl, 4

    cmp dl, 0x00
    je increase
    cmp dl, 0x01
    je increase
    cmp dl, 0x02
    je increase
    cmp dl, 0x03
    je increase
    cmp dl, 0x04
    je increase
    cmp dl, 0x05
    je increase
    cmp dl, 0x06
    je increase
    cmp dl, 0x07
    je increase
    cmp dl, 0x08
    je increase
    cmp dl, 0x09
    je increase
    cmp dl, 0xa
    je increase
    cmp dl, 0xb
    je increase
    cmp dl, 0xc
    je increase
    cmp dl, 0xd
    jne end_error_jump
    jmp increase

increase:                                ; increase to next position                 
    inc ecx
    jmp verifyBuffer

startProccess:
    xor     eax, eax                     ; clear registers
    xor     ebx, ebx
    xor     ecx, ecx
    xor     edx, edx                     
    xor     esi, esi
    lea     ecx, [buffer]                ; load the start of the buffer into ecx
    jecxz end_error_jump                 ; only jump if file descriptor is zero

;#######################
;#   Read the buffer   #
;#######################
readBuffer:
    mov byte [character], 0h             ; clear characters
    mov byte [next_character], 0h 

    xor ebx, ebx                         ; clear ebx
    mov ebx, [ecx]                       ; mov current byte to ebx

    cmp ecx, edi                         ; compare with end of buffer, if it reached the last element then exit
    je end

    mov dl, bl                           ; fetch first character
    shr dl, 4                            ; shift bl right four times, bl >> 4 |1|0|0|1|0|1|1|1| ===== |0|0|0|0|1|0|0|1|

    cmp dl, 0x00                         ; start all comparasions
    je startBLmoving
    cmp dl, 0x01
    je startBLmoving
    cmp dl, 0x02
    je startBLmoving
    cmp dl, 0x03
    je startBLmoving
    cmp dl, 0x04
    je startBLmoving
    cmp dl, 0x05
    je startBLmoving
    jmp afterEndJump

end_error_jump:
    jmp end_error

afterEndJump:
    cmp dl, 0x06
    je startBLmoving
    cmp dl, 0x07
    je startBLmoving
    cmp dl, 0x08
    je startBLmoving
    cmp dl, 0x09
    je startBLmoving
    cmp dl, 0xa
    je startDLmovingWithSpecialCharA
    cmp dl, 0xb
    je startDLmovingWithSpecialCharB
    cmp dl, 0xc
    je startDLmovingWithSpecialCharC
    cmp dl, 0xd ; newline
    je startDLmovingWithSpecialCharD

startDLmovingWithSpecialCharA:
    mov dl, '.'
    jmp startBLmoving
startDLmovingWithSpecialCharB:
    mov dl, '-'
    jmp startBLmoving
startDLmovingWithSpecialCharC:
    mov dl, 0x20
    jmp startBLmoving
startDLmovingWithSpecialCharD:
    mov dl, 0x0a
    jmp startBLmoving

startBLmoving:
    ; bl
    shl bl, 4                            ; shift bl left four times
    shr bl, 4                            ; shift bl right four times

    ; Start cmp's
    cmp bl, 0x00
    je continueBL
    cmp bl, 0x01
    je continueBL
    cmp bl, 0x02
    je continueBL
    cmp bl, 0x03
    je continueBL
    cmp bl, 0x04
    je continueBL
    cmp bl, 0x05
    je continueBL
    cmp bl, 0x06
    je continueBL
    cmp bl, 0x07
    je continueBL
    cmp bl, 0x08
    je continueBL
    cmp bl, 0x09
    je continueBL
    cmp bl, 0xa
    je startBLmovingWithSpecialCharA
    cmp bl, 0xb
    je startBLmovingWithSpecialCharB
    cmp bl, 0xc
    je startBLmovingWithSpecialCharC
    cmp bl, 0xd ; newline
    je startBLmovingWithSpecialCharD
    cmp bl, 0xF
    jmp continueBL

startBLmovingWithSpecialCharA:
    mov bl, '.'
    jmp continueBL
startBLmovingWithSpecialCharB:
    mov bl, '-'
    jmp continueBL
startBLmovingWithSpecialCharC:
    mov bl, 0x20
    jmp continueBL
startBLmovingWithSpecialCharD:
    mov bl, 0x0a
    jmp continueBL

continueBL:
    cmp dl, '.'
    je specialCharCodeDL
    cmp dl, '-'
    je specialCharCodeDL
    cmp dl, 0x20
    je specialCharCodeDL
    cmp dl, 0x0a ; newline
    je zeroedStartChar
    jmp notSpecialCharDL

specialCharCodeDL:                       ; 0010 == (0x2)
    xor al, al
    mov al, 0x2
    shl al, 4
    or  dl, al ; fetched
    jmp codificatedCharDL

zeroedStartChar:
    jmp codificatedCharDL

notSpecialCharDL:
    xor al, al

    mov al, 0x3                          ; trim results to display (0x3 - to normal digit)
    shl al, 4
    or  dl, al                           ; character fetched

codificatedCharDL:
    
    cmp bl, '.'
    je specialCharCodeBL
    cmp bl, '-'
    je specialCharCodeBL
    cmp bl, 0x20
    je specialCharCodeBL
    cmp bl, 0x0a ; newline
    je newLineCharCodeBL
    cmp bl, 0xF
    je blankBLChar
    jmp notSpecialCharBL

specialCharCodeBL:                       ; 0010 == (0x2)
    xor al, al
    mov al, 0x2
    shl al, 4
    or  bl, al                           ; fetched
    jmp codificatedCharBL

newLineCharCodeBL:
    jmp codificatedCharBL

blankBLChar:
    jmp codificatedCharBL

notSpecialCharBL:
    xor al, al
                                         ; trim results to display (0x3 - to normal digit)
    mov al, 0x3
    shl al, 4
    or  bl, al                           ; fetched

codificatedCharBL:
    ; fetch characters
    mov [character], dl
    mov [next_character], bl

writeFirstCharacter:                     ; write 2 characters to file descriptor, transformed in single characters
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

    cmp byte [next_character], 0xF       ; if it is a 0xF character, it means that there isn't a last digit, then, just end the program
    je end

writeSecondCharacter:
    push ecx                             ; save ecx to write 

    mov eax, 4                           ; syscall 4 - write()
    mov ebx, [write_file_descriptor]     ; file desc 1 - stdout
    mov ecx, next_character              ; character to be written
    mov edx, 1                           ; length of message
    int 80h                              ; syscall interupt

    xor edx, edx                         ; clear edx for security
    pop ecx                              ; return ecx to the previous value (counter)

    cmp eax, 0                           ; verification for security
    je end_error

    add ecx, 1                           ; increment position
    jmp readBuffer

end_error:

    mov ebx,[read_file_descriptor]       ; File descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; Kernel call

    mov ebx,[write_file_descriptor]      ; File descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; Kernel call

    pop edi                              ; Restore saved registers
    pop esi
    pop ebx
    mov al, -1                           ; return error
    mov esp,ebp                          ; Destroy stack frame before returning
    pop ebp
    ret                                  ; Return control to Linux

end:
    cmp dword [bytesReaded], len         ; compare with len, if buffer is out of space, then there is a possibility to read more characters
    je startDecompression
end_continue:                            ; else just end program
    mov ebx,[read_file_descriptor]       ; File descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; Kernel call

    cmp eax, 0                           ; verify result of fclose()
    jne end_error

    mov ebx,[write_file_descriptor]      ; File descriptor of src file
    mov eax,6                            ; sys_close()
    int 0x80                             ; Kernel call

    cmp eax, 0                           ; verify result of fclose()
    jne end_error

    pop edi                              ; Restore saved registers
    pop esi
    pop ebx
    
    mov al, 0                            ; return success
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

; Mensagem
read_file_descriptor resd 1             ; 32 bit for read file descriptor
write_file_descriptor resd 1            ; 32 bit for write file descriptor

character: resb 1
next_character: resb 1

bytesReaded: resb 11
