// lab7.cpp : Определяет точку входа для приложения.
//

#include "stdafx.h"
#include "lab7.h"
#include <Windows.h>
#include <windowsx.h>
#include <vector>
using namespace std;

#define MAX_LOADSTRING 100
#define IDM_CLEARBUTTON 1

// Глобальные переменные:
HINSTANCE hInst;                                // текущий экземпляр
WCHAR szTitle[MAX_LOADSTRING];                  // Текст строки заголовка
WCHAR szWindowClass[MAX_LOADSTRING];            // имя класса главного окна

vector<pair<int, pair<int, int>>> points;
int drawFlag = 1;

// Отправить объявления функций, включенных в этот модуль кода:
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

    // TODO: Разместите код здесь.

    // Инициализация глобальных строк
    LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
    LoadStringW(hInstance, IDC_LAB7, szWindowClass, MAX_LOADSTRING);
    MyRegisterClass(hInstance);

    // Выполнить инициализацию приложения:
    if (!InitInstance (hInstance, nCmdShow))
    {
        return FALSE;
    }

    HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB7));

    MSG msg;

    // Цикл основного сообщения:
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



//
//  ФУНКЦИЯ: MyRegisterClass()
//
//  ЦЕЛЬ: Регистрирует класс окна.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
    WNDCLASSEXW wcex;

    wcex.cbSize = sizeof(WNDCLASSEX);

    wcex.style          = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc    = WndProc;
    wcex.cbClsExtra     = 0;
    wcex.cbWndExtra     = 0;
    wcex.hInstance      = hInstance;
    wcex.hIcon          = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB7));
    wcex.hCursor        = LoadCursor(nullptr, IDC_ARROW);
    wcex.hbrBackground  = (HBRUSH)(COLOR_WINDOW+1);
    wcex.lpszMenuName   = MAKEINTRESOURCEW(IDC_LAB7);
    wcex.lpszClassName  = szWindowClass;
    wcex.hIconSm        = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

    return RegisterClassExW(&wcex);
}

//
//   ФУНКЦИЯ: InitInstance(HINSTANCE, int)
//
//   ЦЕЛЬ: Сохраняет маркер экземпляра и создает главное окно
//
//   КОММЕНТАРИИ:
//
//        В этой функции маркер экземпляра сохраняется в глобальной переменной, а также
//        создается и выводится главное окно программы.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   hInst = hInstance; // Сохранить маркер экземпляра в глобальной переменной

   HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);
   HWND hClearButton = CreateWindow(_T("BUTTON"), _T("Очистить окно"), WS_CHILD | WS_VISIBLE, 0, 0, 130, 50, hWnd, (HMENU)IDM_CLEARBUTTON, hInst, 0);
   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

//
//  ФУНКЦИЯ: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  ЦЕЛЬ: Обрабатывает сообщения в главном окне.
//
//  WM_COMMAND  - обработать меню приложения
//  WM_PAINT    - Отрисовка главного окна
//  WM_DESTROY  - отправить сообщение о выходе и вернуться
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    switch (message)
    {
    case WM_COMMAND:
        {
            int wmId = LOWORD(wParam);
            // Разобрать выбор в меню:
            switch (wmId)
            {
			case IDM_CLEARBUTTON:
				points.clear();
				InvalidateRect(hWnd, NULL, TRUE);
				break;
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
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hWnd, &ps);
            // TODO: Добавьте сюда любой код прорисовки, использующий HDC...
			HPEN hBlackPen, hWhitePen;
			hBlackPen = CreatePen(PS_SOLID, 2, RGB(50,150,150));
			hWhitePen = CreatePen(PS_SOLID, 2, RGB(255, 255, 255));

			for (int i = 0; i < points.size(); i++)
			{
				int x = points[i].second.first;
				int y = points[i].second.second;
				SelectObject(hdc, hWhitePen);
				MoveToEx(hdc, x, y, NULL);
				SelectObject(hdc, hBlackPen);
				LineTo(hdc, x -10 , y);
				LineTo(hdc, x + 10, y);
				LineTo(hdc, x + 27, y + 10);
				LineTo(hdc, x + 13, y + 50);
				LineTo(hdc, x - 14, y + 50);
				LineTo(hdc, x - 10, y);
				LineTo(hdc, x + 10, y);
				LineTo(hdc, x + 13, y + 50);
				LineTo(hdc, x - 14, y + 50);
				LineTo(hdc, x - 27, y + 10);
				LineTo(hdc, x - 10, y);
				LineTo(hdc, x - 40, y - 70);
				LineTo(hdc, x - 17, y - 70);
				LineTo(hdc, x - 10, y);
				LineTo(hdc, x + 1, y - 70);
				LineTo(hdc, x - 17, y - 70);
				LineTo(hdc, x + 22, y - 70);
				LineTo(hdc, x + 10, y);
				LineTo(hdc, x + 1, y - 70);
				LineTo(hdc, x + 40, y - 70);
				LineTo(hdc, x + 10, y);
				LineTo(hdc, x + 27, y + 10);
				LineTo(hdc, x + 60, y + 25);
				LineTo(hdc, x + 80, y - 20);
				LineTo(hdc, x + 27, y + 10);
				LineTo(hdc, x + 65, y - 45);
				LineTo(hdc, x + 40, y - 70);
				LineTo(hdc, x + 35, y - 58);
				LineTo(hdc, x + 65, y - 45);
				LineTo(hdc, x + 80, y - 47);
				LineTo(hdc, x + 80, y - 20);
				LineTo(hdc, x + 80, y - 47);
				LineTo(hdc, x + 85, y - 70);
				LineTo(hdc, x + 65, y - 45);
				LineTo(hdc, x + 100, y - 120);
				LineTo(hdc, x + 85, y - 70);
				LineTo(hdc, x + 65, y - 45);
				LineTo(hdc, x + 97, y - 145);
				LineTo(hdc, x + 100, y - 120);
				LineTo(hdc, x + 97, y - 145);
				LineTo(hdc, x + 40, y - 70);
				LineTo(hdc, x - 40, y - 70);
				LineTo(hdc, x - 97, y - 145);
				LineTo(hdc, x - 100, y -120);
				LineTo(hdc, x - 97, y - 145);
				LineTo(hdc, x - 65, y - 45);
				LineTo(hdc, x - 85, y - 70);
				LineTo(hdc, x - 100, y - 120);
				LineTo(hdc, x - 65, y - 45);
				LineTo(hdc, x - 85, y - 70);
				LineTo(hdc, x - 80, y - 47);
				LineTo(hdc, x - 80, y - 20);
				LineTo(hdc, x - 80, y - 47);
				LineTo(hdc, x - 65, y - 45);
				LineTo(hdc, x - 40, y - 70);
				LineTo(hdc, x - 34, y - 55);
				LineTo(hdc, x - 65, y - 45);
				LineTo(hdc, x - 27, y + 10);
				LineTo(hdc, x - 80, y - 20);
				LineTo(hdc, x - 60, y + 25);
				LineTo(hdc, x - 27, y + 10);
				LineTo(hdc, x - 60, y + 25);
				LineTo(hdc, x - 50, y + 50);
				LineTo(hdc, x - 48, y + 60);
				LineTo(hdc, x - 35, y + 75);
				LineTo(hdc, x, y + 90);
				LineTo(hdc, x + 35, y + 75);
				LineTo(hdc, x + 48, y + 60);
				LineTo(hdc, x + 50, y + 50);
				LineTo(hdc, x + 60, y + 25);
				LineTo(hdc, x + 27, y + 10);
				LineTo(hdc, x + 13, y + 50);
				LineTo(hdc, x + 35, y + 75);
				LineTo(hdc, x, y + 70);
				LineTo(hdc, x + 13, y + 50);
				LineTo(hdc, x, y + 60);
				LineTo(hdc, x - 14, y + 50);
				LineTo(hdc, x, y + 70);
				LineTo(hdc, x - 35, y + 75);
				LineTo(hdc, x - 14, y + 50);
				LineTo(hdc, x - 23, y + 60);
				LineTo(hdc, x - 60, y + 25);
				LineTo(hdc, x - 23, y + 60);
				LineTo(hdc, x - 50, y + 50);
				LineTo(hdc, x - 23, y + 60);
				LineTo(hdc, x - 48, y + 60);
				LineTo(hdc, x - 35, y + 75);
				LineTo(hdc, x, y + 90);
				LineTo(hdc, x + 35, y + 75);
				LineTo(hdc, x + 48, y + 60);
				LineTo(hdc, x + 25, y + 62);
				LineTo(hdc, x + 50, y + 50);
				LineTo(hdc, x + 25, y + 62);
				LineTo(hdc, x + 60, y + 25);
			}
			DeleteObject(hBlackPen);
            EndPaint(hWnd, &ps);
        }
        break;
    case WM_DESTROY:
        PostQuitMessage(0);
        break;
	case WM_LBUTTONDOWN:
	{
		int xPos = GET_X_LPARAM(lParam);
		int yPos = GET_Y_LPARAM(lParam);
		points.push_back(pair<int, pair<int, int>>(drawFlag, pair<int, int>(xPos, yPos)));
		InvalidateRect(hWnd, 0, TRUE);
	}
	break;
    default:
        return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}

// Обработчик сообщений для окна "О программе".
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
