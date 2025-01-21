@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Drag-and-drop a video file onto this script to convert it to H.264.
    pause
    exit /b
)

set input=%~1


:: Set the absolute path to toolz
set "baseDir=%~dp0"
set "FFPROBE=%baseDir%ffmpeg\ffprobe.exe"
set "FFMPEG=%baseDir%ffmpeg\ffmpeg.exe"
rem set "LUT=%baseDir%ffmpeg\sRGB_for_ACEScg.csp"

:: Debug
echo Looking for ffprobe at: "!FFPROBE!"
echo Looking for ffmpeg at: "!FFMPEG!"

cd /d %~dp0

mkdir "_OUT"
set "output=%~dp0_OUT\%~n1_960p_GIF_12.5fps.gif"

echo Input file: %input%
echo Output file: %output%
echo Current path: %cd%

!FFMPEG! ^
    -i "%input%" ^
    -vf "fps=12.5, scale=960:-2:flags=lanczos, split[s0][s1];[s0]palettegen=max_colors=128[p];[s1][p]paletteuse=dither=bayer" ^
    -loop 0 ^
    "%output%"

if %errorlevel% neq 0 (
    echo Error occurred during processing.
    pause
    exit /b
)

echo Done.
echo Input file: %input%
echo Output file: %output%
pause



::bayer    Ordered 8x8 bayer dithering (deterministic) 
::heckbert     Dithering as defined by Paul Heckbert in 1982 (simple error diffusion). Note: this dithering is sometimes considered "wrong" and is included as a reference. 
::floyd_steinberg     Floyd and Steingberg dithering (error diffusion) 
::sierra2     Frankie Sierra dithering v2 (error diffusion) 
::sierra2_4a     Frankie Sierra dithering v2 "Lite" (error diffusion) 
::sierra3     Frankie Sierra dithering v3 (error diffusion) 
::burkes     Burkes dithering (error diffusion) 
::atkinson     Atkinson dithering by Bill Atkinson at Apple Computer (error diffusion) 
::none