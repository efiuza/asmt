; FreeBSD Write System Call Implementation
; Sat, 27 Jul 2013 16:23 -0300

bits 32

%include "errno.inc"
%include "syscalls.inc"


global _io_errno
global _write


section .bss

    _io_errno resd 1

section .text

; FreeBSD SYS_write interface
; @prototype int _write (int fd, void *buf, int cnt);
_write:

    push ebp                        ; save previous stack base (frame)
    mov ebp, esp                    ; set new stack base (frame)

    ; alloc space for buffer base copy and syscall args
    sub esp, byte 16

    ; prevent negative file descriptors
    mov eax, [ebp + 8]
    test eax, eax
    js .badargs

    ; prevent signed buffer size
    mov eax, [ebp + 16]
    test eax, eax
    js .badargs

    ; prevent null buffer pointer
    mov eax, [ebp + 12]
    test eax, eax
    jz .badargs

    ; save a copy of buffer base
    mov [ebp - 4], eax              

.write:

    ; perform system call
    mov eax, [ebp + 16]
    mov [esp + 8], eax
    mov eax, [ebp + 12]
    mov [esp + 4], eax
    mov eax, [ebp + 8]
    mov [esp], eax
    mov eax, SYS_WRITE
    call _kernel

    ; carry set indicates an error
    jc .failure

    ; update buffer base
    add [ebp + 12], eax

    ; update write count 
    sub [ebp + 16], eax

    ; try again if anything else to write
    jnz .write

    ; clear _io_errno
    xor eax, eax
    mov [_io_errno], eax

    ; load EAX with buffer offset
    mov eax, [ebp + 12]
    sub eax, [ebp - 4]

    ; exit successfully
    jmp .leave

.badargs:
    mov eax, EINVAL

.failure:
    cmp eax, EINTR                  ; check for interruption error
    je .write                       ; try again if equal
    mov [_io_errno], eax
    xor eax, eax
    not eax

.leave:
    mov esp, ebp
    pop ebp
    ret


; System Call

_kernel:
    int 80h
    ret

