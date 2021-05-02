![Windows Build](https://github.com/philippReist/DanceBotsEditor/workflows/Windows%20Build/badge.svg)
![macOS Build](https://github.com/philippReist/DanceBotsEditor/workflows/macOS%20Build/badge.svg)
![Ubuntu Build](https://github.com/philippReist/DanceBotsEditor/workflows/Ubuntu%20Build/badge.svg)

# Introduction
The Dancebots Editor allows creating choreographies for Dancebots, which are small and inexpensive differential drive robots that can move and blink their eight LEDs. They are designed to be built from scratch by children, see [here](https://www.dancebots.ch/) for more information.

The editor works as follows:
1. The user can load an MP3 into the editor. The backend will decode the MP3 and extract the music beat locations from the audio.
2. Next, the user can create a choreography by configuring and placing motion and LED primitives on the music timeline. Since the primitives use the extracted beats as their time unit, it is straightforward to create beat-synchronized choreographies.
3. When done with editing, the user saves the music and choreography to an MP3 file. In the left channel, the software re-encodes the music data (R+L channel are mixed when decoding); in the right channel, the software writes a signal that encodes the motion and LED commands for the robot to parse, see [here](https://www.dancebots.ch/?page_id=92) for more info.
4. In addition to the music and choreography signal, the software pre-pends the primitive data that makes up the choreography to the MP3 data. This allows re-loading a Dancebot MP3 file and adapting the choreography further.

# Build & Deployment Instructions
## Windows
### Prequisites
1. Install [CMake](https://cmake.org/) 3.15 or above.
   * Add `cmake`'s `bin` folder to the `PATH` environment variable

2. Install [Visual Studio Community](https://visualstudio.microsoft.com/)
   * Install `Desktop development with C++` workload, see [here for instructions](https://devblogs.microsoft.com/cppblog/windows-desktop-development-with-c-in-visual-studio/)

3. Install [Qt](https://www.qt.io/) 5.12.9 LTS. The easiest is to use the [online installer](https://www.qt.io/download). Take note of the installation directory as you will need it later on.
   * You will only need the `MSVC 2017 64-bit` version

4. Install [Git](https://git-scm.com/download/win). The commands in the following steps are run in the `Git Bash`.

5. Clone the repository and update submodules:
   ```
   git submodule update --init --recursive
   ```

### Build
1. Navigate to the `DanceBotsEditor` directory and create a `build` directory:
   ```
   cd DanceBotsEditor\
   mkdir build
   ```

2. Navigate to the `build` directory, configure for release:
   ```
   cd build\
   cmake -DCMAKE_PREFIX_PATH=C:\path\to\Qt\5.12.9\msvc2017_64\ -DCMAKE_BUILD_TYPE=Release -G "Visual Studio 16 2019" ..
   ```
   You may need to update the generator flag (-G) depending on the Visual Studio version that you are using. To check what generators are available, run `cmake -G`.

3. The `build` folder should now contain a Visual Studio solution (.sln) and project files. You can build the project using the Visual Studio IDE or command line.

   a. Using the Visual Studio IDE, open the `dancebotsEditor.sln` file and build the `dancebotsEditor` project in `Release` and 64-bit (x64).

   b. To build on the command line using `x64 Native Tools Command Prompt for VS 2019` (or whatever Visual Studio version you are using), navigate to `DanceBotsEditor\build\gui\` and run:
   ```
   msbuild dancebotsEditor.vcxproj /p:Configuration=Release /p:Platform=x64 /m
   ```

   c. To build on the command line using `PowerShell`, run:
   ```
   C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe .\dancebots_gui.sln /p:Configuration=Release /p:Platform=x64 /m
   ```
   You may need to edit the path depending on the Visual Studio version that you are using.


### Deploy
1. Navigate to the deployment folder:
   ```
   cd DanceBotsEditor\build\gui\Release\
   ```

2. Run the Qt deployment tool on the executable, pointing it to the QML folder, and adding some flags:
   ```
   C:\path\to\Qt\5.12.9\msvc2017_64\bin\windeployqt.exe .\dancebotsEditor.exe --qmldir ..\..\..\gui  --no-translations --release
   ```
   This adds all necessary Qt `.dll` and `QML` files to the deployment folder.

3. Copy the following x64 `.dll` files from the Visual Studio redistributable subfolder to the deployment folder so that the users do not need to install the redistributable package:
   ```
   cp 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.24.28127\x64\Microsoft.VC142.CRT\msvcp140.dll' .
   cp 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.24.28127\x64\Microsoft.VC142.CRT\vcruntime140.dll' .
   cp 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Redist\MSVC\14.24.28127\x64\Microsoft.VC142.CRT\vcruntime140_1.dll' .
   ```

4. Your deployment folder can now be shared with other users.


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

3. Install [Qt](https://www.qt.io/) 5.12.9 LTS. The easiest is to use the [online installer](https://www.qt.io/download). Take note of the installation directory as you will need it later on.

4. Clone the repository and update submodules:
   ```
   git submodule update --init --recursive
   ```

### Build
1. Navigate to the `DanceBotsEditor` directory and create a `build` directory:
   ```
   cd DanceBotsEditor/
   mkdir build
   ```

2. Navigate to the `build` directory, configure for release, and build the project:
   ```
   cd build/
   cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/5.12.9/clang_64/ -DCMAKE_BUILD_TYPE=Release ../
   make -j2
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
./deploy.sh ../../build/ ~/Qt/5.12.9/clang_64/bin/ ../
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

3. Install the Qt 5.12.9 LTS Desktop gcc 64-bit component. The easiest is to use the [online installer](https://www.qt.io/download). Take note of the installation directory as you will need it in the Build step.

4. Clone the repository and update submodules:
   ```
   git submodule update --init --recursive
   ```

### Build
1. Navigate to the `DanceBotsEditor` directory and create a `build` directory:
   ```
   cd DanceBotsEditor/
   mkdir build
   ```

2. Navigate to the `build` directory, configure for release, and build the project:
   ```
   cd build/
   cmake -DCMAKE_PREFIX_PATH=/path/to/Qt/5.12.9/gcc_64 -DCMAKE_BUILD_TYPE=Release ../
   make -j2
   ```

The `dancebotsEditor` binary will be located in the `build/gui` directory.


# Swap Channels
By default, the left-channel plays audio and the right-channels plays data. However, in some cases it may be necessary to swap audio and data channels, e.g. [#62](https://github.com/philippReist/DanceBotsEditor/issues/62#issue-736202876). To do this, create a `config.ini` file alongside the executable. In the `.ini` file, write:
```
[audio]
swapChannels=True
```

If there is no `config.ini` file, the default channel order will be used.


# Style Guide

We are using `cpplint` for static code analysis, and therefore (roughly) follow the [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html).

## Naming

We cannot follow the Google naming style to the letter due to naming restrictions by Qt (lower-case starting signals, upper-case enums). Therefore, we use the following naming convention

| Element   | Example | Comment |
| -------   | ------- | ------- |
| Variable  | `fileName` | camelCase |
| Member Variable | `mFileName` | m + CamelCase|
| Constant  | `fileName` | like variable |
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
Use define guards following [Google Style](https://google.github.io/styleguide/cppguide.html#The__define_Guard) minus the project name, i.e. for the header file `audio_file.h` in folder `DanceBotsEditor/src`, use
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
