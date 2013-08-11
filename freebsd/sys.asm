; FreeBSD System Utils
; Sun, 11 Aug 2013 09:55 -0300

bits 32


%include "errno.inc"
%include "syscalls.inc"


; symbols
global _exit


section .text

; FreeBSD SYS_exit implementation
; @prototype void _exit (int res);

_exit:
    enter 0, 0
    push dword [ebp + 8]
    mov eax, SYS_EXIT
    call _kernel
    leave
    ret


_kernel:
    int 80h
    ret

