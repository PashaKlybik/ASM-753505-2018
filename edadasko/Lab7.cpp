#include "stdafx.h"
#include "Lab7.h"
#include "time.h"

#define MAX_LOADSTRING 100
int x, y = 0;
void Draw(HDC, int, int);
bool isDrawing = false;
bool isBalls = false;
bool isStar = false;

class Tree {
public:
	void show(const HDC& dc, const int X, const int Y);
};

class Ball {
public:
	void showRandom(const HDC& dc, const int X, const int Y);
};

class Star {
public:
	void show(const HDC& dc, const int X, const int Y);
};

void Tree::show(const HDC& dc, const int X, const int Y) {
	HBRUSH  brush = CreateSolidBrush(RGB(50, 200, 50));

	POINT tri1[3] = { { X - 130, Y + 180 },{ X + 130 , Y + 180 },{ X, Y + 80 } };
	SelectObject(dc, brush);
	Polygon(dc, tri1, 3);

	POINT tri2[3] = { { X - 115, Y + 90 },{ X + 115 , Y + 90 },{ X, Y - 10 } };
	SelectObject(dc, brush);
	Polygon(dc, tri2, 3);

	POINT tri3[3] = { { X - 100, Y },{ X + 100 , Y },{ X, Y - 100 } };
	SelectObject(dc, brush);
	Polygon(dc, tri3, 3);

	brush = CreateSolidBrush(RGB(101, 67, 33));
	SelectObject(dc, brush);
	Rectangle(dc, X + 15, Y + 180, X -15, Y + 210);
	DeleteObject(brush);
}

void Ball::showRandom(const HDC& dc, const int X, const int Y) {
	srand(time(NULL));
	int color1 = 0 + rand() % 255;
	int color2 = 0 + rand() % 255;
	int color3 = 0 + rand() % 255;
	HBRUSH  brush = CreateSolidBrush(RGB(color1, color2, color3));
	SelectObject(dc, brush);
	Ellipse(dc, x - 15 , y - 15, x + 15, y + 15);
	DeleteObject(brush);
}

void Star::show(const HDC& dc, const int X, const int Y) {
	HBRUSH  brush = CreateSolidBrush(RGB(230, 230, 30));
	POINT star[5] = { { X, Y - 50 },{ X + 30, Y + 40 } ,{ X - 45, Y - 15 },{ X + 45 , Y - 15 },{ X - 30, Y + 40 } };
	HRGN rg;
	rg = CreatePolygonRgn(star, 5, WINDING);
	FillRgn(dc, rg, brush);
	DeleteObject(brush);
}


HINSTANCE hInst;                                // текущий экземпляр
WCHAR szTitle[MAX_LOADSTRING];                  // Текст строки заголовка
WCHAR szWindowClass[MAX_LOADSTRING];            // имя класса главного окна
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
	if (!InitInstance(hInstance, nCmdShow))
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

	return (int)msg.wParam;
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

	wcex.style = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc = WndProc;
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDC_LAB7));
	wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = MAKEINTRESOURCEW(IDC_LAB7);
	wcex.lpszClassName = szWindowClass;
	wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

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

	HWND treeButton = CreateWindowEx(NULL,
		L"BUTTON",
		L"Нарисовать елку",
		WS_CHILD,
		10,
		10,
		150,
		25,
		hWnd,
		HMENU(3),
		hInst,
		NULL);

	HWND ballButton = CreateWindowEx(NULL,
		L"BUTTON",
		L"Украсить шариками",
		WS_CHILD,
		10,
		50,
		150,
		25,
		hWnd,
		HMENU(2),
		hInst,
		NULL);

	HWND starButton = CreateWindowEx(NULL,
		L"BUTTON",
		L"Украсить звездой",
		WS_CHILD,
		10,
		90,
		150,
		25,
		hWnd,
		HMENU(4),
		hInst,
		NULL);

	HWND clearButton = CreateWindowEx(NULL,
		L"BUTTON",
		L"Очистить",
		WS_CHILD,
		10,
		130,
		150,
		25,
		hWnd,
		HMENU(1),
		hInst,
		NULL);

	if (!hWnd)
	{
		return FALSE;
	}

	ShowWindow(hWnd, nCmdShow);
	ShowWindow(treeButton, nCmdShow);
	ShowWindow(ballButton, nCmdShow);
	ShowWindow(clearButton, nCmdShow);
	ShowWindow(starButton, nCmdShow);
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
	case WM_LBUTTONDOWN:
	{
		isDrawing = true;
		x = LOWORD(lParam);
		y = HIWORD(lParam);
		InvalidateRect(hWnd, NULL, false);
		break;
	}
	case WM_COMMAND:
	{
		int wmId = LOWORD(wParam);
		switch (wmId)
		{
		case 1:
		{
			isDrawing = false;
			InvalidateRect(hWnd, NULL, TRUE);
			break;
		}

		case 2:
		{
			isDrawing = false;
			isBalls = true;
			isStar = false;
			break;
		}

		case 3:
		{
			isDrawing = false;
			isBalls = false;
			isStar = false;
				break;
		}
		case 4:
		{
			isDrawing = false;
			isBalls = false;
			isStar = true;
			break;
		}
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
		Draw(hdc, x, y);
		EndPaint(hWnd, &ps);
	}
	break;
	case WM_DESTROY:
		PostQuitMessage(0);
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

void Draw(HDC hdc, int x, int y)
{
	Tree tree;
	Ball ball;
	Star star;

	if (isDrawing && !isBalls && !isStar)
	{
		tree.show(hdc, x,  y);
	}

	if (isDrawing && isBalls)
	{
		ball.showRandom(hdc, x, y);
	}

	if (isDrawing && isStar)
	{
		star.show(hdc, x, y);
	}

	isDrawing = false;
}