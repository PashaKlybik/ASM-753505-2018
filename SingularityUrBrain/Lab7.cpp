// Lab7.cpp : Defines the entry point for the application.
//

#include "stdafx.h"
#include "Lab7.h"

#define MAX_LOADSTRING 100
// Global Variables:
HINSTANCE hInst;                                // current instance
WCHAR szTitle[MAX_LOADSTRING];                  // The title bar text
WCHAR szWindowClass[MAX_LOADSTRING];            // the main window class name

HWND hClrBttn;
vector<pair<int, int>> centres;
int x = 0, y = 0;

// Forward declarations of functions included in this code module:
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

	// TODO: Place code here.


	// Initialize global strings
	LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
	LoadStringW(hInstance, IDC_LAB7, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// Perform application initialization:
	if (!InitInstance(hInstance, nCmdShow))
	{
		return FALSE;
	}

	HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_LAB7));

	MSG msg;

	// Main message loop:
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
//  FUNCTION: MyRegisterClass()
//
//  PURPOSE: Registers the window class.
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
	wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_LAB7));
	wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = MAKEINTRESOURCEW(IDC_LAB7);
	wcex.lpszClassName = szWindowClass;
	wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

	return RegisterClassExW(&wcex);
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
	hInst = hInstance; // Store instance handle in our global variable

	HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);
	RECT rect;
	GetClientRect(hWnd, &rect);
	hClrBttn = CreateWindow(_T("BUTTON"), _T("Clear"), WS_CHILD | WS_VISIBLE, rect.right - 120, rect.bottom - 70, 100, 50, hWnd, (HMENU)IDM_CLEARBUTTON, hInst, 0);

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
//  PURPOSE: Processes messages for the main window.
//
//  WM_COMMAND  - process the application menu
//  WM_PAINT    - Paint the main window
//  WM_DESTROY  - post a quit message and return
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{

	switch (message)
	{
	case WM_COMMAND:
	{
		int wmId = LOWORD(wParam);
		// Parse the menu selections:
		switch (wmId)
		{
		case IDM_CLEARBUTTON:
			InvalidateRect(hWnd, NULL, TRUE);
			centres.clear();
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
		// TODO: Add any drawing code that uses hdc here...

		HPEN hBlackPen, hWhitePen, hOldPen;
		HBRUSH hRedBrush, hOldBrush, hBrownBrush, hGreenBrush, hHighWhiteBrush, hBlackBrush;
		hBlackPen = CreatePen(PS_SOLID, 1, RGB(0, 0, 0));
		hWhitePen = CreatePen(PS_SOLID, 1, RGB(255, 255, 255));
		hRedBrush = CreateSolidBrush(RGB(255, 0, 0));
		hBlackBrush = CreateSolidBrush(RGB(0, 0, 0));
		hBrownBrush = CreateSolidBrush(RGB(101, 67, 33));
		hGreenBrush = CreateSolidBrush(RGB(0, 255, 0));
		hHighWhiteBrush = CreateSolidBrush(RGB(255, 255, 225));
		hOldPen = (HPEN)SelectObject(hdc, hBlackPen);
		hOldBrush = (HBRUSH)SelectObject(hdc, hRedBrush);
		for (int i = 0; i < centres.size(); i++)
		{
			int x = centres[i].first;
			int y = centres[i].second;

			SelectObject(hdc, hBlackPen);
			SelectObject(hdc, hRedBrush);
			RoundRect(hdc, x - 50, y - 50, x + 50, y + 50, 70, 80);
			SelectObject(hdc, hHighWhiteBrush);
			SelectObject(hdc, hWhitePen);
			Chord(hdc, x - 42, y - 42, x + 30, y + 30, x + 5, y - 50, x - 14, y - 8);
			SelectObject(hdc, hBlackPen);
			SelectObject(hdc, hBrownBrush);
			RoundRect(hdc, x - 6, y - 49, x + 6, y - 70, 50, 50);
			SelectObject(hdc, hGreenBrush);
			Ellipse(hdc, x - 6, y - 59, x + 40, y - 80);
			Ellipse(hdc, x, y - 56, x - 45, y - 82);
			SelectObject(hdc, hBlackBrush);
			Rectangle(hdc, x - 4, y + 47, x + 4, y + 51);
		}
		SelectObject(hdc, hOldPen);
		SelectObject(hdc, hOldPen);
		DeleteObject(hBlackPen);
		DeleteObject(hRedBrush);

		EndPaint(hWnd, &ps);
	}
	break;
	case WM_LBUTTONDOWN:
	{
		x = LOWORD(lParam);
		y = HIWORD(lParam);
		centres.push_back(pair<int, int>(x, y));
		InvalidateRect(hWnd, NULL, false);
	}
	break;
	case WM_SIZE:
	{
		DestroyWindow(hClrBttn);
		RECT rect;
		GetClientRect(hWnd, &rect);
		hClrBttn = CreateWindow(_T("BUTTON"), _T("Clear"), WS_CHILD | WS_VISIBLE, rect.right - 120, rect.bottom - 70, 100, 50, hWnd, (HMENU)IDM_CLEARBUTTON, hInst, 0);
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
