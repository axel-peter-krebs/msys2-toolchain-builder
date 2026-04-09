Motto: As good old Cygwin had a nice GUI.. I want one for MSYS{,}2!

Motivation: Portability is a virtue! Example provided, implement a WxWidgets based UI for MSYS2 package management on Windows.

Although it is very well possible to build Windows GUI, DLL a.s.o. on a Linux (e.g. using the MINGW toolchains provided for Linux, 
s. https://www.mingw-w64.org/downloads/), or the 'dotnet' port for Linux, cmp. https://learn.microsoft.com/en-us/dotnet/core/install/linux);
On the other hand, in order to build Unix/Linux programs on Windows, we must port the libraries that these program makes use of, too.

Note: A principle to follow is, that the toolchain itself must fit the OS it's running on. 
For example, if you're running on Windows 95 32-bit, it doesn't make sense to install the 64-bit toolchains (CLANG64,MINGW64,UCRT64).
On the other hand, running a MINGW32 toolchain on Windows 64-bit works well bcs. of the backward compat. 

The MSYS2 "architecture" styles are meant to support the development of applications for different target OSs; keep that in mind.

For example, if we want a GEdit running on Windows, we can either just install the package provided by the MSYS2 package repository
(s. https://packages.msys2.org/base/mingw-w64-gedit), or build a package for MSYS2 ourselves (s. the instructions on 
https://blogs.gnome.org/nacho/2014/08/01/how-to-build-your-gtk-application-on-windows/). 

The samples given herein concentrate on building MSYS2 packages, and how to set up a toolchain for a compiler architecture. 
At the moment, there are five compiler architectures supported by MSYS2 "environments": 

  - MINGW32: targeting Windows 32-bit, package prefix "mingw-w64-i686-YXZ"
  - MINGW64: targeting Windows 64-bit, package prefix "mingw-w64-x86_64-YXZ"; this may for example support for cross-platform Qt5 development, s. https://wiki.qt.io/MinGW-64-bit. 
  - UCRT64: targeting Windows 64-bit "Universal C Runtime", which is available since Windows8.1; package prefix "mingw-w64-ucrt-x86_64-XYZ".
  - CLANG64: targeting Windows 64-bit, prefix "mingw-w64-clang-x86_64-XYZ"; this provides an alternative to the Windows-native MSVC linker library that comes with Visual Studio; 
		instead of using the GCC infrastructure, the Clang compiler ist used based on the LLVM library. 
  - CLANGARM64: targeting Windows 64-bit, prefix "mingw-w64-clangarm-x86_64-XYZ", providing "an LLVM-based toolchain for building native Windows software for the AArch64 (ARM64) 
		architecture, using libc++ and the UCRT C library" (Google AI).

Irrespective of the targeted platform (CPU+libraries), the last two "environments" differ profoundly from the traditional MSVC (Microsoft Visual C++) vs GCC toolchains
in that they make use of the LLVM "low-level virtual machine", which produces a Intermediate Representation (IR, "bit-code") that is then compiled to the target platform. 

The first goal is to make cross-platform GUI environments available on Windows. Note: This is already achieved by some UI development environments like QTCreator et. al.
Samples for 'cross-platform' GUI libraries (s. https://en.wikipedia.org/wiki/List_of_platform-independent_GUI_libraries) are: 
	
	- CEF: https://github.com/chromiumembedded/cef
	- CEGUI Used for gaming apps primarily
	- EFL used in the "Enlightenment" desktop environment for Linux; cmp. https://www.enlightenment.org/docs/distros/windows-start.md
	- FLTK (Fast Light Toolkit), cmp. https://www.fltk.org/
	- GTK (Gnome Toolkit); cmp. https://gtk-rs.org/
	- IUP s. https://www.tecgraf.puc-rio.br/iup/
	- Qt5/6, cmp. https://wiki.qt.io/MinGW-64-bit (already accomplished)
	- TK (Tcl/Tk, Not TKinter)
	- others?
	
Some of these cross-platform libraries have already been 'ported' to MSYS2 btw making MSYS2 the main provider backend for their development, cmp. https://www.msys2.org/docs/who-is-using-msys2/
Above that, the following libraries have been ported to MSYS2 packages already and are ready to use:

	- Ruby for Windows (RubyInstaller2) installs a 'mingw64' backend;
	- Qt on Windows 10/11 supports either MSVC 2022 or Mingw-w64 13.1 https://doc.qt.io/qt-6/windows.html
	- EFL: this UI library is already available as 'mingw-w64-efl' (https://packages.msys2.org/base/mingw-w64-efl)
	- GTK3: s. https://packages.msys2.org/base/mingw-w64-gtk3; As an example, cmp. https://packages.msys2.org/base/mingw-w64-gedit as a full-fledged application using GTK on Windows. 
	- GTK4: https://packages.msys2.org/base/mingw-w64-gtk4

Of which GTK and Qt are the most prominent; the latter is used in KDE, and it must be noted, that a project exists on "develop.kde.org" 
that shows how to build KDE software for Windows 10 and 11, called "craft", s. https://develop.kde.org/docs/getting-started/building/craft/. 

Because there are already some well-established examples of cross-platform applications and frameworks (s.a.), the 'recipes' section shall concentrate on either newer technologies like GTK4 programming in Rust (cmp. https://www.gtk.org/docs/language-bindings/), or Qt5/6 on win32-API, supporting the following toolchains:
	
	- clang64-llvm21-rust1.91
	  Support LLVM/Clang toolchain with Rust as a frontend.
	  
	- clangarm64-gyp-depot-tools
	  Support CEF development on ARM notebooks. 
		
	- mingw32-gcc-cross-llvm
	  Support UI development on Windows 95 API (win32)
	  
	- ucrt64-ruby34-toolchain
	  Support development of UI applications on Windows >8.0 that use Ruby bindings, cmp. https://github.com/zenotech/fox-toolkit
	  
Another goal is to create MSYS2/MING64 packages of the following UI libraries (not yet done in MSYS2):
	
	- mingw-w64-cef: An example how to build the CEF (Chromium Embedded Framework (CEF), https://chromiumembedded.github.io/cef/) on Windows >8;
	- mingw-w64-cegui: 
	- mingw-w64-fltk:
	- mingw-w64-foxtoolkit:
	- WASM (WebAssembly) on Windows 10 up, cmp.  https://richardanaya.medium.com/write-web-assembly-with-llvm-fbee788b2817. 
	- Electron development.

Installation steps:

	TODO
	