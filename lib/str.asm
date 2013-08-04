; Assembly String Library
; @author Emanuel F. Oliveira
; @date Sat, 27 Jul 2013 18:32 -0300

; Important!
; This library assumes that DS and SS segment registers
; point to the same memory segment.

global _strlen
global _itoa

section .text

; This function counts characters on null terminated strings.
; @prototype unsigned int _strlen (const char *)

_strlen:

    ; enter frame
    push ebp                        ; save previous stack base (frame)
    mov ebp, esp                    ; set new satck base (frame)

    ; save register bank
    push es
    push ecx
    push ebx
    push edi

    ; Make sure ES points to DS (SCASB uses ES:EDI pointer
    ; and string pointer parameter is assumed to be a DS offset)
    mov ax, ds
    mov es, ax

    ; prepare for scan
    mov edi, [ebp + 8]              ; load first parameter (string pointer)
    mov ebx, edi                    ; save string base
    mov ecx, -1                     ; initialize ECX to FFFFFFFFh (REPNE)
    mov al, 0                       ; mov ascii null byte to AL
    cld                             ; clear direction flag (inc EDI)
    repne scasb                     ; scan string
    mov eax, edi                    ; save EDI pointer to EAX
    stc                             ; set carry flag before subtraction
    sbb eax, ebx                    ; subtract base pointer

    ; restore register bank
    pop edi
    pop ebx
    pop ecx
    pop es

    ; leave
    mov esp, ebp
    pop ebp
    ret


; This function converts a double word integer into a null terminated
; character string.
; @prototype void _itoa (int, char *)

_itoa:

    push ebp                        ; save previous stack base (frame)
    mov ebp, esp                    ; set new stack base (frame)

    ; save register bank
    push ecx
    push edx
    push ebx
    push esi
    push edi

    ; prepare registers for division loop
    mov eax, [ebp + 8]              ; load EAX with integer (1st arg)
    mov esi, [ebp + 12]             ; load ESI with string pointer (2nd arg)
    mov edi, esi                    ; save a copy of string base
    mov ecx, 10                     ; load ECX with divisor

    ; check for negative value
    test eax, eax                   ; check for negative value
    sets bl                         ; save sign bit in BL
    jns .divide                     ; skip negative values adjusment
    neg eax

    ; division loop
.divide:
    cdq                             ; sign extend EAX to EDX:EAX
    div ecx                         ; perform division using ECX as divisor
    add dl, '0'                     ; add ascii zero code to remainder (EDX)
    mov [esi], dl                   ; store digit (ESI is an offset of DS)
    inc esi                         ; adjust pointer to next position
    test eax, eax                   ; test quotient
    jnz .divide                     ; start over while EAX is not zero

    ; set number sign
    test bl, bl                     ; check for sign
    jz .terminate
    mov byte [esi], '-'             ; write sign to string
    inc esi                         ; adjust pointer to next position

.terminate:
    mov byte [esi], 0               ; terminate string

    ; reverse string order
.reverse:
    dec esi
    cmp esi, edi
    jbe .leave                      ; leave if below or equal (unsigned)
    mov al, [edi]
    mov ah, [esi]
    mov [edi], ah
    mov [esi], al
    inc edi
    jmp .reverse

.leave:
    pop edi
    pop esi
    pop ebx
    pop edx
    pop ecx

    mov esp, ebp
    pop ebp
    ret

