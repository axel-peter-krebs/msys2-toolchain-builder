README

The 'recipes' contained herein are samples how to establish different 'toolchains' in MSYS2.

Note: 'Toolchains' in this context means to provide compilers, cross-compilers and supporting libraries like 'autoconf', 'cmake' etc. On the MSYS2 website, there is almost for each use case a 'group', which includes the build dependecies; in the recipes, these dependecies are explicit! 

All samples follow a 64-bit architecture, therefore an additional "-w64" naming a.s.o. is omitted. Consequently, the outdated i686 architecture is not supported. 

Per MSYS2 design, a distinction must be made between MINGW packages and 'original' MSYS2 packages, that come from the 'old' Cygwin environment which MSYS2 is trying to supersede; thus the 'platform' entry. The 'target' YAML key on the other side specifies where the code is to be run, e.g. Windows 32-bit (mingw32, or package infix i686), or Windows 64-bit with different runtimes (mingw64, ucrt64, clang64, and clangarm64). A good explanation can be found on StackOverflow:

"The different environments exist to produce different kinds of Windows executables, or do that with different tools."

Thus, even if you succeed to compile a UCRT64 executable on Windows 8.1 (the platform on which I am working at the moment), you may not be able to run it because the OS is missing the required runtime libraries. However, this is not the goal of these examples; the actual goal is to get some originally GNU/Linux GUI libraries running on Windows that claim to be 'platform-independent' resp. 'cross-platform', such as was Javas first intention. 

as a first step, an URCT64 'toolchain' shall be examplified, cmp. 'ucrt-toolchain', which is mainly a script to make the installation of the 'mingw-w64-ucrt-x86_64-toolchain' MSYS2 group more explicit. It follows the instructions given by Tarik Brown on MSDN: https://code.visualstudio.com/docs/cpp/config-mingw. 

Samples to do the same for other targets, as specified in the MSYS2 'repos', can be added. 

One goal is to make use of the LLVM compiler collection on Windows, especially the Clang compiler, since this is the 'new' way to build C(++) programs. Therefore, the UCRT64 toolchain shall be ported from GCC to LLVM using the Clang compiler, s. 'ucrt-llvm-clang'. 

As a third step, other programming languages shall be used as a frontend compiler to LLVM, e.g. Rust; a sample to build "web Assembly" applications with LLVM is to be added, cmp. https://github.com/emscripten-core/emscripten. 

Above installing the required packages, cmp. 'ucrt-toolchain', some environment require downloading of SSL information or manipulation / installation of 'runtime' files, cmp. 'git-for-windows'.

