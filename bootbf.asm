[org 0x7c00]
boot:
    mov ah, 0x42 ; Extended read
    mov si, dap ; Pointer to the DAP
    int 0x13 ; Read from the disk

    mov si, 0x9000 ; We read the disk at 0x9000
    mov di, 0x7e00 ; Start program memory immediately after the bootsector
    .run:
        lodsb ; Read one byte from si into al and increment si

        cmp al, '+' ; Check for +
        jne .no1
        inc byte [di] ; If we have a +, increment the byte pointer to by di

        .no1:
        cmp al, '-' ; Check for -
        jne .no2
        dec byte [di] ; If we have a -, decremet the byte pointed to by di

        .no2:
        cmp al, '>' ; Check for >
        jne .no3
        inc di ; If we have a >, increment the pointer

        .no3:
        cmp al, '<' ; Check for <
        jne .no4
        dec di ; If we have a <, decrement the pointer
        ; Segfaults, here we come

        .no4:
        cmp al, '.' ; Check for .
        jne .no5
        push ax
        mov ah, 0x0e
        mov al, [di]
        int 0x10 ; If we have a ., use int 0x10 to print out the byte pointed to by di
        pop ax

        .no5:
        cmp al, ',' ; Check for ,
        jne .no6
        push ax
        mov ah, 0
        int 0x16 ; If we have a ,, use int 0x16 to read a byte from the keyboard into memory
        mov [di], al
        pop ax

        ; Now looping instructions - this is where it gets tricky

        .no6:
        cmp al, '[' ; Check for [
        jne .no7
        cmp byte [di], 0 ; Don't jump if the byte under the pointer is 0
        jne .no7
        mov cl, 0
        inc si ; Move one byte ahead
        .fm1:
            mov bl, [si] ; Read one byte
            cmp bl, '[' ; If it's a [, start nesting
            jne .fm1noic
            inc cl
            .fm1noic: ; We didn't have a [, check for a ]
            cmp bl, ']'
            jne .fm1nodc
            cmp cl, 0 ; If it's a ], first see if it matches the current bracket
            je .fm1d ; If it does, exit
            dec cl ; Otherwise, decrement the nesting level
            .fm1nodc:
            inc si ; Go to the next byte
            jmp .fm1
        .fm1d:
            inc si ; Skip over the closing bracket

        .no7:
        cmp al, ']' ; Check for ]
        jne .no8
        cmp byte [di], 0 ; If the byte under the pointer is 0, then don't jump
        je .no8
        mov cl, 0
        sub si, 2 ; Go back to the byte before the ]
        .fm2:
            mov bl, [si] ; Load one byte from si
            cmp bl, ']' ; Check for a ]
            jne .fm2noic
            inc cl ; If it is a ], increment the nesting level
            .fm2noic:
            cmp bl, '[' ; Check for [
            jne .fm2nodc
            cmp cl, 0 ; If there is a [, check if it is the matching one
            je .no8
            dec cl ; If it's not, decrement the nesting level
            .fm2nodc:
            dec si ; Go back one byte
            jmp .fm2

        .no8:

        or al, al ; Check if the byte is 0
        jnz .run ; If it's not, loop

    cli ; Halt the system
    hlt

dap:
    db 0x10 ; Size of DAP
    db 0x00 ; Zero
    dw 0x80 ; Number of sectors to read
    dw 0x9000 ; Offset
    dw 0x0000 ; Segment
    dq 0x01 ; Starting sector to read fromawszxcv;,

times 510-($-$$) db 0
dw 0xaa55
