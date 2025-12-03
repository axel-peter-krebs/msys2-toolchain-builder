GOALS

From the website [https://www.gtk.org/docs/installations/windows/#using-gtk-from-msys2-packages] 

Building and distributing your application
Once you have installed the GTK as above, you should have little problem compiling a GTK app. In order to run it successfully, you will also need a GTK theme. There is some old builtin support for a Windows theme in GTK, but that makes your app look like a Windows 7 app. It is better to get a Windows 10 theme, for instance the Windows 10 Transformation Pack.

Step 1. Copy the icon assets from the Windows 10 Transformation Pack repository in a folder under your installation folder, under share/themes/Windows10:

for the GTK4 assets, copy the contents of the gtk-4.0 folder under share/themes/Windows10/gtk-4.0
for the GTK3 assets, copy the contents of the gtk-3.20 folder under share/themes/WIndows10/gtk-3.0
Step 2. You also need to copy the icons from the Adwaita theme, which you can download from the GNOME sources.

Step 3. Perform the same steps for the hicolor icons, which are the mandatory fallback for icons not available in Adwaita.

Step 4. To make GTK pick up this theme, put a file settings.ini under the etc folder in your installation folder:

for GTK4, use etc/gtk-4.0/settings.ini
for GTK3, use etc/gtk-3.0/settings.ini

The settings.ini file should contain:

[Settings]
gtk-theme-name=Windows10
gtk-font-name=Segoe UI 9

Step 5. To top it all off, run the glib-compile-schemas utility provided by GLib to generate the compiled settings schema in your installation folder:

glib-compile-schemas share/glib-2.0/schemas

Step 6. You can then zip up your installation folder, or use an installer generator to do that for you, and distribute the result.

You may use MSYS2 to build your GTK application and create an installer to distribute it. Your installer will need to ship your application build artifacts as well as GTK binaries and runtime dependencies.
