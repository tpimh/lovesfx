# LÖVESFX

The problem that this script is solving is the lack of a way to distribute your LÖVE game as a single executable on Windows.

Linux has AppImage, macOS has a zipped .app directory. On Windows, you can create a fused executable by concatenating your game as a ZIP archive to the LÖVE executable, but then you need to bring along a bunch of DLLs. You can do that on other platforms, too.

A simple .love file is nice, it will run on any platform. But the user needs to have LÖVE runtime installed, which can't be taken for granted outside of the LÖVE community.

## SFX to the rescue

SFX in this case stands for Self-Extracting Archive, not Sound Effects. This script creates an archive of both your game and LÖVE runtime and fuses it together with the unarchiver which would unpack the archive into a temporary directory, launch your game, then clean up after the game is closed.

I tried to put everything together with ready-to-use binary building blocks and avoid compilation. This is only a proof of concept, but it can be easily adapted to use different tools. Currently, it's using 7-Zip SFX module and a shell script (you can run it if you have e.g. Git for Windows installed).

## What this script does

1. Download 7z, LÖVE runtine, a sample game and 7z SFX module
2. Unpack the downloaded components
3. Generate a Windows-compatible icon
4. Repack the game and LÖVE runtime into a 7z archive
5. Fuse the archive with the SFX module and a config that will run the game when it is unpacked

## Limitations

- The script can run on Windows and Linux, but only on x86_64
- The resulting fused binary might trigger false positives in AV software (hadn't happened yet, but please report if it does)
- The official 7z SFX module requires Administrator rights to run, so a fork running as invoker is used
- The resulting exe metainformation and icon is kept from the SFX module
