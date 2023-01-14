::@echo off
cd /d "%~dp0"

git clean -fdxq && git reset --hard


::RD /S /Q "P:\A3A"
::ROBOCOPY ".\A3A" "P:\A3A"

::cd ".\Tools\ArmaScriptCompiler"
::ArmaScriptCompiler.exe
::cd ..\..

cd ".\Tools\Builder"
powershell -file "buildAddons.ps1"
cd ..\..

pause