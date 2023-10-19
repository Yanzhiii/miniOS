;Main Boot Record
;-------------------------------------------------------------------------------
SECTION MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00

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

;INT 0x10   FUNC 0x03
;Video: Sence the cursor's position, starting line and ending line in a
;       display page.
;-------------------------------------------------------------------------------
;Input:
;AH = 0x03
;BH = Dispaly page number
;CH = Starting line of the blinking cursor
;CL = Ending line of the blinking cursor
;(DL, DH) = Screen line in which the cursor is located
;Output:
;No output
;;;;;;;;    Get Cursor Position    ;;;;;;;;
    mov ah, 3
    mov bh, 0

    int 0x10
;;;;;;;;    END    ;;;;;;;;

;INT 0x10   FUNC 0x13
;Video: Write character string
;-------------------------------------------------------------------------------
;Input:
;AH = 0x13
;AL = Output mode (0-3)
;       0: Attribute in BL, retain cursor position
;       1: Attribute in BL, update cursor position
;       2: Attribute in the buffer, retain cursor position
;       3: Attrivute in the buffer, update cursor position
;BH = Dispaly page number
;BL = Attribute byte of the character
;BP = Offset address of the buffer
;CX = Number of characters to be displayed
;DH = display line
;DL = display column
;ES = segment address of the buffer
;Output:
;No output
;;;;;;;;    Print String    ;;;;;;;;
    mov ax, message
    mov bp, ax

    mov cx, 5
    mov ax, 0x1301
    mov bx, 0x2

    int 0x10
;;;;;;;;    END    ;;;;;;;;

    jmp $

    message db "1 MBR"
    times 510-($-$$) db 0
    db 0x55, 0xaa