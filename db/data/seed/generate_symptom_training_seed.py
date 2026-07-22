# -*- coding: utf-8 -*-
"""
One-off generator: reads the NLP router's Hinglish_Symptoms_Reference_v2.csv and emits
seed_symptom_training_examples.sql (idempotent — guarded so it only seeds once, since this
table becomes CMS-editable immediately after and re-running this must never clobber edits).

Run once, from this directory:
    python generate_symptom_training_seed.py /path/to/Hinglish_Symptoms_Reference_v2.csv
"""
import csv
import sys
from pathlib import Path

OUT_PATH = Path(__file__).parent / "seed_symptom_training_examples.sql"


def sql_escape(value: str) -> str:
    return value.replace("'", "''")


def main():
    if len(sys.argv) != 2:
        print("Usage: python generate_symptom_training_seed.py <path-to-csv>", file=sys.stderr)
        sys.exit(1)

    csv_path = Path(sys.argv[1])
    with open(csv_path, newline="", encoding="utf-8-sig") as f:
        rows = list(csv.DictReader(f))

    values_lines = []
    for row in rows:
        text = (row.get("text") or "").strip()
        specialist = (row.get("specialist") or "").strip()
        row_type = (row.get("type") or "").strip()
        if not text or not specialist:
            continue
        type_sql = f"N'{sql_escape(row_type)}'" if row_type else "NULL"
        values_lines.append(f"    (N'{sql_escape(text)}', N'{sql_escape(specialist)}', {type_sql})")

    # T-SQL caps a single VALUES row-constructor list at 1000 rows -- batch into chunks of
    # 900 (comfortable margin) each as its own guarded INSERT.
    BATCH_SIZE = 900
    batches = [values_lines[i:i + BATCH_SIZE] for i in range(0, len(values_lines), BATCH_SIZE)]

    header = """-- One-time seed: loads the NLP router's existing training dataset into
-- dbo.SymptomTrainingExamples so CMS's new dataset editor starts from the real, already-tuned
-- data instead of empty. Guarded to run only once -- this table is CMS-editable from here on,
-- and this script must never re-seed over manual edits.
SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM dbo.SymptomTrainingExamples WHERE Source = 'Seed')
BEGIN
"""
    footer = "END\nGO\n"

    with open(OUT_PATH, "w", encoding="utf-8-sig") as f:
        f.write(header)
        for batch in batches:
            f.write("    INSERT INTO dbo.SymptomTrainingExamples (Text, Specialist, Type, Source)\n")
            f.write("    SELECT v.Text, v.Specialist, v.Type, 'Seed'\n")
            f.write("    FROM (VALUES\n")
            f.write(",\n".join(batch))
            f.write("\n    ) v(Text, Specialist, Type);\n\n")
        f.write(footer)

    print(f"Wrote {len(values_lines)} rows across {len(batches)} batch(es) to {OUT_PATH}")


if __name__ == "__main__":
    main()
