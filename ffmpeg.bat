@echo off
title Build FFmpeg with Full Filters - Windows Batch Script
echo ================================================
echo   BUILD FFMPEG DENGAN FILTER LENGKAP (Windows)
echo ================================================
echo.

REM Step 1: Install Chocolatey (skip if already exists)
where choco >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Installing Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "Set-ExecutionPolicy Bypass -Scope Process -Force; ^
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; ^
      iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
) ELSE (
    echo Chocolatey sudah terpasang.
)

REM Step 2: Install dependencies
echo Installing Git, Make, NASM, YASM, MSYS2...
choco install -y git make nasm yasm msys2

REM Step 3: Update MSYS2
echo Updating MSYS2...
set MSYS_ROOT=C:\tools\msys64
start /wait "" "%MSYS_ROOT%\msys2.exe" -c "exit"

REM Step 4: Install library dan compiler via MSYS2
echo Installing libraries and tools via MSYS2...
echo pacman -Syu --noconfirm > %TEMP%\msys_cmd.sh
echo pacman -S --noconfirm git yasm nasm make mingw-w64-x86_64-gcc mingw-w64-x86_64-pkg-config mingw-w64-x86_64-vmaf mingw-w64-x86_64-opencl-icd-loader mingw-w64-x86_64-freetype mingw-w64-x86_64-libass mingw-w64-x86_64-libvorbis mingw-w64-x86_64-libvpx mingw-w64-x86_64-libx264 mingw-w64-x86_64-libx265 >> %TEMP%\msys_cmd.sh
echo exit >> %TEMP%\msys_cmd.sh

start /wait "" "%MSYS_ROOT%\usr\bin\bash.exe" --login -i "%TEMP%\msys_cmd.sh"
del %TEMP%\msys_cmd.sh

REM Step 5: Clone FFmpeg
cd %USERPROFILE%
IF NOT EXIST ffmpeg (
    echo Cloning FFmpeg source...
    git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
) ELSE (
    echo FFmpeg source folder already exists. Skipping clone.
)
cd ffmpeg

REM Step 6: Configure & build FFmpeg
echo Preparing build commands...
echo cd ~/ffmpeg > %TEMP%\build_ffmpeg.sh
echo ./configure --enable-gpl --enable-version3 --enable-nonfree --enable-libx264 --enable-libx265 --enable-libvmaf --enable-libfreetype --enable-libass --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libvpx --enable-libxvid --enable-libopenjpeg --enable-libwebp --enable-libbluray --enable-shared --disable-static --enable-small --enable-filter=nlmeans --enable-filter=frei0r >> %TEMP%\build_ffmpeg.sh
echo make -j4 >> %TEMP%\build_ffmpeg.sh
echo make install >> %TEMP%\build_ffmpeg.sh
echo exit >> %TEMP%\build_ffmpeg.sh

start /wait "" "%MSYS_ROOT%\usr\bin\bash.exe" --login -i "%TEMP%\build_ffmpeg.sh"
del %TEMP%\build_ffmpeg.sh

REM Step 7: Selesai
echo.
echo ===============================
echo     BUILD FFMPEG SELESAI
echo ===============================
echo Tambahkan path ke:
echo   %MSYS_ROOT%\mingw64\bin
echo ke dalam Environment Variable (PATH).
pause
