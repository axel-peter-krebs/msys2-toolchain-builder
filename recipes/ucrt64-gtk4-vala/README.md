Name: UCRT64-GTK3

Description
Install the Gtk3 stack. 

Note
On the website, [https://www.gtk.org/docs/installations/windows/#using-gtk-from-msys2-packages] 
recommendations is following: 

Step 1.: Download the MSYS2 installer that matches your platform and follow the installation instructions.

Step 2.: Install GTK4 and its dependencies. Open a MSYS2 shell, and run:

pacman -S mingw-w64-ucrt-x86_64-gtk4

If you want to develop with GTK3, run:

pacman -S mingw-w64-ucrt-x86_64-gtk3

Step 3. (optional): If you want to develop a GTK application in C, C++, Fortran, etc, you’ll need a compiler like GCC and its toolchain:

pacman -S mingw-w64-ucrt-x86_64-toolchain base-devel

If you want to develop a GTK application in Python, you need to install the Python bindings:

pacman -S mingw-w64-ucrt-x86_64-python-gobject

If you want to develop a GTK application in Vala, you will need to install the Vala package:

pacman -S mingw-w64-ucrt-x86_64-vala

