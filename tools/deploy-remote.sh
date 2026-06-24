#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# EasyHMS DB — remote apply script (runs ON the VM, talks to the SQL Server
# Docker container via `docker exec`).
#
# Execution order MATCHES tools/deploy.ps1 and .github/workflows/deploy-db.yml:
#     db/schema            (root, usually empty)   — idempotent, re-run
#     db/schema/tables                             — idempotent, re-run
#     db/schema/migrations  <-- apply-once, tracked in dbo.__MigrationHistory
#     db/schema/indexes                            — idempotent, re-run
#     db/schema/views                              — idempotent, re-run
#     db/schema/procs                              — idempotent, re-run
#     db/data/seed                                 — idempotent (MERGE), re-run
#
# tables/indexes/views/procs/seed are guarded (CREATE-if-missing / MERGE) and are
# RE-RUN every deploy so edits and new reference data take effect. Only the
# migrations folder is apply-once: each migration is recorded by name and skipped
# next time.
#
# Env:
#   SA_PASSWORD     (required) SQL Server 'sa' password
#   SQL_CONTAINER   (default: sqlserver) name of the SQL Server docker container
#   DB_NAME         (default: EasyHMSDatabase)
#   DEPLOY_DIR      (default: <this script>/../db) path to the db/ tree on the VM
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

SQL_CONTAINER="${SQL_CONTAINER:-sqlserver}"
DB_NAME="${DB_NAME:-EasyHMSDatabase}"
DEPLOY_DIR="${DEPLOY_DIR:-$(cd "$(dirname "$0")/.." && pwd)/db}"
: "${SA_PASSWORD:?SA_PASSWORD is required}"

docker ps --format '{{.Names}}' | grep -qx "$SQL_CONTAINER" \
  || { echo "ERROR: SQL Server container '$SQL_CONTAINER' is not running on this VM"; exit 1; }

# Locate sqlcmd inside the container: tools18 on 2022 images, tools (v17) on 2019.
SQLCMD_BIN="$(docker exec "$SQL_CONTAINER" sh -lc '
  for p in "$(command -v sqlcmd 2>/dev/null)" /opt/mssql-tools18/bin/sqlcmd /opt/mssql-tools/bin/sqlcmd; do
    if [ -n "$p" ] && [ -x "$p" ]; then echo "$p"; break; fi
  done')"
[ -n "$SQLCMD_BIN" ] || { echo "ERROR: sqlcmd not found inside container '$SQL_CONTAINER'"; exit 1; }
echo "==> container=$SQL_CONTAINER  db=$DB_NAME  sqlcmd=$SQLCMD_BIN"

# -C trusts the server's self-signed cert (valid on sqlcmd 17 & 18); -b returns an
# error exit code on SQL error; -I sets QUOTED_IDENTIFIER ON.
sql_q()  { docker exec -i "$SQL_CONTAINER" "$SQLCMD_BIN" -S localhost -U sa -P "$SA_PASSWORD" -C -b -I "$@"; }
sql_file(){ docker exec -i "$SQL_CONTAINER" "$SQLCMD_BIN" -S localhost -U sa -P "$SA_PASSWORD" -C -b -I -d "$DB_NAME" < "$1"; }

# --- ensure database + migration-tracking table --------------------------------
sql_q -Q "IF DB_ID('$DB_NAME') IS NULL BEGIN CREATE DATABASE [$DB_NAME]; PRINT 'Created $DB_NAME'; END ELSE PRINT '$DB_NAME exists';"
sql_q -d "$DB_NAME" -Q "
  IF OBJECT_ID('dbo.__MigrationHistory') IS NULL
  CREATE TABLE dbo.__MigrationHistory (
    ScriptName NVARCHAR(500) NOT NULL CONSTRAINT PK___MigrationHistory PRIMARY KEY,
    AppliedAt  DATETIME2     NOT NULL CONSTRAINT DF___MigrationHistory_AppliedAt DEFAULT SYSUTCDATETIME()
  );"

# --- idempotent folder: run every .sql in name order, every deploy -------------
run_folder() {
  local dir="$1" label="$2" found=0 f
  [ -d "$dir" ] || { echo "SKIP (missing): $label"; return 0; }
  for f in $(ls "$dir"/*.sql 2>/dev/null | sort); do
    found=1; echo "  RUN: ${f#$DEPLOY_DIR/}"; sql_file "$f"
  done
  [ "$found" = 1 ] || echo "SKIP (empty): $label"
}

# --- apply-once, tracked migrations --------------------------------------------
run_migrations() {
  local dir="$DEPLOY_DIR/schema/migrations" f key applied
  [ -d "$dir" ] || { echo "SKIP (missing): MIGRATIONS"; return 0; }
  echo "==> MIGRATIONS (apply-once, tracked)"
  for f in $(ls "$dir"/*.sql 2>/dev/null | sort); do
    key="schema/migrations/$(basename "$f")"
    applied="$(docker exec -i "$SQL_CONTAINER" "$SQLCMD_BIN" -S localhost -U sa -P "$SA_PASSWORD" -C -h -1 -W -d "$DB_NAME" \
      -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM dbo.__MigrationHistory WHERE ScriptName='$key';" 2>/dev/null | tr -d ' \r\n' || true)"
    if [ "${applied:-0}" != "0" ]; then echo "  SKIP (applied): $key"; continue; fi
    echo "  APPLY: $key"
    sql_file "$f"
    sql_q -d "$DB_NAME" -Q "INSERT INTO dbo.__MigrationHistory (ScriptName) VALUES ('$key');"
  done
}

# --- tables with explicit ordering --------------------------------------------
# create_table_scripts.sql contains the core tables (Appointments, etc.) that
# all other table scripts reference via FK.  Running alphabetically would put
# create_chat_tables / create_prescription_tables before it → FK errors.
# Order: core first → extended (sorted) → zz_foreign_keys last → DML scripts
run_tables_folder() {
  local dir="$DEPLOY_DIR/schema/tables"
  [ -d "$dir" ] || { echo "SKIP (missing): TABLES"; return 0; }
  echo "==> TABLES"

  # 1. Core tables — everything else depends on these
  for core in create_table_scripts.sql create_table_nightjob.sql; do
    local f="$dir/$core"
    [ -f "$f" ] || continue
    echo "  RUN (core): $core"; sql_file "$f"
  done

  # 2. Extended tables — sorted, skip core files and deferred files
  for f in $(ls "$dir"/*.sql 2>/dev/null | sort); do
    local base; base="$(basename "$f")"
    case "$base" in
      create_table_scripts.sql|create_table_nightjob.sql|\
      create_tables_zz_foreign_keys.sql|\
      dml_scripts.sql|dml_nightJob_scripts.sql) continue ;;
    esac
    echo "  RUN: ${f#$DEPLOY_DIR/}"; sql_file "$f"
  done

  # 3. Foreign keys — must be after ALL tables exist
  local fk="$dir/create_tables_zz_foreign_keys.sql"
  if [ -f "$fk" ]; then
    echo "  RUN (fk-last): create_tables_zz_foreign_keys.sql"; sql_file "$fk"
  fi

  # 4. DML embedded with schema
  for dml in dml_scripts.sql dml_nightJob_scripts.sql; do
    local f="$dir/$dml"
    [ -f "$f" ] || continue
    echo "  RUN (dml): $dml"; sql_file "$f"
  done
}

# --- pipeline order ------------------------------------------------------------
run_folder       "$DEPLOY_DIR/schema"         "SCHEMA root"
run_tables_folder
run_migrations
run_folder    "$DEPLOY_DIR/schema/indexes" "INDEXES"
run_folder    "$DEPLOY_DIR/schema/views"   "VIEWS"
run_folder    "$DEPLOY_DIR/schema/procs"   "PROCS"
run_folder    "$DEPLOY_DIR/data/seed"      "SEED"

echo "==> Deploy completed."
sql_q -d "$DB_NAME" -W -Q "SELECT COUNT(*) AS Tables FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';"
