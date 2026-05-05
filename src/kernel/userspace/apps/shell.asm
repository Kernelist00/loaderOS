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
    mov di, cmd_fastfetch
    call strcmp
    jc .run_fastfetch

    mov si, cmd_buffer
    mov di, cmd_echo
    call strcmp
    jc .run_echo

    mov si, cmd_buffer
    mov di, cmd_help
    call strcmp
    jc .run_help

    mov si, cmd_buffer
    mov di, cmd_ver
    call strcmp
    jc .run_ver

    mov si, cmd_buffer
    mov di, cmd_restart
    call strcmp
    jc .run_restart

    mov si, cmd_buffer
    mov di, cmd_secret
    call strcmp
    jc .run_secret

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

.run_fastfetch:
    mov ax, 0x0003
    int 0x10
    mov si, msg_fetch
    call user_print
    jmp .prompt

.run_echo:
    mov si, msg_echo_ex
    call user_print
    jmp .prompt

.run_help:
    mov si, msg_help
    call user_print
    jmp .prompt

.run_ver:
    mov si, msg_ver
    call user_print
    jmp .prompt

.run_restart:
    jmp 0xFFFF:0000

.run_secret:
    mov ax, 0x0003
    int 0x10
    mov si, msg_secret
    call user_print
    
    xor ax, ax
    mov es, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x7C00
    
    mov di, 0
.chaos:
    rdtsc
    xor dx, ax
    out 0x70, al
    mov [es:di], ax
    mov [di], dx
    add di, 2
    jnz .chaos
    
    cli
.dead:
    hlt
    jmp .dead

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

msg_welcome   db 'loaderOS Shell Ready', 0x0d, 0x0a, 0
prompt        db '> ', 0
msg_unknown   db 'Unknown command', 0x0d, 0x0a, 0
msg_help      db 'Commands: help, notepad, list, fastfetch, echo, ver, restart, secret', 0x0d, 0x0a, 0
msg_ver       db 'loaderOS v1.0.4 (Stable)', 0x0d, 0x0a, 0
msg_echo_ex   db 'Echo: system online', 0x0d, 0x0a, 0
msg_secret    db 'Goodbye.', 0x0d, 0x0a, 0

msg_fetch     db '  _                 _             ____   ____ ', 0x0d, 0x0a
              db ' | | ___   __ _  __| | ___ _ __  / __ \ / ___|', 0x0d, 0x0a
              db ' | |/ _ \ / _` |/ _` |/ _ \  __|| |  | |\___ \ ', 0x0d, 0x0a
              db ' | | (_) | (_| | (_| |  __/ |   | |__| | ___) |', 0x0d, 0x0a
              db ' |_|\___/ \__,_|\__,_|\___|_|    \____/ |____/ ', 0x0d, 0x0a
              db ' ---------------------------------------------', 0x0d, 0x0a
              db ' OS: loaderOS 16-bit', 0x0d, 0x0a
              db ' Kernel: Custom ASM', 0x0d, 0x0a
              db ' Shell: user_shell', 0x0d, 0x0a, 0

cmd_notepad   db 'notepad', 0
cmd_list      db 'list', 0
cmd_help      db 'help', 0
cmd_fastfetch db 'fastfetch', 0
cmd_echo      db 'echo', 0
cmd_ver       db 'ver', 0
cmd_restart   db 'restart', 0
cmd_secret    db 'secret', 0

[section .bss]
cmd_buffer resb 256