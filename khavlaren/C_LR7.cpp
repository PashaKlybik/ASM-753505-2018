// C_LR7.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "C_LR7.h"

#define MAX_LOADSTRING 100

// Global Variables:
HINSTANCE hInst;								// current instance
TCHAR szTitle[MAX_LOADSTRING];					// The title bar text
TCHAR szWindowClass[MAX_LOADSTRING];			// the main window class name

// int _startX = 0, _startY = 0, _endX = 0, _endY = 0;
int *_startX = NULL, *_startY = NULL, *_endX = NULL, *_endY = NULL;
int _sX, _sY, _eX, _eY;
int _capacity = 8;
int _count = 0;

HWND hClearButton;
HWND hSelector;
bool _needToDraw = false;

// Forward declarations of functions included in this code module:
ATOM				MyRegisterClass(HINSTANCE hInstance);
BOOL				InitInstance(HINSTANCE, int);
LRESULT CALLBACK	WndProc(HWND, UINT, WPARAM, LPARAM);
INT_PTR CALLBACK	About(HWND, UINT, WPARAM, LPARAM);
void DrawPicture(HDC hdc, int startX, int startY, int endX, int endY);

int APIENTRY _tWinMain(_In_ HINSTANCE hInstance,			// Дескриптор экземпляра приложения.
                     _In_opt_ HINSTANCE hPrevInstance,		// Дескриптор предыдущего экземпляра приложения. Равен нулю. В ней столько же смысла, как и в моей жизни.
                     _In_ LPTSTR    lpCmdLine,				// Указатель на параметры cmd.
                     _In_ int       nCmdShow)				// Константа, характеризующая начальный вид окна.
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

 	// TODO: Place code here.
	MSG msg;
	HACCEL hAccelTable;

	// Initialize global strings
	LoadString(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
	LoadString(hInstance, IDC_C_LR7, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance (hInstance, nCmdShow))
	{
		return FALSE;
	}

	hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_C_LR7));

	// Main message loop:
	while (GetMessage(&msg, NULL, 0, 0))
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
//  FUNCTION: MyRegisterClass()
//
//  PURPOSE: Registers the window class.
//
ATOM MyRegisterClass(HINSTANCE hInstance)
{
	WNDCLASSEX wcex;

	wcex.cbSize = sizeof(WNDCLASSEX);

	wcex.style			= CS_HREDRAW | CS_VREDRAW;
	wcex.lpfnWndProc	= WndProc;
	wcex.cbClsExtra		= 0;
	wcex.cbWndExtra		= 0;
	wcex.hInstance		= hInstance;
	wcex.hIcon			= LoadIcon(hInstance, MAKEINTRESOURCE(IDI_C_LR7));
	wcex.hCursor		= LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground	= (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName	= MAKEINTRESOURCE(IDC_C_LR7);
	wcex.lpszClassName	= szWindowClass;
	wcex.hIconSm		= LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

	return RegisterClassEx(&wcex);
}

//
//   FUNCTION: InitInstance(HINSTANCE, int)
//
//   PURPOSE: Saves instance handle and creates main window
//
//   COMMENTS:
//
//        In this function, we save the instance handle in a global variable and
//        create and display the main program window.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
   HWND hWnd;

   hInst = hInstance; // Store instance handle in our global variable

   hWnd = CreateWindow(szWindowClass, _T("Paint Minimal"), WS_OVERLAPPEDWINDOW,
      CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, NULL, NULL, hInstance, NULL);

   if (!hWnd)
   {
      return FALSE;
   }

   ShowWindow(hWnd, nCmdShow);
   UpdateWindow(hWnd);

   return TRUE;
}

//
//  FUNCTION: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  PURPOSE:  Processes messages for the main window.
//
//  WM_COMMAND	- process the application menu
//  WM_PAINT	- Paint the main window
//  WM_DESTROY	- post a quit message and return
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	int wmId, wmEvent;
	PAINTSTRUCT ps;
	HDC hdc;

	switch (message)
	{
	case WM_CREATE:
		hClearButton = CreateWindow(_T("BUTTON"), _T("Clear Window"), WS_CHILD | WS_VISIBLE,
			0, 0, 119, 50, hWnd, (HMENU)IDM_CLEARBTN, hInst, 0);
		if (!hClearButton)
		{
			MessageBox(NULL, _T("Button error: can't create instance."), _T("Error"), MB_OK);
			return 1;
		}
		else 
		{
			ShowWindow(hClearButton, SW_SHOWNORMAL);
		}
		_startX = (int*)malloc(_capacity * sizeof(int));
		_startY = (int*)malloc(_capacity * sizeof(int));
		_endX = (int*)malloc(_capacity * sizeof(int));
		_endY = (int*)malloc(_capacity * sizeof(int));
		if (!(_startX && _startY && _endY && _endX))
		{
			MessageBox(NULL, _T("Out of memory."), _T("Error"), MB_OK);
		}
		break;
	case WM_LBUTTONDOWN:
		_sX = LOWORD(lParam);
		_sY = HIWORD(lParam);
		InvalidateRect(hWnd, NULL, FALSE);
		break;
	case WM_LBUTTONUP:
		_eX = LOWORD(lParam);
		_eY = HIWORD(lParam);
		_needToDraw = true;
		InvalidateRect(hWnd, NULL, FALSE);
		break;
	case WM_COMMAND:
		wmId    = LOWORD(wParam);
		wmEvent = HIWORD(wParam);
		// Parse the menu selections:
		switch (wmId)
		{
		case IDM_ABOUT:
			DialogBox(hInst, MAKEINTRESOURCE(IDD_ABOUTBOX), hWnd, About);
			break;
		case IDM_EXIT:
			DestroyWindow(hWnd);
			break;
		case IDM_CLEARBTN:
			_needToDraw = false;
			_capacity = 8;
			_count = 0;
			_startX = (int*)realloc(_startX, _capacity * sizeof(int));
			_startY = (int*)realloc(_startY, _capacity * sizeof(int));
			_endX = (int*)realloc(_endX, _capacity * sizeof(int));
			_endY = (int*)realloc(_endY, _capacity * sizeof(int));
			if (!(_startX && _startY && _endY && _endX))
			{
				MessageBox(NULL, _T("Out of memory."), _T("Error"), MB_OK);
			}
			InvalidateRect(hWnd, NULL, TRUE);
			break;
		default:
			return DefWindowProc(hWnd, message, wParam, lParam);
		}
		break;
	case WM_PAINT:
		hdc = BeginPaint(hWnd, &ps);
		// TODO: Add any drawing code here...
		DrawPicture(hdc, _sX, _sY, _eX, _eY);
		EndPaint(hWnd, &ps);
		break;
	case WM_DESTROY:
		free(_startX);
		free(_startY);
		free(_endX);
		free(_endY);
		PostQuitMessage(0);
		break;
	default:
		return DefWindowProc(hWnd, message, wParam, lParam);
	}
	return 0;
}

// Message handler for about box.
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

void DrawPicture(HDC hdc, int startX, int startY, int endX, int endY)
{
	HPEN hOldPen, hBlackPen, hYellowPen, hWhitePen, hBlackPenW;
	HBRUSH hOldBrush, hYellowBrush, hWhiteBrush, hBlackBrush;
	hBlackPen = CreatePen(PS_SOLID, 2, RGB(0, 0, 0));
	hYellowPen = CreatePen(PS_SOLID, 2, RGB(251, 216, 15));
	hWhitePen = CreatePen(PS_SOLID, 2, RGB(255, 255, 255));
	hYellowBrush = CreateSolidBrush(RGB(255, 255, 77));
	hWhiteBrush = CreateSolidBrush(RGB(255, 255, 255));
	hBlackBrush = CreateSolidBrush(RGB(0, 0, 0));
	if (_needToDraw)
	{
		if (_count == _capacity)
		{
			_capacity <<= 1;
			int size = _capacity * sizeof(int);
			_startX = (int*)realloc(_startX, size);
			_startY = (int*)realloc(_startY, size);
			_endX = (int*)realloc(_endX, size);
			_endY = (int*)realloc(_endY, size);
		}
		_startX[_count] = min(startX, endX);
		_startY[_count] = min(startY, endY);
		_endX[_count] = max(endX, startX);
		_endY[_count] = max(startY, endY);
		_count++;
	}
	POINT triangle[3];
	POINT bowtie[4];
	for (int i = 0; i < _count; i++)
	{
		int width = -_startX[i] + _endX[i], height = -_startY[i] + _endY[i];
		triangle[0].x = _startX[i] + width / 2;
		triangle[0].y = _startY[i] + height / 4;
		triangle[2].y = triangle[1].y = _endY[i] - height / 4;
		triangle[1].x = _startX[i];
		triangle[2].x = _endX[i];

		hBlackPenW = CreatePen(PS_SOLID, width / 20, RGB(0, 0, 0));
		SelectObject(hdc, hBlackBrush);
		SelectObject(hdc, hBlackPenW);

		// Руки и ноги.
		MoveToEx(hdc, _startX[i] + width * 0.29, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.29, _endY[i]);
		LineTo(hdc, _startX[i] + width * 0.27, _endY[i] + height / 28);
		MoveToEx(hdc, _startX[i] + width * 0.29, _endY[i], NULL);
		LineTo(hdc, _startX[i] + width * 0.30, _endY[i] + height / 35);
		MoveToEx(hdc, _startX[i] + width * 0.71, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.71, _endY[i]);
		LineTo(hdc, _startX[i] + width * 0.73, _endY[i] + height / 28);
		MoveToEx(hdc, _startX[i] + width * 0.71, _endY[i], NULL);
		LineTo(hdc, _startX[i] + width * 0.70, _endY[i] + height / 35);

		MoveToEx(hdc, _startX[i] + 0.36 * width, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _startX[i] + 0.36 * width, _endY[i] - height / 8);
		LineTo(hdc, _startX[i] + width * 0.38, _endY[i] - height / 9);
		LineTo(hdc, _startX[i] + 0.45 * width, _endY[i] - height / 6);
		LineTo(hdc, _startX[i] + width * 0.43, _endY[i] - height / 12);
		MoveToEx(hdc, _startX[i] + 0.45 * width, _endY[i] - height / 6, NULL);
		LineTo(hdc, _startX[i] + width * 0.42, _endY[i] - height / 12);

		MoveToEx(hdc, _startX[i] + width * 0.64, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _startX[i] + 0.64 * width, _endY[i] - height / 9);
		LineTo(hdc, _startX[i] + width * 0.63, _endY[i] - height / 10);
		LineTo(hdc, _startX[i] + width * 0.55, _endY[i] - height / 8.5);
		MoveToEx(hdc, _startX[i] + width * 0.55, _endY[i] - height / 8.5, NULL);
		LineTo(hdc, _startX[i] + width * 0.57, _endY[i] - height / 16);
		LineTo(hdc, _startX[i] + width * 0.58, _endY[i] - height / 16);
		DeleteObject(hBlackPenW);

		SelectObject(hdc, hYellowPen);
		SelectObject(hdc, hYellowBrush);

		// Тело - треугольник.
		Polygon(hdc, triangle, 3);

		// Полосы - кирпичики горизонтальные.
		hBlackPenW = CreatePen(PS_SOLID, 15, RGB(0, 0, 0));
		MoveToEx(hdc, _startX[i] + 0.15 * width, _startY[i] + 0.6 * height, NULL);
		LineTo(hdc, _endX[i] - 0.15 * width, _startY[i] + 0.6 * height);
		MoveToEx(hdc, _startX[i] + 0.1 * width, _startY[i] + 0.65 * height, NULL);
		LineTo(hdc, _endX[i] - 0.1 * width, _startY[i] + 0.65 * height);
		MoveToEx(hdc, _startX[i] + 0.05 * width, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _endX[i] - 0.05 * width, _startY[i] + 0.7 * height);

		// Полосы - кирпичики вертикальные.
		MoveToEx(hdc, _startX[i] + width / 3, _startY[i] + 0.65 * height, NULL);
		LineTo(hdc, _startX[i] + width / 3, _startY[i] + 0.7 * height);
		MoveToEx(hdc, _endX[i] - width / 3, _startY[i] + 0.65 * height, NULL);
		LineTo(hdc, _endX[i] - width / 3, _startY[i] + 0.7 * height);
		MoveToEx(hdc, _startX[i] + width * 0.2, _startY[i] + 0.6 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.2, _startY[i] + 0.65 * height);
		MoveToEx(hdc, _startX[i] + width * 0.8, _startY[i] + 0.6 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.8, _startY[i] + 0.65 * height);
		MoveToEx(hdc, _startX[i] + width * 0.5, _startY[i] + 0.6 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.5, _startY[i] + 0.65 * height);
		MoveToEx(hdc, _startX[i] + width * 0.2, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.2, _startY[i] + 0.75 * height);
		MoveToEx(hdc, _startX[i] + width * 0.8, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.8, _startY[i] + 0.75 * height);
		MoveToEx(hdc, _startX[i] + width * 0.5, _startY[i] + 0.7 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.5, _startY[i] + 0.75 * height);

		SelectObject(hdc, hBlackBrush);
		SelectObject(hdc, hBlackPen);

		// Ресницы.
		MoveToEx(hdc, _startX[i] + width / 2, _startY[i] + 0.57 * height, NULL);
		LineTo(hdc, _startX[i] + 0.36 * width, _startY[i] + 0.41 * height);
		MoveToEx(hdc, _startX[i] + width / 2, _startY[i] + 0.57 * height, NULL);
		LineTo(hdc, _endX[i] - 0.36 * width, _startY[i] + 0.41 * height);
		MoveToEx(hdc, _startX[i] + width / 2, _startY[i] + 0.57 * height, NULL);
		LineTo(hdc, _startX[i] + 0.45 * width, _startY[i] + 0.385 * height);
		MoveToEx(hdc, _startX[i] + width / 2, _startY[i] + 0.57 * height, NULL);
		LineTo(hdc, _endX[i] - 0.45 * width, _startY[i] + 0.385 * height);
		MoveToEx(hdc, _startX[i] + width / 2, _startY[i] + 0.43 * height, NULL);
		LineTo(hdc, _startX[i] + width / 2, _startY[i] + height * 0.59);
		MoveToEx(hdc, _startX[i] + width / 2, _startY[i] + 0.43 * height, NULL);
		LineTo(hdc, _startX[i] + width * 0.37, _startY[i] + height * 0.58);
		MoveToEx(hdc, _startX[i] + width / 2, _startY[i] + 0.43 * height, NULL);
		LineTo(hdc, _endX[i] - width * 0.37, _startY[i] + height * 0.58);

		SelectObject(hdc, hWhiteBrush);
		SelectObject(hdc, hWhitePen);

		// Глаз (белая часть).
		Chord(hdc, _startX[i] + 0.2 * width, _startY[i] + height * 0.42, _endX[i] - 0.2 * width, _endY[i], _endX[i], _startY[i] + height / 5, _startX[i], _startY[i] + height / 5);
		Chord(hdc, _startX[i] + 0.2 * width, _startY[i], _endX[i] - 0.2 * width, _endY[i] - 0.42 * height, _startX[i], _endY[i] - height / 5, _endX[i], _endY[i] - height / 5);

		SelectObject(hdc, hBlackBrush);
		SelectObject(hdc, hBlackPen);

		// Глаз (черная часть)
		Arc(hdc, _startX[i] + 0.2 * width, _startY[i] + height * 0.42, _endX[i] - 0.2 * width, _endY[i], _endX[i], _startY[i] + height / 5, _startX[i], _startY[i] + height / 5);
		Arc(hdc, _startX[i] + 0.2 * width, _startY[i], _endX[i] - 0.2 * width, _endY[i] - 0.42 * height, _startX[i], _endY[i] - height / 5, _endX[i], _endY[i] - height / 5);
		// Chord(hdc, _startX[i] + width * 0.46, _startY[i] + height * 0.3, _endX[i], _endY[i] - height * 0.3, _startX[i], _startY[i] + height * 0.3, _startX[i], _endY[i] - 0.3 * height);
		Ellipse(hdc, _startX[i] + width * 0.49, _startY[i] + height * 0.44, _startX[i] + width * 0.51, _startY[i] + height * 0.56);
		Ellipse(hdc, _startX[i] + width * 0.48, _startY[i] + height * 0.45, _startX[i] + width * 0.52, _startY[i] + height * 0.55);
		// Шляпа.
		Rectangle(hdc, _startX[i] + 5 * width / 11, _startY[i], _startX[i] + 6 * width / 11, _startY[i] + height / 4);
		Rectangle(hdc, _startX[i] + width * 0.33, _startY[i] + height * 0.23, _endX[i] - width * 0.33, _startY[i] + height / 4);
		// Бабочка.
		bowtie[0].x = bowtie[3].x = _startX[i] + 0.37 * width;
		bowtie[1].x = bowtie[2].x = _endX[i] - 0.37 * width;
		bowtie[0].y = bowtie[2].y = _startY[i] + 0.615 * height;
		bowtie[3].y = bowtie[1].y = _startY[i] + 0.685 * height;
		Polygon(hdc, bowtie, 4);

	}
	hOldBrush = (HBRUSH)SelectObject(hdc, hWhiteBrush);
	hOldPen = (HPEN)SelectObject(hdc, hBlackPen);
	_needToDraw = false;

	SelectObject(hdc, hOldPen);
	SelectObject(hdc, hOldBrush);
	DeleteObject(hBlackBrush);
	DeleteObject(hBlackPen);
	DeleteObject(hYellowBrush);
	DeleteObject(hYellowPen);
	DeleteObject(hWhiteBrush);
	DeleteObject(hWhitePen);
}

