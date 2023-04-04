include \masm32\include\masm32rt.inc

.data?
hInstance dd ?
hEvent1 dd ?
hEvent2 dd ?
Thread1ID dd ?
Thread2ID dd ?
tmpV dd ?


.data
txt_wstep db "sqrt(",NULL
txt_wstep_zam db ")=",NULL
txtp db '.',NULL
akapit db 10,13,NULL
stopien_pierwiastka dw 2 ;stopien pierwiastka
pol  dd 3EFFFFFFh
dz dw 10
bufor dw 0
trash dw 0

.code
NewtonRaphonsa proc liczba_pierwiastkowana:DWORD
    LOCAL wynik:DWORD

    @processRaph:
        finit							;zainicjalizowanie liczby zmiennoprzecinkowej
        fild liczba_pierwiastkowana     ;zamienienie argumentu z int na double i wrzucenie go na stos
        fild stopien_pierwiastka	    
        fdivp st(1),st(0)				;dzielenie elementu zerowego stosu przez pierwszy
        push ecx
        mov ecx,07000000h 
        cmp liczba_pierwiastkowana, 0 
        je @endProcess					;jezeli liczba jest rowna 0 zakoncz proces
		@process:
			fldz						;popchnij na stack
			fadd st(0),st(1)			;dodaj zawartosc zerowego elementu stosu do pierwszego i zwroc wartosc do pierwszego
			fild liczba_pierwiastkowana 
			fxch st(1)					;zamien wartosc zerowego elementu stosu i pierwszego elementu
			fdivp st(1),st(0) 
			faddp st(1),st(0)			;dodawanie elementu zerowego stosu do pierwszego
			fidiv stopien_pierwiastka   ;podziel zerowy element stacku przez stopien pierwiastka i zwroc tam wartosc
		loop @process
	pop ecx
  @endProcess:
	fstp wynik							;skopiuj zawartosc z elementu zerowego na stosie do wyniku
	mov eax,wynik 
  ret
NewtonRaphonsa endp

ShowResult proc liczba_pierwiastkowana2:WORD, re_wynik:DWORD
    LOCAL wynik:DWORD

    finit
    fld re_wynik						;zaladuj zawartosc re_wynik na zerowy element
    fstp wynik
    fld wynik

    INVOKE WriteConsole, hInstance, OFFSET txt_wstep, 5, ADDR tmpV, NULL
    INVOKE WriteConsole, hInstance, ADDR liczba_pierwiastkowana2 , 1, ADDR tmpV, NULL 
    INVOKE WriteConsole, hInstance, OFFSET txt_wstep_zam,2, ADDR tmpV, NULL 

    mov ecx,4 
    @process_print:
	   fild dz 
	   fxch st(1) 
	   fprem							;podziel zerowy elementu stosu przez pierwszy i zwroc reszte z dzielenia do zerowego
	   fsub pol							;odejmij zawartosc pol od zerowego elementu stosu i zwroc tam roznice
	   fist bufor						;zamien wartosc w zerowym elemencie stosu na signed integer i przekaz wynik do bufora
	   fadd pol
	   fmulp st(1),st					;pomnoz pierwszy element ze stosu przez zerowy i zwroc wynik do zerowego
	   mov dx,bufor						;zapisz zawartosc bufora do rejestru dx
	   add dx,30h						;dodaj 30h ('0') do rejestru dx (potrzebne, aby poprawnie wyswietlic liczby zawierajace wiecej niz 1 znak)
	   mov bufor,dx						;zapisz zawartosc rejestru dx do bufora
	   push ecx
	   INVOKE WriteConsole, hInstance, OFFSET bufor, 1,ADDR tmpV, NULL
	   pop ecx
	   cmp ecx,4
	   jne @end_process_print
	   push ecx
	   INVOKE lstrlen, OFFSET txtp 
	   INVOKE WriteConsole, hInstance, OFFSET txtp, eax,ADDR tmpV, NULL 
	   pop ecx
	   @end_process_print:
    loop @process_print
    fistp trash							;zamien wartosc zerowego elementu stosu na inte i zapisz wynik w trash
    INVOKE lstrlen, OFFSET akapit
    INVOKE WriteConsole, hInstance, OFFSET akapit, eax,ADDR tmpV, NULL  
    ret
ShowResult endp

Thread1 proc hIns:DWORD
    mov ecx, 5 
        p1:
		push ecx   
		push ebx
		push eax
		mov ebx,ecx 
		mov al,2
		mul bl
		mov bx,ax
		sub bx,1
		mov edx,ebx
		pop eax
		pop ebx
		push edx
		INVOKE NewtonRaphonsa, edx 
		pop edx 
		add dl,30h
		INVOKE ShowResult, dx, eax
		INVOKE Sleep, 500
		pop ecx
     loop p1
     INVOKE SetEvent, hEvent1 
  ret
Thread1 endp

Thread2 proc hIns:DWORD
mov ecx, 5
    p1:      
	push ecx   
	push ebx
	push eax
	mov ebx,ecx
	mov al,2
	mul bl
	mov bx,ax
	sub bx,2
      mov edx,ebx
	pop eax
	pop ebx
	push edx
	INVOKE NewtonRaphonsa, edx
	pop edx
	add dl,30h
	INVOKE ShowResult, dx, eax
	INVOKE Sleep, 500
	pop ecx
    loop p1
    INVOKE SetEvent, hEvent2
 ret
Thread2 endp

Start:
    INVOKE AllocConsole 
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov hInstance, eax
    INVOKE CreateEvent, NULL, TRUE, FALSE, NULL 
    mov hEvent1, eax
    INVOKE CreateEvent, NULL, TRUE, FALSE, NULL 
    mov hEvent2, eax
    INVOKE CreateThread, NULL, 0, OFFSET Thread1, 0,0,OFFSET Thread1ID
    INVOKE CreateThread, NULL, 0, OFFSET Thread2, 0,0,OFFSET Thread2ID
    INVOKE WaitForMultipleObjects, 2, OFFSET hEvent1, TRUE, INFINITE		
    INVOKE FreeConsole 
    INVOKE ExitProcess,0
END Start