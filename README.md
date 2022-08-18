# Description

This is a minimalistic hello world program written in `x64 Assembly for Windows`.
Instead of using the C standard library, it is directly linked against and invokes Windows API functions from `kernel32.dll`.

# Requirements

* [NASM Assembler](https://www.nasm.us/)
* `link.exe`, which can be acquired as part of the [MSVC x64/x86 Build tools](https://visualstudio.microsoft.com/downloads/)

# Build

* Adapt the paths to build tools at the top of `build.bat` if required
* Run `build.bat`
