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
4. Replace the icon and metainformation in the SFX module
5. Repack the game and LÖVE runtime into a 7z archive
6. Fuse the archive with the SFX module and a config that will run the game when it is unpacked

## Limitations

- The script can run on Windows and Linux, but only on x86_64
- The resulting fused binary might trigger false positives in AV software (hadn't happened yet, but please report if it does)
- The official 7z SFX module requires Administrator rights to run, so a fork running as invoker is used
- Replacing exe metainformation and icon in the SFX module on Linux relies on Wine which is a very ugly solution, should be replaced with native alternative as soon as it is found

## Licensing

This script is licensed under the MIT license, the resulting binary would include the following components:

1. 7zSFX module which is licensed under LGPL, however [an explicit permission was granted by the author](https://sourceforge.net/p/sevenzip/discussion/45797/thread/88757edf/) to not provide any license document about the 7-zip or the LGPL itself alongside a modified version of 7zSFX.
2. LÖVE runtime which is licensed under zlib, and its components are using various licenses, information about them is included in `license.txt` under the LÖVE runtime directory inside the archive.
3. Your game which you are free to license under any license of your choice, and any assets and libraries you are using in your game licensed under their respective licenses. You should probably also include a license file with your game.

The files inside the archive can easily be extracted, viewed, modified or replaced using 7z (or any GUI archiver software that supports 7z). This might not be obvious to the end user, because of the .exe extension, but the software that is used for working with archives can also open such files (alternatively, the extension can be changed to .7z manually). Please, keep the users [informed of their rights](https://opensource.stackexchange.com/questions/7771/is-it-legal-to-create-an-auto-extractible-sfx-archive-containing-mixed-commercia) and the nature of the self-extracting archive!
