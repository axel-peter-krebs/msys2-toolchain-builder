# This scripts sets the parameters so build and install MSYS2 packages from source.
# It is separated from msys2-env.psm1 bcs. its purpose is different: building MSYS2
# as well as MINGW packages from source (with 'makepkg').
# Besides, it requires the MSYS2 to be installed and set in PATH environment variable:
# it uses 'sh' to execute commands bcs. it cannot be assumed that a Windows executable
# exists for a required Unix command like 'makepkg', for example. 
param (
    #[parameter(Position=0,Mandatory=$True)][String] $MSYS2_Path, set in Env:MSYS2_HOME
    #[parameter(Position=1,Mandatory=$False)][String] $MSYS2_User_Home, not needed
    [parameter(Position=1,Mandatory=$False)][String] $MSYS2_Packages_URL,
    [parameter(Position=2,Mandatory=$False)][String] $MSYS2_Packages_Dest,
    [parameter(Position=3,Mandatory=$False)][String] $MINGW64_Packages_URL,
    [parameter(Position=4,Mandatory=$False)][String] $MINGW64_Packages_Dest,
    [parameter(Position=4,Mandatory=$False)][String] $MSYS2_Keyring_URL,
    [parameter(Position=4,Mandatory=$False)][String] $MSYS2_Keyring_Dest
)

#Write-Host "Using MSYS2 packages URL: $MSYS2_Packages_URL";
#Write-Host "Using MSYS2 packages destination: $MSYS2_Packages_Dest";
#Write-Host "Using MINGW64 packages URL: $MINGW64_Packages_URL";
#Write-Host "Using MINGW64 packages destination URL: $MINGW64_Packages_Dest";
#Write-Host "Using MSYS2 keyring URL: $MSYS2_Keyring_URL";
#Write-Host "Using MSYS2 keyring destination: $MSYS2_Keyring_Dest";

$load_facts = [pscustomobject]@{
    msys2_keyring_git_repo_dir = $null
    msys2_pkgs_git_repo_dir = $null
    msys2_pkgs_git_status = $null
    mingw64_pkgs_git_repo_dir = $null
    mingw64_pkgs_git_status = $null
    debug_messages = @()
};

Function Get_Packer_Load_Facts() {
    return $script:load_facts; 
}

Export-ModuleMember 'Get_Packer_Load_Facts';

$msys2_shell_cmd = "bash.exe -i -l"; # /usr/bin/bash.exe is on path; last resort..

# Path must be set previously (not a parameter to module)
$msys2_install_path = "$Env:MSYS2_HOME";
if($msys2_install_path -eq $null) {
    $script:load_facts.'debug_messages' += "The Env:MSYS2_HOME was empty.. Must be set prior to invoking this module!";
    return;
}
else {
    $msys2_shell_cmd = "$msys2_install_path\msys2_shell.cmd"; # cmp. function Enter_Msys2_Shell in msys2-inst.ps1!
    Write-Host "Using MSYS2 shell cmd entrypoint in $msys2_shell_cmd";
}

Function Run_In_Shell_Job() {
    param (
        [parameter(Position=0,Mandatory=$True)][String] $command,
        [parameter(Position=1,Mandatory=$False)][String] $path,
        [parameter(Position=2,Mandatory=$False)][String] $logfile
    )
    Write-Host "->Run_In_Shell_Job(command: '$command',path:'$path',logfile:'$logfile')";
    $job_output = "/dev/null"; # background jobs shall not use STDOUT
    if ($logfile -ne $null) {
        $job_output = $logfile;
    }
    #$job_cmd = "bash.exe -c '$command' > $job_output 2>&1";
    $job_cmd = "$msys2_shell_cmd -c '$command' > $job_output 2>&1";
    Push-Location $path;
    #$job = Start-Job -ScriptBlock { $job_cmd;  } # -Credential Domain01\User01 -WorkingDirectory $path
    #$null = Wait-Job $job;
    #$output = $job | Receive-Job -Wait -AutoRemove;
    $output = iex "$job_cmd";
    Pop-Location
    return $output;
}

# Check preconditions for building packages

$msys2_package_repo_exists = Test-Path $($MSYS2_Packages_Dest);
if($msys2_package_repo_exists) {
    $script:load_facts.'msys2_pkgs_git_repo_dir' = $MSYS2_Packages_Dest;
}
else {
    $script:load_facts.'debug_messages' += "No MSYS2 package repository found in folder $MSYS2_Packages_Dest!";
}

$msys2_keyring_repo_exists = Test-Path $($MSYS2_Keyring_Dest);
if($msys2_keyring_repo_exists) {
    $script:load_facts.'msys2_keyring_git_repo_dir' = $MSYS2_Keyring_Dest;
}
else {
    $script:load_facts.'debug_messages' += "No MSYS2 keyring repository found in folder $MSYS2_Packages_Dest!";
}

$mingw64_package_repo_exists = Test-Path $($MINGW64_Packages_Dest);
if($mingw64_package_repo_exists) {
    $script:load_facts.'mingw64_pkgs_git_repo_dir' = $MINGW64_Packages_Dest;
}
else {
    $script:load_facts.'debug_messages' += "No MINGW-W64 package repository found in folder $MINGW64_Packages_Dest!";
}

Function Receive_PGP_Keys() {
    <#
    #!/bin/bash

    . PKGBUILD

    set -e

    _keyserver=(
        "keyserver.ubuntu.com"
        "keys.gnupg.net"
        "pgp.mit.edu"
        "keys.openpgp.org"
    )
    for key in "${validpgpkeys[@]}"; do
        for server in "${_keyserver[@]}"; do
            timeout 20 /usr/bin/gpg --keyserver "${server}" --recv "${key}" && break || true
        done
    done
    #>

    <#
        pacman-key --recv-keys 3176EF7DB2367F1FCA4F306B1F9B0E909AF37285
        pacman-key --lsign-key 3176EF7DB2367F1FCA4F306B1F9B0E909AF37285
    #>
}

Function Import_MSYS2_Keyring() {

}

Export-ModuleMember 'Import_MSYS2_Keyring'; 

Function MakePKG_MSYS2() {
    param (
        [parameter(Position=0,Mandatory=$True)][String] $pkg_name
    )
    $msys2_packages_dir = $script:load_facts.'msys2_pkgs_git_repo_dir';
    $pkgbuild_dir = "$msys2_packages_dir\$pkg_name";
    $pgkbuild_posixpath = cygpath -u $pkgbuild_dir;
    Write-Host "Build package in $pkgbuild_dir, Posix path: $pgkbuild_posixpath";
    $shell_log = "NONE";
    try {
        #iex "sh -c '. /etc/makepkg.conf'"; #| Write-Host
        #$print_srcinfo_cmd = "makepkg --printsrcinfo";
        #iex "sh -c '$print_srcinfo_cmd'";
        #$bash_cmd = "makepkg --packagelist";
        #$bash_cmd = "makepkg --check $pkg"; no key verification! (TODO)
        $bash_cmd = "makepkg --skipinteg  --syncdeps --noconfirm --needed --install";
        #$shell_log = iex "sh -c '$bash_cmd' 2>&1";
        $job_id = Run_In_Shell_Job $bash_cmd $pkgbuild_dir "makepkg_log.txt";
        Write-Host "->Run_In_Shell_Job returned $job_id";
    }
    catch {
        Write-Host "Problem installing $pkg_name!";
        $shell_log = $_;
    }
    return $shell_log;
}

Export-ModuleMember 'MakePKG_MSYS2'; 

# Now, for running 'makepkg', we need a bash-like environment.. 
Function MakePKG_MINGW() {
    param (
        [parameter(Position=0,Mandatory=$True)][String] $pkg_name
    )
    $mingw64_packages_dir = $script:load_facts.'mingw64_pkgs_git_repo_dir';
    $mingw_w64_package_name = "mingw-w64-$pkg_name";
    $pkgbuild_dir = "$mingw64_packages_dir\$mingw_w64_package_name";
    $pgkbuild_cygpath = cygpath -u $pkgbuild_dir;
    Write-Host "Building package in $pgkbuild_cygpath.."
    $result = "NONE";
    try {
        Push-Location $pkgbuild_dir; # now, current path for bash is this location
        $Env:MINGW_ARCH = "mingw64"; # default!
        #iex "sh -c '. /etc/makepkg.conf'"; #| Write-Host
        #$print_srcinfo_cmd = "makepkg --printsrcinfo";
        #iex "sh -c '$print_srcinfo_cmd'";
        #$list_packages_cmd = "makepkg --packagelist";
        #iex "sh -c '$list_packages_cmd'";
        $bash_cmd = "makepkg-mingw --syncdeps --noconfirm --needed --install";
        $result = iex "sh -c '$bash_cmd' 2>&1";
        Pop-Location
    }
    catch {
        Write-Host "Problem installing $pkg!";
    }
    return $result;
}

Export-ModuleMember 'MakePKG_MINGW'; 
