format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
n dd 3          ; строки
m dd 4          ; столбцы

; Исходный массив 3x4
; Например:
array dd  1, -2,  3,  4, \
        5,  6,  -7,  8, \
       -9, 10, 11, -12

fmt_int db "%6d ",0
fmt_line db 13,10,0
fmt_title db "Modified array:",13,10,0
fmt_sum db 13,10,"Sum of positives: %d",13,10,0
fmt_neg db "Negative count: %d",13,10,0
msg_wait db 13,10,"Press any key to exit...",13,10,0

sum dd 0
neg_count dd 0

section '.code' code readable executable
start:

    ; Поменять местами array[1][2] и array[1][3]
    mov eax, 1
    mov ecx, 2
    mov edx, [m]
    imul eax, edx      ; eax = 1 * 4 = 4 (номер первого элемента строки 1)
    add eax, ecx       ; eax = 4 + 2 = 6
    shl eax, 2         ; умножить на 4 (байты)
    lea esi, [array]

    mov ebx, [esi + eax]  ; save array[1][2]
    mov ecx, 1
    mov edx, 3
    mov eax, ecx
    mov ecx, [m]
    imul eax, ecx        ; 1 * 4 = 4
    add eax, edx         ; 4 + 3 = 7
    shl eax, 2           ; байты
    mov edi, esi

    mov edx, [edi + eax] ; save array[1][3] into edx
    mov [esi + eax], ebx ; array[1][3] = array[1][2]
    mov [esi + eax - 4], edx ; array[1][2] = array[1][3], так как индекс 6 это на 4 байта меньше, чем 7

    ; Подсчет суммы положительных и количества отрицательных элементов
    xor esi, esi      ; индекс от 0 до 11 (3*4 = 12 элементов)
    mov dword [sum], 0
    mov dword [neg_count], 0

count_loop:
    cmp esi, 12
    jge print_results

    mov eax, [array + esi*4]

    cmp eax, 0
    jg add_sum
    jl inc_neg
    jmp next_item

add_sum:
    mov ebx, [sum]
    add ebx, eax
    mov [sum], ebx
    jmp next_item

inc_neg:
    mov ebx, [neg_count]
    inc ebx
    mov [neg_count], ebx

next_item:
    inc esi
    jmp count_loop

; Вывод массива и результатов
print_results:
    push fmt_title
    call [printf]
    call print_array

    push dword [sum]
    push fmt_sum
    call [printf]
    add esp, 8

    push dword [neg_count]
    push fmt_neg
    call [printf]
    add esp, 8

    push msg_wait
    call [printf]
    call [getchar]

    invoke ExitProcess, 0

print_array:
    push ebp
    mov ebp, esp

    xor esi, esi

print_rows:
    cmp esi, [n]
    jge print_done

    xor edi, edi

print_cols:
    cmp edi, [m]
    jge new_line

    mov eax, esi
    imul eax, [m]
    add eax, edi
    shl eax, 2
    mov ebx, [array + eax]

    push ebx
    push fmt_int
    call [printf]
    add esp, 8

    inc edi
    jmp print_cols

new_line:
    push fmt_line
    call [printf]

    inc esi
    jmp print_rows

print_done:
    mov esp, ebp
    pop ebp
    ret

section '.idata' import data readable
library kernel32,'kernel32.dll',\
        msvcrt,'msvcrt.dll'

import kernel32,\
       ExitProcess,'ExitProcess'

import msvcrt,\
       printf,'printf',\
       getchar,'getchar'

