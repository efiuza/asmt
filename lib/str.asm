; Assembly String Library
; @author Emanuel F. Oliveira
; @date Sat, 27 Jul 2013 18:32 -0300

bits 32

; IMPORTANT!
; This library assumes that main data segment registers (DS and SS)
; point to the same momory segment.

global _strlen
global _itoa

section .text

; @prototype unsigned _strlen(const char *);
; String length calculation

_strlen:

    ; create new frame
    push ebp
    mov ebp, esp

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
    ; not ecx = (-1 * ecx) - 1
    not ecx                         
    mov eax, ecx

    ; restore previous register contents
    pop edi
    pop ecx

    ; restore previous stack frame and return
    leave
    ret



; @prototype char *_utoad(unsigned, char *);
; Converts an unsigned integer into a decimal ascii string

_utoad:

    ; enter new stack frame
    push ebp
    mov ebp, esp

    ; save previous register contents
    push ecx
    push edx
    push ebx
    push esi
    push edi

    ; load registers with paramenters
    mov eax, [ebp + 8]
    mov ebx, [ebp + 12]
    mov esi, ebx
    mov edi, ebx

    ; main division loop
    mov ecx, 10                     ; load ECX with divisor
.main_loop:
    cdq                             ; sign extend EAX to EDX:EAX
    div ecx                         ; perform division using ECX as divisor
    add edx, '0'                    ; add ascii zero code to remainder (EDX)
    mov [edi], dl
    inc edi
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

    ; restore previous stack frame and return
    leave
    ret



; @prototype char *_utoax(unsigned, char *);
; Converts an unsigned integer into an hexadecimal ascii string.

_utoax:

    ; enter new stack frame
    push ebp
    mov ebp, esp

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
; Converts an unsigned integer into an octal ascii string.

_utoao:

    ; enter new stack frame
    push ebp
    mov ebp, esp

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

    ; restore previous stack frame and return
    leave
    ret



; @prototype char *_utoab(unsigned, char *);
; Converts an unsigned integer into a binary ascii string.

_utoab:

    ; enter new stack frame
    push ebp
    mov ebp, esp

    ; save previous register contents
    push ecx
    push edx
    push ebx

    ; load registers with parameters
    mov edx, [ebp + 8]
    mov ebx, [ebp + 12]

    ; bit scan loop
    mov ecx, 31
.scan:
    bt edx, ecx
    jc .convert
    loop .scan

    ; prepare for conversion
.convert:
    lea ebx, [ebx + ecx * 1 + 1]
    mov byte [ebx], 0

    ; main conversion loop
.main_loop:
    mov eax, edx
    and eax, 1
    add eax, '0'
    dec ebx
    mov [ebx], al
    shr edx, 1
    jnz .main_loop

    ; set return value
    mov eax, ebx

    ; restore previous register contents
    pop ebx
    pop edx
    pop ecx

    ; restore previous stack frame and return
    leave
    ret



; @prototype char *_itoad(int, char *);
; Converts a signed integer into a decimal ascii string.

_itoad:

    ; enter new stack frame
    push ebp
    mov ebp, esp

    ; save previous register contents
    push esi
    push edi

    ; load registers with parameters
    mov eax, [ebp + 8]
    mov esi, [ebp + 12]
    mov edi, esi

    ; check if the supplied number is negative
    test eax, eax
    jns .convert

    ; negate number and add minus sign to buffer before conversion
    mov byte [edi], '-'
    inc edi
    neg eax

    ; call unsigned version
.convert:
    push edi
    push eax
    call _utoad
    add esp, 8

    ; set return value
    mov eax, esi

    ; restore previous register contents
    pop edi
    pop esi

    ; restore previous stack frame and return
    leave
    ret



; @prototype char *_itoa(int val, char *buf, int base);
; Converts an integer value to a null-terminated string using the
; specified base (2, 8, 10, 16) and stores the result in the
; specified buffer.

_itoa:

    ; enter new stack frame
    push ebp
    mov ebp, esp

    ; save previous register values
    push esi
    push edi





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

    ; enter new stack frame
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

    ; restore previous stack frame and return
    leave
    ret


