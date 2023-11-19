;Main Boot Record
;-------------------------------------------------------------------------------
%include "boot.inc"
SECTION MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800
    mov gs, ax

;INT 0x10   FUNC 0x06
;Video: Intialize window/scroll text upward.
;-------------------------------------------------------------------------------
;Input:
;AH = 0x06
;AL = Number of window lines to be scrolled upward(0=clear window)
;BH = Color (attribute) for blank line(s)
;(CL, CH) = Upper left corner of the window
;(DL, DH) = Lower right corner of the window
;Output:
;No output
;;;;;;;;    Clear Window    ;;;;;;;;
    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0
    mov dx, 0x184f

    int 0x10

;Using graphics card
    mov byte [gs:0x00],'1'
    mov byte [gs:0x01],0xA4

    mov byte [gs:0x02],' '
    mov byte [gs:0x03],0xA4

    mov byte [gs:0x04],'M'
    mov byte [gs:0x05],0xA4

    mov byte [gs:0x06],'B'
    mov byte [gs:0x07],0xA4

    mov byte [gs:0x08],'R'
    mov byte [gs:0x09],0xA4

    mov eax, LOADER_START_SECTOR    ;LBA start sector
    mov bx, LOADER_BASE_ADDR
    mov cx, 1                       ;number of sectors to read
    call rd_disk_m_16

    jmp LOADER_BASE_ADDR

;-------------------------------------------------------------------------
;Function: Read n sectors from disk
rd_disk_m_16:
;-------------------------------------------------------------------------
        mov esi, eax    ;backup eax
        mov di, cx      ;backup cx
;Read and write disk:
;Step 1: Set the number of sectors to read
        mov dx, 0x1f2
        mov al, cl
        out dx, al      ;number of sectors to read

        mov eax, esi    ;recover ax

;Step 2: Store the LBA address to 0x1f3 ~ 0x1f6

        ;LBA bits 7 ~ 0 are written to port 0x1f3
        mov dx, 0x1f3
        out dx, al

        ;LBA bits 15 ~ 8 are written to port 0x1f4
        mov cl, 8
        shr eax, cl
        mov dx, 0x1f4
        out dx, al

        ;LBA bits 23 ~ 16 are written to port 0x1f5
        shr eax, cl
        mov dx, 0x1f5
        out dx, al

        shr eax, cl
        and al, 0x0f    ;LBA bits 24 ~ 27
        or al, 0xe0     ;set bits 7 ~ 4 to 1100 for LBA mode
        mov dx, 0x1f6
        out dx, al

;Step 3: Write read command 0x20 to port 0x1f7
        mov dx, 0x1f7
        mov al, 0x20
        out dx, al

;Step 4: Check disk status
    .not_ready:
        nop
        in al, dx
        and al, 0x88
        cmp al, 0x08
        jnz .not_ready

;Step 5: Read data from port 0x1f0
        mov ax, di      ;di is number of sectors to read
        mov dx, 256     ;one sector has 512 bytes, read in one word at a time so di*256
        mul dx
        mov cx, ax
        mov dx, 0x1f0
    .go_on_read:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop .go_on_read
        ret

    times 510-($-$$) db 0
    db 0x55, 0xaa