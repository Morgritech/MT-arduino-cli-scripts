# Check admin privileges.
#$isAdmin = (
#  [Security.Principal.WindowsPrincipal]::new(
#    [Security.Principal.WindowsIdentity]::GetCurrent()
#  )
#).IsInRole(
#  [Security.Principal.WindowsBuiltInRole]::Administrator
#)

#if (-not $isAdmin) {
#  Write-Host "Please run as admin."
#  exit 1
#}

# Command line arguments
$SCRIPT_NAME = Split-Path $PSCommandPath -Leaf
$CMD_CLI   = "-cli"
$ARG_PATH  = "--path"
$CMD_DEPS  = "-deps"
$CMD_BUILD = "-build"
$CMD_HELP  = "-help"

# Specify the directory where arduino-cli is/will be installed.
# C:\Program Files\Arduino CLI
$ARDUINO_CLI_DIR = "$env:ProgramFiles\Arduino CLI"
$ARDUINO_CLI_EXE = Join-Path $ARDUINO_CLI_DIR "arduino-cli.exe"

function InstallCli {
  Write-Host "...Installing Arduino CLI..."
  Write-Host ""
  
  winget install --accept-package-agreements -e ArduinoSA.CLI
  Write-Host ""

  if ($args.Count -gt 1 -and $args[1] -eq $ARG_PATH) {
    # Add arduino CLI directory to Windows environment path (current session) so it can be executed directly.
    Write-Host "...Adding Arduino CLI to the Windows environment path..."
    Write-Host ""
    $env:PATH += ";$ARDUINO_CLI_DIR"
  }

  & $ARDUINO_CLI_EXE version
  Write-Host ""

  End
}

function InstallDeps {
  Write-Host "...Installing and setting up project dependencies..."
  Write-Host ""

  Write-Host "...Installing arduino platforms/cores..."
  Write-Host ""

  # Specify the directory to the file listing the required arduino cores.
  # The name of the cores will be extracted from the name of the boards.
  $CORES = "arduino-boards.txt"

  & $ARDUINO_CLI_EXE core update-index

  # Read one line at a time.
  # Split text separated by colon (:).
  foreach ($LINE in Get-Content $CORES) {
    $PARTS = $LINE.Split(':', 2)
    if ($PARTS.Count -eq 2) {
      $CORE = "$($parts[0]):$($parts[1])"
      & $ARDUINO_CLI_EXE core install $CORE
    }
  }

  Write-Host ""

  Write-Host "...Installing arduino libraries..."
  Write-Host ""

  # Specify the directory to file listing the required arduino libraries.
  $LIBS = "arduino-libs.txt"

  & $ARDUINO_CLI_EXE lib update-index

  foreach ($lLIB in Get-Content $LIBS) {
    & $ARDUINO_CLI_EXE lib install $lLIB
  }
  
  Write-Host ""

  End
}

function Build {

  Write-Host "...Compiling the project..."
  Write-Host ""

  # Specify the sketch directory.
  $SKETCH_DIR = "src"
  # Specify the build directory.
  $BUILD_DIR = "build"
  # Specify the directories to files listing the required arduino boards.
  $BOARDS = "arduino-boards.txt"
  # Build for multiple boards.
  # Read one line at a time (No spaces or tabs as delimiters).
  foreach ($BOARD in Get-Content $BOARDS) {
    # Replace ":" with "-" to create the build sub-folder with the board name.
    $BUILD_SUBDIR = $BOARD -replace ':','-'
    # Take 2nd argument onwards from the command line args.
    $BUILD_ARGS = $args[1..($args.Count - 1)]
    # Compile clean (no cache) and use command line args (2nd onwards) if passed to the script.
    & $ARDUINO_CLI_EXE compile -b $BOARD $SKETCH_DIR --clean --build-path "$BUILD_DIR\$BUILD_SUBDIR" $BUILD_ARGS
  }

  Write-Host ""

  End
}

function Help {
  Write-Host "...Help..."
  Write-Host ""
  Write-Host "Available commands are:"
  Write-Host "$CMD_CLI    Install arduino-cli. Add optional flag $ARG_PATH to add arduino-cli to the Windows environment path." 
  Write-Host "$CMD_DEPS   Install project dependencies (Arduino cores and libraries)."
  Write-Host "$CMD_BUILD  Compile the project. Add optional arduino-cli flags if desired (e.g., to upload the programme to the board)."
  Write-Host "$CMD_HELP   Show available commands."
  Write-Host "Usage:"
  Write-Host "$SCRIPT_NAME <command>"
  Write-Host "$SCRIPT_NAME $CMD_CLI [optional flag]"
  Write-Host "$SCRIPT_NAME $CMD_BUILD [optional arduino-cli compile flags]"
  Write-Host "Examples:"
  Write-Host "$SCRIPT_NAME $CMD_CLI $ARG_PATH"
  Write-Host "$SCRIPT_NAME $CMD_BUILD --port COM3 --upload"
  Write-Host ""

  End
}

function End {
  Write-Host "...End..."
  Write-Host ""
  exit
}

switch ($args[0]) {
  $CMD_CLI   { InstallCli }
  $CMD_DEPS  { InstallDeps }
  $CMD_BUILD { Build }
  $CMD_HELP  { Help }
  default    { Help }
}
