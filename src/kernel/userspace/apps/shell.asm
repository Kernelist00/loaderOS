[bits 16]
[section .text]
global shell_start
extern user_print
extern notepad_start
extern notepad_buffer

shell_start:
    mov si, msg_welcome
    call user_print
.prompt:
    mov si, prompt
    call user_print
    mov di, cmd_buffer
    xor cx, cx
.read_cmd:
    mov ah, 0x00
    int 0x16
    cmp al, 0x0d
    je .execute
    cmp al, 0x08
    je .backspace
    cmp cx, 31
    je .read_cmd
    stosb
    inc cx
    mov ah, 0x0e
    int 0x10
    jmp .read_cmd
.backspace:
    jcxz .read_cmd
    dec di
    dec cx
    mov ah, 0x0e
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .read_cmd
.execute:
    mov byte [di], 0
    mov al, 0x0d
    mov ah, 0x0e
    int 0x10
    mov al, 0x0a
    int 0x10
    jcxz .prompt
    
    mov si, cmd_buffer
    mov di, cmd_notepad
    call strcmp
    jc .run_notepad
    
    mov si, cmd_buffer
    mov di, cmd_list
    call strcmp
    jc .run_list

    mov si, cmd_buffer
    mov di, cmd_help
    call strcmp
    jc .run_help
    
    mov si, msg_unknown
    call user_print
    jmp .prompt
.run_notepad:
    call notepad_start
    jmp .prompt
.run_list:
    mov si, notepad_buffer
    call user_print
    mov al, 0x0d
    mov ah, 0x0e
    int 0x10
    mov al, 0x0a
    int 0x10
    jmp .prompt
.run_help:
    mov si, msg_help
    call user_print
    jmp .prompt

strcmp:
    pusha
.loop:
    lodsb
    mov bl, [di]
    inc di
    cmp al, bl
    jne .not_equal
    cmp al, 0
    je .equal
    jmp .loop
.not_equal:
    popa
    clc
    ret
.equal:
    popa
    stc
    ret

msg_welcome db 'loaderOS Shell Ready', 0x0d, 0x0a, 0
prompt db '> ', 0
msg_unknown db 'Unknown command', 0x0d, 0x0a, 0
msg_help db 'Commands: help, notepad, list', 0x0d, 0x0a, 0
cmd_notepad db 'notepad', 0
cmd_list db 'list', 0
cmd_help db 'help', 0

[section .bss]
cmd_buffer resb 32