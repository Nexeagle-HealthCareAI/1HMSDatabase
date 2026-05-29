#Requires -Version 5.1
<#
.SYNOPSIS
  Deploys the easyHMS database schema, migrations and seed scripts to a target
  SQL Server / Azure SQL database. Mirrors the execution order in azure-pipelines.yml.

.DESCRIPTION
  Folder order (matches the CI pipeline):
    db/schema            (root, usually empty)
    db/schema/tables
    db/schema/migrations   <-- apply-once + tracked (see below)
    db/schema/indexes
    db/schema/views
    db/schema/procs
    db/data/seed

  Base-schema folders (tables/indexes/views/procs/seed) are RE-RUN on every deploy.
  Every script in those folders must therefore be idempotent (guarded CREATE/ALTER).

  The db/schema/migrations folder is APPLY-ONCE and tracked in dbo.SchemaMigrations:
    * A migration that has never been applied is run, then recorded with a SHA-256
      of its current contents.
    * A migration already recorded with the SAME hash is skipped.
    * A migration already recorded with a DIFFERENT hash is a hard ERROR -- you must
      never edit an applied migration in place; add a new one instead.

  This is what stops "schema drift": you can always tell, from dbo.SchemaMigrations,
  exactly which migrations a given database has received.

.PARAMETER Server
  SQL host, e.g. easyhmserver.database.windows.net  (port 1433 is appended automatically).

.PARAMETER Database
  Target database name, e.g. easyHMSDatabase.

.PARAMETER User
  SQL login. If omitted, integrated security (-E) is used.

.PARAMETER Password
  Password for -User. If omitted, the SQLCMDPASSWORD environment variable is used
  (preferred -- avoids the password landing in your shell history).

.PARAMETER MigrationsOnly
  Only process db/schema/migrations (skip tables/indexes/seed re-runs). Handy for a
  quick "apply whatever's new" pass.

.PARAMETER WhatIf
  Show what would run, without executing any SQL.

.EXAMPLE
  $env:SQLCMDPASSWORD = '...'
  ./tools/deploy.ps1 -Server easyhmserver.database.windows.net -Database easyHMSDatabase -User easyHMSAdmin

.EXAMPLE
  ./tools/deploy.ps1 -Server localhost -Database easyHMSDatabase -MigrationsOnly -WhatIf
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $Server,
    [Parameter(Mandatory = $true)] [string] $Database,
    [string] $User,
    [string] $Password,
    [switch] $MigrationsOnly,
    [switch] $WhatIf
)

$ErrorActionPreference = 'Stop'

# --- locate sqlcmd ---------------------------------------------------------
$sqlcmd = (Get-Command sqlcmd -ErrorAction SilentlyContinue)
if (-not $sqlcmd) {
    throw "sqlcmd not found on PATH. Install the SQL Server command-line tools (mssql-tools / ODBC) and retry."
}

# --- repo root = parent of this tools/ folder ------------------------------
$root = Split-Path -Parent $PSScriptRoot

# --- build the common sqlcmd argument list ---------------------------------
# -b  : exit with error code on SQL error
# -N -C : encrypt connection + trust server cert (Azure SQL requires encryption)
# -I  : QUOTED_IDENTIFIER ON   -r 1 : errors to stderr   -m -1 : show all messages
$server1433 = "$Server,1433"
$baseArgs = @('-S', $server1433, '-d', $Database, '-b', '-l', '60', '-I', '-r', '1', '-m', '-1', '-N', '-C')

if ($User) {
    $baseArgs += @('-U', $User)
    if ($Password) { $env:SQLCMDPASSWORD = $Password }
    if (-not $env:SQLCMDPASSWORD) {
        throw "User '$User' supplied but no password. Pass -Password or set `$env:SQLCMDPASSWORD."
    }
} else {
    $baseArgs += '-E'   # integrated security
}

function Invoke-SqlFile {
    param([string] $File)
    & sqlcmd @baseArgs -i $File
    if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed (exit $LASTEXITCODE) on: $File" }
}

function Invoke-SqlScalar {
    param([string] $Query)
    $out = & sqlcmd @baseArgs -h -1 -W -Q "SET NOCOUNT ON; $Query"
    if ($LASTEXITCODE -ne 0) { throw "sqlcmd scalar query failed (exit $LASTEXITCODE): $Query" }
    # -h -1 -W gives just the value rows; take the first non-empty line.
    return ($out | Where-Object { $_ -and $_.Trim() -ne '' } | Select-Object -First 1)
}

function RelPath {
    param([string] $Full)
    return ($Full.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/')
}

# --- ensure the tracking table exists --------------------------------------
$ensureTracking = @"
IF OBJECT_ID('dbo.SchemaMigrations') IS NULL
CREATE TABLE dbo.SchemaMigrations (
    ScriptName   NVARCHAR(260) NOT NULL CONSTRAINT PK_SchemaMigrations PRIMARY KEY,
    Sha256       CHAR(64)      NOT NULL,
    AppliedAtUtc DATETIME2(0)  NOT NULL CONSTRAINT DF_SchemaMigrations_AppliedAt DEFAULT SYSUTCDATETIME(),
    AppliedBy    NVARCHAR(128) NOT NULL CONSTRAINT DF_SchemaMigrations_AppliedBy DEFAULT SUSER_SNAME()
);
"@

Write-Host "==> Target: $server1433 / $Database" -ForegroundColor Cyan
if ($WhatIf) { Write-Host "    (WhatIf: no SQL will be executed)" -ForegroundColor Yellow }

if (-not $WhatIf) {
    & sqlcmd @baseArgs -Q $ensureTracking | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Failed to ensure dbo.SchemaMigrations exists." }
}

# --- run an idempotent (re-run-every-deploy) folder ------------------------
function Invoke-Folder {
    param([string] $Dir, [string] $Label)
    $path = Join-Path $root $Dir
    if (-not (Test-Path $path)) { Write-Host "SKIP (missing): $Dir" -ForegroundColor DarkGray; return }
    $files = Get-ChildItem -Path $path -Filter *.sql -File | Sort-Object Name
    if (-not $files) { Write-Host "SKIP (empty):   $Dir" -ForegroundColor DarkGray; return }
    Write-Host "==> $Label  ($Dir)" -ForegroundColor Green
    foreach ($f in $files) {
        Write-Host "    RUN: $(RelPath $f.FullName)"
        if (-not $WhatIf) { Invoke-SqlFile -File $f.FullName }
    }
}

# --- run the tracked, apply-once migrations folder -------------------------
function Invoke-Migrations {
    $dir = Join-Path $root 'db/schema/migrations'
    if (-not (Test-Path $dir)) { Write-Host "SKIP (missing): db/schema/migrations" -ForegroundColor DarkGray; return }
    $files = Get-ChildItem -Path $dir -Filter *.sql -File | Sort-Object Name
    if (-not $files) { Write-Host "SKIP (empty):   db/schema/migrations" -ForegroundColor DarkGray; return }
    Write-Host "==> MIGRATIONS (apply-once, tracked)  (db/schema/migrations)" -ForegroundColor Green
    foreach ($f in $files) {
        $rel  = RelPath $f.FullName
        $hash = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash.ToUpperInvariant()

        $recorded = $null
        if (-not $WhatIf) {
            $recorded = Invoke-SqlScalar -Query "SELECT Sha256 FROM dbo.SchemaMigrations WHERE ScriptName = N'$rel';"
            if ($recorded) { $recorded = $recorded.Trim().ToUpperInvariant() }
        }

        if ($recorded) {
            if ($recorded -eq $hash) {
                Write-Host "    SKIP (applied): $rel"
                continue
            }
            throw "Migration '$rel' was already applied with a different hash.`n" +
                  "  recorded: $recorded`n  current : $hash`n" +
                  "Never edit an applied migration in place -- add a NEW migration file instead."
        }

        Write-Host "    APPLY: $rel"
        if ($WhatIf) { continue }

        Invoke-SqlFile -File $f.FullName
        $insert = "INSERT INTO dbo.SchemaMigrations (ScriptName, Sha256) VALUES (N'$rel', '$hash');"
        & sqlcmd @baseArgs -Q $insert | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "Applied '$rel' but FAILED to record it in dbo.SchemaMigrations." }
    }
}

# --- execute in pipeline order ---------------------------------------------
try {
    if (-not $MigrationsOnly) {
        Invoke-Folder 'db/schema'        'SCHEMA root'
        Invoke-Folder 'db/schema/tables' 'TABLES'
    }

    Invoke-Migrations

    if (-not $MigrationsOnly) {
        Invoke-Folder 'db/schema/indexes' 'INDEXES'
        Invoke-Folder 'db/schema/views'   'VIEWS'
        Invoke-Folder 'db/schema/procs'   'PROCS'
        Invoke-Folder 'db/data/seed'      'SEED'
    }

    Write-Host "==> Deploy completed." -ForegroundColor Cyan
}
catch {
    Write-Host "==> Deploy FAILED: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
