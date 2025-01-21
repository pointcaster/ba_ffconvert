@echo off
setlocal enabledelayedexpansion

:: Check if a folder or file is provided
if "%~1"=="" (
    echo Please drag and drop a folder or EXR file onto this script!
    pause
    exit /b
)

:: Set the absolute path to oiitool and ffmpeg
set "baseDir=%~dp0"
set "OIIOTOOL=%baseDir%oiio\oiiotool.exe"
set "FFMPEG=%baseDir%ffmpeg\ffmpeg.exe"

:: Output the path where the script is looking for oiitool
echo Looking for oiitool at: "!OIIOTOOL!"
echo Looking for ffmpeg at: "!FFMPEG!"

:: Check if oiitool and ffmpeg exist in the specified location
if not exist "!OIIOTOOL!" (
    echo oiitool utility not found in the oiio folder!
    pause
    exit /b
)

if not exist "!FFMPEG!" (
    echo ffmpeg not found in the folder!
    pause
    exit /b
)

:: Set the color config file path
set "colorConfig=%baseDir%oiio\aces1.2\config.ocio"

:: Determine the input folder (if a file is provided, get the folder)
set "input_folder=%~1"
if not exist "!input_folder!" (
    echo The specified folder or file does not exist: "!input_folder!"
    pause
    exit /b
)

:: If it's a file, get the folder
if not exist "!input_folder!\*" (
    set "input_folder=%~dp1"
)

:: Find first and last frames in the sequence
set "first_file="
set "last_file="
for /f "delims=" %%A in ('dir /b /on "!input_folder!\*.exr"') do (
    if not defined first_file set "first_file=%%~nA"
    set "last_file=%%~nA"
)

:: Validate that files were found
if not defined first_file (
    echo No EXR files found in the specified folder: "!input_folder!"
    pause
    exit /b
)

:: Extract base name and frame numbers
set "base_name="
set "first_number="
set "last_number="
for /f "tokens=1* delims=." %%A in ("!first_file!") do set "base_name=%%A"
for /f "tokens=2 delims=." %%A in ("!first_file!") do set "first_number=%%A"
for /f "tokens=2 delims=." %%A in ("!last_file!") do set "last_number=%%A"

:: Create output folder
set "output_folder=!baseDir!!base_name!"
mkdir "!output_folder!" >nul 2>&1

:: Debug info
echo Base name: "!base_name!"
echo First frame: "!first_number!"
echo Last frame: "!last_number!"

:: Process the sequence with oiiotool
echo Processing sequence from !first_number! to !last_number!. Please wait...
echo Temporary directory will be deleted after the task is completed.

:: Start oiiotool and run it in the background
start "" /B "!OIIOTOOL!" --frames !first_number!-!last_number! "!input_folder!\!base_name!.#.exr" --ch R,G,B --flatten --compression zip -o "!output_folder!\!base_name!.#.exr"

:: Show "Converting..." every 2 seconds while oiiotool is running
:loop
echo Converting...
timeout /t 2 >nul
tasklist /fi "imagename eq oiiotool.exe" | findstr /i "oiiotool.exe" >nul
if %errorlevel% neq 0 (
    echo Conversion completed. Files saved in: "!output_folder!"
    goto :convert_mp4
)
goto loop

:convert_mp4
:: Get the first frame in the output folder to extract the parameters
set "first_frame="
for %%f in ("!output_folder!\*.exr") do (
    set "first_frame=%%f"
    goto :found_frame
)

:found_frame
:: Extract the base name without the number and the start number
for %%a in ("!first_frame!") do set "file_name_no_ext=%%~Na"
set "base_name_no_number=%file_name_no_ext:~0,-5%"
set "start_number=%file_name_no_ext:~-4%"

:: Define the output file path
set "baseDir=%~dp0"
set "FFMPEG=%baseDir%ffmpeg\ffmpeg.exe"
set "LUT=%baseDir%ffmpeg/sRGB_for_ACEScg.csp"

rem convert path
set "LUT=!LUT:\=/!"
set "LUT=!LUT::=\:/!"

cd /d %~dp0
mkdir "_OUT"
set "out=_OUT\!base_name_no_number!_1920_HQ.mp4"
set "output_file=%baseDir%!out!

:: Create the MP4 file using ffmpeg
echo Converting sequence to MP4...
set "input_dir=!baseDir!!base_name!\"
set "ext=.exr"

rem Debug
echo -------------------------------------
echo FFMPEG Path: "%FFMPEG%"
echo Transformed LUT Path: "!LUT!"
echo First frame: %first_frame%
echo Directory: %input_dir%
echo Base name without number: %base_name_no_number%
echo Start number: %start_number%
echo Expected pattern: %input_dir%%base_name_no_number%.%%04d.exr
echo current path: %cd%
echo bat path: %~dp0
echo -------------------------------------

!FFMPEG! ^
    -framerate 25 ^
    -start_number !start_number! ^
    -i "!input_dir!!base_name_no_number!.%%04d!ext!" ^
    -f lavfi -i anullsrc=r=48000:cl=stereo ^
    -c:a aac -b:a 128k ^
    -vf "scale=out_color_matrix=bt709:out_range=tv, lut3d=file='!LUT!', colorspace=all=bt709:iall=bt709:itrc=bt709, scale=1920:-2" ^
    -c:v libx264 -pix_fmt yuv420p -crf 18 -bsf:v h264_metadata=video_full_range_flag=0:colour_primaries=1:transfer_characteristics=1:matrix_coefficients=1 ^
    -preset slow -tune film ^
    -shortest ^
    "!output_file!"

:: Delete the !base_name! folder after conversion
echo Deleting !base_name! folder...
rd /s /q "!baseDir!!base_name!"

echo Preview video created: !output_file!
echo Input Directory: %input_dir%
echo Applied LUT File: !LUT!
echo Done!
pause

rem setsar=sar=1