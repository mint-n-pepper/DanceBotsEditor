# Deployment
## Windows
1. Compile in Visual Studio in Release. To avoid console from popping up upon startup add ```WIN32``` to the executable command in the Gui CMAKE code:
	```cmake
	add_executable(${PROJECT_NAME} WIN32 ${SOURCES} ${APP_RESOURCES} ${HEADERS} ${QMLS})
	```
2. Copy the exe file to a deployment folder
3. Run the Qt deployment tool on the executable, pointing it to the QML folder and adding some extra flags (--compiler-runtime does not seem to work, though, as users still have to install the executable):
	```
	windeployqt.exe C:\Users\philipp\Git\dancebots_gui\build\gui\Release\dancebotsGui.exe --release --qmldir C:\Users\philipp\Git\dancebots_gui\gui\  --compiler-runtime --no-translations
	```
	This adds all necessary dlls to the deployment folder.

## MacOS
1. Create a build folder in the cloned repo folder (typically ```dancebots_gui```).
2. Run CMAKE with the release type:
	```
	cmake .. -DCMAKE_BUILD_TYPE=Release
	```
3. Create a folder called ```dancebotsGui.app```, and within that, create a folder ```Contents```, and within that, a folder ```MacOS```.
4. Copy the executable from the ```build/gui``` folder to ```dancebotsGui.app/Contents/MacOS```
5. Run the Qt deployment tool on the app folder
	```
		~/Qt/5.13.0/clang_64/bin/macdeployqt ./dancebotsGui.app -qmldir=/Users/philipp/Git/dancebots_gui/gui -dmg
	```
	where you can add ```-dmg``` to create a dmg.

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
