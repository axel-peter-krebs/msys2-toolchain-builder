# 

https://gtk-rs.org/gtk4-rs/stable/latest/book/introduction.html

- Install the LLVM build environment with clang compiler. Use Rust as frontend (Cargo, Crates.io)
- Install the CLANG64 GTK4 libraries. 

mingw-w64-ucrt-x86_64-toolchain consists of:

mingw-w64-ucrt-x86_64-binutils
mingw-w64-ucrt-x86_64-crt
mingw-w64-ucrt-x86_64-gcc
mingw-w64-ucrt-x86_64-gdb
mingw-w64-ucrt-x86_64-gdb-multiarch
mingw-w64-ucrt-x86_64-headers
mingw-w64-ucrt-x86_64-libmangle
mingw-w64-ucrt-x86_64-libwinpthread
mingw-w64-ucrt-x86_64-winpthreads
mingw-w64-ucrt-x86_64-make
mingw-w64-ucrt-x86_64-pkgconf
mingw-w64-ucrt-x86_64-tools
mingw-w64-ucrt-x86_64-winstorecompat

mingw-w64-ucrt-x86_64-gtk4 dependencies:

mingw-w64-ucrt-x86_64-adwaita-icon-theme
mingw-w64-ucrt-x86_64-cairo
mingw-w64-ucrt-x86_64-cc-libs
mingw-w64-ucrt-x86_64-gdk-pixbuf2
mingw-w64-ucrt-x86_64-glib2
mingw-w64-ucrt-x86_64-graphene
mingw-w64-ucrt-x86_64-gst-plugins-bad-libs
mingw-w64-ucrt-x86_64-gtk-update-icon-cache
mingw-w64-ucrt-x86_64-json-glib
mingw-w64-ucrt-x86_64-libepoxy
mingw-w64-ucrt-x86_64-pango
mingw-w64-ucrt-x86_64-shared-mime-info
mingw-w64-ucrt-x86_64-vulkan-loader

mingw-w64-ucrt-x86_64-efl dependecies:

mingw-w64-ucrt-x86_64-cc-libs
mingw-w64-ucrt-x86_64-dbus
mingw-w64-ucrt-x86_64-fontconfig
mingw-w64-ucrt-x86_64-freetype
mingw-w64-ucrt-x86_64-fribidi
mingw-w64-ucrt-x86_64-gst-plugins-base
mingw-w64-ucrt-x86_64-gstreamer
mingw-w64-ucrt-x86_64-libavif
mingw-w64-ucrt-x86_64-libheif
mingw-w64-ucrt-x86_64-libjpeg-turbo
mingw-w64-ucrt-x86_64-libjxl
mingw-w64-ucrt-x86_64-libpng
mingw-w64-ucrt-x86_64-libraw
mingw-w64-ucrt-x86_64-libsndfile
mingw-w64-ucrt-x86_64-libtiff
mingw-w64-ucrt-x86_64-luajit
mingw-w64-ucrt-x86_64-lz4
mingw-w64-ucrt-x86_64-openjpeg2
mingw-w64-ucrt-x86_64-openssl
mingw-w64-ucrt-x86_64-pixman

mingw-w64-wxwidgets3.3 dependencies:

mingw-w64-ucrt-x86_64-wxwidgets3.3-common
mingw-w64-ucrt-x86_64-wxwidgets3.3-common-libs
mingw-w64-ucrt-x86_64-wxwidgets3.3-gtk3
mingw-w64-ucrt-x86_64-wxwidgets3.3-gtk3-libs
mingw-w64-ucrt-x86_64-wxwidgets3.3-msw
mingw-w64-ucrt-x86_64-wxwidgets3.3-msw-cb_headers
mingw-w64-ucrt-x86_64-wxwidgets3.3-msw-libs
mingw-w64-ucrt-x86_64-wxwidgets3.3-qt
mingw-w64-ucrt-x86_64-wxwidgets3.3-qt-libs

Rust libraries installed:

- "mingw-w64-ucrt-x86_64-rust"
- "mingw-w64-ucrt-x86_64-rust-bindgen"
- "mingw-w64-ucrt-x86_64-rust-src"
- "mingw-w64-ucrt-x86_64-rustup"
		
Rust has additional support for WASM not included here:

- "mingw-w64-ucrt-x86_64-rust-emscripten"
- "mingw-w64-ucrt-x86_64-rust-wasm"