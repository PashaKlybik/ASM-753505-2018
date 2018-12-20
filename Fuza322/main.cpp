#if defined(UNICODE) && !defined(_UNICODE)
    #define _UNICODE
#elif defined(_UNICODE) && !defined(UNICODE)
    #define UNICODE
#endif
#define ID_BTN 0
#include <iostream>
#include <tchar.h>
#include <windows.h>

LRESULT CALLBACK WindowProcedure (HWND, UINT, WPARAM, LPARAM);
TCHAR szClassName[] = "CodeBlocksWindowsApp";
TCHAR path[] = "KlbIbikOneLove.bmp";

bool LoadAndBlitBitmap(LPCSTR, HDC, int, int);


int WINAPI WinMain (HINSTANCE hThisInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR lpszArgument,
                     int nCmdShow)
{
    HWND hwnd;
    MSG messages;
    WNDCLASSEX wincl;
    wincl.hInstance = hThisInstance;
    wincl.lpszClassName = szClassName;
    wincl.lpfnWndProc = WindowProcedure;
    wincl.style = CS_DBLCLKS;
    wincl.cbSize = sizeof (WNDCLASSEX);
    wincl.hIcon = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hIconSm = LoadIcon (NULL, IDI_APPLICATION);
    wincl.hCursor = LoadCursor (NULL, IDC_ARROW);
    wincl.lpszMenuName = NULL;
    wincl.cbClsExtra = 0;
    wincl.cbWndExtra = 0;
    wincl.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);
    if (!RegisterClassEx (&wincl))
    {
        MessageBox(NULL, "Unable to register class", "Error", MB_OK);
        return 0;
    }
    hwnd = CreateWindowEx (
           0,
           szClassName,
           _T("Lab7"),
           WS_OVERLAPPEDWINDOW,
           CW_USEDEFAULT,
           CW_USEDEFAULT,
           750,
           750,
           HWND_DESKTOP,
           NULL,
           hThisInstance,
           NULL
           );
    if (!hwnd)
    {
        MessageBox(NULL, "Unable to create window!", "Error", MB_OK);
        return 0;
    }
ShowWindow (hwnd, nCmdShow);
UpdateWindow(hwnd);
    while (GetMessage (&messages, NULL, 0, 0))
    {

        TranslateMessage(&messages);

        DispatchMessage(&messages);
    }

    return messages.wParam;
}
bool PrintPicture(LPCSTR path, HDC hWinDC, int x, int y)
{
    HBITMAP hOldBmp;
	HBITMAP hBitmap;
	BITMAP bitmap;
	HDC hLocalDC;
	hBitmap = (HBITMAP)LoadImage(NULL, path, IMAGE_BITMAP, 0, 0,
		LR_LOADFROMFILE);
	hLocalDC = CreateCompatibleDC(hWinDC);
	hOldBmp = (HBITMAP)SelectObject(hLocalDC, hBitmap);
	BitBlt(hWinDC, x, y, bitmap.bmWidth, bitmap.bmHeight,
		hLocalDC, 0, 0, SRCCOPY);
	DeleteDC(hLocalDC);
	DeleteObject(hBitmap);
	return true;
}

LRESULT CALLBACK WindowProcedure (HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    HDC hdc;
    PAINTSTRUCT ps;
    POINT p;
    HWND Button;

    switch (message)
    {
        case case WM_PAINT:
            break;
         case WM_LBUTTONDOWN:
            hdc = BeginPaint(hwnd, &ps);
            GetCursorPos(&p);
            std::cout<<p.x<<" "<<p.y<<"\n";
            ScreenToClient(hwnd, &p);
            std::cout<<p.x<<" "<<p.y<<"\n";
            LoadAndBlitBitmap(path, hdc, p.x-150, p.y-150);
            InvalidateRect(hwnd, NULL, false);
            EndPaint(hwnd, &ps);
            UpdateWindow(hwnd);
            break;
            }
            break;
        case WM_REMOVE:
            PostQuitMessage (0);
            break;
        case WM_COMMAND:
            switch(LOWORD(wParam))
            {
                case ID_BTN:
                {
                    InvalidateRect(hwnd, NULL, true);
                    UpdateWindow(hwnd);
                    break;
                }
            }
            break;
       case WM_CREATE:
            button = CreateWindow("Button", "Clear_ALL",
                                  WS_VISIBLE | WS_CHILD | BS_DEFPUSHBUTTON, 350, 600, 100, 30,
                                  hwnd, (HMENU) ID_BTN, NULL, NULL);
            break;
        default:
            return DefWindowProc (hwnd, message, wParam, lParam);
    }
    return 0;
}
