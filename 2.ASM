format PE console
entry start

include 'win32a.inc'

section '.data' data readable writeable
n dd 4
m dd 3

; Исходный массив 4?3
array dd  1, -2,  3, \
         4,  -5, 6, \
        -7,  8,  9, \
        10, -11, 12

fmt_int db "%6d ",0
fmt_line db 13,10,0

msg_init     db 13,10,"Initial array:",13,10,0
msg_max_neg  db 13,10,"After negating max elements in each row:",13,10,0
msg_swap    db 13,10,"After swapping first and last columns:",13,10,0
msg_wait db 13,10,"Press any key to exit...",13,10,0

section '.code' code readable executable
start:
    push msg_init
    call [printf]
    call print_array_func

    ; ===== 1. Заменить максимум в каждой строке на противоположный по знаку =====
    xor esi, esi

find_max_in_rows:
    cmp esi, [n]
    jge after_max_negation

    mov edi, array

    ; Получить первый элемент строки в ebx (array[i][0])
    mov eax, esi
    imul eax, [m]
    shl eax, 2
    mov ebx, [edi + eax]

    xor ecx, ecx                 ; индекс максимума = 0
    mov edx, 1                   ; j = 1

.find_max_loop:
    cmp edx, [m]
    jge .found_max

    mov eax, esi
    imul eax, [m]
    add eax, edx
    shl eax, 2
    mov eax, [edi + eax]

    cmp eax, ebx
    jle .next_j
    mov ebx, eax
    mov ecx, edx
.next_j:
    inc edx
    jmp .find_max_loop

.found_max:
    mov eax, esi
    imul eax, [m]
    add eax, ecx
    shl eax, 2

    neg dword [edi + eax]

    inc esi
    jmp find_max_in_rows

after_max_negation:
    push msg_max_neg
    call [printf]
    call print_array_func

    ; ===== 2. Поменять местами первый и последний столбцы =====
    xor esi, esi

swap_loop:
    cmp esi, [n]
    jge after_swap_columns

    mov edi, array

    ; load array[i][0]
    mov eax, esi
    imul eax, [m]
    shl eax, 2
    mov ebx, [edi + eax]

    ; load array[i][m-1]
    mov ecx, [m]
    dec ecx
    mov edx, esi
    imul edx, [m]
    add edx, ecx
    shl edx, 2
    mov edi, array
    mov ecx, [edi + edx]

    mov edi, array
    mov [edi + eax], ecx
    mov [edi + edx], ebx

    inc esi
    jmp swap_loop

after_swap_columns:
    push msg_swap
    call [printf]
    call print_array_func

    ; Пауза перед выходом
    push msg_wait
    call [printf]
    call [getchar]
    invoke ExitProcess, 0

; ===== Функция вывода массива =====
print_array_func:
    push ebp
    mov ebp, esp

    push esi
    push ecx
    push eax
    push ebx
    push edi

    mov edi, array
    xor esi, esi           ; i = 0

print_row:
    cmp esi, [n]
    jge print_array_done

    xor ecx, ecx           ; j = 0

print_col:
    cmp ecx, [m]
    jge print_newline

    mov eax, esi
    imul eax, [m]
    add eax, ecx
    shl eax, 2
    mov ebx, [edi + eax]

    push ebx
    push fmt_int
    call [printf]
    add esp, 8

    inc ecx
    jmp print_col

print_newline:
    push fmt_line
    call [printf]

    inc esi
    jmp print_row

print_array_done:
    pop edi
    pop ebx
    pop eax
    pop ecx
    pop esi

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
