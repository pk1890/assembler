dane1 segment
 
txt1	db "To jest tekst ! :) $"
	db ?
adres1	dw 1345
 
dane1 ends
 
 
 
 
code1 segment
 
start1:
	;inicjowanie stosu
	mov	sp, offset wstosu
	mov	ax, seg wstosu
	mov	ss, ax
 
	mov al, 13h
	mov ah, 0
	int 10h     ; set graphics video mode. 
    
    
    mov dx, 0A000h ; wskaz na pamiec vga
	mov es, dx

    mov bx, 500
    lp:
    mov byte ptr es:[bx], 13
    dec bx
    jne lp

 
    mov ah, 1
    int 21h       

	mov	ah,4ch  ; zakoncz program i wroc do systemu
	int	021h
 
code1 ends
 
 
 
stos1 segment stack
	dw 200 dup(?)
wstosu	dw ?
stos1 ends
 
 
end start1