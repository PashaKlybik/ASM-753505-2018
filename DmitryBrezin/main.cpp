#include <windows.h> // ������������ ����, ���������� WINAPI
#include <windowsx.h>
#include<stdlib.h>
#include <wchar.h>
#define ID_BUTTON_1 3000
#define ID_BUTTON_2 3001

HWND hBtn1;

// �������� ������� ��������� ��������� � ���������������� ���������:
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
TCHAR mainMessage[] = "��� ���� ������!"; // ������ � ����������

// ����������� �������:
int WINAPI WinMain(HINSTANCE hInst, // ���������� ���������� ����������
                   HINSTANCE hPrevInst, // �� ����������
                   LPSTR lpCmdLine, // �� ����������
                   int nCmdShow) // ����� ����������� ������
{
    TCHAR szClassName[] = "��� �����"; // ������ � ������ ������
    HWND hMainWnd; // ������ ���������� �������� ������
    MSG msg; // ����� ��������� ��������� MSG ��� ��������� ���������
    WNDCLASSEX wc; // ������ ���������, ��� ��������� � ������ ������ WNDCLASSEX
    wc.cbSize        = sizeof(wc); // ������ ��������� (� ������)
    wc.style         = CS_HREDRAW | CS_VREDRAW; // ����� ������ ������
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
    if(!RegisterClassEx(&wc)){
        // � ������ ���������� ����������� ������:
        MessageBox(NULL, "�� ���������� ���������������� �����!", "������", MB_OK);
        return NULL; // ����������, �������������, ������� �� WinMain
    }
    // �������, ��������� ������:
    hMainWnd = CreateWindow(
        szClassName, // ��� ������
        "������ ��� ����� ���", // ��� ������ (�� ��� ������)
        WS_OVERLAPPEDWINDOW | WS_VSCROLL, // ������ ����������� ������
        CW_USEDEFAULT, // ������� ������ �� ��� �
        NULL, // ������� ������ �� ��� � (��� ������ � �, �� ������ �� �����)
        CW_USEDEFAULT, // ������ ������
        NULL, // ������ ������ (��� ������ � ������, �� ������ �� �����)
        (HWND)NULL, // ���������� ������������� ����
        NULL, // ���������� ����
        HINSTANCE(hInst), // ���������� ���������� ����������
        NULL); // ������ �� ������� �� WndProc

     hBtn1 = CreateWindow("BUTTON", "clear", BS_PUSHBUTTON | WS_VISIBLE | WS_CHILD | WS_TABSTOP, 70, 45, 100, 50, hMainWnd, (HMENU)ID_BUTTON_1, hInst, NULL);



    if(!hMainWnd){
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

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
    PAINTSTRUCT ps;
    HDC hdc;
    POINT My_Massiv[3];
    static int XStartPos = 20, YStartPos = 20, WidthGrid, HeightGrid, StepGrid = 20;

    switch (message)
    {
        case WM_SIZE:
        {
            // ���������� ������� ����
            WidthGrid = LOWORD(lParam) - XStartPos;
            HeightGrid = HIWORD(lParam) - YStartPos;
            break;
        }
        case WM_LBUTTONDOWN:
        {
            if (LOWORD(lParam) >= XStartPos && LOWORD(lParam) <= XStartPos + WidthGrid &&
                HIWORD(lParam) >= YStartPos && HIWORD(lParam) <= YStartPos + HeightGrid )
            {
                int XBuf = LOWORD(lParam), YBuf = HIWORD(lParam);
                bool flag = true;
                register int    BufWidth = XStartPos + ((WidthGrid - XStartPos) / StepGrid) * StepGrid,
                                BufHeight = YStartPos + ((HeightGrid - YStartPos) / StepGrid) * StepGrid;
                for(register int Y = YStartPos; Y < BufHeight && flag; Y += StepGrid)
                {
                    for(register int X = XStartPos; X < BufWidth; X += StepGrid)
                    {
                        if ((XBuf > X && XBuf < X + StepGrid) && (YBuf > Y && YBuf < Y + StepGrid))
                        {
                            HDC hdc = GetDC(hWnd);
                            //������ �������������
                            HBRUSH hBrush = CreateSolidBrush(RGB(250,200,100));
                            SelectObject(hdc, hBrush);
                            RECT r{X ,Y ,X + 20, Y + 20};
                            //��������� �������������
                            FillRect(hdc, &r, hBrush);
                            DeleteObject(hBrush);

                            //������ ������������
                            HBRUSH MyBrush = CreateSolidBrush(RGB(10,200,100));
                          //  HPEN MyPen = CreatePen(PS_SOLID,4,RGB(150,0, 0));
                            My_Massiv[0].x = X - 20; My_Massiv[0].y = Y;
                            My_Massiv[1].x =  X + 40; My_Massiv[1].y = Y;
                            My_Massiv[2].x = X + 10; My_Massiv[2].y = Y - 30;
                            SelectBrush(hdc,MyBrush);
                            Polygon(hdc,My_Massiv,3);


                            My_Massiv[0].x = X - 20; My_Massiv[0].y = Y - 20;
                            My_Massiv[1].x =  X + 40; My_Massiv[1].y = Y - 20;
                            My_Massiv[2].x = X + 10; My_Massiv[2].y = Y - 50;
                            Polygon(hdc,My_Massiv,3);


                            My_Massiv[0].x = X - 20; My_Massiv[0].y = Y - 40;
                            My_Massiv[1].x =  X + 40; My_Massiv[1].y = Y - 40;
                            My_Massiv[2].x = X + 10; My_Massiv[2].y = Y - 70;
                            Polygon(hdc,My_Massiv,3);

                            DeleteObject(MyBrush);
                            flag = false;
                            break;
                        }
                    }
                }
            }
            break;
        }
        case WM_PAINT:
        {
            hdc = BeginPaint(hWnd, &ps);
                register int    BufWidth = XStartPos + ((WidthGrid - XStartPos) / StepGrid) * StepGrid + 1,
                        BufHeight =YStartPos + ((HeightGrid - YStartPos) / StepGrid) * StepGrid;

            EndPaint(hWnd, &ps);
            break;
        }
        case WM_DESTROY:
        {
            PostQuitMessage(0);
            break;
        }
        case WM_COMMAND:
			switch(wParam) {
				case ID_BUTTON_1:
					//SetWindowText(hBtn1, "������� ����");
                    InvalidateRect(hWnd, NULL, true);
                    UpdateWindow(hWnd);
					return 0;
					break;
			}
        default: return DefWindowProc(hWnd, message, wParam, lParam);
    }
}

