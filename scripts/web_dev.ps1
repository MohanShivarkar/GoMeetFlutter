param(
  [Parameter(Mandatory = $true)]
  [ValidateSet("doctor", "pub-get", "analyze", "run", "build", "serve")]
  [string]$Command,

  [int]$Port = 8000
)

$ErrorActionPreference = "Stop"

function Get-ProjectRoot {
  return (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Get-FlutterCommand {
  $flutterOnPath = Get-Command flutter -ErrorAction SilentlyContinue
  if ($flutterOnPath) {
    return $flutterOnPath.Source
  }

  $projectRoot = Get-ProjectRoot
  $localProperties = Join-Path $projectRoot "android\local.properties"
  if (-not (Test-Path $localProperties)) {
    throw "Flutter was not found on PATH and android\local.properties is missing."
  }

  $flutterSdkLine = Get-Content $localProperties | Where-Object { $_ -like "flutter.sdk=*" } | Select-Object -First 1
  if (-not $flutterSdkLine) {
    throw "flutter.sdk was not found in android\local.properties."
  }

  $flutterSdk = ($flutterSdkLine -split "=", 2)[1].Trim()
  if (-not $flutterSdk) {
    throw "flutter.sdk in android\local.properties is empty."
  }

  $flutterBat = Join-Path $flutterSdk "bin\flutter.bat"
  if (-not (Test-Path $flutterBat)) {
    throw "Flutter executable not found at $flutterBat."
  }

  return $flutterBat
}

function Invoke-Flutter {
  param(
    [string[]]$Arguments
  )

  $projectRoot = Get-ProjectRoot
  $flutterCommand = Get-FlutterCommand

  Push-Location $projectRoot
  try {
    & $flutterCommand @Arguments
  }
  finally {
    Pop-Location
  }
}

$projectRoot = Get-ProjectRoot

switch ($Command) {
  "doctor" {
    Invoke-Flutter -Arguments @("doctor", "-v")
  }
  "pub-get" {
    Invoke-Flutter -Arguments @("pub", "get")
  }
  "analyze" {
    Invoke-Flutter -Arguments @("analyze")
  }
  "run" {
    Invoke-Flutter -Arguments @("run", "-d", "chrome")
  }
  "build" {
    Invoke-Flutter -Arguments @("build", "web", "--release")

    $flutterAssetsPath = Join-Path $projectRoot "build\flutter_assets"
    $webAssetsPath = Join-Path $projectRoot "build\web\assets"
    if (Test-Path $flutterAssetsPath) {
      if (-not (Test-Path $webAssetsPath)) {
        New-Item -ItemType Directory -Path $webAssetsPath | Out-Null
      }

      Copy-Item -Path (Join-Path $flutterAssetsPath "*") -Destination $webAssetsPath -Recurse -Force
    }
  }
  "serve" {
    $buildWebPath = Join-Path $projectRoot "build\web"
    if (-not (Test-Path $buildWebPath)) {
      throw "build\web does not exist. Run '.\scripts\web_dev.ps1 build' first."
    }

    Push-Location $buildWebPath
    try {
      python -m http.server $Port
    }
    finally {
      Pop-Location
    }
  }
}
