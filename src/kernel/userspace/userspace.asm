[bits 16]
[section .text]
global setup_userspace
extern shell_start

setup_userspace:
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE
    call shell_start
    ret