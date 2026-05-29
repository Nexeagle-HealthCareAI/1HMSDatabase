# Database deploy tooling

`deploy.ps1` applies the SQL scripts in this repo to a target SQL Server / Azure SQL
database, in the same order as [`azure-pipelines.yml`](../azure-pipelines.yml).

## Folder model

| Folder                 | Behavior on each deploy                                  |
|------------------------|----------------------------------------------------------|
| `db/schema/tables`     | re-run every time — **must be idempotent**               |
| `db/schema/migrations` | **apply-once**, tracked in `dbo.SchemaMigrations`        |
| `db/schema/indexes`    | re-run every time — must be idempotent                   |
| `db/schema/views`      | re-run every time — must be idempotent                   |
| `db/schema/procs`      | re-run every time — must be idempotent                   |
| `db/data/seed`         | re-run every time — must be idempotent                   |

Within a folder, files run in **alphabetical order**. (That's why
`create_tables_zz_foreign_keys.sql` is named to sort last.)

## Migration tracking

The first time `deploy.ps1` runs it creates:

```sql
dbo.SchemaMigrations(ScriptName, Sha256, AppliedAtUtc, AppliedBy)
```

For each file in `db/schema/migrations`:

- never applied → run it, then record its SHA-256.
- already applied, same hash → **skip**.
- already applied, different hash → **hard error**. Never edit an applied migration
  in place; add a new `db/schema/migrations/alter_*.sql` file instead.

To see what a database has received:

```sql
SELECT ScriptName, AppliedAtUtc, AppliedBy FROM dbo.SchemaMigrations ORDER BY AppliedAtUtc;
```

## Usage

Set the password via environment variable so it stays out of your shell history:

```powershell
$env:SQLCMDPASSWORD = '<password>'

# Full deploy (Azure SQL)
./tools/deploy.ps1 -Server easyhmserver.database.windows.net -Database easyHMSDatabase -User easyHMSAdmin

# Only apply new migrations (skip the idempotent re-runs)
./tools/deploy.ps1 -Server easyhmserver.database.windows.net -Database easyHMSDatabase -User easyHMSAdmin -MigrationsOnly

# Dry run — print what would execute, change nothing
./tools/deploy.ps1 -Server localhost -Database easyHMSDatabase -WhatIf
```

- Omit `-User` to use Windows integrated security (`-E`).
- Requires `sqlcmd` on PATH (SQL Server command-line tools / ODBC).

## Adding a new schema change

1. Add a guarded, idempotent script under `db/schema/migrations/`
   (e.g. `alter_tables_<feature>.sql`), following the `COL_LENGTH(...) IS NULL`
   pattern used by the existing migrations.
2. Add the matching rollback under `db/rollback/`.
3. Run `deploy.ps1` against each environment (or let the pipeline do it).
