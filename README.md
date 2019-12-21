# Deployment / Building
## Windows
### Build
1. Install ```cmake``` from https://cmake.org/download/.
2. Install Visual Studio from https://visualstudio.microsoft.com/.
3. Install Qt 5.12.6 LTS from https://www.qt.io/. You only have to select/install the MSVC 2015 64-bit version.
4. Create the environment variable ```CMAKE_PREFIX_PATH``` and set it to the directory where the Qt MSVC 2015 64-bit version is, e.g. ```C:\Qt\5.12.6\msvc2015_64```.
5. Clone the repository, best using the ```--recursive``` option to init and download all submodules.
6. Create build folder and run ```cmake``` in it, pointing to repo root, where root ```CMakeLists.txt``` is.
7. Compile in Visual Studio in Release. To avoid console from popping up upon startup add ```WIN32``` to the executable command in the Gui CMAKE code:
	```cmake
	add_executable(${PROJECT_NAME} WIN32 ${SOURCES} ${APP_RESOURCES} ${HEADERS} ${QMLS})
	```
### Deploy
1. Copy the exe file to a deployment folder
2. Run the Qt deployment tool on the executable, pointing it to the QML folder and adding some extra flags (--compiler-runtime does not seem to work, though, as users still have to install the executable):
	```
	windeployqt.exe C:\Users\philipp\Git\dancebots_gui\build\gui\Release\dancebotsGui.exe --release --qmldir C:\Users\philipp\Git\dancebots_gui\gui\  --compiler-runtime --no-translations
	```
	This adds all necessary dlls to the deployment folder.

## MacOS
### Build
1. Install ```cmake```, probably easiest using homebrew.
2. Install XCode https://developer.apple.com/xcode/
3. Install Qt 5.12.6 LTS from https://www.qt.io/. You only have to select/install the MacOS version.
4. Create the environment variable ```CMAKE_PREFIX_PATH``` and set it to the path to the Qt clang_64 folder of the 5.12.6 installation, e.g. do ```EXPORT CMAKE_PREFIX_PATH=/Users/philipp/Qt/5.12.6/clang_64/```, or add this command to the ```.bash_profile``` in your home folder.
5. Clone the repo, best using the ```--recursive``` option to init and download all submodules.
6. Create a build folder in the cloned repo folder (e.g. ```dancebots_gui/build```).
7. In the build folder, run CMAKE with the release type:
	```
	cmake .. -DCMAKE_BUILD_TYPE=Release
	```
	where the .. will point to the repository root folder.
8. Build the gui by running ```make dancebotsEditor``` in the build folder.
### Deploy
1. Go to the subfolder ```gui/mac_os_rc```, and run the script ```deploy.sh ../../build```, where the first command line argument is the path to your build folder. The script then creates the folder ```DancebotsEditor.app``` in your build folder and copies the executable, icon, and run settings files to the appropriate subfolders.
2. Run the Qt deployment tool on the app folder to copy the appropriate frameworks to the app:
	```
		~/Qt/5.12.6/clang_64/bin/macdeployqt ./dancebotsEditor.app -qmldir=/Users/philipp/Git/dancebots_gui/gui -dmg
	```
	where the ```-dmg``` option creates an app dmg file. You should replace the Qt install folder and gui folders with the appropriate locations.

## Debian/Ubuntu
1. Install 5.12.6 LTS from [online installer](https://www.qt.io/download), selecting gcc 64 bit version.
2. Install `cmake`:
   ```
   sudo apt-get install cmake
   ```
3. Install build dependencies:
	```
	sudo apt-get install libgl1-mesa-dev build-essential
	```
4. In the `build` directory, configure for release:
   ```
   cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/<VERSION>/gcc_64 -DCMAKE_BUILD_TYPE=Release ../
   ```
5. In the `build` directory, build the project:
   ```
   make dancebotsEditor
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

You can find more hardware information in the [electronics and firmware repository](https://github.com/philippReist/dancebots_electronics), and more general info on the [Dancebots website](http://www.dancebots.ch/).

The workshop's continued existence is due to the educational outreach program [mint & pepper](https://www.mintpepper.ch/) at the [Wyss Zurich](https://www.wysszurich.uzh.ch/).

The Dancebots GUI was developed by Philipp Reist, Robin Hanhart, and Raymond Oung.

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
