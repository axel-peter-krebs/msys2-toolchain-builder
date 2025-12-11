Motto: As good old Cygwin had a nice GUI.. I want one for MSYS{,}2!

Goal: Build LLVM/Clang toolchains for use of Linux UI libraries on Windows. 

Motivation: Portability is a virtue!

Following this motto, the environment shall be self-sufficient and avoid system resources like user management etc.

Although it is very well possible to build Windows GUI, DLL a.s.o. on a Linux (e.g. using the MINGW toolchains provided for Linux, 
s. https://www.mingw-w64.org/downloads/), or the 'dotnet' port for Linux, cmp. https://learn.microsoft.com/en-us/dotnet/core/install/linux);
On the other hand, in order to build Unix/Linux programs on Windows, we must port the libraries that the program makes use of, too.

For example, if we want a GEdit running on Windows, we can either just install the package provided by the MSYS2 package repository
(s. https://packages.msys2.org/base/mingw-w64-gedit), or build a package for MSYS2 ourselves, s. the instructions on 
https://blogs.gnome.org/nacho/2014/08/01/how-to-build-your-gtk-application-on-windows/. 

The samples given herein concentrate on building MSYS2 packages, and how to set up a toolchain for a compiler architecture. 
At the moment, there are five compiler architectures supported by MSYS2 "environments": 

  - MINGW32: targeting Windows 32-bit, package prefix "mingw-w64-i686-YXZ"
  - MINGW64: targeting Windows 64-bit, package prefix "mingw-w64-x86_64-YXZ"; this may for example support for cross-platform Qt5 development, s. https://wiki.qt.io/MinGW-64-bit. 
  - UCRT64: targeting Windows 64-bit "Universal C Runtime", which is available since Windows 10 only; package prefix "mingw-w64-ucrt-x86_64-XYZ"
  - CLANG64: targeting Windows 64-bit, prefix "mingw-w64-clang-x86_64-XYZ"; this provides an alternative to the Windows-native MSVC linker library that comes with Visual Studio;
  - CLANGARM64: targeting Windows 64-bit, prefix "mingw-w64-clangarm-x86_64-XYZ", providing "an LLVM-based toolchain for building native Windows software for the AArch64 (ARM64) 
	architecture, using libc++ and the UCRT C library" (Google AI).

Irrespective of the targeted platform (CPU+libraries), the last two "environments" differ profoundly from the traditional MSVC (Microsoft Visual C++) vs GCC toolchains
in that they make use of the LLVM "low-level virtual machine", which produces a Intermediate Representation (IR, "bit-code") that is then compiled to the target platform. 

The first goal is to make Linux GUI environments available on Windows. Note: This is already achieved by some UI development environments like QTCreator et. al.
Samples for 'cross-platform' GUI libraries (s. https://en.wikipedia.org/wiki/List_of_platform-independent_GUI_libraries) are: 

	- CEGUI Used for gaming apps primarily
	- ELF used in the "Enlightenment" desktop environment for Linux; cmp. https://www.enlightenment.org/docs/distros/windows-start.md
	- FLTK (Fast Light Toolkit), cmp. https://www.fltk.org/
	- GTK (Gnome Toolkit); cmp. https://gtk-rs.org/
	- IUP s. https://www.tecgraf.puc-rio.br/iup/
	- Qt5/6, cmp. https://wiki.qt.io/MinGW-64-bit
	- TK (Tcl/Tk, Not TKinter)
	- others

Samples should be given how to use these libraries on different platforms, in MSYS2-speak this is "environments": 

	- Gtk3 application compiled with MINGW64/UCRT64 GNU tools;
	- GTK4 application with Python3 bindings compiled with 

The next goal of is to build the LLVM library from source, using CMake which is the recommended way. CMake is already provided as a package in MSYS2, however, and can be easily 
installed with "pacman -S --needed cmake" or CMake for Windows, provided as a NuGet package on chocolatey: choco install cmake --installargs 'ADD_CMAKE_TO_PATH=System';
The MSYS2 pacman command installs the Cygwin version. The first decision to made here is to decide upon the "environment" in which the LLVM source code will be build, 
that is MING32, MING64 etc. Since the LLVM runs on almost any platform, the decision shall be guided by the platform where the development is taking place, 
e.g. 'mingw-w64-i686-cmake' for older Windows versions, 'mingw-w64-x86_64-ccmake' or 'mingw-w64-ucrt-x86_64-ccmake' for newer Windows versions. I'm running on Window 8.1, 
thus I chose the newer MINGW64 environment. It must be noted, however, that packages for LLVM exist for every MSYS2 environment already.. Thus, this example is mereley a test-run 
for CMAKE and MINGW64 to build the LLVM library. Cmp. https://packages.msys2.org/base/mingw-w64-llvm.

Steps to reproduce: 
  a) Install MSYS2 and the GIT repository for MINGW-packages. 
  b) Build the CMake package that best suits your development platform, e.g. 

The final goal of this "etude" is to build a MSYS2 package based on the newer Clang/LLVM architecture using a Rust frontend. The package shall make use of one of the many 
UI libraries provided for cross-platform development. 



Of which GTK and Qt are the most prominent; the latter is used in KDE, and it must be noted, that a project exists on "develop.kde.org" 
that shows how to build KDE software for Windows 10 and 11, called "craft", s. https://develop.kde.org/docs/getting-started/building/craft/. 

A second goal, quasi bon-bon, is to establish a toolchain for WebAssembly development on Windows and run a test in a browser of choice, 
cmp. https://richardanaya.medium.com/write-web-assembly-with-llvm-fbee788b2817. 

Installation steps:

	* Download MSYS2-base installer and install into folder 'msys2' (this can be changed via the 'msys2.properties' 
	  file).
	* Configure MSYS2 installation: A User for building packages should be established, defaulting to user 'qafila'
	  (arab. for 'caravan'). Use the 'git-for-windows' recipe to establish the proper environment, including pgp managment 
	  and check-summing the downloaded package. 
	* Install the CMake package for UCRT64 from source. 

	* Install additional packages needed: 
	  - mingw-w64-x86_64-xmake 
	  
	* The 'llvm-mingw' builder builds toolchains for Windows platforms, cmp. the *.sh scripts contained in the 'source';
	  However, these will be migrated to a Perl script which in turn can be executed from PowerShell.
	  Note: Perl is pre-installed on the initial MSYS2 installation (whilst Python etc. is not; this will be done with PKGBUILD)
	* Provide PS commands to build toolchain on the current system. 

Note: Some commands are not available in the base MSYS2 installation, e.g. 'makepkg'; therefore, these _must_ 
be run on a command line tool (shell) like Bash, which is only possible "within" the MSYS2 installation.


