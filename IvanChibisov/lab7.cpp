


#include "stdafx.h"
#include "LR7.h"
#include <windows.h>

#define MAX_LOADSTRING 100

HINSTANCE hInst;                                
WCHAR szTitle[MAX_LOADSTRING];                  
WCHAR szWindowClass[MAX_LOADSTRING];            


ATOM                MyRegisterClass(HINSTANCE hInstance);
BOOL                InitInstance(HINSTANCE, int);
LRESULT CALLBACK    WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK    About(HWND, UINT, WPARAM, LPARAM);

int APIENTRY wWinMain(_In_ HINSTANCE hInstance,
                     _In_opt_ HINSTANCE hPrevInstance,
                     _In_ LPWSTR    lpCmdLine,
                     _In_ int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);


    LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
    LoadStringW(hInstance, IDC_LR7, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);

    if (!InitInstance (hInstance, nCmdShow))
    {
        return FALSE;
    }

    HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LR7));

    MSG msg;

  
    while (GetMessage(&msg, nullptr, 0, 0))
    {
        if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
        {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }
    }
	
    return (int) msg.wParam;
}


ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LR7));
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_LR7);
    wcex.lpszClassName  = szWindowClass;
    wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

    return RegisterClassExW(&wcex);
}


BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; 
   HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

   if (!hWnd)
   {
	  MessageBox(NULL, L"Неудалось создать окошко(((", L"Ошибка", MB_OKCANCEL);
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

WORD globalPosX, globalPosY;
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	HDC thisHandle = GetDC(hWnd);
	static HWND ButtonHandle;
	static HWND ButtonClear;
	PAINTSTRUCT ps;
	HPEN pen = NULL;
	HBRUSH brush = NULL;

    switch (message)
    {
	case WM_LBUTTONDOWN:
	{
		WORD xPos, yPos;
		xPos = LOWORD(lParam);
		yPos = HIWORD(lParam);
		globalPosX = xPos;
		globalPosY = yPos;
		pen = CreatePen(2, 2, RGB(0, 0, 0));
		brush = CreateSolidBrush(RGB(242, 235, 145));
		SelectObject(thisHandle, pen);
		SelectObject(thisHandle, brush);
		Rectangle(thisHandle, (int)xPos - 40, (int)yPos - 30, (int)xPos + 40, (int)yPos + 40);
		DeleteObject(brush);
		brush = CreateSolidBrush(RGB(165, 81, 25));
		SelectObject(thisHandle,brush);
		POINT poly[3] = { {(int)xPos - 40, (int)yPos - 30},{(int)xPos,(int)yPos - 60},{(int)xPos + 40,(int)yPos - 30} };
		Polygon(thisHandle, poly, 3);
		DeleteObject(poly);

		DeleteObject(brush);
		DeleteObject(pen);
		pen = CreatePen(1, 1, RGB(0, 0, 0));
		brush = CreateSolidBrush(RGB(165, 81, 25));
		SelectObject(thisHandle, pen);
		SelectObject(thisHandle, brush);
		Rectangle(thisHandle, (int)xPos - 30, (int)yPos, (int)xPos - 10, (int)yPos + 40);

		DeleteObject(brush);
		brush = CreateSolidBrush(RGB(109, 213, 239));
		SelectObject(thisHandle, brush);
		Rectangle(thisHandle, (int)xPos, (int)yPos - 20, (int)xPos + 30, (int)yPos + 20);
		MoveToEx(thisHandle, (int)xPos, (int)yPos, NULL);
		LineTo(thisHandle, (int)xPos + 30, (int)yPos);
		MoveToEx(thisHandle, (int)xPos + 10, (int)yPos - 20, NULL);
		LineTo(thisHandle, (int)xPos + 10, (int)yPos + 20);
		MoveToEx(thisHandle, (int)xPos + 20, (int)yPos - 20, NULL);
		LineTo(thisHandle, (int)xPos + 20, (int)yPos + 20);
		break; 
	}
	case WM_CREATE:
		ButtonHandle = CreateWindow(L"Button", L"Открыть дверь", WS_CHILDWINDOW | WS_BORDER, 100, 100, 100, 50, hWnd, NULL, (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE), NULL);
		ButtonClear = CreateWindow(L"Button", L"Очистить", WS_CHILDWINDOW | WS_BORDER, 100, 200, 100, 50, hWnd, NULL, (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE), NULL);
		ShowWindow(ButtonHandle, SW_SHOWNORMAL);
		ShowWindow(ButtonClear, SW_SHOWNORMAL);
		break;
    case WM_COMMAND:
        {
			if (lParam == (LPARAM)ButtonHandle)
			{
				WORD xPos, yPos;
				xPos = globalPosX;
				yPos = globalPosY;
				pen = CreatePen(2, 2, RGB(0, 0, 0));
				brush = CreateSolidBrush(RGB(242, 235, 145));
				SelectObject(thisHandle, pen);
				SelectObject(thisHandle, brush);
				Rectangle(thisHandle, (int)xPos - 40, (int)yPos - 30, (int)xPos + 40, (int)yPos + 40);
				DeleteObject(brush);
				brush = CreateSolidBrush(RGB(165, 81, 25));
				SelectObject(thisHandle, brush);
				POINT poly[3] = { {(int)xPos - 40, (int)yPos - 30},{(int)xPos,(int)yPos - 60},{(int)xPos + 40,(int)yPos - 30} };
				Polygon(thisHandle, poly, 3);
				DeleteObject(poly);

				DeleteObject(brush);
				DeleteObject(pen);
				pen = CreatePen(1, 1, RGB(0, 0, 0));
				brush = CreateSolidBrush(RGB(241, 247, 51)); 
				SelectObject(thisHandle, pen);
				SelectObject(thisHandle, brush);
				Rectangle(thisHandle, (int)xPos - 30, (int)yPos, (int)xPos - 10, (int)yPos + 40);

				DeleteObject(brush);
				brush = CreateSolidBrush(RGB(109, 213, 239));
				SelectObject(thisHandle, brush);
				Rectangle(thisHandle, (int)xPos, (int)yPos - 20, (int)xPos + 30, (int)yPos + 20);
				MoveToEx(thisHandle, (int)xPos, (int)yPos, NULL);
				LineTo(thisHandle, (int)xPos + 30, (int)yPos);
				MoveToEx(thisHandle, (int)xPos + 10, (int)yPos - 20, NULL);
				LineTo(thisHandle, (int)xPos + 10, (int)yPos + 20);
				MoveToEx(thisHandle, (int)xPos + 20, (int)yPos - 20, NULL);
				LineTo(thisHandle, (int)xPos + 20, (int)yPos + 20);
				
				DeleteObject(brush);
				brush = CreateSolidBrush(RGB(165, 81, 25));
				SelectObject(thisHandle, brush);
				POINT poly2[4] = { {(int)xPos-30,(int)yPos},{(int)xPos - 30,(int)yPos + 40},{(int)xPos - 45,(int)yPos +50},{(int)xPos - 45,(int)yPos + 15} };
				Polygon(thisHandle, poly2, 4);
			}
			if (lParam == (LPARAM)ButtonClear)
			{
				InvalidateRect(hWnd, 0, true);
				UpdateWindow(hWnd);
				MessageBox(NULL, L"Сообщение", L"Очищено", MB_OK);
			}
            int wmId = LOWORD(wParam);
			
            switch (wmId)
            {
            case IDM_ABOUT:
                DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
                break;
            case IDM_EXIT:
                DestroyWindow(hWnd);
                break;
            default:
                return DefWindowProc(hWnd, message, wParam, lParam);
            }
        }
        break;
	
    case WM_PAINT:
        {
		thisHandle = BeginPaint(hWnd, &ps);
            EndPaint(hWnd, &ps);
        }
        break;
    case WM_DESTROY:
		DeleteObject(pen);
        PostQuitMessage(0);
        break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

INT_PTR CALLBACK About(HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
    UNREFERENCED_PARAMETER(lParam);
    switch (message)
    {
    case WM_INITDIALOG:
        return (INT_PTR)TRUE;

    case WM_COMMAND:
        if (LOWORD(wParam) == IDOK || LOWORD(wParam) == IDCANCEL)
        {
            EndDialog(hDlg, LOWORD(wParam));
            return (INT_PTR)TRUE;
        }
        break;
    }
    return (INT_PTR)FALSE;
}
