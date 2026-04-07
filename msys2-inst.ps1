# Convenience script to manage MSYS2 installation on Windows. Goals: cmp. 'msys2-env.psm1' and 'msys2-packer.psm1'.
# Entry point for 'msys2-env.psm1': Reading settings 'msys2.properties' (values overridden via configuration) and apply.
# If started in debug mode, print debug messages on screen.
param(
    [parameter(Position=0,Mandatory=$False)][Bool] $show_debug_information
)

$Current_Script_loc = $PSScriptRoot;

Set-location $Current_Script_loc; # necessary to find configuration files

$admin_mode = $False;

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "You're running the PS script as non-administrator; if you want to use 'makepkg', you must run it as Administrator, however..";
}
else {
    $script:admin_mode = $True;
}

Function __log_if_debug([string] $debug_message) {
    if ($show_debug_information -eq $true) {
        Write-Host $debug_message;
    }
}

#Function __reload_script() {
#    .\msys2-inst.ps1; # reload the whole script
#}

# Assume sensible defaults for MSYS2 location, MSYS2 user, download location, source location a.s.o.
$settings = @{
    'sync.on.start' = "True";
    'downloads.dir' = "downloads"; # default location for downloads
    'msys2.install.dir' = "msys64"; # default as provided by installer, can be overridden in msys2.properties file
    'msys2.download.url' = "https://repo.msys2.org/distrib/x86_64/msys2-x86_64-20250830.exe"; 
    'msys2.packages.master.url' = "https://github.com/msys2/MSYS2-packages.git"; 
    'msys2.mingw64.packages.master.url' = "https://github.com/msys2/MINGW-packages.git"; 
    'msys2.mingw64.hdl.url' = ""; # MINGW-w32
    'msys2.keyring.master.url' = "https://github.com/msys2/MSYS2-keyring.git";
    'msys2.user' =  ""; # to be set or left to environment
    'msys2.msystem' =  'mingw32'; # default (Windows 32-bit, id est Windows 95 [sic!]); 
};

Function print_settings() {
    $settings.Keys | ForEach-Object{
        $message = "Key: {0}, Value: {1}" -f $_, $settings[$_] | Write-Host
    }
}

# Read the 'msys2.properties' file and override defaults if required.
$settingsFile = Convert-Path "msys2.properties"
Import-Csv $settingsFile -Delimiter "=" -Header Key,Value | ForEach-Object { 
    $key = $_[0].Key #| Write-Host
    $val = $_[0].Value #| Write-Host
    $overridden = $False
    
    __log_if_debug "Import-Csv# key: $key, value: $val";
    
    if($key -eq 'downloads.dir') {
        $overridden = $True
        #$settings.Add($key, $val); False: key already present
        #$settings[$key] = $val;
    }
    elseif($key -eq 'msys2.install.dir') {
        $overridden = $True;
    }
    elseif($key -eq 'msys2.download.url') {
        $overridden = $True;
    }
    elseif($key -eq 'msys2.keyring.master.url') {
        $overridden = $ $True;
    }
    elseif($key -eq 'msys2.packages.master.url') {
        $overridden = $True;
    }
    elseif($key -eq 'msys2.mingw64.packages.master.url') {
        $overridden = $True;
    }
    elseif($key -eq 'msys2.mingw64.hdl.url') {
        $overridden = $True;
    }
    elseif($key -eq 'msys2.user') {
        $overridden = $True;
    }
    elseif($key -eq 'github.local.dir') {
        $overridden = $True;
    }
    elseif($key -eq 'sync.on.start') {
        $overridden = $True;
    }
    elseif($key -eq 'msys2.msystem') {
        $overridden = $True;
    }
    else {
        __log_if_debug "The specified key '$key' is not recognized - will ignore!";
    }
    # Show overrides to user for clarification if settings in msys2.properties
    if($overridden -eq $True){
        __log_if_debug "Overriding default settings: Key '$key' defined as '$($script:settings[$key])' will be overridden with '$val'!";
        $settings[$key] = $val;
    }
}

if ($show_debug_information) {
    print_settings
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set the path to the MSYS2 executables (GNU programs)
Write-Host "Loading MSYS2 installer.."
$sync_on_start = $False; # introduced this for lazy upgrade
if ( $script:settings.'sync.on.start' -eq "True") {
    Write-Host "MSYS2 will be updated automatically - You can prevent this by specifying 'sync.on.start=False' in 'msys2.properties'!";
    $sync_on_start = $True;
}
Import-Module "$Current_Script_loc\msys2-env.psm1" -ArgumentList @(
    $script:settings.'msys2.install.dir',
    $script:settings.'msys2.download.url',
    $sync_on_start,
    $show_debug_information
)

$module_load_facts = Get_Module_Load_Facts;

$msys2_absolute_path = $module_load_facts.'msys2_path';
__log_if_debug "Absolute path to MSYS2 installation: $msys2_absolute_path";

# The HOME environment variable is needed for bash et al. 
$user_home_dir = $Env:USERPROFILE; # This is default system setting on Windows
                                   # but may be overridden by parameter, see below

Function Enter_Msys2_Shell_Cmd() {
    param (
        [parameter(Position=0,Mandatory=$False)][String] $msys2_user_home
        #[parameter(Position=0,Mandatory=$True)][String] $msys2_arch
    )
    __log_if_debug "A bash-like MSYS2 program will be opened through 'msys2_shell.cmd' located at the MSYS2 root installation..";
    $m_system = $script:settings.'msys2.msystem';
    if ( $Env:MSYSTEM -eq $null ) {
        Write-Host "The envionment variable MSYSTEM was not set; I will use the value for 'msys2.msystem' in 'msys2.properties', which is set to '$m_system'";
    }
    else {
        Write-Host "The target platform was specified by the environment variable MSYSTEM as '$Env:MSYSTEM' - I will use that!"
        $m_system = $Env:MSYSTEM;
    }
    $msys2_shell_cmd_path = $script:msys2_absolute_path + "\msys2_shell.cmd";
    __log_if_debug "Shell to open: $msys2_shell_cmd_path"

    # Now we have the path to the shell command; however, no HOME environment has been set.. 
    $working_directory = $script:user_home_dir # set prior;
    if ($working_directory -eq "") { # not set prior
        $working_directory = $msys2_absolute_path + "\tmp"
        Write-Host "The value of 'user_home_dir' was empty, using $working_directory instead!";
    }
    $processOptions = @{
        FilePath = "$msys2_shell_cmd_path"
        #UseNewEnvironment = $true
        ArgumentList = "-$m_system" # -here -where '$Env:HOME' -use-full-path -mingw64 -conemu -no-start -defterm -shell bash
        WorkingDirectory = $working_directory;
        Verb = "RunAs" # we need adminstrative rights, e.g. to install in protected directories
    }
    $proc = Start-Process @processOptions # -Wait -PassThru # -WorkingDirectory $user_home_dir 
}

$required_packages_for_running_installer = @(
    "perl-YAML-Syck",
    "perl-Path-Tiny",
    "perl-File-Which",
    "perl-Params-Util"
);

$missing_yaml_packages = @();

$recipes_folder = Convert-Path "$Current_Script_loc\recipes";
$perl_install_script_loc = "$Current_Script_loc\install.pl"

Function Run_Install_Script() {
    $file_exists = $False;
    while ( $file_exists -ne $True ) {
        $recipe = Read-Host -Prompt "`nPls. tell me which recipe to run (path to 'recipe.yml' file), or type 'x' to exit: >";
        if($recipe -eq 'x') {
            $file_exists = $True; # hack
        }
        else {
            Write-Host "YAML file to execute: $recipes_folder\$recipe\recipe.yml";
            $file_exists = Test-Path "$recipes_folder\$recipe";
            if ($file_exists) {
                # Now, if we want to use the MSYS2-Perl, we mimic a Unix-like environment, 
                # bcs. we will execute Perl in Bash (bash has path settings of MSYS2 installation)
                $perl_install_script_cygpath = cygpath -u $perl_install_script_loc; # short for iex "sh -c 'cygpath -u $perl_install_script_loc";
                $yaml_file_cygpath = cygpath -u $recipes_folder\$recipe\recipe.yml;
                $msys2_install_cygpath = $script:settings.'msys2.install.dir'; # cygpath would always be '/'!
                Invoke-Command { 
                    #$queryRes = iex "perl -s $perl_install_script_loc $yaml_file_cygpath"; # arguments?
                    $perl_cmd = "perl -s $perl_install_script_cygpath $yaml_file_cygpath $msys2_install_cygpath";
                    __log_if_debug "Running Perl command: $perl_cmd";
                    iex "sh -c '$perl_cmd'"; # execute Perl in bash!!!
                    Write-Host "`nReceipe successfully executed!";
                }
            }
            else {
                Write-Host "A file '$recipe' wasn't found; pls. specifiy a valid path!";
            }
        }
    }
}

# Now, on the website is stated, that the 'makepkg' Bash script (sic) will be installed by 'base-devel'; 
# However, this draws in some other programs like 'binutils', 'bison', 'diffstat', 'diffutils', 'dos2unix' a.o.
# Cmp. https://packages.msys2.org/packages/base-devel?variant=x86_64
# S. also https://wiki.archlinux.org/title/Makepkg
$required_packages_for_packing = @(
    "base-devel", # base|binutils|bison|diffstat|diffutils|dos2unix|file|flex|gawk|gettext|grep|make|pacman|patch|sed|tar|texinfo|texinfo-tex
    "cmake", # MSYS2 (Cygwin) package!
    "curl"
    "cygutils",
    "diffutils",
    "git",
    "help2man",
    "patch",
    "perl-File-Next",
    "rsync",
    # needed by Bazel:
    "python", # Python-2!
    "unzip",
    "zip",
    "zlib-devel"
);

$missing_packer_dependencies = @(); # will be checked later, s.b.

# When MSYS2 installation is found valid (synched and clean), the user may choose to enter the 'packing' environment;
# Note: it is assumed that the GIT source resides under the /usr/src tree of the MSYS2 installation.
Function Start_Packing() {

    Write-Host "Inspecting package-build environment .."

    # next step is to enable build environment for MSYS2 packages; if a valid local GitHub path 
    # is provided, use this one; otherwise use current path (default).
    $msys2_packages_master_src_dir = "$script:msys2_absolute_path\usr\src\MSYS2-packages";
    $mingw64_packages_master_src_dir = "$script:msys2_absolute_path\usr\src\MINGW-packages";
    $msys2_keyring_master_src_dir = "$script:msys2_absolute_path\usr\src\MSYS2-keyring";

    Import-Module "$Current_Script_loc\msys2-pack.psm1" -ArgumentList @(
        $script:settings.'msys2.packages.master.url',
        $msys2_packages_master_src_dir,
        $script:settings.'msys2.mingw64.packages.master.url',
        $mingw64_packages_master_src_dir,
        $script:settings.'msys2.keyring.master.url',
        $msys2_keyring_master_src_dir
    )

    $packer_load_facts = Get_Packer_Load_Facts;
    $msys2_keyring_dir = $packer_load_facts.'msys2_keyring_git_repo_dir';
    __log_if_debug "`tThe MSYS2 git repository for MSYS2 keyring is in $msys2_keyring_dir.";
    $msys2_packages_dir = $packer_load_facts.'msys2_pkgs_git_repo_dir';
    __log_if_debug "`tThe MSYS2 git repository for packages is in $msys2_packages_dir.";
    $mingw_packages_dir = $packer_load_facts.'mingw64_pkgs_git_repo_dir';
    __log_if_debug "`tThe MINGW-W64 git repository for packages is in $mingw_packages_dir.";

    $pkg_kind = Read-Host -Prompt "What kind of package do you want to build? Type
        - 'c2' for a MSYS2 package build, 
        - 'w64' for MINGW-W64 package build, 
        - 'w32' for HDL packages (MINGW-w32), 
        - 'keys' to install the MINGW-keyring to the local MSYS installation, or
        - 'x' to exit this menu.`n>>";
    if ( $pkg_kind -eq 'c2' ) {
        $pkg = Read-Host -Prompt "Pls. type the name of the package (subdirectory in the GIT repository)`n>>";
        $res = MakePKG_MSYS2($pkg);
        Write-Host "->makepkg returned $res.";
    }
    elseif ($pkg_kind -eq 'w64') {
        $pkg = Read-Host -Prompt "Pls. type the name of the package (subdirectory in the GIT repository)`n>>";
        $res = MakePKG_MINGW($pkg);
        Write-Host "->makepkg returned $res.";
    }
    elseif ($pkg_kind -eq 'keys') {
            Write-Host "TODO!";
    }
    elseif ( $pkg_kind -eq 'x') {
        Write-Host "Exiting packaging.."
    }
    else {
        Write-Host "Could not understand your input: $pkg_kind. Exiting.."
    }
    #Make_MINGW_Package($pkg);
    return "OK";
}

Function Install_Required_Packages() {
    $missing_packages_merged = $script:missing_packer_dependencies + $script:missing_yaml_packages;
    $results = @();
    foreach ($missing_package in $missing_packages_merged) {
        Write-Host "Installing missing package: $missing_package..";
        $pacman_install_pkg_cmd = "pacman -S --needed --noconfirm $missing_package";
        $res = iex "sh -c '$pacman_install_pkg_cmd' 2>&1";
        $results += $res;
    }
    return $results;
}

# TODO: Build the menu dynamically, resp. which functions are available
Function Loop_Menu() {
    param (
        [parameter(Position=0,Mandatory=$False)][Bool] $packages_missing,
        [parameter(Position=1,Mandatory=$False)][Bool] $clean_start_required
    )
    $exitWhile = $False;
    do {
        $prompt = "Please choose an activity:`n";
        $prompt += "`tType 'H' to get some help about this MSYS2 installation.`n";
        $prompt += "`tType 'B' to bash into the MSYS2 installation with a predefined user account.`n";
        if ( $clean_start_required ) {
            $prompt += "`tType 'C' to reload the MSYS2 library in a clean way (and unlock DB if necessary).`n";
        }
        else {
            if ( $packages_missing ) {
                $prompt += "`tType 'R' to install missing requirements.`n";
            }
            else {
                $prompt += "`tType 'P' for a MSYS2-packing (package building) environment.`n";
                $prompt += "`tType 'Y' to run an advanced YAML installer recipe (Perl).`n";
            }
        }
        $prompt += "`tType 'X' to exit this menu; Note: MSYS2-ROOT/usr/bin is still on path! Programs like 'pacman' etc. are still available!!`n>";
        $activity = Read-Host -Prompt $prompt;
        switch ($activity) {
            H {
                Msys_Help;
                #$exitWhile = $True;
            }
            B {
                Enter_Msys2_Shell_Cmd $script:user_home_dir;
                #$exitWhile = $True;
            }
            C {
                Msys_Sync_Packages;
                Write-Host "MSYS2 has been reloaded (sync'd)..";
                $exitWhile = $True;
                #__reload_script;
            }
            R {
                Install_Required_Packages | ForEach-Object { Write-Host "Installed $_"; };
                $exitWhile = $True;
                #__reload_script;
            }
            Y {
                Run_Install_Script;
                # Stay in loop
            }
            P {
                $retval = Start_Packing;
                if($retval -eq "OK") {
                    Write-Host "Packaging ended with 'OK'";
                }
                else {
                    Write-Host "Something unexpected happened..";
                }
                #$exitWhile = $True;
            }
            X {
                Set-Location $Current_Script_loc;
                $exitWhile = $True;
            }
            default { 
                Write-Host "Your input has not been recognized as a valid option!" 
            }
        }
    } while ( ! $exitWhile);
}

if($module_load_facts.'msys2_clean' -eq $True) {
    Write-Host "Local MSYS2 installation was properly initialized.";

    # Setting new HOME if desired.. must be unter /home in MSYS2 installation
    if ($script:settings.'msys2.user' -ne "") { # Do not use the OS's user profile, but the MSYS2 'home' folder
            $msys2_user = $script:settings.'msys2.user';
            $script:user_home_dir = "$script:msys2_absolute_path\home\$msys2_user"; # changed for all functions!
            __log_if_debug "User's HOME directory set to $script:user_home_dir"
            $Env:HOME = Convert-Path $script:user_home_dir; # used for opening a bash env
            #$Env:HOMEPATH = $user_home_path;
            #$Env:USERNAME = $msys2_user;
            #$Env:USERPROFILE = $user_home_path;
            # set-variable -name HOME -value "$user_home_path" -Option ReadOnly;
            Write-Host "A path to the users HOME was set to $Env:HOME";
    }
    else {
        Write-Host "A path to the users HOME was not set in the 'msys2.properties' file - Will use the systems settings.";
        # Now, we cannot set the HOME variable to MSYS2/home, bcs. we don't know wheter MSYS2 was initiailized, yet..
    }

    # Check whether the installation contains the required Perl modules for YAML installer
    $installed_packages = $module_load_facts.'msys2_packages';

    #$installablePackages = $requiredPerlModules | Where {$installedPackages -NotContains $_}
    Write-Host "Checking if requirements for YAML installation are met..";
    foreach ($pkg in $script:required_packages_for_running_installer) {
        if ($pkg -in $installed_packages.Keys) {
             __log_if_debug "`tRequired package '$pkg' is already installed.";
        }
        else {
            $script:missing_yaml_packages += $pkg;
        }
    }
    if ( $missing_yaml_packages.count -gt 0 ) {
        Write-Host "Some packages for running the YAML installer are missing!";
        foreach ($pkg in $missing_yaml_packages) {
             __log_if_debug "`tPackage $pkg not found."
        }
    }
    
    Write-Host "Checking if requirements for building MSYS2 packages are met..";
    foreach ($pkg in $script:required_packages_for_packing) {
        if ($pkg -in $installed_packages.Keys) {
             __log_if_debug "`tRequired package '$pkg' already installed.";
        }
        else {
            $script:missing_packer_dependencies += $pkg;
        }
    }
    if ( $missing_packer_dependencies.count -gt 0 ) {
        Write-Host "Some dependencies for building MSYS2 packages are missing! You may install them with 'R'.";
        foreach ($pkg in $missing_packer_dependencies) {
            Write-Host "`tPackage $pkg not found."
        }
    }

    $missing_packages_merged = $script:missing_packer_dependencies + $script:missing_yaml_packages;
    $are_packages_missing = $False;
    if($missing_packages_merged.count -gt 0) {
        $are_packages_missing = $True;
    }
    Loop_Menu $are_packages_missing $False;
}
else {
    Write-Host "There have been some problems loading the local MSYS2 installation.. Log: "
    foreach($msg in $module_load_facts.debug_messages) {
        Write-Host "`t$msg";
    }
    Loop_Menu $False $True;
}
