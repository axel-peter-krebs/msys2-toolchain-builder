#!/bin/bash 

# This script simply redirects the Windows HOME environment variable to point to the users profile within MSYS2/home.

echo "[/etc/profile.d/100-portable-home.sh] Exporting HOME environment variable for user $USERNAME to bash (Find your files in /home/$USERNAME)!"

export HOME=/home/$USERNAME;

