#!/bin/bash
nasm -f elf32 compress.asm
nasm -f elf32 decompress.asm
gcc compress.o decompress.o main.c -m32 -o filetool