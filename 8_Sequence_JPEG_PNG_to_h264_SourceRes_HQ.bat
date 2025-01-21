@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Drag-and-drop a folder or the first frame of your image sequence onto this bat-file.
    pause
    exit /b
)

set input=%~1

if exist "%input%\*" (
    for %%f in ("%input%\*.jpg" "%input%\*.jpeg" "%input%\*.png") do (
        set first_frame=%%f
        goto found_file
    )
    echo No valid JPG/PNG files found in the folder.
    pause
    exit /b
)

if exist "%input%" (
    set first_frame=%input%
) else (
    echo Input file or folder not found.
    pause
    exit /b
)

:found_file
set "input_dir=%~dp1"

if exist "%input%\*" (
    set "input_dir=%~1\"
)

for %%a in ("%first_frame%") do set "file_name_no_ext=%%~Na"

set "base_name_no_number=%file_name_no_ext:~0,-5%"
set "start_number=%file_name_no_ext:~-4%"

set "baseDir=%~dp0"
set "FFMPEG=%baseDir%ffmpeg\ffmpeg.exe"

rem Get format
for %%f in ("%first_frame%") do set "ext=%%~Xf"

:: Find first and last frames in the sequence
set "first_file="
set "last_file="
for /f "delims=" %%A in ('dir /b /on "!input_dir!\*%ext%"') do (
    if not defined first_file set "first_file=%%~nA"
    set "last_file=%%~nA"
)

:: Extract base name and frame numbers
set "first_number="
set "last_number="
for /f "tokens=2 delims=." %%A in ("!first_file!") do set "first_number=%%A"
for /f "tokens=2 delims=." %%A in ("!last_file!") do set "last_number=%%A"

cd /d %~dp0

mkdir "_OUT"
set out=_OUT\%base_name_no_number%_HQ.mp4
set output_file=%~dp0%out%

rem Debug
echo -------------------------------------
echo FFMPEG Path: "%FFMPEG%"
echo First frame: %first_number%
echo Last frame: %last_number%
echo Grabbed frame: %first_frame%
echo Directory: %input_dir%
echo Base name without number: %base_name_no_number%
echo Start number: %start_number%
echo Expected pattern: %input_dir%%base_name_no_number%.%%04d%ext%
echo current path: %cd%
echo bat path: %~dp0
echo -------------------------------------

"%FFMPEG%" ^
    -framerate 25 ^
    -start_number %first_number% ^
    -i "%input_dir%%base_name_no_number%.%%04d%ext%" ^
    -f lavfi -i anullsrc=r=48000:cl=stereo ^
    -c:a aac -b:a 128k ^
    -vf "scale=out_color_matrix=bt709:out_range=tv, colorspace=all=bt709:iall=bt709:itrc=bt709" ^
    -c:v libx264 -pix_fmt yuv420p -crf 18 -bsf:v h264_metadata=video_full_range_flag=0:colour_primaries=1:transfer_characteristics=1:matrix_coefficients=1 ^
    -preset slow -tune film ^
    -shortest ^
    "%out%"

if %errorlevel% neq 0 (
    echo Error occurred during processing.
    pause
    exit /b
)

echo Preview video created: %output_file%
echo Input Directory: %input_dir%
pause