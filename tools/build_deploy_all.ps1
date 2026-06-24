#Requires -Version 5.1
<#
.SYNOPSIS
  Regenerates tools/deploy_all.sql -- one consolidated, idempotent SQL file that
  bundles every schema/migration/index/seed script in canonical deploy order.

.DESCRIPTION
  Run this whenever you add or change a .sql file under db/. The output is a single
  file you can run in SSMS (F5) or via sqlcmd -i, against the
  easyHMS database. Order matches .github/workflows/deploy-db.yml:
    tables -> migrations -> indexes -> seed

.EXAMPLE
  ./tools/build_deploy_all.ps1
#>
[CmdletBinding()]
param(
    [string] $OutFile
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $OutFile) { $OutFile = Join-Path $PSScriptRoot 'deploy_all.sql' }

$order = @(
    @{ Dir = 'db\schema\tables';     Label = 'TABLES' },
    @{ Dir = 'db\schema\migrations'; Label = 'MIGRATIONS (column ALTERs)' },
    @{ Dir = 'db\schema\indexes';    Label = 'INDEXES' },
    @{ Dir = 'db\data\seed';         Label = 'SEED DATA' }
)

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine('-- =====================================================================')
[void]$sb.AppendLine('-- easyHMS - consolidated database deploy script')
[void]$sb.AppendLine("-- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm')  (via tools/build_deploy_all.ps1)")
[void]$sb.AppendLine('-- Run against the easyHMS database (connect to it first; the script')
[void]$sb.AppendLine('-- targets your CURRENT database). All statements are idempotent and')
[void]$sb.AppendLine('-- safe to re-run. Order: tables -> migrations -> indexes -> seed.')
[void]$sb.AppendLine('--')
[void]$sb.AppendLine('-- SSMS : just open and Execute (F5).')
[void]$sb.AppendLine('-- sqlcmd                   : sqlcmd -S <server> -d <db> -U <user> -i deploy_all.sql')
[void]$sb.AppendLine('-- =====================================================================')
[void]$sb.AppendLine('SET QUOTED_IDENTIFIER ON;')
[void]$sb.AppendLine('GO')
[void]$sb.AppendLine('SET ANSI_NULLS ON;')
[void]$sb.AppendLine('GO')
[void]$sb.AppendLine('SET NOCOUNT ON;')
[void]$sb.AppendLine('GO')
[void]$sb.AppendLine('')

foreach ($o in $order) {
    $p = Join-Path $root $o.Dir
    if (-not (Test-Path $p)) { continue }
    $files = Get-ChildItem $p -Filter *.sql -File | Sort-Object Name
    [void]$sb.AppendLine('-- #####################################################################')
    [void]$sb.AppendLine("-- ##  SECTION: $($o.Label)")
    [void]$sb.AppendLine('-- #####################################################################')
    [void]$sb.AppendLine('')
    foreach ($f in $files) {
        $rel = $f.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
        [void]$sb.AppendLine('-- ---------------------------------------------------------------------')
        [void]$sb.AppendLine("-- FILE: $rel")
        [void]$sb.AppendLine('-- ---------------------------------------------------------------------')
        # Re-assert safe SET options per file, in case an upstream batch changed them.
        [void]$sb.AppendLine('SET QUOTED_IDENTIFIER ON; SET ANSI_NULLS ON;')
        [void]$sb.AppendLine('GO')
        $content = Get-Content -Path $f.FullName -Raw
        [void]$sb.AppendLine($content.TrimEnd())
        [void]$sb.AppendLine('')
        [void]$sb.AppendLine('GO')
        [void]$sb.AppendLine('')
    }
}

[void]$sb.AppendLine("PRINT 'easyHMS deploy_all.sql completed.';")
[void]$sb.AppendLine('GO')

[System.IO.File]::WriteAllText($OutFile, $sb.ToString(), (New-Object System.Text.UTF8Encoding($false)))
Write-Host ("Wrote {0} ({1:N0} bytes)" -f $OutFile, (Get-Item $OutFile).Length) -ForegroundColor Green
