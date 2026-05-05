[bits 16]
[section .text]
global notepad_start
global notepad_buffer
extern user_print

notepad_start:
    mov si, msg_notepad
    call user_print
    mov di, notepad_buffer
    xor cx, cx
.input_loop:
    mov ah, 0x00
    int 0x16
    cmp al, 27
    je .exit
    cmp al, 0x08
    je .backspace
    cmp al, 0x0d
    je .newline
    cmp cx, 1498
    jae .input_loop
    stosb
    inc cx
    mov ah, 0x0e
    int 0x10
    jmp .input_loop
.backspace:
    jcxz .input_loop
    dec di
    dec cx
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .input_loop
.newline:
    mov al, 0x0d
    mov ah, 0x0e
    int 0x10
    mov al, 0x0a
    int 0x10
    mov al, 0x0d
    stosb
    inc cx
    mov al, 0x0a
    stosb
    inc cx
    jmp .input_loop
.exit:
    mov byte [di], 0
    mov al, 0x0d
    int 0x10
    mov al, 0x0a
    int 0x10
    ret

msg_notepad db 0x0d, 0x0a, 'Notepad (ESC to exit):', 0x0d, 0x0a, 0
[section .data]
notepad_buffer times 1501 db 0