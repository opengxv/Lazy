#include <windows.h>
#include <tchar.h>
#include <stdio.h>
#include <accctrl.h>
#include <aclapi.h>
#include <time.h>
#include <tchar.h>
#include "tesseract/baseapi.h"
#include "leptonica/allheaders.h"
#include <sys/cygwin.h>
#include <WinNls.h>
#include <iconv.h>

#define KEY_SIZE sizeof(double)
#define BUFFER_SIZE (4096 * 1)

HWND hWindow;
#define BIT_COUNT 32


void ShowLastError() {
	// Retrieve the system error message for the last-error code
	DWORD ERROR_ID = GetLastError();
	void* MsgBuffer = nullptr;
	//LCID lcid;
	//GetLocaleInfoEx(L"en-US", LOCALE_RETURN_NUMBER | LOCALE_ILANGUAGE, (wchar_t*)& lcid, sizeof(lcid));

	//get error message and attach it to Msgbuffer
	FormatMessageW(
		FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL, ERROR_ID, 0, (wchar_t*)& MsgBuffer, 0, NULL);
	//concatonate string to DisplayBuffer
	const std::wstring DisplayBuffer = L" failed with error " + std::to_wstring(ERROR_ID) + L": " + static_cast<wchar_t*>(MsgBuffer);

	// Display the error message and exit the process
	MessageBoxExW(NULL, DisplayBuffer.c_str(), L"Error", MB_ICONERROR | MB_OK, 0);
}

#define assertWin32(v) if (!(v)) { ShowLastError(); exit(1); }

class Screen {
private:
	HWND m_hwnd;
	HDC m_hdcWnd;
	HBITMAP m_hbmWnd;
	HDC m_hdcMem;
	BITMAP m_bmpWnd;
	unsigned char* m_bmp;
	unsigned char* m_buffer;
	unsigned m_size;
	unsigned m_buffersize;
	unsigned m_width;
	unsigned m_height;
	BITMAPFILEHEADER* m_header;
	BITMAPINFOHEADER *m_bi;
public:
	Screen(HWND hwnd) 
	: m_hwnd(hwnd), m_hdcWnd(), m_hbmWnd(), m_hdcMem(), m_bmpWnd(), m_buffer(),
	  m_width(148), m_height(25) {
		assertWin32(m_hdcWnd = ::GetDC(hwnd));
		assertWin32(m_hbmWnd = ::CreateCompatibleBitmap(m_hdcWnd, m_width, m_height));
		assertWin32(m_hdcMem = ::CreateCompatibleDC(m_hdcWnd));
		assertWin32(::SelectObject(m_hdcMem, m_hbmWnd));

		m_size = ((m_width * BIT_COUNT + 31) / 32) * 4 * m_height;
		m_buffersize = m_size + sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
		m_buffer = (unsigned char*)malloc(m_buffersize);
		memset(m_buffer, 0, m_buffersize);

		m_header = (BITMAPFILEHEADER*)m_buffer;
		m_bi = (BITMAPINFOHEADER*)(m_buffer + sizeof(BITMAPFILEHEADER));
		m_bmp = m_buffer + sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);

		BITMAP bmpWnd;
		assertWin32(::GetObject(m_hbmWnd, sizeof(BITMAP), &bmpWnd));

		m_bi->biSize = sizeof(BITMAPINFOHEADER);
		m_bi->biWidth = bmpWnd.bmWidth;
		m_bi->biHeight = bmpWnd.bmHeight;
		m_bi->biPlanes = 1;
		m_bi->biBitCount = BIT_COUNT;
		m_bi->biCompression = BI_RGB;
		m_bi->biSizeImage = 0;
		m_bi->biXPelsPerMeter = 0;
		m_bi->biYPelsPerMeter = 0;
		m_bi->biClrUsed = 0;
		m_bi->biClrImportant = 0;

		m_header->bfType = 0x4d42;
		m_header->bfOffBits = sizeof(BITMAPFILEHEADER) + sizeof(BITMAPINFOHEADER);
		m_header->bfSize = m_buffersize;
	}

	~Screen() {
		if (m_hdcMem) {
			::DeleteDC(m_hdcMem);
		}
		if (m_hbmWnd) {
			::DeleteObject(m_hbmWnd);
		}
		if (m_hdcWnd) {
			::ReleaseDC(m_hwnd, m_hdcWnd);
		}
		if (m_buffer) {
			free(m_buffer);
		}
	}

	PIX* get(unsigned x, unsigned y) {
		assertWin32(::BitBlt(m_hdcMem, 0, 0, m_width, m_height, m_hdcWnd, x, y, SRCCOPY));
		assertWin32(::GetDIBits(m_hdcMem, m_hbmWnd, 0, m_height, m_bmp, (BITMAPINFO*)m_bi, DIB_RGB_COLORS));
		return pixReadMemBmp(m_buffer, m_buffersize);
	}

	void save() {
		FILE* fp = fopen("d:\\capture.bmp", "w");
		fwrite(m_buffer, m_buffersize, 1, fp); 
		fclose(fp);
	}
};

unsigned long long get_time() {
	struct timeval tv;		
	time_t clock;		
	struct tm tm;		
	SYSTEMTIME wtm; 		
	GetLocalTime(&wtm);		
	tm.tm_year = wtm.wYear - 1900;		
	tm.tm_mon = wtm.wMonth - 1;		
	tm.tm_mday = wtm.wDay;		
	tm.tm_hour = wtm.wHour;		
	tm.tm_min = wtm.wMinute;
	tm.tm_sec = wtm.wSecond;
	tm.tm_isdst = -1;
	clock = mktime(&tm);
	tv.tv_sec = clock;
	tv.tv_usec = wtm.wMilliseconds * 1000;	
	return ((unsigned long long)tv.tv_sec * 1000 + (unsigned long long)tv.tv_usec / 1000);
}

int main(int argc, char **argv)
{
	unsigned long long mark1 = 40320540000;
	unsigned long long mark2 = 40320550000;
	unsigned width = GetSystemMetrics(SM_CXSCREEN);
	unsigned height = GetSystemMetrics(SM_CYSCREEN);
#if 0
	unsigned x = atoi(argv[1]);
	unsigned y = height - atoi(argv[2]);
#else
	unsigned x = 10;
	unsigned y = height - 116;
#endif
	Screen screen(0);
	char* out;
	tesseract::TessBaseAPI* api = new tesseract::TessBaseAPI();
	if (api->Init(NULL, "eng")) {
		fprintf(stderr, "Could not initialize tesseract.\n");
		exit(1);
	}

	unsigned long long old = 0;
	while (1) {
		unsigned long long t = get_time();
		Pix *pix = screen.get(x, y);
		pix->xres = 70;
		pix->yres = 70;
		api->SetImage(pix);	// Get OCR result	
		out = api->GetUTF8Text();
		//api->End();
		unsigned long long val = atoll(out);
		//if (val >= mark1 && val <= mark2) {
			if (old != val) {
				old = val;
				printf("%llu\n", old);
			}
		//}
		delete[] out;
		pixDestroy(&pix);
		Sleep(20);
	}
	delete api;
	return 0;
}

