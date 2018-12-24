// WindowsProject1.cpp : ���������� ����� ����� ��� ����������.
//

#include "stdafx.h"
#include "WindowsProject1.h"

#define MAX_LOADSTRING 100

// ���������� ����������:
HINSTANCE hInst;                                // ������� ���������
WCHAR szTitle[MAX_LOADSTRING];                  // ����� ������ ���������
WCHAR szWindowClass[MAX_LOADSTRING];            // ��� ������ �������� ����

bool DrawingMode = false;
int xLocation = 0, yLocation = 0, objectNumber = 15, currentIndex = 0;
void Draw(HDC, int, int);
int *XLocationsArray;
int *YLocationsArray;

// ��������� ���������� �������, ���������� � ���� ������ ����:
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

	// TODO: ���������� ��� �����.
	XLocationsArray = new int[objectNumber];
	YLocationsArray = new int[objectNumber];
	// ������������� ���������� �����
	LoadStringW(hInstance, IDS_APP_TITLE, szTitle, MAX_LOADSTRING);
	LoadStringW(hInstance, IDC_WINDOWSPROJECT1, szWindowClass, MAX_LOADSTRING);
	MyRegisterClass(hInstance);

	// ��������� ������������� ����������:
	if (!InitInstance(hInstance, nCmdShow))
	{
		return FALSE;
	}

	HACCEL hAccelTable = LoadAccelerators(hInstance, MAKEINTRESOURCE(IDC_WINDOWSPROJECT1));

	MSG msg;

	// ���� ��������� ���������:
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
//  �������: MyRegisterClass()
//
//  ����: ������������ ����� ����.
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
	wcex.hIcon = LoadIcon(hInstance, MAKEINTRESOURCE(IDI_WINDOWSPROJECT1));
	wcex.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wcex.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
	wcex.lpszMenuName = MAKEINTRESOURCEW(IDC_WINDOWSPROJECT1);
	wcex.lpszClassName = szWindowClass;
	wcex.hIconSm = LoadIcon(wcex.hInstance, MAKEINTRESOURCE(IDI_SMALL));

	return RegisterClassExW(&wcex);
}

//
//   �������: InitInstance(HINSTANCE, int)
//
//   ����: ��������� ������ ���������� � ������� ������� ����
//
//   �����������:
//
//        � ���� ������� ������ ���������� ����������� � ���������� ����������, � �����
//        ��������� � ��������� ������� ���� ���������.
//
BOOL InitInstance(HINSTANCE hInstance, int nCmdShow)
{
	hInst = hInstance; // ��������� ������ ���������� � ���������� ����������

	HWND hWnd = CreateWindowW(szWindowClass, szTitle, WS_OVERLAPPEDWINDOW,
		CW_USEDEFAULT, 0, CW_USEDEFAULT, 0, nullptr, nullptr, hInstance, nullptr);

	if (!hWnd)
	{
		return FALSE;
	}

	ShowWindow(hWnd, nCmdShow);
	UpdateWindow(hWnd);

	return TRUE;
}

//
//  �������: WndProc(HWND, UINT, WPARAM, LPARAM)
//
//  ����: ������������ ��������� � ������� ����.
//
//  WM_COMMAND  - ���������� ���� ����������
//  WM_PAINT    - ��������� �������� ����
//  WM_DESTROY  - ��������� ��������� � ������ � ���������
//
//
LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_CREATE:
	{
		hWnd = CreateWindowEx(NULL,
			L"BUTTON",
			L"Clear",
			WS_CHILD,
			400,
			0,
			300,
			25,
			hWnd,
			HMENU(55),
			hInst,
			NULL);
		ShowWindow(hWnd, SW_SHOWNORMAL);
		break;
	}
	case WM_LBUTTONDOWN:
	{
		DrawingMode = true;
		xLocation = LOWORD(lParam);
		yLocation = HIWORD(lParam);
		InvalidateRect(hWnd, NULL, false);
		break;
	}
	case WM_COMMAND:
	{
		int wmId = LOWORD(wParam);
		// ��������� ����� � ����:
		switch (wmId)
		{
		case 55:
		{
			DrawingMode = false;
			currentIndex = 0;
			delete(XLocationsArray);
			delete(YLocationsArray);
			XLocationsArray = new int[objectNumber];
			YLocationsArray = new int[objectNumber];
			InvalidateRect(hWnd, NULL, TRUE);
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
		Draw(hdc, xLocation, yLocation);
		// TODO: �������� ���� ����� ��� ����������, ������������ HDC...
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

// ���������� ��������� ��� ���� "� ���������".
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

void Draw(HDC hdc, int xLocation, int yLocation)
{
	HPEN hOldPen, hGreenPen;
	hGreenPen = CreatePen(PS_SOLID, 2, RGB(0, 0, 255));
	hOldPen = (HPEN)SelectObject(hdc, hGreenPen);
	HBRUSH hOldBrush, hSkyBrush;
	hSkyBrush = CreateSolidBrush(RGB(0, 204, 255));
	hOldBrush = (HBRUSH)SelectObject(hdc, hSkyBrush);
	if (DrawingMode)
	{
		XLocationsArray[currentIndex] = xLocation;
		YLocationsArray[currentIndex] = yLocation;
		currentIndex++;
		if (currentIndex = objectNumber)
		{
			objectNumber += 15;
			XLocationsArray = (int*)realloc(XLocationsArray, objectNumber * sizeof(int));
			YLocationsArray = (int*)realloc(YLocationsArray, objectNumber * sizeof(int));
		}
	}
	for (int i = 0; i < currentIndex; i++)
	{
		Ellipse(hdc, XLocationsArray[i] - 33, YLocationsArray[i] + 40, XLocationsArray[i] + 33, YLocationsArray[i] - 25);
		Ellipse(hdc, XLocationsArray[i] - 13, YLocationsArray[i] + 20, XLocationsArray[i] + 13, YLocationsArray[i] - 5);
		MoveToEx(hdc, XLocationsArray[i] - 30, YLocationsArray[i], NULL);

	}
	DrawingMode = false;
	SelectObject(hdc, hOldPen);
	DeleteObject(hGreenPen);
}