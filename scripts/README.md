# Scripts

This folder contains scripts to be used for git-prehooks on \*nix systems.

## Prerequisites
### Python3, PIP, and Virtual Environments
* Instructions for setting up Python's PIP and virtual environments can be found [here](https://gist.github.com/Geoyi/d9fab4f609e9f75941946be45000632b)


### Clang Formatter
`clang-format` will be used to auto-format code and maintain code style consistency.
```
sudo apt-get install clang-format
```

Useful references:
* https://www.codepool.biz/vscode-format-c-code-windows-linux.html
* https://clang.llvm.org/docs/ClangFormatStyleOptions.html


## Setup
Install prerequisites and run the following command to complete setup:
```
./setup.sh
```

## Usage
Auto-format and lint code.
```
./lint.sh
```