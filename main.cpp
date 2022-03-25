#include <stdlib.h>

extern "C" int C_printf(const char*, ...);

int main()
{
    int aza = 5;
    int m = C_printf("%d love %x na %b%%%c \n", -1, 3802, 4, '!');
}