# Check admin privileges.
#$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
#$Principal = [Security.Principal.WindowsPrincipal]::new($Identity)
#if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
#{
#  Write-Host "Please run as administrator."
#  exit 1
#}

# Command line arguments
$ScriptName = Split-Path $PSCommandPath -Leaf
$CmdSetup = "-setup"
$CmdCli   = "-cli"
$ArgPath  = "--path"
$CmdDeps  = "-deps"
$CmdBuild = "-build"
$CmdHelp  = "-help"

# Specify the directory where arduino-cli is/will be installed.
# C:\Program Files\Arduino CLI
$ArduinoCliDir = "$env:ProgramFiles\Arduino CLI"
$ArduinoCliExe = Join-Path $ArduinoCliDir "arduino-cli.exe"

function Install-ArduinoCli {
  Write-Host "...Installing Arduino CLI..."
  Write-Host ""
  
  winget install --accept-package-agreements -e ArduinoSA.CLI
  Write-Host ""

  if ($args.Count -gt 1 -and $args[1] -eq $ArgPath) {
    # Add arduino CLI directory to Windows environment path (current session) so it can be executed directly.
    Write-Host "...Adding Arduino CLI to the Windows environment path..."
    Write-Host ""
    $env:PATH += ";$ArduinoCliDir"
  }

  & $ArduinoCliExe version
  Write-Host ""
}

function Install-Dependencies {
  Write-Host "...Installing and setting up project dependencies..."
  Write-Host ""

  Write-Host "...Installing arduino platforms/cores..."
  Write-Host ""

  # Specify the directory to the file listing the required arduino cores.
  # The name of the cores will be extracted from the name of the boards.
  $Cores = "arduino-boards.txt"

  & $ArduinoCliExe core update-index

  # Read one line at a time.
  # Split text separated by colon (:).
  foreach ($Line in Get-Content $Cores) {
    $Parts = $Line.Split(':', 2)
    if ($PARTS.Count -eq 2) {
      $Core = "$($Parts[0]):$($Parts[1])"
      & $ArduinoCliExe core install $Core
    }
  }

  Write-Host ""

  Write-Host "...Installing arduino libraries..."
  Write-Host ""

  # Specify the directory to file listing the required arduino libraries.
  $Libs = "arduino-libs.txt"

  & $ArduinoCliExe lib update-index

  foreach ($Lib in Get-Content $Libs) {
    & $ArduinoCliExe lib install $Lib
  }
  
  Write-Host ""
}

function Start-Setup {
  if ($args.Count -lt 2) {
    $args += "--path"
  }
  else {
    Show-Help
  }

  Install-ArduinoCli
  Install-Dependencies
}

function Start-Build {

  Write-Host "...Compiling the project..."
  Write-Host ""

  # Specify the sketch directory.
  $SketchDir = "src"
  # Specify the build directory.
  $BuildDir = "build"
  # Specify the directories to files listing the required arduino boards.
  $Boards = "arduino-boards.txt"
  # Build for multiple boards.
  # Read one line at a time (No spaces or tabs as delimiters).
  foreach ($Board in Get-Content $Boards) {
    # Replace ":" with "-" to create the build sub-folder with the board name.
    $BuildSubdir = $Board -replace ':','-'
    # Take 2nd argument onwards from the command line args.
    $BuildArgs = $args[1..($args.Count - 1)]
    # Compile clean (no cache) and use command line args (2nd onwards) if passed to the script.
    & $ArduinoCliExe compile -b $Board $SketchDir --clean --build-path "$BuildDir\$BuildSubdir" $BuildArgs
  }

  Write-Host ""
}

function Show-Help {
  Write-Host "...Help..."
  Write-Host ""
  Write-Host "Available commands are:"
  Write-Host "$CmdSetup  Install arduino-cli (adds to the Windows environment path) and project dependencies (Arduino cores and libraries)."
  Write-Host "$CmdCli    Install arduino-cli. Add optional flag $ArgPath to add arduino-cli to the Windows environment path." 
  Write-Host "$CmdDeps   Install project dependencies (Arduino cores and libraries)."
  Write-Host "$CmdBuild  Compile the project. Add optional arduino-cli flags if desired (e.g., to upload the programme to the board)."
  Write-Host "$CmdHelp   Show available commands."
  Write-Host ""
  Write-Host "Usage:"
  Write-Host "$ScriptName <command>"
  Write-Host "$ScriptName $CmdSetup"
  Write-Host "$ScriptName $CmdCli [optional flag]"
  Write-Host "$ScriptName $CmdBuild [optional arduino-cli compile flags]"
  Write-Host "Examples:"
  Write-Host "$ScriptName $CmdCli $ArgPath"
  Write-Host "$ScriptName $CmdBuild --port COM3 --upload"
  Write-Host ""
}

switch ($args[0]) {
  $CmdSetup { Start-Setup }
  $CmdCli   { Install-ArduinoCli }
  $CmdDeps  { Install-Dependencies }
  $CmdBuild { Start-Build }
  $CmdHelp  { Show-Help }
  default   { Show-Help }
}

Write-Host "...End..."
Write-Host ""