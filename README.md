# MT-arduino-cli-scripts

Setup and build scripts leveraging Arduino CLI for compiling and uploading C++ code on Arduino microcontrollers without requiring an IDE. Scripts are available for various operating systems (including Windows and Linux).

## Project setup

Your Arduino C++ source code must be contained in a folder in your projects root directory called ```src```, which should contain the main Arduino sketch file ```src.ino```.

The following files must also be present in your projects root directory:

- arduino-boards.txt
- arduino-libs.txt

These files are used by setup/build scripts to automatically install the required libraries, and build/compile/upload the project as described in the following sections. The project will be built for all boards defined in ```arduino-boards.txt```.

> [!NOTE]
> Running the setup/build scripts will install arduino-cli and other dependencies (Arduino cores and libraries) on your device. Cores are extracted from the required boards defined in ```arduino-boards.txt``` and required libraries are defined in ```arduino-libs.txt```. Binaries from the build process when running the scripts will be created in a folder called ```build```.

The setup/build scripts can be added to your project using Git Submodules by running the following command:

``` shell
git submodule add https://github.com/Morgritech/MT-arduino-cli-scripts scripts
```

The resulting project folder structure should look like this:

``` text
Project  
├─ scripts  
│   ├─ setup-build-linux.sh  
│   └─ setup-build-windows.cmd  
├─ src  
│   ├─ some_other_file.cpp  
│   ├─ some_other_file.h  
│   └─ src.ino  
├─ arduino-boards.txt  
├─ arduino-libs.txt  
```

## Setup and build scripts

The following sections will assume that the submodule was created exactly as described above, however, you may replace scripts in the above and following commands with your desired folder name. The commands described in the following sections must be executed in the projects root directory to allow directory paths to resolve correctly.

### Windows

Open a Command Prompt (CMD) terminal, navigate to the project directory, and run the commands in the following sections.

**Setup a Windows device ready to build the project.**

Install arduino-cli:

``` shell
scripts\setup-build-windows.cmd -cli
```

OR

Install arduino-cli and add it to the Windows environment path. This allows you to run ```arduino-cli``` commands (if desired) directly without specifying the full path to the arduino-cli executable (%ProgramFiles%\Arduino CLI):

``` shell
scripts\setup-build-windows.cmd -cli --path
```

> [!NOTE]
> This only updates the path in the current user session and does not persist if the session is closed. You will need to re-run the command for a new session.

Install arduino cores and libraries:

``` shell
scripts\setup-build-windows.cmd -deps
```

**Build and optionally upload the project.**

Build only:

``` shell
scripts\setup-build-windows.cmd -build
```

Build and upload:

``` shell
scripts\setup-build-windows.cmd -build --port COM3 --upload
```

Replace COM3 in the command with the desired serial port.

### Linux

Open a terminal, navigate to the project directory, and run the commands in the following sections.

**Setup a Linux device ready to build the project.**

In order for Arduino tools to access the ports (e.g., to upload the programme to a board), your username/log-in name must be added to the dialout group:

``` shell
sudo usermod -a -G dialout username
```

Replace "username" with your actual username/log-in name. You will need to log-out and back in again for changes to take effect.

Install arduino-cli:

``` shell
scripts/setup-build-linux.sh -cli
```

OR

Install arduino-cli and add it to the Windows environment path. This allows you to run ```arduino-cli``` commands (if desired) directly without specifying the full path to the arduino-cli executable (~/bin):

``` shell
source scripts/setup-build-linux.sh -cli --path
```

> [!NOTE]
> This only updates the path in the current user session and does not persist if the session is closed. You will need to re-run the command for a new session.

Install arduino cores and libraries:

``` shell
scripts/setup-build-linux.sh -deps
```

**Build and optionally upload the project.**

Build only:

``` shell
scripts/setup-build-linux.sh -build
```

Build and upload:

``` shell
scripts/setup-build-linux.sh -build --port /dev/ttyACM0 --upload
```

Replace /dev/ttyACM0 in the command with the desired serial port.

### Running arduino-cli directly (Windows or Linux)

Once arduino-cli is installed as described above, the commands can be used directly in the terminal. This can be useful if more functionality is required, beyond what the setup and build scripts provide. See the official [Arduino CLI](https://arduino.github.io/arduino-cli) website for more information.

If you added arduino-cli to your devices environment path:

``` shell
arduino-cli <commands>
```

If you did not add arduino-cli to your devices environment path, the full path must be given with the command.

For windows:

``` shell
"%ProgramFiles%\Arduino CLI\arduino-cli" <commands>
```

For Linux:

``` shell
~/bin/arduino-cli <commands>
```
