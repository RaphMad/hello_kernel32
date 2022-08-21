;; Resources:
;; https://sonictk.github.io/asm_tutorial/
;; https://gist.github.com/mcandre/b3664ffbeb4f5764b36a397fafb04f1c
;; https://retroscience.net/x64-assembly.html


;; Make clear this file contains 64bit assembly
bits 64

;; Use rip-relative addressing
default rel

;; Export entry symbol (this is specified in the call to link.exe)
global _start

;; Import external symbols
;; (all of them exist in kernel32.lib, which gets passed to link.exe in addition to the programs object file hello.obj)
;;
;; Why import symbols/functions from kernel32.lib?
;;
;; In windows, the "low level API stack" is: Kernel < Syscalls < ntdll.dll < kernel32.dll (and others like user32.dll)
;;
;; * The kernel itself cannot be accessed by user programs for obvious reasons (CPU ring protection modes)
;; * Syscalls could be performed, but are undocumented and evidently unstable between different versions of windows
;; * ntdll.dll is only partially documented and not intended for external use
;; * kernel32.dll (and friends) are the "official" low-level entry points to the windows API
extern GetStdHandle
extern WriteFile
extern ExitProcess


;; This section contains read-only data
section .rodata

    ;; Store the output string followed by CRLF as a sequence of bytes, at address 'msg'
    msg db "Hello World!", 0x0d, 0x0a

    ;; The length will be needed by the output function, and can be statically calculated at assembly time with 'equ'
    ;; It is actually a nifty trick that calculates the offset between the current address '$', and the address of 'msg'
    ;; See https://nasm.us/doc/nasmdoc3.html#section-3.2.4
    msg_len equ $ - msg


;; This section contains the code
section .text

_start:
    ;; This will discard the return address on the stack which we don't need since we will never call `ret`,
    ;; but terminate via `call ExitProcess`.
    ;; It has the positive effect of aligning the stack to 16bytes for upcoming calls, and will provide _our_
    ;; shadow space to those called functions.
    add rsp, 8;

    ;; For being able to print text, we first need to acquire a HANDLE to STDOUT
    ;; This HANDLE is a required parameter for the call to WriteFile

    ;; HANDLE = GetStdHandle(-11)
    ;;
    ;; See https://docs.microsoft.com/en-us/windows/console/getstdhandle
    ;;
    ;; Parameter 1 (rcx): requests the type of HANDLE, -11 is the constant for STDOUT
    ;; Return value (rax): HANDLE (an address with some type of meaning) is stored in rax, as per calling conventions
    mov rcx, -11
    call GetStdHandle

    ;; code = WriteFile(HANDLE, msg, msg_len, NULL, NULL)
    ;;
    ;; See https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-writefile
    ;;
    ;; Parameter 1 (rcx): HANDLE to write to
    ;; Parameter 2 (rdx): Address of message to print
    ;; Parameter 3 (r8): Length of message
    ;; Parameter 4 (r9): Write amount of written bytes to this address, null pointer
    ;;                   (Required according to docs when parameter 5 is null, but passing null seems to work just fine)
    ;; Parameter 5 (on stack): Unused optional parameter, null pointer
    ;; Return value (rax): Nonzero on success
    mov rcx, rax
    lea rdx, [msg]
    mov r8, msg_len
    mov r9, 0
    mov qword [rsp + 32], 0 ;; We already allocated the shadow space in the prolog and can't use push.
    call WriteFile

    ;; ExitProcess(code)
    ;;
    ;; See https://docs.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-exitprocess
    ;;
    ;; Parameter 1 (rcx): Exit code
    xor rcx, rcx
    call ExitProcess
    ;; ExitProcess will internally issue the syscall for terminating the process after doing some cleanup
    ;; We messed with rsp in the prolog which would make a `ret` impossible anyway
