@echo off
setlocal enabledelayedexpansion

:: Default values
set "INSTALL_TYPE=multi"
set "FORCE_INSTALL=false"
set "VERBOSE=false"
set "USE_DOCKER=false"
set "WORKDIR="

:: Nix installation URL
set "NIX_INSTALL_URL=https://nixos.org/nix/install"

:: Function to print usage
:print_usage
echo Usage: %0 [OPTIONS]
echo Options:
echo   -t, --type ^<type^>     Installation type: 'multi' or 'single' (default: multi)
echo   -f, --force           Force installation even if Nix is already installed
echo   -v, --verbose         Enable verbose output
echo   -d, --docker          Use Docker for installation
echo   -w, --workdir ^<path^>  Specify a work directory for Docker (requires -d)
echo   -h, --help            Print this help message
exit /b

:: Parse command line arguments
:parse_args
if "%~1"=="" goto :main
if "%~1"=="-t" set "INSTALL_TYPE=%~2" & shift & shift & goto :parse_args
if "%~1"=="--type" set "INSTALL_TYPE=%~2" & shift & shift & goto :parse_args
if "%~1"=="-f" set "FORCE_INSTALL=true" & shift & goto :parse_args
if "%~1"=="--force" set "FORCE_INSTALL=true" & shift & goto :parse_args
if "%~1"=="-v" set "VERBOSE=true" & shift & goto :parse_args
if "%~1"=="--verbose" set "VERBOSE=true" & shift & goto :parse_args
if "%~1"=="-d" set "USE_DOCKER=true" & shift & goto :parse_args
if "%~1"=="--docker" set "USE_DOCKER=true" & shift & goto :parse_args
if "%~1"=="-w" set "WORKDIR=%~2" & shift & shift & goto :parse_args
if "%~1"=="--workdir" set "WORKDIR=%~2" & shift & shift & goto :parse_args
if "%~1"=="-h" call :print_usage & exit /b
if "%~1"=="--help" call :print_usage & exit /b
echo Unknown option: %~1
call :print_usage
exit /b 1

:: Function to log messages
:log
if "%VERBOSE%"=="true" echo [%date% %time%] %*
exit /b

:: Function to check if Nix is already installed
:is_nix_installed
where nix >nul 2>&1
if %errorlevel% equ 0 (
    exit /b 0
) else (
    exit /b 1
)

:: Function to install Nix using Docker
:install_nix_docker
if not "%WORKDIR%"=="" (
    call :log Starting Docker with Nix and workdir
    docker run -it -v "%cd%\%WORKDIR%:/workdir" nixos/nix
) else (
    call :log Starting Docker with Nix
    docker run -it nixos/nix
)
exit /b

:: Main execution
:main
if "%USE_DOCKER%"=="true" (
    call :install_nix_docker
) else (
    call :is_nix_installed
    if %errorlevel% equ 0 (
        if "%FORCE_INSTALL%"=="false" (
            call :log Nix is already installed. Use --force to reinstall.
            exit /b 0
        )
    )

    call :log Starting Nix installation (Type: %INSTALL_TYPE%)
    
    if "%INSTALL_TYPE%"=="multi" (
        call :log Multi-user installation is not supported on Windows. Please use WSL.
        exit /b 1
    ) else (
        call :log Single-user installation is not supported on Windows. Please use WSL.
        exit /b 1
    )
)

:: Print installation type information
call :log Installation type: %INSTALL_TYPE%
if "%INSTALL_TYPE%"=="multi" (
    call :log Multi-user installation:
    call :log - Recommended for Linux running systemd, with SELinux disabled
    call :log - Requires authentication with sudo
    call :log - Pros: Better build isolation, better security, sharing builds between users
    call :log - Cons: Requires root to run daemon, more involved installation, harder to uninstall
) else (
    call :log Single-user installation:
    call :log - Nix is owned by the invoking user
    call :log - Run under your usual user account, not as root
    call :log - The script will invoke sudo to create /nix if it doesn't exist
)

call :log Nix installation is not directly supported on Windows.
call :log Please use Windows Subsystem for Linux (WSL) to install Nix on Windows.
call :log Refer to the Unix script for WSL installation instructions.

exit /b
