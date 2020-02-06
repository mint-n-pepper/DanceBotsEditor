![](https://github.com/philippReist/dancebots_gui/workflows/macOS%20Build/badge.svg)
![](https://github.com/philippReist/dancebots_gui/workflows/Ubuntu%20Build/badge.svg)
# Introduction
The Dancebots Editor allows creating choreographies for Dancebots, which are small and inexpensive differential drive robots that can move and blink their eight LEDs. They are designed to be built from scratch by children, see [here](https://www.dancebots.ch/) for more information.

The editor works as follows:
1. The user can load an MP3 into the editor. The backend will decode the MP3 and extract the music beat locations from the audio.
2. Next, the user can create a choreography by configuring and placing motion and LED primitives on the music timeline. Since the primitives use the extracted beats as their time unit, it is straightforward to create good-looking choreographies.
3. When done with editing, the user saves the music and choreography to an MP3 file. In the left channel, the software re-encodes the music data (R+L channel are mixed when decoding); in the right channel, the software writes a signal that encodes the motion and LED commands for the robot to parse, see [here](https://www.dancebots.ch/?page_id=92) for more info.
4. In addition to the music and choreography signal, the software pre-pends the primitive data that makes up the choreography to the MP3 data. This allows re-loading a Dancebot MP3 file and adapting the choreography further.

# Build & Deployment Instructions
## Windows
### Build
1. Install ```cmake``` from https://cmake.org/download/. Make sure its ```bin``` folder is in the path so that you can use cmake from the command line.
2. Install Visual Studio Community 2019 from https://visualstudio.microsoft.com/.
3. Install Qt 5.12.6 LTS from https://www.qt.io/. You only have to select/install the MSVC 2015 64-bit version.
4. Install Git from https://git-scm.com/download/win. The following commands are run in the ```Git Bash```.
5. Clone the repository, best using the ```--recursive``` option to init and download all submodules, i.e. run
	```git
	git clone --recursive https://github.com/philippReist/dancebots_gui.git
	```
	or, if you use ssh,
	```git
	git clone --recursive git@github.com:philippReist/dancebots_gui.git
	```
6.  CD into the cloned repository, create a ```build``` folder, and run ```cmake``` in it:
	```bash
	cd dancebots_gui
	mkdir build
	cd build
	cmake -DCMAKE_PREFIX_PATH="C:\Qt\5.12.6\msvc2015_64" -G "Visual Studio 16 2019" ..
	```
	where you should adapt the ```CMAKE_PREFIX_PATH``` variable according to your installation. You may also have to update the generator flag (```-G```) depending on the Visual Studio version that you use. You may check what generators are available by running ```cmake -G```.

7. CMAKE now generates Visual Studio solution and project files in the build folder. You may either compile using the Visual Studio IDE, or the command line (see below). In the IDE, open the ```dancebots_gui.sln``` solution and then build the ```dancebotsEditor``` project in ```Release``` and for 64-bit, i.e. ```x64```.
8. In order to build on the command line, open the ```x64 Native Tools Command Prompt for VS 2019```, CD to ```dancebots_gui/build/gui``` and run
	```bash
	msbuild dancebotsEditor.vcxproj /p:Configuration=Release /p:Platform=x64
	```

### Deploy
1. Copy the ```.exe``` file to a deployment folder, or leave it in the ```build/gui/Release``` folder as shown below.
2. Run the Qt deployment tool on the executable, pointing it to the QML folder and adding some extra flags:
	```
	windeployqt.exe C:\\Users\\philipp\\Git\\dbgui\\dancebots_gui\\build\\gui\\Release\\dancebotsEditor.exe --qmldir C:\\Users\\philipp\\Git\\dbgui\\dancebots_gui\\gui  --no-translations --release
	```
	This adds all necessary Qt ```.dll``` and ```QML``` files to the deployment folder.
3. From the Visual Studio install folder, go to the redistributable subfolder, e.g. ```C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.23.27820\x64\Microsoft.VC142.CRT```, and copy the following x64 ```.dll``` files to the deployment folder (same folder as executable), so that the users do not have to install the redistributable package:
	```bash
		msvcp140.dll
		vcruntime140.dll
		vcruntime140_1.dll
	```

## macOS
### Prequisites
1. Install [Xcode](https://developer.apple.com/xcode/):
   ```
   xcode-select --install
   ```
   If that fails, follow the instructions [here](https://www.ics.uci.edu/~pattis/common/handouts/macmingweclipse/allexperimental/macxcodecommandlinetools.html).

2. Install [CMake](https://cmake.org/) 3.15 or above. The easiest is to use [Homebrew](https://brew.sh/):
   ```
   brew install cmake
   ```

3. Install Qt 5.12.6 LTS (macOS). The easiest is to use the [online installer](https://www.qt.io/download). Take note of the installation directory as you will need it in the Build and Deploy steps.

4. Clone the repository and update submodules:
   ```
   git submodule update --init --recursive
   ```

### Build
1. Navigate to the `dancebots_gui` directory and create a `build` directory:
   ```
   cd dancebots_gui/
   mkdir build
   ```

2. Navigate to the `build` directory, configure for release, and build the project:
   ```
   cd build/
   cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/5.12.6/clang_64/ -DCMAKE_BUILD_TYPE=Release ../
   make -j
   ```

### Deploy
To generate a macOS app and DMG file, go to the `gui/mac_os_rc` directory and run the `deploy.sh` script.

```
usage: deploy.sh <build-dir> <qt-bin-dir> <qml-dir>

Deploy app for macOS

positional arguments:

  build-dir             cmake build directory
  qt-bin-dir            QT bin directory
  qml-dir               QML directory
```

For example:
```
cd gui/mac_os_rc/
./deploy.sh ../../build/ ~/Qt/5.12.6/clang_64/bin/ ../
```

The script will create `Dancebots Editor.app` and `Dancebots Editor.dmg` in your `build` directory.


## Ubuntu
### Prerequisites
1. Install build dependencies:
   ```
   sudo apt-get install build-essential libpulse-dev libgl1-mesa-dev
   ```

2. Install [CMake](https://cmake.org/) 3.15 or above. The easiest is to use the package manager:
   ```
   sudo apt-get install cmake
   ```

3. Install the Qt 5.12.6 LTS Desktop gcc 64-bit component. The easiest is to use the [online installer](https://www.qt.io/download). Take note of the installation directory as you will need it in the Build step.

3. Clone the repository and update submodules:
   ```
   git submodule update --init --recursive
   ```

### Build
1. Navigate to the `dancebots_gui` directory and create a `build` directory:
   ```
   cd dancebots_gui/
   mkdir build
   ```

2. Navigate to the `build` directory, configure for release, and build the project:
   ```
   cd build/
   cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/5.12.6/gcc_64 -DCMAKE_BUILD_TYPE=Release ../
   make -j
   ```

The `dancebotsEditor` binary will be located in the `build/gui` directory.


# Style Guide

We are using `cpplint` for static code analysis, and therefore (roughly) follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html).

## Naming

We cannot follow the Google naming style to the letter due to naming restrictions by Qt (lower-case starting signals, upper-case enums). Therefore, we use the following naming convention

| Element 	| Example | Comment |
| ------- 	| ------- | ------- |
| Variable 	| `fileName` | camelCase |
| Member Variable | `mFileName` | m + CamelCase|
| Constant	| `fileName` | like variable |
| Enum | `WriteOnly` | CamelCase|
| Class | `FileHandler` | CamelCase|
| Files | `file_handler.[h\|cc]` | lower_case + file ending|

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
Use define guards following [Google Style](https://google.github.io/styleguide/cppguide.html#The__define_Guard) minus the project name, i.e. for the header file `audio_file.h` in folder `dancebots_gui/src` (where `dancebots_gui` is the repo root folder), use
```cpp
	#ifndef SRC_AUDIO_FILE_H_
	#define SRC_AUDIO_FILE_H_

	#endif  // SRC_AUDIO_FILE_H_
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
