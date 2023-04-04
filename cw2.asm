include \masm32\include\masm32rt.inc 
ID_DLG_MAIN = 100 
ID_PB_OK = 102 
ID_EDIT = 103 
ID_PB_EXIT = 104 
ID_CHBOX = 105 
ID_ACTION = 106 
ID_EDIT2 = 107 
.data? 
hInstance dd ? 
fSize dd ? 
.data 
buff1 db 65 dup(NULL) 
hFile dd ? 
xRead dd ? 
xWrite dd ? 
.code 
 DlgProc proc hDlg,uMsg,wParam,lParam:DWORD 
 pushad 
 .IF uMsg==WM_CLOSE 
    INVOKE EndDialog,hDlg,0 
 .ELSEIF uMsg==WM_COMMAND 
    .IF wParam==ID_PB_EXIT 
        INVOKE EndDialog,hDlg,0 
    .ELSEIF wParam==ID_PB_OK 
        INVOKE GetDlgItemText, hDlg, ID_EDIT, OFFSET buff1, SIZEOF buff1 
        INVOKE SetDlgItemText, hDlg, ID_EDIT2, OFFSET buff1 
    .ELSEIF wParam==ID_ACTION 
        INVOKE IsDlgButtonChecked, hDlg, ID_CHBOX 
        .IF eax==BST_CHECKED 
            INVOKE GetDlgItemText, hDlg, ID_EDIT2, OFFSET buff1, SIZEOF buff1 
            INVOKE CreateFile,OFFSET buff1,GENERIC_WRITE,NULL,NULL,CREATE_ALWAYS,NULL,NULL 
            mov hFile,eax 
            .IF hFile!=NULL 
                INVOKE GetDlgItemText,hDlg,ID_EDIT,OFFSET buff1,SIZEOF buff1 
                mov xWrite,eax 
                INVOKE WriteFile,hFile,OFFSET buff1,xWrite, ADDR xWrite,NULL 
                INVOKE CloseHandle,hFile 
            .ENDIF 
        .ELSE 
            INVOKE GetDlgItemText, hDlg, ID_EDIT2, OFFSET buff1, SIZEOF buff1 
             INVOKE CreateFile,OFFSET buff1,GENERIC_READ,NULL,NULL,OPEN_EXISTING,NULL,NULL 
            mov hFile,eax 
                .IF hFile!=NULL 
                     INVOKE ReadFile,hFile,OFFSET buff1,SIZEOF buff1, ADDR xRead,NULL 
                .IF eax!=0 
                     INVOKE SetDlgItemText,hDlg, ID_EDIT,OFFSET buff1  
                .ENDIF 
                    INVOKE CloseHandle,hFile 
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