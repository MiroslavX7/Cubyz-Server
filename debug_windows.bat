@echo off

cd /D "%~dp0"

REM Use a temporary directory outside the workspace for compiler and build artifacts
set CUBYZ_BUILD_DIR=%TEMP%\Cubyz-Server-Build
if not exist "%CUBYZ_BUILD_DIR%" mkdir "%CUBYZ_BUILD_DIR%"

cd /D "%CUBYZ_BUILD_DIR%"

call "%~dp0scripts\install_compiler_windows.bat"
if errorlevel 1 (
    echo Failed to install Zig compiler.
    exit /b 1
)

echo Building Zig Cubyz (%*^) from source. This may take a few minutes...

compiler\zig\zig build --error-style minimal %*

if errorlevel 1 (
    cd /D "%~dp0"
    exit /b 1
)

echo Cubyz successfully built!
echo Launching Cubyz.

cd /D "%~dp0"
"%CUBYZ_BUILD_DIR%\zig-out\bin\Cubyz"
