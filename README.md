# MT-arduino-cli-scripts

Setup and build scripts leveraging Arduino CLI for compiling and uploading C++ code on Arduino microcontrollers without requiring an IDE. Scripts are available for various operating systems (including Windows and Linux).

## Project setup

Your Arduino C++ source code must be contained in a folder in your projects root directory called:

```src```

The following files must be present in your projects root directory:

- arduino-boards.txt
- arduino-libs.txt

These files are used by setup/build scripts to automatically install the required libraries, and build/compile/upload the project as described in the following sections. The project will be built for all boards defined in ```arduino-boards.txt```.

> [!NOTE]
> Running the setup/build scripts will install arduino-cli and other dependencies (Arduino cores and libraries) on your device. Cores are extracted from the required boards defined in ```arduino-boards.txt``` and required libraries are defined in ```arduino-libs.txt```. Binaries from the build process when running the scripts will be created in a folder called ```build```.

The setup/build scripts can be added to your project using Git Submodules by running the following command:

``` shell
git submodule add https://github.com/Morgritech/MT-arduino-cli-scripts scripts
```

The resulting projet folder structure should look like this:

Project  
├─ scripts  
│   ├─ setup-build-linux.sh  
│   └─ setup-build-windows.cmd  
├─ src  
│   ├─ main.cpp  
│   └─ modules  
├─ arduino-boards.txt  
├─ arduino-libs.txt  

## Setup and build

The following sections will assume that the submodule was created exactly as described above, however, you may replace scripts in the above and following commands with your desired folder name. The commands described in the following sections must be executed in the projects root directory to allow directory paths to resolve correctly.
