# Deployment / Building
## Windows
1. Install ```cmake``` from https://cmake.org/download/.
2. Install Visual Studio from https://visualstudio.microsoft.com/.
3. Install Qt 5.13 from https://www.qt.io/. You only have to select/install the MSVC 2017 64-bit version.
4. Create the environment variable ```CMAKE_PREFIX_PATH``` and set it to the directory where the Qt MSVC 2017 64-bit version is, e.g. ```C:\Qt\5.13.2\msvc2017_64```.
5. Clone the repository, best using the ```--recursive``` option to init and download all submodules.
6. Create build folder and run cmake in it, pointing to repo root, where root ```CMakeLists.txt``` is.
7. Compile in Visual Studio in Release. To avoid console from popping up upon startup add ```WIN32``` to the executable command in the Gui CMAKE code:
	```cmake
	add_executable(${PROJECT_NAME} WIN32 ${SOURCES} ${APP_RESOURCES} ${HEADERS} ${QMLS})
	```
8. Copy the exe file to a deployment folder
9. Run the Qt deployment tool on the executable, pointing it to the QML folder and adding some extra flags (--compiler-runtime does not seem to work, though, as users still have to install the executable):
	```
	windeployqt.exe C:\Users\philipp\Git\dancebots_gui\build\gui\Release\dancebotsGui.exe --release --qmldir C:\Users\philipp\Git\dancebots_gui\gui\  --compiler-runtime --no-translations
	```
	This adds all necessary dlls to the deployment folder.

## MacOS
1. Install ```cmake```, probably easiest using homebrew.
2. Install XCode https://developer.apple.com/xcode/
3. Install Qt 5.13 from https://www.qt.io/. You only have to select/install the MacOS version.
4. Create the environment variable ```CMAKE_PREFIX_PATH``` and set it to the path to the Qt clang_64 folder of the 5.13 installation, e.g. do ```EXPORT CMAKE_PREFIX_PATH=/Users/philipp/Qt/5.13.2/clang_64/```, or add this command to the ```.bash_profile``` in your home folder.
5. Clone the repo, best using the ```--recursive``` option to init and download all submodules.
6. Create a build folder in the cloned repo folder (typically ```dancebots_gui```).
7. Run CMAKE with the release type:
	```
	cmake .. -DCMAKE_BUILD_TYPE=Release
	```
8. Create a folder called ```dancebotsGui.app```, and within that, create a folder ```Contents```, and within that, a folder ```MacOS```.
9. Copy the executable from the ```build/gui``` folder to ```dancebotsGui.app/Contents/MacOS```
10. Run the Qt deployment tool on the app folder
	```
		~/Qt/5.13.0/clang_64/bin/macdeployqt ./dancebotsGui.app -qmldir=/Users/philipp/Git/dancebots_gui/gui -dmg
	```
	where you can add ```-dmg``` to create a dmg.

## Ubuntu / Linux
1. Install Qt 5.13 from online installer, selecting gcc 64 bit Version
2. Install cmake
3. Install build dependencies:
	```
	sudo apt-get install libgl1-mesa-dev build-essential
	```
4. Create environment variable pointing to Qt:
	```
	export CMAKE_PREFIX_PATH=/home/philipp/Qt/5.13.2/gcc_64
	```
5. Run cmake in a build folder, configure for release build:
	```
	cmake .. -DCMAKE_BUILD_TYPE=Release
	```

# Style Guide

## Naming

| Element 	| Example | Comment |
| ------- 	| ------- | ------- |
| Variable 	| `fileName` | camelCase |
| Member Variable | `mFileName` | m + CamelCase|
| Constant	| `fileName` | like variable | 
| Enum | `eWriteOnly` | e + CamelCase|
| Class | `FileHandler` | CamelCase|
| Files | `FileHandler.h` | CamelCase + file ending|

## Indentation / Tabs
are two spaces.

## Function Doc

Use following template:
```cpp
	/**
	\brief  Calculate convolution of two signals.
			
			Some more detailed description or an example goes here.
	\param[in] Signal A
	\param[in] Signal B
	\param[out] Convolution A * B
	\return Whether the operation was successful (0) or not (1).
	*/
```

## Header Guards
Use the standard define guards, e.g.
```cpp
	#ifndef AUDIO_FILE_H_
	#define AUDIO_FILE_H_

	#endif // AUDIO_FILE_H_
```
# License and Credits
The GUI source code is distributed under the terms of the [GNU General Public License 3.0](https://spdx.org/licenses/GPL-3.0.html). See the LICENSE file for more information.

The Dancebots hard- and software was originally developed by Raymond Oung and Philipp Reist during their PhD at the [Institute for Dynamic Systems and Control](https://idsc.ethz.ch/) for use in the [Sportferienlager Fiesch of the City of Zürich](https://zuerifiesch.ch/).

You can find more hardware information in the [electronics and firmware repository](https://github.com/philippReist/dancebots_pcb), and more general info on the [Dancebots website](http://www.dancebots.ch/).

The workshop's continued existence is due to the educational outreach program [mint & pepper](https://www.mintpepper.ch/) at the [Wyss Zurich](https://www.wysszurich.uzh.ch/).

The Dancebots GUI was developed by Philipp Reist (main author), Robin Hanhart, and Raymond Oung.

## Third-party libraries
We are grateful to the developers of the following open-source libraries. For the libraries' licenses refer to the file LICENSE_3RD_PARTY, or the submodule repositories in the lib folder and the [Qt open-source licensing info](https://www.qt.io/licensing/).

Refer to the links below or [contact us](mailto:philipp.reist@gmail.com) if you wish to obtain any of the libraries' source code.

### Table of third-party libraries and licenses
| Library | Authors |  License |
| ------- | ------- |  ------- |
| [Qt Toolkit](https://www.qt.io/) | The Qt Company Ltd. and other contributors | [GNU LGPL 3.0](https://doc.qt.io/qt-5/lgpl.html) |
| [QM Vamp Plugins](https://github.com/c4dm/qm-vamp-plugins) | Queen Mary, University of London | [GNU LGPL 2.0](https://spdx.org/licenses/LGPL-2.0-or-later.html) |
| [TagLib](https://github.com/taglib/taglib) | Scott Wheeler et al. | [GNU LGPL 2.1](https://spdx.org/licenses/LGPL-2.1-or-later.html) and [MPL 1.1](https://spdx.org/licenses/MPL-1.1.html)|
| [libsndfile](https://github.com/erikd/libsndfile) | Erik de Castro Lopo et al. | [GNU LGPL 2.1](https://www.gnu.org/licenses/lgpl-2.1.html) |
| [kissfft](https://github.com/mborgerding/kissfft) | Mark Borgerding | [BSD 3-Clause](https://spdx.org/licenses/BSD-3-Clause.html)|
| [LAME](https://lame.sourceforge.io/) | [List of Developers](https://lame.sourceforge.io/developers.php) | [GNU LGPL 2.0](https://spdx.org/licenses/LGPL-2.0-or-later.html) |
| [Google Test](https://github.com/google/googletest) | Google Inc. | [BSD 3-Clause](https://spdx.org/licenses/BSD-3-Clause.html)|
