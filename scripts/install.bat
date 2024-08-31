@echo off

REM Install packages using Chocolatey
choco install alacritty zellij neovim -y

REM Create symlinks
mkdir "%USERPROFILE%\.config\alacritty" 2>nul
mkdir "%USERPROFILE%\.config\zellij" 2>nul
mkdir "%USERPROFILE%\.config\nvim" 2>nul

mklink "%USERPROFILE%\.config\alacritty\alacritty.yml" "%~dp0config\alacritty\alacritty.yml"
mklink "%USERPROFILE%\.config\zellij\config.yaml" "%~dp0config\zellij\config.yaml"
mklink "%USERPROFILE%\.config\nvim\init.vim" "%~dp0config\nvim\init.vim"

echo Setup complete!