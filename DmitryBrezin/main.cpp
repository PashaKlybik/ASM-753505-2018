#include <windows.h> // заголовочный файл, содержащий WINAPI
#include <windowsx.h>
#include<stdlib.h>
#include <wchar.h>
#define ID_BUTTON_1 3000
#define ID_BUTTON_2 3001

HWND hBtn1;

// Прототип функции обработки сообщений с пользовательским названием:
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
TCHAR mainMessage[] = "Это наша ЁЛОЧКА!"; // строка с сообщением

// Управляющая функция:
int WINAPI WinMain(HINSTANCE hInst, // дескриптор экземпляра приложения
                   HINSTANCE hPrevInst, // не используем
                   LPSTR lpCmdLine, // не используем
                   int nCmdShow) // режим отображения окошка
{
    TCHAR szClassName[] = "Мой класс"; // строка с именем класса
    HWND hMainWnd; // создаём дескриптор будущего окошка
    MSG msg; // создём экземпляр структуры MSG для обработки сообщений
    WNDCLASSEX wc; // создаём экземпляр, для обращения к членам класса WNDCLASSEX
    wc.cbSize        = sizeof(wc); // размер структуры (в байтах)
    wc.style         = CS_HREDRAW | CS_VREDRAW; // стиль класса окошка
    wc.lpfnWndProc   = WndProc; // указатель на пользовательскую функцию
    wc.lpszMenuName  = NULL; // указатель на имя меню (у нас его нет)
    wc.lpszClassName = szClassName; // указатель на имя класса
    wc.cbWndExtra    = NULL; // число освобождаемых байтов в конце структуры
    wc.cbClsExtra    = NULL; // число освобождаемых байтов при создании экземпляра приложения
    wc.hIcon         = LoadIcon(NULL, IDI_WINLOGO); // декриптор пиктограммы
    wc.hIconSm       = LoadIcon(NULL, IDI_WINLOGO); // дескриптор маленькой пиктограммы (в трэе)
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW); // дескриптор курсора
    wc.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH); // дескриптор кисти для закраски фона окна
    wc.hInstance     = hInst; // указатель на строку, содержащую имя меню, применяемого для класса
    if(!RegisterClassEx(&wc)){
        // в случае отсутствия регистрации класса:
        MessageBox(NULL, "Не получилось зарегистрировать класс!", "Ошибка", MB_OK);
        return NULL; // возвращаем, следовательно, выходим из WinMain
    }
    // Функция, создающая окошко:
    hMainWnd = CreateWindow(
        szClassName, // имя класса
        "Ёлочка под новый год", // имя окошка (то что сверху)
        WS_OVERLAPPEDWINDOW | WS_VSCROLL, // режимы отображения окошка
        CW_USEDEFAULT, // позиция окошка по оси х
        NULL, // позиция окошка по оси у (раз дефолт в х, то писать не нужно)
        CW_USEDEFAULT, // ширина окошка
        NULL, // высота окошка (раз дефолт в ширине, то писать не нужно)
        (HWND)NULL, // дескриптор родительского окна
        NULL, // дескриптор меню
        HINSTANCE(hInst), // дескриптор экземпляра приложения
        NULL); // ничего не передаём из WndProc

     hBtn1 = CreateWindow("BUTTON", "clear", BS_PUSHBUTTON | WS_VISIBLE | WS_CHILD | WS_TABSTOP, 70, 45, 100, 50, hMainWnd, (HMENU)ID_BUTTON_1, hInst, NULL);



    if(!hMainWnd){
        // в случае некорректного создания окошка (неверные параметры и тп):
        MessageBox(NULL, "Не получилось создать окно!", "Ошибка", MB_OK);
        return NULL;
    }
    ShowWindow(hMainWnd, nCmdShow); // отображаем окошко
    UpdateWindow(hMainWnd); // обновляем окошко
    while(GetMessage(&msg, NULL, NULL, NULL)){ // извлекаем сообщения из очереди, посылаемые фу-циями, ОС
        TranslateMessage(&msg); // интерпретируем сообщения
        DispatchMessage(&msg); // передаём сообщения обратно ОС
    }
    return msg.wParam; // возвращаем код выхода из приложения
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
            // Запоминаем размеры окна
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
                            //делаем прямоугольник
                            HBRUSH hBrush = CreateSolidBrush(RGB(250,200,100));
                            SelectObject(hdc, hBrush);
                            RECT r{X ,Y ,X + 20, Y + 20};
                            //Заполняем прямоугольник
                            FillRect(hdc, &r, hBrush);
                            DeleteObject(hBrush);

                            //делаем треугольники
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
					//SetWindowText(hBtn1, "Закрыть порт");
                    InvalidateRect(hWnd, NULL, true);
                    UpdateWindow(hWnd);
					return 0;
					break;
			}
        default: return DefWindowProc(hWnd, message, wParam, lParam);
    }
}

