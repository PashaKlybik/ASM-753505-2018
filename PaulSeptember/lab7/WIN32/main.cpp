#include <windows.h>
#include <dos.h>
#include <stdlib.h>
#include "main.h"

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
WORD xPos, yPos, GxPos, GyPos;
int nTimerID;
LPCSTR image[7] = {"picture.bmp","picture2.bmp","picture3.bmp","picture4.bmp","picture5.bmp","picture6.bmp","picture7.bmp"};
int flg = 0, ClickFlg = 0, op1 = 1, op2 = 0, op3 = 0, op4 = 0,count=0;
int t = 0;
// ����������� �������:
int WINAPI WinMain(HINSTANCE hInst, // ���������� ���������� ����������
                   HINSTANCE hPrevInst, // �� ����������
                   LPSTR lpCmdLine, // �� ����������
                   int nCmdShow) // ����� ����������� ������
{
    TCHAR szClassName[] = "��� �����"; // ������ � ������ ������
    HWND hMainWnd; // ������ ���������� �������� ������
    MSG msg; // ����� ��������� ��������� MSG ��� ��������� ���������
    static HWND hButton, hButton2, hButton3;
    WNDCLASSEX wc; // ������ ���������, ��� ��������� � ������ ������ WNDCLASSEX
    wc.cbSize        = sizeof(wc); // ������ ��������� (� ������)
    wc.style         = CS_HREDRAW | CS_VREDRAW ; // ����� ������ ������
    wc.lpfnWndProc   = WndProc; // ��������� �� ���������������� �������
    wc.lpszMenuName  = NULL; // ��������� �� ��� ���� (� ��� ��� ���)
    wc.lpszClassName = szClassName; // ��������� �� ��� ������
    wc.cbWndExtra    = NULL; // ����� ������������� ������ � ����� ���������
    wc.cbClsExtra    = NULL; // ����� ������������� ������ ��� �������� ���������� ����������
    wc.hIcon         = LoadIcon(NULL, IDI_WINLOGO); // ��������� �����������
    wc.hIconSm       = LoadIcon(NULL, IDI_WINLOGO); // ���������� ��������� ����������� (� ����)
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW); // ���������� �������
    wc.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH); // ���������� ����� ��� �������� ���� ����
    wc.hInstance     = hInst; // ��������� �� ������, ���������� ��� ����, ������������ ��� ������
   	wc.lpszMenuName  = "MAINMENU";
   	SetWindowLong(hMainWnd, GWL_STYLE, GetWindowLong(hMainWnd, GWL_STYLE) and not WS_THICKFRAME);
    if(!RegisterClassEx(&wc)){
        MessageBox(NULL, "�� ���������� ���������������� �����!", "������", MB_OK);
        return NULL;
    }
    hMainWnd = CreateWindow(
        szClassName, 
        "������������ ������ �7",
        WS_OVERLAPPED, // ������ ����������� ������
        CW_USEDEFAULT, // ������� ������ �� ��� �
        NULL, // ������� ������ �� ��� � (��� ������ � �, �� ������ �� �����)
        CW_USEDEFAULT, // ������ ������
        NULL, // ������ ������ (��� ������ � ������, �� ������ �� �����)
        (HWND)NULL, // ���������� ������������� ����
        NULL, // ���������� ����
        hInst, // ���������� ���������� ����������
        NULL); // ������ �� ������� �� WndProc
    hButton = CreateWindow ((LPCSTR)"button", (LPCSTR)"EXIT", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,  150, 500, 200, 30, hMainWnd, (HMENU)101, hInst, 0);
    hButton3 = CreateWindow ((LPCSTR)"button", (LPCSTR)"CLEAR", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,  750, 500, 200, 30, hMainWnd, (HMENU)1000, hInst, 0);
	if(!hMainWnd || !hButton){
        // � ������ ������������� �������� ������ (�������� ��������� � ��):
        MessageBox(NULL, "�� ���������� ������� ����!", "������", MB_OK);
        return NULL;
    }
    ShowWindow(hMainWnd, nCmdShow); // ���������� ������
    UpdateWindow(hMainWnd); // ��������� ������
    while(GetMessage(&msg, NULL, NULL, NULL)){ // ��������� ��������� �� �������, ���������� ��-�����, ��
        TranslateMessage(&msg); // �������������� ���������
        DispatchMessage(&msg); // ������� ��������� ������� ��
    }
    return msg.wParam; // ���������� ��� ������ �� ����������
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam){
    HDC hDC, hCompatibleDC;
    PAINTSTRUCT PaintStruct;
    HANDLE hBitmap, hOldBitmap;
    PAINTSTRUCT ps;
    RECT Rect;
    int f = 0;
    BITMAP Bitmap;
    static int nHDif = 0, nVDif = 0, nHPos = 0, nVPos = 0;
    switch(uMsg){ 	
    	case WM_CREATE:
			CreateWindow("EDIT", "",WS_CHILD|WS_VISIBLE|WS_HSCROLL|WS_VSCROLL|ES_MULTILINE|ES_WANTRETURN,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd, (HMENU)IDC_MAIN_TEXT, GetModuleHandle(NULL), NULL);
			SendDlgItemMessage(hWnd, IDC_MAIN_TEXT, WM_SETFONT,(WPARAM)GetStockObject(DEFAULT_GUI_FONT), MAKELPARAM(TRUE,0));
			break;
			
		case WM_LBUTTONDOWN:
    		xPos   = LOWORD(lParam);
    		yPos   = HIWORD(lParam);
    		if(xPos > 980 || xPos < 100) break;
    		if(yPos > 350 || yPos < 100) break;
    		GxPos = xPos;
    		GyPos = yPos;
    		hDC = GetDC(hWnd);
       		hBitmap = LoadImage(NULL, image[count%7], IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
       		count++;
        	GetObject(hBitmap, sizeof(BITMAP), &Bitmap);
        	hCompatibleDC = CreateCompatibleDC(hDC);
        	hOldBitmap = SelectObject(hCompatibleDC, hBitmap);      
        	GetClientRect(hWnd, &Rect);
    		BitBlt(hDC, xPos - 150, yPos - 150, Rect.right - 150, Rect.bottom - 150, hCompatibleDC,nHPos, nVPos, SRCCOPY);  
        	break;
        	
    	case WM_COMMAND:
			switch(LOWORD(wParam)){
				case CLOSE:
					DestroyWindow(hWnd);
					break;	
				case CLEAR:
					InvalidateRect(hWnd, 0, TRUE);
					UpdateWindow(hWnd);
					break;
			}
			break;
    	default:
        	return DefWindowProc(hWnd, uMsg, wParam, lParam);
    }
    return NULL; 
}
