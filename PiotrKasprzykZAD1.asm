;Piotr Kasprzyk
;Zad nr 1

; program wyswietlajacy liczbe podana w systemie szesnastkowym w formie binarnego baneru
; zakres wczytywanych liczb to od 0 do f
.model tiny ; model, w ktorym kod i dane mieszcza sie w jednym 64kB segmencie -typowym dla programow typu .com
.code
org 100h 

start:	    
        xor     ax, ax
		mov 	ah, 8               ; wczytanie pojedynczego znaku do AL
		int 	21h				
		     
	    mov     liczba, al          ; zapisanie wczytanego znaku do zmiennej, uzywane do debugowania -zeby sprawdzic czy wczytana cyfra jest poprawna
 
     ;   sub     liczba, 48          ; zamiana kodu ASCII na liczbe
	    	              
        ;======konwersja z kodu ASCII do wartosci liczbowej========	    	            
	    mov   bl, liczba                  
        cmp   bl, 48
        jb    wypisz_info       ; kod ASCII nie moze byc mniejszy niz 48 --> 0
              
        cmp   bl, 102           ; kod ASCII nie moze byc wiekszy niz 102 --> f
        ja    wypisz_info               	    

        cmp   bl, 57            ;
        jbe   konwersja_09      ; kod ASCII <= 57
        
        ; jesli dotarlismy tu to kod w zakresie 59 do 102
        cmp   bl, 65            ;  59 <= ASCII <= 64
        jb    wypisz_info
        
        cmp   bl, 70
        jbe   konwersja_duze_AF      
        
        ;jesli tu jestesmy, to  71 <= ASCII <= 102
        cmp   bl, 97
        jb    wypisz_info     ; ASCI < 97
        
        ;jesli to, to 97 <= ASCII <= 102
        jmp konwersja_male_af
	       
	    ; co jesli liczba z zakresu A-F (ASCI: 65 - 70)?
	    
	    ; a co jesli z zakresu a-f (ASCI: 97 - 102)?
	        ;sprawdzic cmp 
	        ;jak z zakresu to jeszcze odjac               
koniec_konwersji:        	                 
	    ;==============koniec konwersji================
	    
	    ; bl - wartosc dzisietna wpisanej liczby 
	        
	    ;========== obliczanie kolejnych reszt z dzielenia =========
	    mov cx, 4           ; tyle mamy reszt z dzielenia do obliczenia, bo rozwazane liczby w kodzie hex to od 0 do f
	    mov bp, 0           ; indeks wskazujacy ktora reszte zapisujemy
petla:  
        xor bh, bh          ; aby miec pewnosc, ze w bh jest 0
        mov ax, bx          ; do ax przenosimy bx (gdzie bh=0 a w bl znajduje sie wczytana liczba)
        div dwa             ; ah - reszta, al - wynik dzielenia 
           
        
        mov byte ptr ds:[reszty + bp], ah                        ; Drozdowski str. 21
        ;mov dl, [reszty + bp]  ;skrocony zapis tego co wyzej -sprawdzmy czy otrzymalismy poprawna reszte 
        inc bp
        mov bl, al          ; bl = bl / 2
        
        loop petla	    
	    ;==========================================================
	    ; reszta[0] <--- najmniej znaczaca cyfra
	    ; ...
	    ; reszta[3] <--- najbardziej znaczaca cyfra
	    
	    ;=======tworzenie banera=========
	    
	    
	    
	    jmp drukuj_baner
	    ;================================
	    

                    ;mov     ah, 9               ; wypisanie znaku
	                ;mov     dx, offset liczba
	                ;int     21h
		   
drukuj_baner:
        mov     cx, 7               ; tyle jest wierszy (po 28 znakow kazdy -bo 28=4*7)
        mov     bp, 0               ; ktory wiersz przepisujemy
petla2:
        call przepisz_wiersz            

        ;wypisanie danego wiersza
        mov     ah, 9              
	    mov     dx, offset wiersz
	    int     21h 
	    
	    inc bp		
	    loop petla2
		  
koniec:	mov 	ax, 4c00h           ; zakonczenie programu
		int 	21h

wypisz_info:                             ;wypisywanie komunikatu o zakresie
        mov     ah, 9
        mov     dx, offset info_zakres        
        int     21h
        jmp     koniec

;========== podfunkcje do konwersji =================
konwersja_duze_AF:
        sub bl, 55     
        jmp koniec_konwersji
        
konwersja_male_af:
        sub bl, 87                    
        jmp koniec_konwersji
        
konwersja_09:                                 
	sub   bl, 48                ; bl zawiera wartosc liczbowa wczytanej liczby, z kodu ASCII przechodze na wartosc dziesietna
	jmp koniec_konwersji
;=====================================================	
przepisz_wiersz:    
    mov di, 0           ; di - wskaznik komorki wiersza
    
    push cx
    mov cx, 4           ; liczba cyfr 
    powtorz:                                             
       ;-- ustawianie wskaznika cyfry na poczatek bp-tego wiersza--
       mov ax, bp          ; ax = nr_wiersza
       mov bh, 7           ; szerokosc cyfry
       mul bh              ; ax = ax * 7
       mov si, ax          ; si = nr_wiersza * szerokosc = ax * 7     
                           ; si - wskaznik komorki cyfry 
       ;-----------------------------------------------------------
       push bp            ; zapamietanie na stosie nr wiersza cyfry
       mov bp, cx         ; ktora cyfre przepisujemy bp = 4
       dec bp             ; cyfra pierwsza (najbardziej znaczacza) ---> reszta[3], stad bp = 3
       ;-----------------------------------------------------------
       
       push cx
       mov cx, 7            ; dla kazdej z 4 cyfr banera przepisujemy 7 komorek z bp-tego wiersza           
       
       ;============== przepisanie wiersza jendnej cyfry ======================
       powtorz2:            
            cmp [reszty + bp], 1    ; sprawdzamy reszte z dzielenia przez 2 
            je przepisz_jeden
            ; przepisanie zera
            mov dh, [zero + si]
            mov [wiersz + di], dh
            jmp koniec_przepisz_jeden
            ;--------------------
       przepisz_jeden:
            mov dh, [jeden + si]
            mov [wiersz + di], dh  
       koniec_przepisz_jeden:
            ;--------------------
            
            inc di          ; kolejna komorka wiersza
            inc si          ; kolejna komorka cyfry
       loop powtorz2
       ;============== wiersz cyfry przepisany============================
             
       pop cx               ; ile cyfr do przepisania pozostalo
       pop bp               ; przypominamy sobie, ktory wiersz cyfry przepisywalismy
    loop powtorz
    pop cx
ret	                    
	                    
;=====================================================	                    
	liczba db ?, "$"   
			
	info_zakres db "Blad! Podaj liczbe z przedzialu od 0 do F", "$" 
	
	zero 	db		"  ###  "              ; 7 bajtow
	        db 	    " #   # "              ; 7 bajtow
            db      "#     #"              ; ...
            db      "#     #"
            db      "#     #"
            db      " #   # "
            db      "  ###  "
   
   jeden 	db		"   #   "
        	db 	    "  ##   "
            db      " # #   "
            db      "   #   "
            db      "   #   "
            db      "   #   "
            db      " ##### "         
      
   dwa      db  2 
   reszty   db  4 dup(0)      ; kolejne reszty z dzielenie przez 2 liczby zapisanej w bl (zapisane w kolejnosci odwrotnej)
                  
   wiersz   db  4 dup("XXXXXXX"), 10, 13, "$"                                           
   
end start 

		
		