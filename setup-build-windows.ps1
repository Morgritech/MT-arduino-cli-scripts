Write-Host ""

# Check admin privileges.
#$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
#$Principal = [Security.Principal.WindowsPrincipal]::new($Identity)
#if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
#{
#  Write-Host "Please run as administrator."
#  exit 1
#}

# Colours.

$ErrorColour = [ConsoleColor]::Red
#$SuccessColour = [ConsoleColor]::Green
#$WarningColour = [ConsoleColor]::Yellow
$SubHeadingColour = [ConsoleColor]::Blue
#$DebugColour = [ConsoleColor]::Magenta
$HeadingColour = [ConsoleColor]::Cyan

# Directories and files.

$ScriptName = Split-Path $PSCommandPath -Leaf

# Arduino CLI.
$ArduinoCliDir = "$env:ProgramFiles\Arduino CLI" # C:\Program Files\Arduino CLI
$ArduinoCliExe = Join-Path $ArduinoCliDir "arduino-cli.exe"

# File listing the arduino boards (in the form of FQBN). Cores will be extracted from the FQBN.
$BoardsFile = "arduino-boards.txt"

# File listing the arduino libraries (in the form of "library_name@version_number").
$LibrariesFile = "arduino-libs.txt"

# Sketch directory.
$SketchDir = "src" # ./src

# Build directory.
$BuildDir = "build" # ./build

# Command-line parameters.

$CmdSetup = "-setup"
$CmdCli   = "-cli"
$ArgPath  = "--path"
$CmdDeps  = "-deps"
$CmdBuild = "-build"
$CmdHelp  = "-help"

# Functions.

function Install-ArduinoCli {
  param([switch]$AddToPath)

  Write-Host "...Installing Arduino CLI..." -ForegroundColor $HeadingColour
  Write-Host ""
  
  winget install --accept-package-agreements -e ArduinoSA.CLI
  Write-Host ""

  if ($AddToPath) {
    # Add arduino CLI directory to Windows environment path (current session) so it can be executed directly.
    Write-Host "...Adding Arduino CLI to the Windows environment path..."
    Write-Host ""

    $env:PATH += ";$ArduinoCliDir"
  }

  & $ArduinoCliExe version
  Write-Host ""
}

function Install-Dependencies {
  Write-Host "...Installing and setting up project dependencies..." -ForegroundColor $HeadingColour
  Write-Host ""

  Write-Host "...Installing arduino platforms/cores..."
  Write-Host ""

  & $ArduinoCliExe core update-index

  # Read one line at a time.
  # Split text separated by colon (:).
  foreach ($Board in Get-Content $BoardsFile) {
    if ([string]::IsNullOrWhiteSpace($Board)) { continue }

    $Parts = $Board.Split(':')
    if ($Parts.Count -ge 2) {
      $Core = "$($Parts[0]):$($Parts[1])"
      & $ArduinoCliExe core install $Core
    }
  }

  Write-Host ""

  Write-Host "...Installing arduino libraries..."
  Write-Host ""

  & $ArduinoCliExe lib update-index

  foreach ($Library in Get-Content $LibrariesFile) {
    if ([string]::IsNullOrWhiteSpace($Library)) { continue }

    & $ArduinoCliExe lib install $Library
  }
  
  Write-Host ""
}

function Start-Setup {
  Install-ArduinoCli -AddToPath:$true
  Install-Dependencies
}

function Start-Build {
  param([string[]]$BuildArgs)

  Write-Host "...Compiling the project..." -ForegroundColor $HeadingColour
  Write-Host ""

  # Build for multiple boards.
  # Read one line at a time (No spaces or tabs as delimiters).
  foreach ($Board in Get-Content $BoardsFile) {
    if ([string]::IsNullOrWhiteSpace($Board)) { continue }

    # Replace ":" with "-" to create the build sub-folder with the board name.
    $BuildSubdir = $Board -replace ':','-'
    # Compile clean (no cache) and use command line args (2nd onwards) if passed to the script.
    & $ArduinoCliExe compile -b $Board $SketchDir --clean --build-path "$BuildDir\$BuildSubdir" $BuildArgs
  }

  Write-Host ""
}

function Show-Help {
  Write-Host "...Help..." -ForegroundColor $HeadingColour
  Write-Host ""
  Write-Host "Available commands are:" -ForegroundColor $SubHeadingColour
  Write-Host "$CmdSetup  Install arduino-cli (adds to the Windows environment path) and project dependencies (Arduino cores and libraries)."
  Write-Host "$CmdCli    Install arduino-cli. Add optional flag $ArgPath to add arduino-cli to the Windows environment path." 
  Write-Host "$CmdDeps   Install project dependencies (Arduino cores and libraries)."
  Write-Host "$CmdBuild  Compile the project. Add optional arduino-cli flags if desired (e.g., to upload the programme to the board)."
  Write-Host "$CmdHelp   Show available commands."
  Write-Host ""
  Write-Host "Usage:" -ForegroundColor $SubHeadingColour
  Write-Host "$ScriptName <command>"
  Write-Host "$ScriptName $CmdSetup"
  Write-Host "$ScriptName $CmdCli [optional flag]"
  Write-Host "$ScriptName $CmdBuild [optional arduino-cli compile flags]"
  Write-Host ""
  Write-Host "Examples:" -ForegroundColor $SubHeadingColour
  Write-Host "$ScriptName $CmdCli $ArgPath"
  Write-Host "$ScriptName $CmdBuild --port COM3 --upload"
  Write-Host ""
}

# Script.

switch ($args[0]) {
  $CmdSetup { Start-Setup }
  $CmdCli   { Install-ArduinoCli -AddToPath ($args.Count -gt 1 -and $args[1] -eq $ArgPath) }
  $CmdDeps  { Install-Dependencies }
  $CmdBuild { Start-Build -BuildArgs $args[1..($args.Count - 1)] }
  $CmdHelp  { Show-Help }
  default   {
    Write-Host "Error: Invalid command." -ForegroundColor $ErrorColour
    Write-Host ""
    Show-Help
  }
}

Write-Host "...End..." -ForegroundColor $HeadingColour
Write-Host ""