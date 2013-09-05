; Assembly String Library
; @author Emanuel F. Oliveira
; @date Sat, 27 Jul 2013 18:32 -0300

; IMPORTANT!
; This library assumes data segment registers (DS, ES and SS)
; point to the same momory segment.

global _strlen
global _itoa

section .text

; @prototype unsigned _strlen(const char *);
; String length calculation

_strlen:

    ; create new frame
    enter 0, 0

    ; save previous register contents
    push ecx
    push edi

    ; load registers with parameters
    mov edi, [ebp + 8]

    ; main scan loop
    xor ecx, ecx
    not ecx
.scan:
    mov al, [edi]
    test al, al
    jz .return
    inc edi
    loop .scan

.return:
    not ecx                         ; ~ecx = (-1 * ecx) - 1
    mov eax, ecx

    ; restore previous register contents
    pop edi
    pop ecx

    ; restore previous stack frame and return
    leave
    ret



; @prototype char *_utoad(unsigned, char *);
; Conversion of an unsigned integer into a decimal ascii string

_utoad:

    ; enter new stack frame
    enter 0, 0

    ; save previous register contents
    push ecx
    push edx
    push ebx
    push esi
    push edi

    ; load registers with paramenters
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    mov edi, ebx
    mov esi, ebx

    ; main division loop
    mov ecx, 10                     ; load ECX with divisor
.main_loop:
    cdq                             ; sign extend EAX to EDX:EAX
    div ecx                         ; perform division using ECX as divisor
    add edx, '0'                    ; add ascii zero code to remainder (EDX)
    mov [edi], dl                   ; store digit (ESI is an offset of DS)
    inc edi                         ; adjust pointer to next position
    test eax, eax                   ; test quotient
    jnz .main_loop                  ; start over while EAX is not zero

    ; mark end of string
    mov byte [edi], 0

    ; reverse digits order
    jmp .test_reverse
.reverse:
    mov al, [esi]
    mov ah, [edi]
    mov [esi], ah
    mov [edi], al
    inc esi
.test_reverse:
    dec edi
    cmp edi, esi
    ja .reverse

    ; set return value
    mov eax, ebx

    ; restore previous register contents
    pop edi
    pop esi
    pop ebx
    pop edx
    pop ecx

    ; restore previous stack frame
    leave
    ret



; @prototype char *_utoax(unsigned, char *);
; Conversion of an unsigned integer into an hexadecimal ascii string.

_utoax:
    ; enter new stack frame
    enter 0, 0

    ; save previous register contents
    push edx
    push ebx
    push esi
    push edi

    ; load registers with parameters
    mov edx, [ebp + 8]
    mov ebx, [ebp + 12]
    mov esi, ebx
    mov edi, ebx

.main_loop:
    mov eax, edx
    and eax, 15
    cmp eax, 10
    jb .less_than
    sub eax, 10
    add eax, 'a'
    jmp .continue
.less_than:
    add eax, '0'
.continue:
    mov [edi], al
    inc edi
    shr edx, 4
    jnz .main_loop

    ; mark end of string
    mov byte [edi], 0

    ; reverse digits order
    jmp .test_reverse
.reverse:
    mov al, [esi]
    mov ah, [edi]
    mov [esi], ah
    mov [edi], al
    inc esi
.test_reverse:
    dec edi
    cmp edi, esi
    ja .reverse

    ; set return value
    mov eax, ebx

    ; restore previous register contents
    pop edi
    pop esi
    pop ebx
    pop edx

    ; restore previous stack frame
    leave
    ret



; @prototype char *_utoao(unsigned, char *);
; Conversion of an unsigned integer into an octal ascii string.

_utoao:

    ; enter new stack frame
    enter 0, 0

    ; save previous register contents
    push edx
    push ebx
    push esi
    push edi

    ; load registers with parameters
    mov edx, [ebp + 8]
    mov ebx, [ebp + 12]
    mov esi, ebx
    mov edi, ebx

.main_loop:
    mov eax, edx
    and eax, 7
    add eax, '0'
    mov [edi], al
    inc edi
    shr edx, 3
    jnz .main_loop

    ; mark end of string
    mov byte [edi], 0

    ; reverse digits order
    jmp .test_reverse
.reverse:
    mov al, [esi]
    mov ah, [edi]
    mov [esi], ah
    mov [edi], al
    inc esi
.test_reverse:
    dec edi
    cmp edi, esi
    ja .reverse

    ; set return value
    mov eax, ebx

    ; restore previous register contents
    pop edi
    pop esi
    pop ebx
    pop edx

    ; restore previous stack frame
    leave
    ret



; @prototype int _strf(const char *frmt, char *buf, ...);
; Apply parameters to a format string
; Formats:
;     %d or %i => signed decimal integer
;     %u       => unsigned decimal integer
;     %o       => unsigned octal integer
;     %x       => unsigned hexadecimal integer
;     %X       => unsigned hexadecimal integer (uppercase)
;     %c       => character
;     %s       => null terminated byte string
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

