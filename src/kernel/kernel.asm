[bits 16]
extern main_print
extern setup_userspace

start:
    mov ax, cs
    mov ds, ax
    mov si, msg_kernel_welcome
    call main_print
    call setup_userspace
    jmp $

msg_kernel_welcome db 'loaderOS Kernel Loaded', 0x0d, 0x0a, 0