-- Some hospitals' NumberSeries rows were saved with junk values (e.g. prefix 'string',
-- a multi-char separator, an unrecognised year format, or an oversized pad length) — producing
-- invoice numbers like "stringstrinstrin0000000011". This normalises any such row back to clean
-- defaults (INV / RCPT / ADM / IB · YYYY · '-' · pad 6) while PRESERVING CurrentValue so the
-- running sequence is not disturbed. Idempotent: only rewrites fields that are actually invalid.
UPDATE dbo.NumberSeries
SET
    YearFormat = CASE WHEN YearFormat IN ('YYYY', 'YY', 'YYYYMM', 'OFF') THEN YearFormat ELSE 'YYYY' END,
    Separator  = CASE WHEN Separator IS NULL OR LEN(Separator) > 1 THEN '-' ELSE Separator END,
    PadLength  = CASE WHEN PadLength BETWEEN 1 AND 10 THEN PadLength ELSE 6 END,
    Prefix     = CASE
                    WHEN Prefix IS NULL OR Prefix = '' OR Prefix LIKE 'string%' OR LEN(Prefix) > 12
                    THEN CASE SeriesCode
                            WHEN 'RCPT' THEN 'RCPT'
                            WHEN 'ADM'  THEN 'ADM'
                            WHEN 'IB'   THEN 'IB'
                            ELSE 'INV'
                         END
                    ELSE Prefix
                 END
WHERE SeriesCode IN ('INV', 'RCPT', 'ADM', 'IB')
  AND (
        YearFormat NOT IN ('YYYY', 'YY', 'YYYYMM', 'OFF')
     OR Separator IS NULL OR LEN(Separator) > 1
     OR PadLength NOT BETWEEN 1 AND 10
     OR Prefix IS NULL OR Prefix = '' OR Prefix LIKE 'string%' OR LEN(Prefix) > 12
  );
GO
