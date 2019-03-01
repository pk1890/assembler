
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

mov ah, 00h
mov al, 03h
int 10h       ;odpal w trybie tekstowym          
    

mov [02h], 'K'
mov [04h], 'U'
mov [06h], 'R'      
mov [08h], 'W'
mov [0ah], 'A'             


mov ah, 013h ;wypisz stringa
mov bl, 00fh ;kolor
mov cx, 5; len of str
mov dh, 0 ;row
mov dl, 0 ;col
int 10h

;ustaw kursor po slowie wyzej
mov ah, 02h
mov dh, 03h  ;trzeci row
mov dl, 00h  ;zerowa kolumna
int 10h
           
mov dx, 02h  
mov ah, 09h
mov al, '!'      
mov bl, 00fh           
mov cx, 100
int 10h      ;wypisz 100x 'F'        
            
            

           
ret




