

dane1 segment
emptytxt db ' $'    
hellotxt db "KALKULATOR NIE PRZESTRZEGA KOLEJNOSCI WYKONYWANIA DZIALAN", 0ah, 0dh, "(dziala jak lewostronne nawiasowanie)", 0ah, 0dh, "Wprowadz slowny opis dzialania:  $"        
error_msg db 'Nieprawidlowe dane $'         
print_error_msg db 'liczba spoza zakresu wypisywania $' 
plus db 'plus $'
minus db 'minus $'
razy db 'razy $'
zero db "zero $"
one db "jeden $"
two db "dwa $"
three db "trzy $"
four db "cztery $"
five db "piec $"
six db "szesc $"
seven db "siedem $"
eight db "osiem $"
nine db "dziewiec $"
ten db "dziesiec $"
eleven db 'jedenascie $'
twelve db 'dwanascie $'
thirteen db 'trzynascie $'
fourteen db 'czternascie $'
fifteen db 'pietnascie $'
sixteen db 'szesnascie $'
seventeen db 'siedemnascie $'
eighteen db 'osiemnascie $'
nineteen db 'dziewietnascie $' 
twenty db 'dwadziescia $'
thirty db 'trzydziesci $'
fourty db 'czterdziesci $'
fifty db 'piecdziesiat $'
sixty db 'szescdziesiat $'
seventy db 'siedemdizesiat $'
eighty db 'osiemdziesiat $'
ninety db 'dziewiecdziesiat $'
hundred db 'sto $'
buffer db 128,?, 128 dup(0)   ;bufor na podanego stringa
result dw 0000h ; wynik
db 100 dup(0)

dane1 ends

code1 segment
    
start1:
    ;inicjowanie stosu
    mov sp, offset peak
    mov ax, seg peak
    mov ss, ax
             
         
    mov dx, offset hellotxt
    mov ax, seg hellotxt
    mov ds, ax
    mov ah, 9 ;wypisz stringa z from ds:dx
    int 21h  
        
    mov dx, offset buffer
    mov ah, 0ah           ;czytaj stringa
    int 21h
    
    xor bx, bx                      ; zeruj bx
    mov bl, byte ptr ds:buffer[1]      ; na 1 bajcie budora jest ile znakow sczytano
    mov byte ptr ds:buffer[bx+2], ' '
    mov byte ptr ds:buffer[bx+3], '$'  ; dodaj na koncu sczytanego stringa $
    
    mov ah, 2
	mov dl, 0ah ; wypisz \n
	int 21h 
	
	mov ah, 2
	mov dl, 0dh ; wypisz crt
	int 21h     
        
    mov bx, offset buffer + 2  ;opusc dwa pierwsze bajty buforu (dlugosc buforu i ilosc sczytanych bajtow
    
    xor cx, cx; wyzeruj cx - w cl bedzie kod dzialania
    mov cl, 01h; ustaw na dodawanie (wpisanie pierwszej liczby to to samo co zero + liczba, a bufor wyniku na poczatku jest zapisany zerami)
    ;;;;;;TABELKA KODOW
    ; 01h add
    ; 02h sub
    ; 03h mul
    ;

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   

    looop: ;glowna petla wykonania programu
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CZYTAJ LICZBE

    call delspace ;usun spacje z poczatku stringa
    
    mov al, byte ptr ds:[bx] ; sprawdz czy pierwszy znak stringa to nie dolar (czyli ze koniec)
    cmp al, '$'                                                             
    je wrong_input ;jesli tak to koncz z bledem (tzn ze podano operator a potem nie bylo liczby)
    
    call read_num ;parsuj slowo na liczbe               
    
    cmp al, 080h  ; obsluz bledne dane
    je wrong_input                    


    cmp cl, 01h
    je adding

    
    cmp cl, 02h
    je substracting

    
    cmp cl, 03h
    je multiplying



    calculate:
    cmp word ptr ds:result, 128 ;obsluga overflow
    jge eoverflow

    cmp word ptr ds:result, -127
    jl eoverflow
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CZYTAJ OPERATOR
  ;  xor ah, ah ; wyczysc ah    
 ;   push ax ;odluz liczbe na stos (wprowadzona liczba jest w al)   
     

    ;add byte ptr result, al
    call delspace ;usun spacje z poczatku stringa
    
    mov al, byte ptr ds:[bx] ; sprawdz czy pierwszy znak stringa to nie dolar (czyli ze koniec)
    cmp al, '$'                                                             
    je eend ;jesli tak to koncz
    
    call read_operator ;parsuj slowo na liczbe               
    
    cmp cl, 080h  ; obsluz bledne dane
    je wrong_input  
                             
                                 
   
    
    jmp looop ;koniec petli glownej
    
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
    
    
    eend:
    mov ax, word ptr ds:result ; przerzuc wynik do ax
    
    call print_unum_word   ; wypisz slownie liczbe z ax
    
    exit:                          
    mov	ah,4ch  ; zakoncz program i wroc do systemu   
	int	021h    
	
	wrong_input: ; jak blad to wystietl wiadomosc i koncz
	mov dx, offset error_msg
	mov ah, 9
	int 21h
	jmp exit

    eoverflow:
    mov dx, offset print_error_msg
	mov ah, 9
	int 21h
	jmp exit
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    adding:
    add word ptr ds:result, ax
    jmp calculate

    substracting:
    sub word ptr ds:result, ax
    jmp calculate
    
    multiplying:
    push dx
   ; xor dx, dx; wyzeruj dx - po jego zmianie bedziemy wiedziec czy byl overflw
    mov cl, al; wyslij do cx liczbe przez ktora mnozymy
    mov al, byte ptr ds:result ; do ax zaladuj result
    imul cl ; pomnoz
    cmp ax, 127  
    je eoverflow
    cmp ax, -127
    jl eoverflow
    mov word ptr ds:result, ax; zapisz wynik
    pop dx
    jmp calculate
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CZESC KODU PROCEDUR;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
	
	delspace:; utnij spacje z pocztaku stringa zaczynajacego sie na adresie ds:bx  
    delspace_loop:
    
    mov ah, byte ptr ds:[bx]
    mov al, 9
    cmp al, ah ; sprawdz czy pierwszy znak to tabulacja
    je loop_delspace ;jak tak to nastepna iteracja
    
    mov ah, byte ptr ds:[bx]
    mov al, 20h
    cmp al, ah ; sprawdz czy pierwszy znak to spacja
    je loop_delspace ;jak tak to nastepna iteracja 
    ret 

    loop_delspace:
    inc bx ;jak tak to przesun na nastepny bit
    jmp delspace_loop ;powtorz
    
    
    ;delspace endp
	
	
	 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    checkword: ; sprawdza, czy slowo zaczynajace sie na adresie ds:bx zgadza sie ze wzorcem pod adresem ds:ax (wynikiem jest odpowiednio ustwaiona flaga ZF)
    push bx ; zachowaj na stos wskaznik na poczatek stringa (jak sie nie zgadza ze wzorcem to go przywaraca)
    mov bp, ax ; wpisz do bp adres wzorca
            
    checkloop:        
    mov al, byte ptr [bx]    ;pierwszy bajt stringa do porownania
    mov ah, byte ptr ds:[bp]    ;pierwszy bajt wzorca

    
    cmp ah, 20h ;sprawdzam, czy ten znak to byla spacja
    je check_if_end

    je endfunc_checkword_good ;jak to byla spacja, to znaczy ze wprowadzone slowo zgadza sie ze wzornikiem
        
    sub al, ah ;czy sa takie same
    jne endfunc_checkword_wrong ;jak nie to koncz z bledem
    
    ok: ; jak ok to:
        
    inc bx  ;nastepny bajt
    inc bp  ;nastepny bajt
    jmp checkloop ;powtorz
    
    check_if_end:
    cmp al, 20h
    je endfunc_checkword_good
    cmp al, 9
    je endfunc_checkword_good

    jmp endfunc_checkword_wrong

    endfunc_checkword_wrong:
    pop bx ; przywroc wskaznik na przed slowem 
    ret                                       
    
    endfunc_checkword_good:
    add sp, 2          ;sciagnij wartosc ze stosu, bo juz jej nie potrzebujemy  ! zmienia zero flag
    cmp al, al ; ustaw zero flag
    ret
    
    ;checkword endp
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    read_num proc; procedura, ktora czyta slowo  zaczynajace sie na adresie ds:dx i zwraca jego wartosc w ax
    
    push cx

    mov ch, 00h; ch oznacza
    mov ax, offset minus  
    call checkword
    je negate_read_num
    
    mov ch, 00h; ch oznacza
    read_num_continue:
    
    mov ax, offset zero  
    call checkword
    mov ax, 0
    je endfunc_read_num
    
    mov ax, offset one  
    call checkword
    mov ax, 1
    je endfunc_read_num
    
    mov ax, offset two  
    call checkword
    mov ax, 2
    je endfunc_read_num     
    
    mov ax, offset three  
    call checkword
    mov ax, 3
    je endfunc_read_num
    
    mov ax, offset four  
    call checkword
    mov ax, 4
    je endfunc_read_num
    
    mov ax, offset five  
    call checkword
    mov ax, 5
    je endfunc_read_num
    
    mov ax, offset six  
    call checkword
    mov ax, 6
    je endfunc_read_num
    
    mov ax, offset seven  
    call checkword
    mov ax, 7
    je endfunc_read_num
    
    mov ax, offset eight  
    call checkword
    mov ax, 8
    je endfunc_read_num
                         
    mov ax, seg nine
    mov ds, ax                     
    mov ax, offset nine   
    call checkword
    mov ax, 9
    je endfunc_read_num 
    
    mov ax, offset ten  
    call checkword
    mov ax, 10
    je endfunc_read_num                      
                         
    mov ax, 080h   ; 080h oznacza nieprawidlowa wartosc
    
    endfunc_read_num:
    cmp ax, 080h ;sprawdz czy blad
    je wrong_input

    cmp ch, 01h
    je neg_read_num

    pop cx
    ret             

    neg_read_num:
    neg ax ;jak był minus wczesniej to al = -al

    pop cx
    ret

    negate_read_num:
    mov ch, 01h;zaznacz ze czytana liczba bedzie ujemna
    call delspace 
    jmp read_num_continue   ;czytaj nastepny wyraz             
                   
    read_num endp 
               
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;TODO
   read_operator proc ;parsuje operator  zaczynajacy sie na adresie ds:dx i zwraca jego kod w cl
        mov ax, offset plus  
        call checkword
        mov cl, 01h
        je endfunc_read_operator

        mov ax, offset minus  
        call checkword
        mov cl, 02h
        je endfunc_read_operator

        mov ax, offset razy  
        call checkword
        mov cl, 03h
        je endfunc_read_operator

        mov cl, 080h ;bledny operator

        endfunc_read_operator:
        ret

   read_operator endp           
               
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  
    print_unum_word proc ; wypisuje na ekranie slownie liczbe z ax (zakres od -100 do 100)
        push ax
        push bx
        push cx
        push dx ; zachowaj wartosci rejestrow
        
        cmp ax, 0
        jnl print_abs  ; jak ax >= 0 to nie zmieniaj znaku tylko wypisuj
        

        ;w przeciwnym wypadku odwroc znak ax i wypisz na ekranie 'minus'
        ;--------------------------------------------
        neg ax    ;ax = -ax
        push ax   ;push ax bo int21h wymaga zmiany ax
        mov dx, offset minus
        mov ah, 9   ;wyswietl minus
        int 21h
        pop ax    ;przywroc stara wartosc rejestru
        ;-------------------------------------
        
        
        print_abs: ;wypisywanie liczby dodatniej
        cmp ax, 100 
        jge print_sto ;jak rowne sto to osobna funkcja
        ;jg print_error  ; jak liczba > 100 to wyswietl ze nie jest w zakresie   
        
              
        xor dx, dx ; wyzeruj dx dla bezpieczenstwa     
              
        mov bx, 10
        div bx ;dzielimy przez 10 - wynik w ax, reszta w dx
        
        push dx ; przechowaj reszte z dzielenia
        
        cmp al, 0
        je sing_digit_print ;jak zero to przejdz do funkcji wypisywania jednosci
        
        cmp al, 1
        je teen_print ;jak 1 to prezjdz do funkcji wypisujacej "-nastki"
        
        ; przechowac liczbe jednosci i wypisac 
        cmp al, 2
        mov dx, offset twenty
        je double_dig_print
                           
        
        cmp al, 3
        mov dx, offset thirty
        je double_dig_print
        
        
        cmp al, 4
        mov dx, offset fourty
        je double_dig_print
        
        
        cmp al, 5
        mov dx, offset fifty
        je double_dig_print
        
        
        cmp al, 6
        mov dx, offset sixty
        je double_dig_print
        
        
        cmp al, 7
        mov dx, offset seventy
        je double_dig_print
        
        
        cmp al, 8
        mov dx, offset eighty
        je double_dig_print
        
        
        cmp al, 9
        mov dx, offset ninety
        je double_dig_print                   
          
        
        
        print_num_end:
        pop dx
        pop cx
        pop bx
        pop ax
        
        ret
        
        
        sing_digit_print:      
        pop dx ; zrzuc reszte z dzielenia
        mov ax, dx; przesun ja do ax
        
        cmp al, 0
        mov dx, offset zero
        je digit_printout

        cmp al, 1
        mov dx, offset one
        je digit_printout
        
        cmp al, 2
        mov dx, offset two
        je digit_printout
        
        cmp al, 3
        mov dx, offset three
        je digit_printout
        
        cmp al, 4
        mov dx, offset four
        je digit_printout
        
        cmp al, 5
        mov dx, offset five
        je digit_printout
        
        cmp al, 6
        mov dx, offset six
        je digit_printout
        
        cmp al, 7
        mov dx, offset seven
        je digit_printout
        
        cmp al, 8
        mov dx, offset eight
        je digit_printout
        
        cmp al, 9
        mov dx, offset nine
        je digit_printout
        

        digit_printout:
        mov ah, 9
    	int 21h
	    jmp  print_num_end 
        

        teen_print:
        pop dx ; zrzuc reszte z dzielenia

        mov ax, dx; przesun ja do ax
        
        cmp al, 0
        mov dx, offset ten
        je digit_printout

        cmp al, 1
        mov dx, offset eleven
        je digit_printout
        
        cmp al, 2
        mov dx, offset twelve
        je digit_printout
        
        cmp al, 3
        mov dx, offset thirteen
        je digit_printout
        
        cmp al, 4
        mov dx, offset fourteen
        je digit_printout
        
        cmp al, 5
        mov dx, offset fifteen
        je digit_printout
        
        cmp al, 6
        mov dx, offset sixteen
        je digit_printout
        
        cmp al, 7
        mov dx, offset seventeen
        je digit_printout
        
        cmp al, 8
        mov dx, offset eighteen
        je digit_printout
        
        cmp al, 9
        mov dx, offset nineteen
        je digit_printout


        double_dig_print:
        mov ah, 9 ; wypisz dziesiatki
    	int 21h

        pop dx ;zrzuc reszte z dzielenia i porownaj z zerem - zapobiega wypisaniu liczby np 40 jako 'czterdziesci zero'
        cmp dx, 0
        
        je print_num_end; jak nie to skoncz
        push dx
        jmp sing_digit_print ;jak rozne od zera to wypisz jednosci

        print_sto:  ; osobny przypadek zeby nie musiec dzielic przez 100
        xor ah, ah
        push ax
        mov dx, offset hundred
    	mov ah, 9          
    	int 21h
        pop ax
        sub ax, 100
        je print_num_end
      ;  push ax
	    jmp print_abs
        
        print_error:
           
        mov dx, offset print_error_msg
    	mov ah, 9
    	int 21h
	    jmp  print_num_end 
	    
	    
	    
	      
        
        
    print_unum_word endp
    
ret

code1 ends

stos1 segment stack
    dw 200 dup(?)
peak dw ?

stos1 ends

end start1


