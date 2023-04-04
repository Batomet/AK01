include \masm32\include\masm32rt.inc

ID_DLG_MAIN   =  100
ID_EDIT		  =  101
ID_OTWORZ     = 1020
ID_KONIEC     = 1030
ID_ZAPISZ     = 1040

OFN_ENABLESIZING    = 00800000h
OFN_FORCESHOWHIDDEN = 10000000h

.data?                         
hInstance dd ?
hFile dd ?
oofn OPENFILENAME <>
bufor db 30000 dup(?)
xRead dd ?

.data                          
ofilter     db 'Wszystkie pliki (*.*)',NULL,'*.*',NULL,'Pliki ASM (*.asm)',NULL,'*.asm',NULL,'Pliki HTML (*.html)',NULL,'*.html',NULL,'Pliki Tekstowe',NULL,'*.txt',NULL
ocustFilter db 256 dup(NULL)
ofname      db 256 dup(NULL)
oftitle     db 256 dup(NULL)
oinitDir    db 'C:\',NULL
oDlgTitle   db 'Otworz',NULL
sDlgTitle   db 'Zapisz',NULL

.code                          
   DlgProc proc hDlg,uMsg,wParam,lParam:DWORD
     pushad

     .IF  uMsg==WM_CLOSE
       INVOKE EndDialog,hDlg,0
     .ELSEIF uMsg==WM_COMMAND
        .IF wParam==ID_KONIEC
             INVOKE EndDialog,hDlg,0
        .ELSEIF wParam==ID_OTWORZ
             mov oofn.lStructSize,SIZEOF oofn
             
             push hDlg   
             pop oofn.hwndOwner
            
             push hInstance
             pop oofn.hInstance

             mov oofn.lpstrFilter,OFFSET ofilter

             mov oofn.lpstrCustomFilter,OFFSET ocustFilter
             mov oofn.nMaxCustFilter,SIZEOF ocustFilter ;256
             mov oofn.nFilterIndex,0

             mov oofn.lpstrFile,OFFSET ofname
             mov oofn.nMaxFile,256
          
             mov oofn.lpstrFileTitle,OFFSET oftitle
             mov oofn.nMaxFileTitle,SIZEOF oftitle
            
             mov oofn.lpstrInitialDir,OFFSET oinitDir
         
             mov oofn.lpstrTitle,OFFSET oDlgTitle
         
             mov oofn.Flags,OFN_ENABLESIZING OR \
                        OFN_EXPLORER OR \
                        OFN_FORCESHOWHIDDEN OR \
                        OFN_PATHMUSTEXIST OR \
                        OFN_OVERWRITEPROMPT OR \
                        OFN_HIDEREADONLY OR \
                        OFN_FILEMUSTEXIST OR \
                        OFN_NODEREFERENCELINKS
             mov oofn.nFileOffset,0
             mov oofn.lpfnHook,NULL
             mov oofn.lpTemplateName,NULL
    
             INVOKE GetOpenFileName,ADDR oofn
             .IF eax!=NULL
                INVOKE CreateFile,OFFSET ofname,GENERIC_READ,NULL,NULL,\
                    OPEN_EXISTING,NULL,NULL
                mov hFile,eax    
                .IF hFile!=NULL    
                    INVOKE ReadFile,hFile,OFFSET bufor,SIZEOF bufor, ADDR xRead,NULL
                    .IF eax!=0    
                        INVOKE SetDlgItemText,hDlg, 101,OFFSET bufor
                        INVOKE SendMessage,hDlg,WM_SETTEXT,0,OFFSET oftitle
                    .ENDIF   
                INVOKE CloseHandle,hFile
             .ENDIF
         .ENDIF   
        .ELSEIF wParam==ID_ZAPISZ
             mov oofn.lStructSize,SIZEOF oofn
             
             push hDlg   
             pop oofn.hwndOwner
            
             push hInstance
             pop oofn.hInstance

             mov oofn.lpstrFilter,OFFSET ofilter

             mov oofn.lpstrCustomFilter,OFFSET ocustFilter
             mov oofn.nMaxCustFilter,SIZEOF ocustFilter ;256
             mov oofn.nFilterIndex,0

             mov oofn.lpstrFile,OFFSET ofname
             mov oofn.nMaxFile,256
          
             mov oofn.lpstrFileTitle,OFFSET oftitle
             mov oofn.nMaxFileTitle,SIZEOF oftitle
            
             mov oofn.lpstrInitialDir,OFFSET oinitDir
         
             mov oofn.lpstrTitle,OFFSET sDlgTitle
         
             mov oofn.Flags,OFN_ENABLESIZING OR \
                        OFN_EXPLORER OR \
                        OFN_FORCESHOWHIDDEN OR \
                        OFN_PATHMUSTEXIST OR \
                        OFN_OVERWRITEPROMPT OR \
                        OFN_HIDEREADONLY OR \
                        OFN_FILEMUSTEXIST OR \
                        OFN_NODEREFERENCELINKS 
             mov oofn.nFileOffset,0
             mov oofn.lpfnHook,NULL
             mov oofn.lpTemplateName,NULL
    
             INVOKE GetSaveFileName,OFFSET oofn

             .IF eax!=NULL
               	invoke CreateFile, OFFSET ofname, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS,0,0
				mov hFile, eax
				.if hFile!=0
					INVOKE GetDlgItemText, hDlg, ID_EDIT, OFFSET bufor, SIZEOF bufor
					mov xRead,eax
					invoke WriteFile,hFile,OFFSET bufor, xRead, OFFSET xRead, 0 
                    INVOKE CloseHandle,hFile

				.endif
			.ENDIF 
		.ENDIF
     .ENDIF

     popad
     xor eax,eax
     ret
   DlgProc endp

   Start:                     

     INVOKE GetModuleHandle,NULL
     mov hInstance,eax

     INVOKE DialogBoxParam,hInstance,ID_DLG_MAIN,0,ADDR DlgProc,0

     INVOKE ExitProcess,0         

END Start                   
