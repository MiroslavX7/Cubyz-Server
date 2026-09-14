@echo off

echo Detecting Zig compiler...

set /p baseVersion=<".zigversion"

IF "%PROCESSOR_ARCHITECTURE%"=="AMD64"(set arch=x86_64)
IF "%PROCESSOR_ARCHITECTURE%"=="IA64"(set arch=x86_64)
IF "%PROCESSOR_ARCHITECTURE%"=="x86"(set arch=x86)
IF "%PROCESSOR_ARCHITECTURE%"=="ARM64"(set arch=aarch64)
IF "%arch%"=="" (
echo Machine architecture could not be recognized: %arch%. Please file a bug report.
echo Defaulting architecture to x86_64.
set arch=x86_64
)

set version=zig-%arch%-windows-%baseVersion%

REM Use CUBYZ_BUILD_DIR if set (from debug_windows.bat), otherwise use local compiler folder
if defined CUBYZ_BUILD_DIR (
    set COMPILER_DIR=%CUBYZ_BUILD_DIR%\compiler
) else (
    set COMPILER_DIR=compiler
)

if not exist "%COMPILER_DIR%" mkdir "%COMPILER_DIR%"
if not exist "%COMPILER_DIR%\version.txt" copy NUL "%COMPILER_DIR%\version.txt" >NUL

set currVersion=
set /p currVersion<"%COMPILER_DIR%\version.txt"

if not "%version%" == "%currVersion%" (
echo Your Zig is the wrong version.
echo Deleting current Zig installation...
if exist "%COMPILER_DIR%\zig" rmdir /s /q "%COMPILER_DIR%\zig"
echo Downloading %version%...
powershell -Command $ProgressPreference = 'SilentlyContinue'; "Invoke-WebRequest -uri https://github.com/PixelGuys/Cubyz-zig-versions/releases/download/%baseVersion%/%version%.zip -OutFile %COMPILER_DIR%\archive.zip"
if errorlevel 1 (
echo Failed to download the Zig compiler.
exit /b 1
)
echo Extracting zip file...
C:\\Windows\\System32\\tar.exe -xf %COMPILER_DIR%\archive.zip --directory %COMPILER_DIR%
ren "%COMPILER_DIR%\%version%" zig
del %COMPILER_DIR%\archive.zip
echo %version%> "%COMPILER_DIR%\version.txt"
echo Done updating Zig.
) ELSE (
echo Zig compiler is valid.
)
