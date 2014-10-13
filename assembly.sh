#!/bin/bash

for file in $@; do
    echo "Compiling $file..."
    nasm -g -f elf "$file" || exit
    echo "Linking $file..."
    ld -m elf_i386 -static -o "${file%.*}" "${file%.*}.o" || exit
done
