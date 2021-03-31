# 10/20/2020

## The Following profile configuration was originally built by Mike MacCana and these configs plus more are hosted on his github
## https://github.com/mikemaccana/powershell-profile

# Proper history etc
Import-Module PSReadLine

# Produce UTF-8 by default
# https://news.ycombinator.com/item?id=12991690
$PSDefaultParameterValues["Out-File:Encoding"] = "utf8"

# https://technet.microsoft.com/en-us/magazine/hh241048.aspx
$MaximumHistoryCount = 10000;

# Aliases
Set-Alias trash Remove-ItemSafely
# Self authored
#  `la` list all items, including hidden
Function List-All {Get-ChildItem . -Force}
Set-Alias -Name la -Value List-All

function open($file) {
  invoke-item $file
}

function explorer {
  explorer.exe .
}

function settings {
  start-process ms-settings:
}

# Oddly, Powershell doesn't have an inbuilt variable for the documents directory. So let's make one:
# From https://stackoverflow.com/questions/3492920/is-there-a-system-defined-environment-variable-for-documents-directory
$env:DOCUMENTS = [Environment]::GetFolderPath("mydocuments")

# PS comes preset with 'HKLM' and 'HKCU' drives but is missing HKCR 
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT | Out-Null

# Get Bash style prompt [username@computername currentdirectory]
function Get-CustomDirectory {

  [CmdletBinding()]
  [Alias("CDir")]
  [OutputType([String])]
  Param (
    [Parameter(ValueFromPipeline=$true,Position=0)]
    $Path = $PWD.Path
    
  )

  Begin {
    $ComputerName = $env:COMPUTERNAME
    $UserName = $env:USERNAME
  }
  Process {
    # Check if user is in home directory
    if( $Path -ne "$home") {
      # Remove all but the current directory
      $Path = $Path.Replace("$home", "")
      $Path = $Path -replace "\\.*\\", ""
      $Path = $Path -replace "\\", ""
    } else {
      # Replace with tilde alias
      $Path = $Path.Replace("$home", "~")
    }
    # Add additional imformation and brackets
    $Path = '[' + $UserName + '@' + $ComputerName + ' ' + $Path + ']'
    $Path
  }
  End {
  }

}

# Must be called 'prompt' to be used by pwsh 
# https://github.com/gummesson/kapow/blob/master/themes/bashlet.ps1
function prompt {
  $realLASTEXITCODE = $LASTEXITCODE
  Write-Host $(Get-CustomDirectory) -ForegroundColor Yellow -NoNewline
  Write-Host " $" -NoNewline
  $global:LASTEXITCODE = $realLASTEXITCODE
  Return " "
}

# Make $lastObject save the last object output
# From http://get-powershell.com/post/2008/06/25/Stuffing-the-output-of-the-last-command-into-an-automatic-variable.aspx
function out-default {
  $input | Tee-Object -var global:lastobject | Microsoft.PowerShell.Core\out-default
}

# If you prefer oh-my-posh
# Import-Module posh-git
# Import-Module oh-my-posh

function rename-extension($newExtension){
  Rename-Item -NewName { [System.IO.Path]::ChangeExtension($_.Name, $newExtension) }
}
