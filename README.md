# Printf_asm
## Standard C function Printf, but written in assembly language

### Need to compile all source files and one of main files.


- Work with __System V x86-64__ calling convention
- The transfer from __System V x86-64__ to __cdecl__ is used
- main.s and main_new.s  - simulates passing System V arguments
- main.cpp - classic call from C 
- _Cprintf_ call function Printf( __cdecl__ calling) and then the classic function Printf from <stdlib.h>
