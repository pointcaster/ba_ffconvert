## Overview
This folder contains batch files for converting sequences and videos to H.264. All scripts work in drag-and-drop mode for convenience.

### Supported Input
- You can drag and drop any frame from a sequence or an entire folder containing a sequence.
- The script will automatically detect and convert the entire sequence.

---

### EXR Files
Wherever a script mentions EXR, it specifically refers to ACEScg files in an EXR container that adhere to the following naming convention:

`filename.####.exr`

For example:
`sh_070_main_v022_rgb.1002.exr`

- `####` represents the frame number.
- The frame number must:
  - Contain exactly four digits.
  - Appear directly before the file extension, following a dot separator.
- Only `.exr` extensions are supported.

- You can modify scripts to fit your own naming conventions.

---

### Recommendations for EXR
- Scripts 6 and 7 are optimized for handling EXR files. These options are the fastest as they process EXR files directly and convert sequences to video.

#### Known Issue with Multilayer EXRs
- If you’re using multilayer EXRs with DWAA/DWAB compression, you may encounter the `decode_block() failed` error in ffmpeg.
- This is caused by issues with the OpenEXR library in ffmpeg.
- To address this, script 1 uses `oiiotool` for a guaranteed conversion. This method involves double conversion, making it slower but reliable.
- Note: Script 1 only has a high-quality (HQ) version. For a low-quality (LQ) output, you can duplicate the script and apply LQ parameters from scripts 6 or 7.

---

### Additional Formats
- Script 8 handles image sequences in formats like JPEG, JPG, and PNG (you can extend it to support other formats).
- These scripts operate on the same principles as the EXR workflows.

---

### GIF Conversion
- Bonus scripts allow you to convert videos or EXR sequences directly to GIFs:
  - Hardcoded settings: 12.5 FPS and 960px horizontal width.
  - For EXR sequences, transparency is preserved if present.
  - Note: FPS may behave differently when converting sequences.

---

### Video Conversion
- Bonus scripts are included for converting any video to H.264.
- Two versions are provided:
  - **NVIDIA GPU**: Faster but slightly lower quality.
  - **CPU**: Slower but offers highest quality.
- Example performance:
  - NVIDIA RTX 3090 is approximately 3x faster than AMD 5950X for GPU encoding.

---

### Output Options
- Scripts are available for:
  - Source resolution.
  - Compressed resolution (1920px horizontal width, maintaining aspect ratio).
- All converted files will be saved in an `_OUT` folder created automatically next to the `ffmpeg` and `oiio` folders.

---

### Script Details
#### 1_OIIO_Sequence_EXR_to_h264
- **1920_HQ**: Extracts the primary RGB channel from source EXRs using `oiiotool`, compresses them as ZIP, and converts to H.264 using ffmpeg. Outputs at 1920px horizontal resolution (aspect ratio preserved).
- **SourceRes_HQ**: Same as above but retains the source resolution.

#### 2_Video_to_h264
- **1920_HQ**: Converts any video to H.264 with a 1920px horizontal resolution. Tuned for high quality.
- **1920_HQ_GPU**: GPU-accelerated version of the above.

#### 3_Video_to_h264
- **1920_LQ**: Converts any video to H.264 with a 1920px horizontal resolution. Tuned for low but reasonable quality.
- **1920_LQ_GPU**: GPU-accelerated version of the above.

#### 4_Video_to_GIF_960_128c_12.5fps
- Converts any video to GIF at 960px horizontal resolution with 12.5 FPS. Uses a 128-color palette. You can make it 256, but the file size will be enormous.

#### 5_Sequence_to_GIF_960_128c_12.5fps
- Converts sequences to GIFs at 960px horizontal resolution and 12.5 FPS. Uses a 128-color palette. Transparency is preserved if present.

#### 6_Sequence_EXR_to_h264
- **1920_HQ**: Converts EXR sequences to H.264 at 1920px horizontal resolution. FPS is set to 25. Tuned for high quality.
- **1920_LQ**: Same as above but tuned for lower quality.

#### 7_Sequence_EXR_to_h264
- **SourceRes_HQ**: Converts EXR sequences to H.264 at source resolution. FPS is set to 25. Tuned for high quality.
- **SourceRes_LQ**: Same as above but tuned for lower quality.

#### 8_Sequence_JPEG_PNG_to_h264
- **1920_HQ**: Converts JPEG/PNG sequences to H.264 at 1920px horizontal resolution. Tuned for high quality.
- **SourceRes_HQ**: Same as above but retains the source resolution.

---

### Customization
- If you need additional encoding variations, feel free to modify the scripts to meet your specific requirements.

---

### Notes
- All scripts are designed in a way that the resulting video will have either the original audio or an empty audio track, but never a missing one. This is intended to prevent messengers like Telegram from recognizing the video as a gif.

---

Enjoy.

// Andrey Babaev // 2025.