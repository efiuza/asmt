; Linux Write System Call Implementation
; Sat, 27 Jul 2013 16:23 -0300

bits 32

%define SYS_WRITE 04h

global _io_errno
global _write


section .bss

    _io_errno resd 1

section .text

; Linux SYS_WRITE interface
; @prototype int write (int fd, void *buf, int cnt);
_write:

    push ebp                        ; save previous stack base (frame)
    mov ebp, esp                    ; set new stack base (frame)
    sub esp, 16                     ; alloc space for local variables

    ; save register bank
    push ecx
    push edx
    push ebx
    push esi
    push edi

    ; set local variables

    ; copy 1st parameter to [ebp - 4] (int fd)
    mov eax, dword [ebp + 8]
    mov dword [ebp - 4], eax

    ; copy 2nd parameter to [ebp - 8] (void *buf)
    mov eax, dword [ebp + 12]
    mov dword [ebp - 8], eax

    ; copy 3rd parameter to [ebp - 12] (int cnt)
    mov eax, dword [ebp + 16]
    mov dword [ebp - 12], eax

    ; initialize [ebp - 16] (write booking) to 0
    mov dword [ebp - 16], 0

.write:

    ; perform system call
    mov eax, SYS_WRITE
    mov ebx, dword [ebp - 4]
    mov ecx, dword [ebp - 8]
    mov edx, dword [ebp - 12]
    int 80h

    ; test EAX for negative values (error)
    test eax, eax
    js .failure

    ; update write booking with positive value returned in EAX
    add dword [ebp - 16], eax

    ; check if there is anything left to write
    mov ebx, dword [ebp - 12]       ; load write count
    sub ebx, eax                    ; subtract bytes written from it
    je .success                     ; if result is zero, success!
    mov dword [ebp - 12], ebx       ; update write count with result in EBX
    add dword [ebp - 8], eax        ; update buffer offset by adding EAX
    jmp .write

.failure:
    neg eax
    mov dword [_io_errno], eax
    mov eax, -1
    jmp .leave

.success:
    xor eax, eax                    ; clear EAX
    mov dword [_io_errno], eax
    mov eax, dword [ebp - 16]

.leave:

    ; restore register bank
    pop edi
    pop esi
    pop ebx
    pop edx
    pop ecx

    mov esp, ebp
    pop ebp
    ret
