include \masm32\include\masm32rt.inc

.data?
hInstance dd ?
hFile dd ?
hBuff dd ?
fSize dd ?
fName dd ?
readBytes dd ?
tmpV dd ?
argc dd ?
argv dd ?

.data
txt1 db "Brak parametrow.", NULL
txt2 db "Blad otwarcia pliku.", NULL
txt3 db "Blad odczytu pliku.", NULL
txt4 db "Blad alokacji pamieci.", NULL
txt5 db "Za duzo parametrow.", NULL

.code
Start:
invoke AllocConsole
invoke GetStdHandle, STD_OUTPUT_HANDLE
mov hInstance, eax

invoke GetCommandLineW
invoke CommandLineToArgvW, eax, addr argc
mov argv, eax
mov ebx, argc 

.if ebx == 1
  invoke lstrlen, addr txt1
  invoke WriteConsole, hInstance, addr txt1, eax, ADDR tmpV, NULL
  jmp @end
.endif

.if ebx == 2
  invoke GetCL, 1, addr fName
  invoke lstrlen, addr fName
  invoke CreateFile, addr fName, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_ARCHIVE, 0
  mov hFile, eax

  .if eax == INVALID_HANDLE_VALUE
    invoke lstrlen, addr txt2
    invoke WriteConsole, hInstance, addr txt2, eax, ADDR tmpV, NULL
    jmp @end
  .endif

  invoke GetFileSize, hFile, 0
  mov fSize, eax
  invoke VirtualAlloc, 0, eax, MEM_COMMIT, PAGE_READWRITE

  .if eax == NULL
    invoke lstrlen, addr txt4
    invoke WriteConsole, hInstance, addr txt4, eax, addr tmpV, NULL
  .else
    mov hBuff, eax
    invoke ReadFile, hFile, eax, fSize, addr readBytes, 0

    .if eax == -1
      invoke lstrlen, addr txt3
      invoke WriteConsole, hInstance, addr txt3, eax, ADDR tmpV, NULL
    .else
      invoke WriteConsoleA, hInstance, hBuff, fSize, addr tmpV, NULL
    .endif

  .endif

  jmp @end

.endif

.if ebx == 3
  invoke GetCL, 1, addr fName
  invoke lstrlen, addr fName
  invoke CreateFile, addr fName, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0
  mov hFile, eax
  invoke GetCL, 2, addr tmpV
  invoke lstrlen, addr tmpV
  invoke WriteFile, hFile, addr tmpV, eax, 0, 0
  jmp @end
.endif

.if ebx>3
  invoke lstrlen, addr txt5
  invoke WriteConsole, hInstance, addr txt5, eax, addr tmpV, NULL
  jmp @end
.endif

invoke VirtualFree,eax,addr fSize,MEM_RELEASE
invoke CloseHandle, hFile 

@end:
invoke FreeConsole
invoke ExitProcess, 0

PUBLIC Start

END Start
