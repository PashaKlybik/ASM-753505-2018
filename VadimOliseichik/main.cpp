#include <windows.h>
#include <dos.h>
#include <stdlib.h>
#include "main.h"

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
TCHAR mainMessage[] = "Мой текст!"; // строка с сообщением
WORD xPos, yPos, GxPos, GyPos;
int nTimerID;
LPCSTR image = "picture1.bmp";
int flg = 0, ClickFlg = 0, op1 = 1, op2 = 0, op3 = 0, op4 = 0;
int t = 0;
// Управляющая функция:
int WINAPI WinMain(HINSTANCE hInst, // дескриптор экземпляра приложения
                   HINSTANCE hPrevInst, // не используем
                   LPSTR lpCmdLine, // не используем
                   int nCmdShow) // режим отображения окошка
{
    TCHAR szClassName[] = "Мой класс"; // строка с именем класса
    HWND hMainWnd; // создаём дескриптор будущего окошка
    MSG msg; // создём экземпляр структуры MSG для обработки сообщений
    static HWND hButton, hButton3;
    WNDCLASSEX wc; // создаём экземпляр, для обращения к членам класса WNDCLASSEX
    wc.cbSize        = sizeof(wc); // размер структуры (в байтах)
    wc.style         = CS_HREDRAW | CS_VREDRAW ; // стиль класса окошка
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
   	wc.lpszMenuName  = "MAINMENU";
   	SetWindowLong(hMainWnd, GWL_STYLE, GetWindowLong(hMainWnd, GWL_STYLE) and not WS_THICKFRAME);
    if(!RegisterClassEx(&wc)){
        // в случае отсутствия регистрации класса:
        MessageBox(NULL, "Не получилось зарегистрировать класс!", "Ошибка", MB_OK);
        return NULL; // возвращаем, следовательно, выходим из WinMain
    }
    // Функция, создающая окошко:
    hMainWnd = CreateWindow(
        szClassName, // имя класса
        "Лабораторная работа №7", // имя окошка (то что сверху)
        WS_OVERLAPPED, // режимы отображения окошка
        CW_USEDEFAULT, // позиция окошка по оси х
        NULL, // позиция окошка по оси у (раз дефолт в х, то писать не нужно)
        1440, // ширина окошка
        900, // высота окошка (раз дефолт в ширине, то писать не нужно)
        (HWND)NULL, // дескриптор родительского окна
        NULL, // дескриптор меню
        hInst, // дескриптор экземпляра приложения
        NULL); // ничего не передаём из WndProc
    hButton = CreateWindow ((LPCSTR)"button", (LPCSTR)"Закрыть", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,  150, 600, 200, 30, hMainWnd, (HMENU)101, hInst, 0);
    hButton3 = CreateWindow ((LPCSTR)"button", (LPCSTR)"Очистить", WS_CHILD | WS_VISIBLE | BS_PUSHBUTTON,  750, 600, 200, 30, hMainWnd, (HMENU)1000, hInst, 0);
	if(!hMainWnd || !hButton){
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

LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam){
    HDC hDC, hCompatibleDC;// Дескрипторы окон
    HANDLE hBitmap, hOldBitmap;//Отбработчик картинки
    RECT Rect;//прямоуголик
    int f = 0;
   
    BITMAP Bitmap;
    static int nHDif = 0, nVDif = 0, nHPos = 0, nVPos = 0;
    switch(uMsg){
    case WM_CREATE:
			CreateWindow("EDIT", "",WS_CHILD|WS_VISIBLE|WS_HSCROLL|WS_VSCROLL|ES_MULTILINE|ES_WANTRETURN,CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,hWnd, (HMENU)IDC_MAIN_TEXT, GetModuleHandle(NULL), NULL);
			SendDlgItemMessage(hWnd, IDC_MAIN_TEXT, WM_SETFONT,(WPARAM)GetStockObject(DEFAULT_GUI_FONT), MAKELPARAM(TRUE,0));
			break;
	case WM_LBUTTONDOWN:
 	  if(ClickFlg == 1) break;
      xPos   = LOWORD(lParam); //Принимаем координаты мышки
      yPos   = HIWORD(lParam);
      
      /*if(xPos > 890 || xPos < 100) break; //Запрет на рисование сильно справа, т.к. там границы были */
      if(yPos > 390 || yPos < 90) break; // Запрет на рисование сильно низко, так как там кнопки 
      
      		ClickFlg = 1;
      		GxPos = xPos;
      		GyPos = yPos;

     		hDC = GetDC(hWnd);
            hBitmap = LoadImage(NULL, image, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
            if ( !hBitmap ){
                MessageBox(NULL, "Файл не найден!", "Ошибка", MB_OK);
                return 0;
            }
            GetObject(hBitmap, sizeof(BITMAP), &Bitmap);
            hCompatibleDC = CreateCompatibleDC(hDC);
            hOldBitmap = SelectObject(hCompatibleDC, hBitmap);
            GetClientRect(hWnd, &Rect);
            BitBlt(hDC, xPos - 350, yPos - 300, Rect.right - 660, Rect.bottom - 245, hCompatibleDC,nHPos, nVPos, SRCCOPY);
            DeleteDC(hCompatibleDC); //Очищаю память 
            ReleaseDC(hWnd, hDC);
            break;
    case WM_COMMAND:
			switch(LOWORD(wParam))
			{
				case CLOSE:

				     switch ((int)MessageBox(NULL, "Вы уверены, что хотите выйти?", "Предупреждение",
                             MB_ICONQUESTION | MB_YESNO))
				     {
					     case IDYES: DestroyWindow(hWnd);break;
					     case IDNO:  break;
				     }
					break;
				case CLEAR:
					ClickFlg = 0;
					image = "picture1.bmp";
					flg = 0;
					InvalidateRect(hWnd, 0, TRUE);
					UpdateWindow(hWnd);
					MessageBox(NULL, "Очищено","Сообщение", MB_OK);
					break;
			}
			break;
    case WM_CLOSE:
    	PostQuitMessage(NULL);
		DestroyWindow(hWnd);
		break;
    case WM_DESTROY: // если окошко закрылось, то:
        PostQuitMessage(NULL); // отправляем WinMain() сообщение WM_QUIT
        break;
    default:
        return DefWindowProc(hWnd, uMsg, wParam, lParam); // если закрыли окошко
    }
    return NULL; // возвращаем значение
}
