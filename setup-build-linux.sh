#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e 

echo

# Check sudo
#if [ "$EUID" -ne 0 ]
#  then echo "Please run as root."
#  exit
#fi

# Command line arguments
SCRIPT_NAME=$(basename "$0")
CMD_SETUP="-setup"
CMD_CLI="-cli"
ARG_PATH="--path"
CMD_DEPS="-deps"
CMD_BUILD="-build"
CMD_HELP="-help"

# Specify the directory where arduino-cli is/will be installed.
# home/<username>/bin OR ~/bin
ARDUINO_CLI_DIR="$HOME/bin"
ARDUINO_CLI_EXE="$ARDUINO_CLI_DIR/arduino-cli"

install_arduino_cli() {
  local add_to_path=$1
  
  echo ...Installing Arduino CLI...
  echo

  pushd $PWD /dev/null # Save current working directory + suppress the output of pushd.
  cd "$HOME" # Ensure we are in the "home/<username>" directory.
  sudo apt-get --no-install-recommends install -y curl
  curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
  popd > /dev/null # Restore the working directory + suppress the output of popd.
  echo

  if [[ $add_to_path == true ]] ; then
    # Add arduino CLI directory to Linux environment path (current session) so it can be executed directly.
    echo ...Adding arduino-cli to the Linux environment path...
    echo

    PATH="$PATH:$ARDUINO_CLI_DIR" # $PATH already exported by default.
  fi

  "$ARDUINO_CLI_EXE" version
  echo
}


install_dependencies() {
  echo ...Installing and setting up project dependencies...
  echo

  echo ...Installing arduino platforms/cores...
  echo

  # Specify the directory to the file listing the required arduino cores.
  # The name of the cores will be extracted from the name of the boards.  
  local boards_file="arduino-boards.txt"

  "$ARDUINO_CLI_EXE" core update-index

  # Read one line at a time.
  for board in $(cat "$boards_file") ; do
    # Split text which are separated by colon (:) into 1st (first), 2nd (second) and 3rd (third) argument.
    # Carriage return '\r' must also be removed in-case file was created in Windows.
    IFS=':' read -r first second third <<< "${board%$'\r'}"
    core="$first:$second"
    "$ARDUINO_CLI_EXE" core install "$core"
  done

  unset IFS
  
  echo

  echo ...Installing arduino libraries...
  echo

  # Specify the directory to the file listing the required arduino libraries.
  local libraries_file="arduino-libs.txt"

  "$ARDUINO_CLI_EXE" lib update-index

  for library in $(cat "$libraries_file") ; do
    "$ARDUINO_CLI_EXE" lib install "${library%$'\r'}"
  done
  
  echo
}

start_setup()
{
  install_arduino_cli true
  install_dependencies
}

start_build() {
  local build_args=("$@") # Here for readability (Redundant as "$@" can be used directly in the function).

  echo ...Compiling the project...
  echo

  # Specify the sketch directory.
  local sketch_dir="src" #./src
  # Specify the build directory.
  local build_dir="build"
  # Specify the directories to files listing the required arduino boards.
  local boards_file="arduino-boards.txt"
  # Build for multiple boards.
  # Read one line at a time (No spaces or tabs as delimiters).
  for board in $(cat "$boards_file") ; do
      # Replace ":" with "-" to create the build sub-folder with the board name.
      build_subdir="${board//:/-}"
      # Compile clean (no cache) and use command line args (2nd onwards) if passed to the script.
      # Carriage return '\r' must be removed in-case file was created in Windows.
      "$ARDUINO_CLI_EXE" compile -b "${board%$'\r'}" "$sketch_dir" --clean --build-path "$build_dir/$build_subdir" "${build_args[@]}" # "${build_args[@]}" equivalent to "$@"
  done

  echo
}

show_help() {
  echo \
  "...Help...

  Available commands are:
  $CMD_SETUP  Install arduino-cli (adds to the Linux environment path) and project dependencies (Arduino cores and libraries).
  $CMD_CLI    Install arduino-cli. Optional flag $ARG_PATH to add arduino-cli to the Linux environment path. 
  $CMD_DEPS   Install project dependencies (Arduino cores and libraries).
  $CMD_BUILD  Compile the project. Add optional arduino-cli flags if desired (e.g., to upload the programme to the board).
  $CMD_HELP   Show available commands.

  Usage:
  $SCRIPT_NAME <command>
  $SCRIPT_NAME $CMD_SETUP
  $SCRIPT_NAME $CMD_CLI [optional flag]
  $SCRIPT_NAME $CMD_BUILD [optional arduino-cli compile flags]

  Examples:
  $SCRIPT_NAME $CMD_CLI $ARG_PATH
  $SCRIPT_NAME $CMD_BUILD --port /dev/ttyACM0 --upload
  "
}

case "$1" in

"$CMD_SETUP")
  start_setup
  ;;

"$CMD_CLI")
  if [[ $2 == $ARG_PATH ]]; then
    install_arduino_cli true
  else
    install_arduino_cli false
  fi
  ;;

"$CMD_DEPS")
  install_dependencies
  ;;

"$CMD_BUILD")
  start_build "${@:2}"
  ;;

"$CMD_HELP")
  show_help
  ;;

*)
  show_help
  ;;

esac

echo ...End...
echo