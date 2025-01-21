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
set "output=%~dp0_OUT\%~n1_1920_LQ_h264.mp4"

echo Input file: %input%
echo Output file: %output%
echo Current path: %cd%

!FFPROBE! -loglevel error -show_entries stream=codec_type -of compact=p=0:nk=1 "%input%" | findstr /i "audio" >nul
if %errorlevel% neq 0 (
    echo No audio stream detected. Adding silent audio.
    !FFMPEG! ^
        -i "%input%" ^
        -f lavfi -i anullsrc=r=48000:cl=stereo ^
        -c:a aac -b:a 128k ^
        -vf "scale=1920:-2" ^
        -c:v h264_nvenc -preset p6 -cq 36 -pix_fmt yuv420p ^
        -shortest ^
        -map 0:v:0 -map 1:a:0 ^
        "%output%"
) else (
    echo Audio stream detected.
    !FFMPEG! ^
        -i "%input%" ^
        -vf "scale=1920:-2" ^
        -c:v h264_nvenc -preset p6 -cq 36 -pix_fmt yuv420p ^
        -c:a aac -b:a 128k ^
        "%output%"
)

::p1 - fastest (minimum quality),
::p7 - highest quality (slower).
::cq - Controls video quality (the lower the value, the better the quality, but the larger the size).

if %errorlevel% neq 0 (
    echo Error occurred during processing.
    pause
    exit /b
)

echo Done.
echo Input file: %input%
echo Output file: %output%
pause