@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Drag-and-drop a folder or the first frame of your EXR sequence onto this bat-file.
    pause
    exit /b
)

set input=%~1

if exist "%input%\*" (
    for %%f in ("%input%\*.exr") do (
        set first_frame=%%f
        goto found_file
    )
    echo No EXR files found in the folder.
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
set "LUT=%baseDir%ffmpeg/sRGB_for_ACEScg.csp"

rem convert path
set "LUT=!LUT:\=/!"
set "LUT=!LUT::=\:/!"

:: Find first and last frames in the sequence
set "first_file="
set "last_file="
for /f "delims=" %%A in ('dir /b /on "!input_dir!\*.exr"') do (
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
set out=_OUT\%base_name_no_number%_960_GIF_12.5fps.gif
set output_file=%~dp0%out%

rem Debug
echo -------------------------------------
echo FFMPEG Path: "%FFMPEG%"
echo Transformed LUT Path: "!LUT!"
echo First frame: %first_number%
echo Last frame: %last_number%
echo Grabbed frame: %first_frame%
echo Directory: %input_dir%
echo Base name without number: %base_name_no_number%
echo Start number: %start_number%
echo Expected pattern: %input_dir%%base_name_no_number%.%%04d.exr
echo current path: %cd%
echo bat path: %~dp0
echo -------------------------------------

"%FFMPEG%" ^
    -start_number %first_number% ^
    -i "%input_dir%%base_name_no_number%.%%04d.exr" ^
    -vf "fps=12.5,scale=out_color_matrix=bt709:out_range=tv,lut3d=file='!LUT!', colorspace=all=bt709:iall=bt709:itrc=bt709, scale=960:-2:flags=lanczos,split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" ^
    -loop 0 ^
    "%out%"

if %errorlevel% neq 0 (
    echo Error occurred during processing.
    pause
    exit /b
)

echo Preview GIF created: %output_file%
echo Input Directory: %input_dir%
echo Applied LUT File: !LUT!
pause