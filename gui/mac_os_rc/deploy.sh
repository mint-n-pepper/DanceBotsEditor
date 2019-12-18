#!/bin/sh
# create app directory and resources directory
mkdir -p $1/DancebotsEditor.app/Contents/MacOS
mkdir -p $1/DancebotsEditor.app/Contents/Resources

# copy executable, Info.plist, and Icon file
cp -f $1/gui/dancebotsEditor $1/DancebotsEditor.app/Contents/MacOS/
cp -f ./applogo.icns $1/DancebotsEditor.app/Contents/Resources/
cp -f ./Info.plist $1/DancebotsEditor.app/Contents
