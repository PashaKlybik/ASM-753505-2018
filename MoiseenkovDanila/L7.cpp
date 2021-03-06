// L7.cpp: Определяет точку входа для приложения.
//

#include "stdafx.h"
#include "L7.h"

#define MAX_LOADSTRING 100

const double PI = acos(-1);

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
	LoadStringW(hInstance, IDC_L7, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	if (!InitInstance(hInstance, nCmdShow))
	{
		return FALSE;
	}

	HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_L7));

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


ATOM MyRegisterClass(HINSTANCE hInstance)
{
	WNDCLASSEXW wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style = CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc = WndProc;
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_L7));
	wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = MAKEINTRESOURCEW(IDC_L7);
	wcex.lpszClassName = szWindowClass;
	wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

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

void DrawDynamite(int x, int y, HDC Handle)
{
	int const width = 100;
	const int height = 200;
	HPEN pen = NULL;
	HBRUSH brush = NULL;
	pen = CreatePen(PS_SOLID, 1, RGB(255, 0, 0));
	SelectObject(Handle, pen);
	brush = CreateSolidBrush(RGB(255, 0, 0));
	SelectObject(Handle, brush);
	Rectangle(Handle, x - width / 2, y - height / 2, x+width/2, y + height / 2);
	Ellipse(Handle, x - width / 2, y + height / 2 - 30, x + width / 2, y + height / 2 + 30);
	DeleteObject(brush);
	DeleteObject(pen);
	pen = CreatePen(PS_SOLID, 1, RGB(100, 0, 0));
	SelectObject(Handle, pen);
	brush = CreateSolidBrush(RGB(100, 0, 0));
	SelectObject(Handle, brush);
	Ellipse(Handle, x - width / 2, y - height / 2 - 30, x + width / 2, y - height / 2 + 30);
	DeleteObject(brush);
	DeleteObject(pen);
	pen = CreatePen(PS_SOLID, 4, RGB(0, 0, 0));
	SelectObject(Handle, pen);
	MoveToEx(Handle, x, y - height / 2, NULL);
	LineTo(Handle, x, y- height / 2 - 40);
	LineTo(Handle, x - 30, y - height / 2 - 70);
	DeleteObject(pen);
	return;
}

void FireAtWill(int x, int y, HDC Handle)
{
	int const width = 100;
	const int height = 200;
	x -= 30;
	y += -height / 2 - 70;
	HPEN pen = NULL;
	HBRUSH brush = NULL;
	POINT points[16];
	pen = CreatePen(PS_SOLID, 1, RGB(255, 160, 0));
	SelectObject(Handle, pen);
	brush = CreateSolidBrush(RGB(255, 160,0));
	SelectObject(Handle, brush);

	for(int i = 0; i < 16; i++)
		if (i % 2 == 0)
		{
			points[i].x = x + 50 * cos(PI * 2 / 16 * i);
			points[i].y = y + 50 * sin(PI * 2 / 16 * i);
		}
		else
		{
			points[i].x = x + 25 * cos(PI * 2 / 16 * i);
			points[i].y = y + 25 * sin(PI * 2 / 16 * i);
		}
	Polygon(Handle, points, 16);

	DeleteObject(pen);
	DeleteObject(brush);

	pen = CreatePen(PS_SOLID, 1, RGB(255, 255, 0));
	SelectObject(Handle, pen);
	brush = CreateSolidBrush(RGB(255, 255, 0));
	SelectObject(Handle, brush);

	for (int i = 0; i < 16; i++)
		if (i % 2 == 0)
		{
			points[i].x = x + 25 * cos(PI * 2 / 16 * i);
			points[i].y = y + 25 * sin(PI * 2 / 16 * i);
		}
		else
		{
			points[i].x = x + 10 * cos(PI * 2 / 16 * i);
			points[i].y = y + 10 * sin(PI * 2 / 16 * i);
		}
	Polygon(Handle, points, 16);

	DeleteObject(pen);
	DeleteObject(brush);
}

WORD globalPosX, globalPosY;
bool first = true;
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

		DrawDynamite(globalPosX, globalPosY, thisHandle);

		
		break;
	}
	case WM_CREATE:
		ButtonHandle = CreateWindow(L"Button", L"Огоньку!", WS_CHILDWINDOW | WS_BORDER, 50, 50, 100, 50, hWnd, NULL, (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE), NULL);
		ButtonClear = CreateWindow(L"Button", L"Очистить", WS_CHILDWINDOW | WS_BORDER, 50, 125, 100, 50, hWnd, NULL, (HINSTANCE)GetWindowLong(hWnd, GWL_HINSTANCE), NULL);
		ShowWindow(ButtonClear, SW_SHOWNORMAL);
		ShowWindow(ButtonHandle, SW_SHOWNORMAL);
		break;
	case WM_COMMAND:
	{
		if (lParam == (LPARAM)ButtonHandle)
		{
			WORD xPos, yPos;
			xPos = globalPosX;
			yPos = globalPosY;
			FireAtWill(xPos, yPos, thisHandle);
			break;
		}
		if (lParam == (LPARAM)ButtonClear)
		{
			first = true;
			InvalidateRect(hWnd, 0, true);
			UpdateWindow(hWnd);
			MessageBox(NULL, L"Обезврежено", L"Сообщение", MB_OK);
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
		if (!first)
		{
			MessageBox(NULL, L"А про перерисовку забыл!", L"Так так", MB_OK);
		}
		first = false;
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