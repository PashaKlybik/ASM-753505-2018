#include "stdafx.h"
#include "Win32API.h"
#include <cstdlib>
#include "targetver.h"

#define RADIUS 100
#define STIPERADIUS 30

#define MAX_LOADSTRING 100

int* xArr;
int* yArr;
int index;
int capasity = 16;
void MyWindowClass(HINSTANCE hInstance);
BOOL InitInstance(HINSTANCE, int);
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK About(HWND, UINT, WPARAM, LPARAM);
void Draw(HDC, int, int);


HINSTANCE hInst;
WCHAR szWindowClass[MAX_LOADSTRING];
HWND hWnd2;
int X = 0, Y = 0;
bool toDraw = false;

int WINAPI WinMain(HINSTANCE hInstance,
	HINSTANCE hPrevInstance,
	PSTR lpCmdLine,
	int nCmdShow)
{
	// Инициализируем 2 массив хранящие нажатия мыши
	xArr = (int*)malloc(capasity * sizeof(int)); 
	yArr = (int*)malloc(capasity * sizeof(int));
	//Описываем класс окна в соответствующей функции
	MyWindowClass(hInstance);                    
	// Отображаем окошко
	if (!InitInstance(hInstance, nCmdShow))
	{
		return 0; // выходим из WinMain
	}
	// Устанавливаем обработчик сообщений

	HACCEL hAccelTable = LoadAccelerators(hInstance,
		MAKEINTRESOURCE(IDC_WINDOWSPROJECT2)
	);

	MSG msg;
	while (GetMessage(&msg, nullptr, 0, 0))
	{
		if (!TranslateAccelerator(msg.hwnd, hAccelTable, &msg))
		{
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
	}
	return (int)msg.wParam;
}

void MyWindowClass(HINSTANCE hInstance)
{
	LoadStringW(hInstance, 
		IDC_WINDOWSPROJECT2,
		szWindowClass,
		MAX_LOADSTRING);
	WNDCLASSEXW wc;
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.style = NULL;
	wc.lpfnWndProc = WndProc;
	wc.cbClsExtra = 0; 
	wc.cbWndExtra = 0; 
	wc.hInstance = hInstance;
	wc.hIcon = NULL;
	wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wc.hbrBackground = (HBRUSH)CreateSolidBrush(RGB(0, 255, 0));
	wc.lpszMenuName = NULL;
	wc.lpszClassName = szWindowClass;
	wc.hIconSm = NULL;
	RegisterClassExW(&wc);            // Регистрируем класс
}

BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
	hInst = hInstance;
	HWND hWnd = CreateWindowW(szWindowClass,
		L"LabWork 7",
		WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		nullptr,
		nullptr,
		hInstance,
		nullptr
	);
	// Создали окошко (или нет)
	if (!hWnd)
		return FALSE;
	ShowWindow(hWnd, nCmdShow);
	UpdateWindow(hWnd);
	return TRUE;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_CREATE:
	{
		hWnd2 = CreateWindowEx(NULL,
			L"BUTTON",
			L"Clear",
			WS_CHILD,
			0,
			0,
			100,
			25,
			hWnd,
			HMENU(IDC_MyButton),
			hInst,
			NULL);
		ShowWindow(hWnd2, SW_SHOWNORMAL);
		break;
	}
	case WM_LBUTTONDOWN:                  // Если просто кликнули на экран и мы должны отрисовать
	{
		toDraw = true;
		X = LOWORD(lParam);
		Y = HIWORD(lParam);
		InvalidateRect(hWnd, NULL, FALSE);
		break;
	}
	case WM_COMMAND:
	{
		switch (LOWORD(wParam))
		{
		case IDC_MyButton:                 // Если кликнули на кнопочку Clear
			toDraw = false;
			index = 0;
			InvalidateRect(hWnd, NULL, TRUE);
			break;
		default:
			DefWindowProc(hWnd, message, wParam, lParam);
		}
		break;
	}
	case WM_PAINT:         // Когда перерисовываем
	{
		PAINTSTRUCT ps;
		HDC hdc = BeginPaint(hWnd, &ps);
		Draw(hdc, X, Y);
		EndPaint(hWnd, &ps);
		break;
	}
	case WM_DESTROY:        // Задаем условие закрытия окошка
	{
		PostQuitMessage(0);
		break;
	}
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}


void Draw(HDC hdc, int x, int y)
{
	HPEN hOldPen, hBlackPen;
	HBRUSH hOldBrush, hBrownBrush, hWhiteBrush;
	hBlackPen = CreatePen(PS_SOLID, 2, RGB(0,0,0));
	hBrownBrush = CreateSolidBrush(RGB(150, 75, 0));
	hWhiteBrush = CreateSolidBrush(RGB(255, 255, 255));
	//Если нужно нарисовать новый объект
	if (toDraw) {
		xArr[index] = x;
		yArr[index] = y;
		index++;
		if (index == capasity) {
			capasity *= 2;
			xArr = (int*)realloc(xArr, capasity * sizeof(int));
			yArr = (int*)realloc(yArr, capasity * sizeof(int));
		}
	}
	hOldPen = (HPEN)SelectObject(hdc, hBlackPen);
	hOldBrush = (HBRUSH)SelectObject(hdc, hWhiteBrush);
	for (int i = 0; i < index; i++)
	{
		SelectObject(hdc, hWhiteBrush);
		RoundRect(hdc,
			xArr[i] - STIPERADIUS, yArr[i] - STIPERADIUS,
			xArr[i] + STIPERADIUS, yArr[i] + RADIUS + STIPERADIUS,
			2*STIPERADIUS, 2*STIPERADIUS);
		SelectObject(hdc, hBrownBrush);
		Chord(hdc, 
			xArr[i] - RADIUS, yArr[i] + RADIUS,
			xArr[i] + RADIUS, yArr[i]-RADIUS,
			xArr[i]+RADIUS, yArr[i],
			xArr[i]-RADIUS, yArr[i]);
	}
	toDraw = false;
	// Удаляем ресурсы
	SelectObject(hdc, hOldPen);
	SelectObject(hdc, hOldBrush);
	DeleteObject(hBlackPen);
	DeleteObject(hBrownBrush);
	DeleteObject(hWhiteBrush);
}