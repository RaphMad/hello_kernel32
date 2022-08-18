@echo off

:: Required to use link.exe, path may need adaption
set vcv="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

:: May need an absolute path if your nasm.exe is not on %PATH%
set nasm="nasm.exe"

:: Perform the assembly
%nasm% -f win64 src\hello.asm -o out\hello.obj

:: Linking step
CMD /c "call %vcv% & link.exe out\hello.obj kernel32.lib /entry:_start /nodefaultlib /subsystem:console /out:out\hello.exe"

:: hello.obj kernel32.lib
:: Link files 'hello.obj kernel32.lib', the latter one contains the used windows API functions.

:: /entry:_start
:: Defines a custom entry point symbol
:: See https://docs.microsoft.com/en-us/cpp/build/reference/entry-entry-point-symbol

:: /nodefaultlib
:: Strip all libraries that would be included by default
:: See https://docs.microsoft.com/en-us/cpp/build/reference/nodefaultlib-ignore-libraries

:: /subsystem:console
:: Would define the entry point symbol, but this gets overriden by /entry: and is effectively ignored.
:: See https://docs.microsoft.com/en-us/cpp/build/reference/subsystem-specify-subsystem
