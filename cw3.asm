include \masm32\include\masm32rt.inc
ID_DLG_MAIN = 100
ID_OTWORZ = 1020
ID_ZAPISZ = 1030
ID_KONIEC = 1040
OFN_ENABLESIZING = 00800000h
OFN_FORCESHOWHIDDEN = 10000000h
.data?
hInstance dd ?
hFile dd ?
ofn OPENFILENAME <>
bufor db 30000 dup(?)
writeBytes dd ?
xRead dd ?
fSize dd ?
.data
ofilter db		 'Pliki Tekstowe',NULL,'*.txt',NULL,
				'Dokument tekstowy OpenDocument',NULL,'*.odt',NULL,
				'Microsoft Word 2003 XML',NULL,'*.xml',NULL,
				'Rich Text Format',NULL,'*.rtf',NULL
ocustFilter db 256 dup(NULL)
ofname db 256 dup(NULL)
oftitle db 256 dup(NULL)
oinitDir db 'C:\',NULL
oDlgTitle db 'Otwórz',NULL
.code
DlgProc proc hDlg,uMsg,wParam,lParam:DWORD 
pushad

.IF uMsg == WM_CLOSE
INVOKE EndDialog,hDlg,NULL
 
 
.ELSEIF uMsg == WM_COMMAND
.IF wParam==ID_KONIEC
INVOKE EndDialog,hDlg,NULL

.ELSEIF wParam == ID_OTWORZ
mov ofn.lStructSize,SIZEOF ofn
push hDlg
pop ofn.hwndOwner
push hInstance
pop ofn.hInstance
mov ofn.lpstrFilter,OFFSET ofilter
mov ofn.lpstrCustomFilter,OFFSET ocustFilter
mov ofn.nMaxCustFilter,SIZEOF ocustFilter ;256
mov ofn.nFilterIndex,0
mov ofn.lpstrFile,OFFSET ofname
mov ofn.nMaxFile,256
mov ofn.lpstrFileTitle,OFFSET oftitle
mov ofn.nMaxFileTitle,SIZEOF oftitle
mov ofn.lpstrInitialDir,OFFSET oinitDir
mov ofn.lpstrTitle,OFFSET oDlgTitle
mov ofn.Flags,OFN_ENABLESIZING OR \
OFN_EXPLORER OR \
OFN_FORCESHOWHIDDEN OR \
OFN_PATHMUSTEXIST OR \
OFN_OVERWRITEPROMPT OR \
OFN_HIDEREADONLY OR \
OFN_FILEMUSTEXIST OR \
OFN_NODEREFERENCELINKS
mov ofn.nFileOffset,0
mov ofn.lpfnHook,NULL
mov ofn.lpTemplateName,NULL
INVOKE GetOpenFileName,ADDR ofn

.IF eax!=NULL
INVOKE CreateFile,OFFSET ofname,GENERIC_READ,NULL,NULL,OPEN_EXISTING,NULL,NULL

mov hFile,eax

.IF hFile!=NULL
INVOKE ReadFile,hFile,OFFSET bufor,SIZEOF bufor, ADDR xRead,NULL

.IF eax != NULL
INVOKE SetDlgItemText,hDlg, 101,OFFSET bufor
.ENDIF

INVOKE CloseHandle,hFile
INVOKE RtlZeroMemory, ADDR bufor, SIZEOF bufor

.ENDIF
.ENDIF
.ELSEIF wParam == ID_ZAPISZ

mov ofn.lpstrDefExt, OFFSET ocustFilter
mov ofn.lStructSize,SIZEOF ofn
push hDlg
pop ofn.hwndOwner
push hInstance
pop ofn.hInstance
mov ofn.lpstrFilter,OFFSET ofilter
mov ofn.lpstrCustomFilter,OFFSET ocustFilter
mov ofn.nMaxCustFilter,SIZEOF ocustFilter ;256
mov ofn.nFilterIndex,0
mov ofn.lpstrFile,OFFSET ofname
mov ofn.nMaxFile,256
mov ofn.lpstrFileTitle,OFFSET oftitle
mov ofn.nMaxFileTitle,SIZEOF oftitle
mov ofn.lpstrInitialDir,OFFSET oinitDir
mov ofn.lpstrTitle,OFFSET oDlgTitle

mov ofn.Flags,OFN_ENABLESIZING OR \
OFN_EXPLORER OR \
OFN_FORCESHOWHIDDEN OR \
OFN_PATHMUSTEXIST OR \
OFN_OVERWRITEPROMPT OR \
OFN_HIDEREADONLY OR \
OFN_FILEMUSTEXIST OR \
OFN_NODEREFERENCELINKS
mov ofn.nFileOffset,0
mov ofn.lpfnHook,NULL
mov ofn.lpTemplateName,NULL

INVOKE GetSaveFileName,ADDR ofn
.IF eax!=NULL
INVOKE CreateFile, OFFSET ofname, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0

mov hFile,eax 
.IF hFile != NULL
INVOKE GetDlgItemText,hDlg,101,OFFSET bufor,SIZEOF bufor
mov writeBytes,eax

.IF eax != NULL
INVOKE WriteFile,hFile,OFFSET bufor, writeBytes, ADDR writeBytes, NULL
.ENDIF
INVOKE CloseHandle,hFile 
INVOKE RtlZeroMemory, ADDR bufor, SIZEOF bufor 

.ENDIF
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
