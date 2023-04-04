include \masm32\include\masm32rt.inc
include \masm32\include\ws2_32.inc
includelib \masm32\lib\ws2_32.lib

ID_MAIN    = 100
ID_LISTBOX = 101
ID_WYSLIJ  = 102
ID_TEXT    = 103
ID_IP      = 104
ID_NAPIS   = 105
ID_NAPIS2  = 106
ID_PORTTX  = 107
ID_PORTRX  = 108
ID_NAPIS3  = 109
ID_NAPIS4  = 112
ID_START   = 110
ID_PORTTX2 = 111

.data?                         
hInstance dd ?
hLog      dd ?
hThread   dd ?
hDlgEx    dd ?
hKlientRx dd ?
hSocketRx dd ?
hSocketTx dd ? 
hSocketTx2 dd ? 
wsadata WSADATA <>

.data              
buffRx      db 64 dup(NULL)
buffTx      db 64 dup(NULL)
buffTx2      db 64 dup(NULL)
txt1 db ' :: listen',NULL
txt2 db ' :: rx',NULL
txt3 db ' :: tx',NULL
kalkulator db 'calc.exe',NULL
komenda db '/kalkulator',NULL

.code                       

   Rx proc 
      LOCAL Port:DWORD
      LOCAL SockAddr:sockaddr_in
      LOCAL SockAddrLen:DWORD

      INVOKE GetDlgItemInt, hDlgEx, ID_PORTRX, ADDR Port, 0
	  mov Port, eax       
         
      INVOKE socket, AF_INET, SOCK_STREAM, 0
      mov hSocketRx, eax
      cmp eax, INVALID_SOCKET
      je @e1
      
      INVOKE htons, Port
        
      mov [SockAddr.sin_port],ax
      mov [SockAddr.sin_family],AF_INET
      mov [SockAddr.sin_addr],INADDR_ANY    
    
      INVOKE bind, hSocketRx, ADDR SockAddr, SIZEOF SockAddr
      INVOKE listen, hSocketRx, 1
      cmp eax, 0
      jne @e1

      INVOKE SendMessage, hLog, LB_ADDSTRING, 0, OFFSET txt1 
      @p1:
		 mov SockAddrLen, SIZEOF SockAddr
		 INVOKE accept, hSocketRx, ADDR SockAddr, ADDR SockAddrLen  
		 mov hKlientRx, eax
		 INVOKE recv, eax, OFFSET buffRx, 64, 0
		 INVOKE szCmp, OFFSET buffRx, OFFSET komenda
		 .IF eax==11
		 INVOKE ShellExecute,0,NULL,OFFSET kalkulator, NULL, 0, SW_SHOWNORMAL
		 .ENDIF
		 INVOKE SendMessage, hLog, LB_ADDSTRING, 0, OFFSET txt2
		 INVOKE SendMessage, hLog, LB_ADDSTRING, 0, OFFSET buffRx
      jmp @p1

      @e1:  
      ret  
   Rx endp  
   
  tx proc parametr:DWORD
     LOCAL SockAddr:sockaddr_in
     LOCAL IP:DWORD
     LOCAL szIP[128]:BYTE
     LOCAL Port:DWORD 
    
     INVOKE GetDlgItemText,hDlgEx,ID_IP,ADDR szIP,SIZEOF szIP

     INVOKE GetDlgItemInt, hDlgEx, ID_PORTTX, ADDR Port, 0
	 mov Port, eax
	 
     INVOKE gethostbyname,ADDR szIP
     cmp eax, 0
     jne AddrName

     INVOKE    inet_addr,ADDR szIP
     mov IP,eax

     INVOKE    gethostbyaddr,ADDR IP,4,AF_INET

     AddrName:

     cld
     lea esi,dword ptr [eax+hostent.h_len]
     lea edi,SockAddr.sin_addr
     lodsw
     movzx ecx,ax
     lodsd
     mov esi,dword ptr [eax]
     rep movsb        
                		

     INVOKE    inet_ntoa,DWORD PTR SockAddr.sin_addr
  
     INVOKE    lstrcpy,ADDR szIP,eax

     INVOKE    SetDlgItemText,hDlgEx,ID_IP,ADDR szIP
    

     INVOKE    htons,Port
     mov    [SockAddr.sin_port],ax
     mov    [SockAddr.sin_family],AF_INET

     INVOKE    socket,AF_INET,SOCK_STREAM,0
     mov    hSocketTx,eax

     INVOKE    connect,hSocketTx,ADDR SockAddr,SIZEOF SockAddr
 
 
     INVOKE GetDlgItemText,hDlgEx,ID_TEXT,ADDR buffTx,SIZEOF buffTx  
     INVOKE lstrlen, OFFSET buffTx
     INVOKE send, hSocketTx, OFFSET buffTx, 64, 0
	 INVOKE SendMessage, hLog, LB_ADDSTRING, 0, OFFSET txt3
	 INVOKE SendMessage, hLog, LB_ADDSTRING, 0, OFFSET buffTx
     .IF hSocketTx != 0
		 INVOKE closesocket, hSocketTx
		 mov hSocketTx, 0  
     .ENDIF
     ret
   tx endp
   
   ;////////////////////
     tx2 proc parametr:DWORD
     LOCAL SockAddr:sockaddr_in
     LOCAL IP:DWORD
     LOCAL szIP[128]:BYTE
     LOCAL Port:DWORD 
    
     INVOKE GetDlgItemText,hDlgEx,ID_IP,ADDR szIP,SIZEOF szIP

     INVOKE GetDlgItemInt, hDlgEx, ID_PORTTX2, ADDR Port, 0
	 mov Port, eax
	 
     INVOKE gethostbyname,ADDR szIP
     cmp eax, 0
     jne AddrName

     INVOKE    inet_addr,ADDR szIP
     mov IP,eax

     INVOKE    gethostbyaddr,ADDR IP,4,AF_INET

     AddrName:

     cld
     lea esi,dword ptr [eax+hostent.h_len]
     lea edi,SockAddr.sin_addr
     lodsw
     movzx ecx,ax
     lodsd
     mov esi,dword ptr [eax]
     rep movsb        
                		

     INVOKE    inet_ntoa,DWORD PTR SockAddr.sin_addr
  
     INVOKE    lstrcpy,ADDR szIP,eax

     INVOKE    SetDlgItemText,hDlgEx,ID_IP,ADDR szIP
    

     INVOKE    htons,Port
     mov    [SockAddr.sin_port],ax
     mov    [SockAddr.sin_family],AF_INET

     INVOKE    socket,AF_INET,SOCK_STREAM,0
     mov    hSocketTx2,eax

     INVOKE    connect,hSocketTx2,ADDR SockAddr,SIZEOF SockAddr
 
 
     INVOKE GetDlgItemText,hDlgEx,ID_TEXT,ADDR buffTx2,SIZEOF buffTx2
     INVOKE lstrlen, OFFSET buffTx2
     INVOKE send, hSocketTx2, OFFSET buffTx2, 64, 0
     .IF hSocketTx2 != 0
		 INVOKE closesocket, hSocketTx2
		 mov hSocketTx2, 0  
     .ENDIF
     ret
   tx2 endp
   ;////////////////////
   
   DlgProc proc hDlg,uMsg,wParam,lParam:DWORD
     pushad
     .IF uMsg==WM_INITDIALOG	

		 INVOKE GetDlgItem,hDlg,ID_LISTBOX
		 mov hLog,eax
       
		 mov eax, hDlg
		 mov hDlgEx, eax
              
     .ELSEIF  uMsg==WM_CLOSE
	 	 .IF hSocketTx2 != 0
			 INVOKE closesocket, hSocketTx2
		 .ENDIF
		 
		 .IF hSocketRx != 0
			 INVOKE closesocket, hSocketRx
		 .ENDIF
		
		 .IF hKlientRx != 0
			 INVOKE closesocket, hKlientRx
		 .ENDIF
		
		INVOKE TerminateThread, hThread, 0
        INVOKE EndDialog,hDlg,0
     .ELSEIF uMsg==WM_COMMAND     
         .IF wParam == ID_WYSLIJ             
             INVOKE CreateThread, NULL, 0, OFFSET tx, 0, 0, OFFSET hThread
			 INVOKE CreateThread, NULL, 0, OFFSET tx2, 0, 0, OFFSET hThread
		 .ELSEIF wParam == ID_START       
			 INVOKE CreateThread, NULL, 0, OFFSET Rx, 0,0,OFFSET hThread
         .ENDIF
     .ENDIF

     popad
     xor eax,eax
     ret
   DlgProc endp

   Start:                     

     INVOKE GetModuleHandle,NULL
     mov hInstance,eax
    
     INVOKE WSAStartup, 00000101h, OFFSET wsadata
     INVOKE DialogBoxParam,hInstance,ID_MAIN,0,ADDR DlgProc,0
     
     INVOKE ExitProcess,0

END Start                   
