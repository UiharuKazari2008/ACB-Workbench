# ACB-Workbench
Easy workspace to replace audio files in games that use ACB/AWB/HCA/ADX (Chunithm)


## Setup Workspace
0. Download and Extract the **Pinned Message** with the latest ZIP
1. Extract the `chu.acb` and `chu.awb` from `/data/sound/` and place them in `/acb/in`
  * Open `extract.ps1` and `generate.ps1` in Notepad and fill in the "HCA Key" for Chunithm for `key0` and `key1` if your not using JP
  * Each should be 8 HEX long refer to the referance in the comments
2. Right-Click `extract.ps1` and click **Run with PowerShell**
3. Wait for the ACB to extract

## Finding the system music files
* Files are extracted to `/extracted` as WAV and can be opened in VLC
* You will want to the `Length` column to the folder view
  * Right Click the Column bar and select Length
  * Click the Length Column  to sort by Length

Most system music like entry, results, and total results will be at the bottom as they are the longest audio files, Items like the SEGA and game title callout are going to be at the top.<br/>
Most of the files will be online battle city names and such and are not relevant at this time.

## Tips for new audio files
* Shoot for 0dB at all times, if your under that it wont flow with the rest of the system audio
* Output files should be 4800/16Bit/Stereo (Sega call out is Mono) WAV Uncompressed

# Compile new ACB
0. Place all replacement file in the `/replacements` folder 
  * **The same name as they are in the extracted folder**
1. Right-Click `generate.ps1` and click **Run with PowerShell**
2. The generated ACB will be placed in the root of the workspace, replace the ones  in `/data/sound`
  * The original files are always left untouched in the `/acb/in` folder

* When you want to clean out everything to work on another version run the cleanup.ps1 script, replacement files will not be removed

Note: ADX convertion is not in used as its not working correctly
