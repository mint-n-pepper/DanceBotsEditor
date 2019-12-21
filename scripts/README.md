# Scripts

This folder contains scripts for the build system. These scripts can also be used for git-prehooks on \*nix systems.

## Prerequisites
### Python PIP and Virtual Environments
* Instructions for setting up Python's PIP and virual environments can be found [here](https://gist.github.com/Geoyi/d9fab4f609e9f75941946be45000632b)


### Clang Formatter
`clang-format` will be used to auto-formatting code and maintaining code style consistency.
```
sudo apt-get install clang-format
```

Useful references:
* https://www.codepool.biz/vscode-format-c-code-windows-linux.html
* https://clang.llvm.org/docs/ClangFormatStyleOptions.html


## Setup
Install prerequisites and run:
```
./setup.sh
```

## Usage
`lint.sh`
Auto-format and lint code.
```
./lint.sh
```