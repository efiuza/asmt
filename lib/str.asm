; Assembly String Library
; @author Emanuel F. Oliveira
; @date Sat, 27 Jul 2013 18:32 -0300

; IMPORTANT!
; This library assumes data segment registers (DS, ES and SS)
; point to the same momory location.

global _strlen
global _itoa

section .text

; This function counts characters on null terminated strings.
; @prototype unsigned int _strlen(const char *)

_strlen:

    ; create new frame
    enter 0, 0

    ; save register bank
    push ecx
    push edi

    ; prepare for scan
    mov edi, [ebp + 8]              ; load first parameter (string pointer)
    xor ecx, ecx                    ; clear ECX...
    not ecx                         ; turn it into FFFFFFFFh
    mov al, 0                       ; mov ascii null byte to AL
    cld                             ; clear direction flag (inc EDI)

    ; Scan string at [ES:EDI]. Because DS and ES are assumed to point
    ; to the same location, there is no need to change memory segments.
    repne scasb

    ; REPNE decrements ECX after string operation...
    not ecx                         ; !x = (-1 * x) - 1
    lea eax, [ecx - 1]              ; load EAX with ECX - 1

    ; restore register bank
    pop edi
    pop ecx

    ; restore previous stack frame and return
    leave
    ret


; This function converts a double word integer into a null terminated
; character string.
; @prototype void _itoa(int, char *)

_itoa:

    ; create new frame
    ; push ebp
    ; mov ebp, esp
    enter 0, 0

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

    ; restore precious stack frame
    ; mov esp, ebp
    ; pop ebp
    leave
    ret

; @prototype char *_utoax(unsigned, char *);
; Convert unsigned integer into hexadecial ASCII string.
_utoax:
    enter 0, 0

    ; save register contents
    push edx
    push edi

    ; load parameters
    mov edi, [ebp + 12]
    mov edx, [ebp + 8]

.loop:
    mov eax, edx
    and eax, 15
    cld
    stosb
    shr edx, 4
    jnz .loop

    ; restore registers
    pop edi
    pop edx

    leave
    ret


; Apply parameters to a format string
; Formats:
;     %d or %i => signed decimal integer
;     %c       => character
;     %s       => null terminated byte string
; @prototype int _strf(const char *frmt, char *buf, ...)
_strf:

    enter 4, 0

    ; save used registers
    push ecx
    push esi
    push edi


    ; initialize ECX
    xor ecx, ecx
    not ecx
.loop:

    loop .loop

.leave:
    pop edi
    pop esi
    pop ecx

    leave
    ret

