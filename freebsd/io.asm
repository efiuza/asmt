; FreeBSD Write System Call Implementation
; Sat, 27 Jul 2013 16:23 -0300

bits 32

%define SYS_WRITE  4
%define EINTR      4
%define EINVAL    22

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

    ; alloc space for write booking and syscall args
    sub esp, 16                     

    ; initialze write booking
    xor eax, eax
    mov [ebp - 4], eax

    ; prevent negative file descriptors
    mov eax, [ebp + 8]
    test eax, eax
    js .badargs

    ; prevent null buffer pointer
    mov eax, [ebp + 12]
    test eax, eax
    jz .badargs

    ; prevent signed buffer size
    mov eax, [ebp + 16]
    test eax, eax
    js .badargs

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
    jc .failure

    ; update write booking with EAX
    add [ebp - 4], eax

    ; check if there is anything left to write
    sub [ebp + 16], eax             ; update write count
    je .success                     ; if result is zero, success!

    add [ebp + 12], eax             ; update buffer offset by adding EAX
    jmp .write

.badargs:
    mov eax, EINVAL

.failure:
    cmp eax, EINTR                  ; check for interruption error
    je .write                       ; try again if equal
    mov [_io_errno], eax
    xor eax, eax
    not eax
    jmp .leave

.success:
    xor eax, eax                    ; clear _io_errno
    mov [_io_errno], eax
    mov eax, [ebp - 4]              ; load EAX with write booking

.leave:
    mov esp, ebp
    pop ebp
    ret



; System Call

_kernel:
    int 80h
    ret

