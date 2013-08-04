; This is an assembly program that simply displays environment variables
; Sat, 27 Jul 2013

bits 32

%define STDOUT 1
%define SYS_EXIT 01h

extern _strlen
extern _itoa
extern _write

section .data

    _str db "Hello Nasm World!", 10, 0

section .text

; application start point
global _start
_start:

    push ebp
    mov ebp, esp
    sub esp, 20

    ; calc string length
    push dword _str
    call _strlen
    add esp, 4
    mov [ebp - 4], eax              ; save result

    mov eax, [ebp - 4]
    push eax
    push dword _str
    push dword STDOUT
    call _write
    add esp, 12

    lea ebx, [ebp - 20]
    push ebx
    push eax                        ; _write reult
    call _itoa
    add esp, 8

    lea ebx, [ebp - 20]
    push ebx
    call _strlen
    add esp, 4
    mov [ebp - 4], eax              ; save result

    lea ebx, [ebp + eax - 20]
    mov al, 10
    mov [ebx], al
    mov eax, [ebp - 4]
    inc eax
    lea ebx, [ebp - 20]

    push eax
    push ebx
    push dword STDOUT
    call _write
    add esp, 12

    mov eax, SYS_EXIT
    xor ebx, ebx
    int 80h

