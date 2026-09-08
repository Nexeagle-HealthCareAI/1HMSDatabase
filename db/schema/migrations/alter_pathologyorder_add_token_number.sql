-- Adds PathologyOrder.TokenNumber -- a daily, per-hospital sequential token (1, 2, 3... resetting
-- every day) assigned at order creation and printed on a thermal receipt for the patient, same
-- idea as Appointments' token feature but hospital-scoped instead of per-doctor (pathology has no
-- doctor-queue concept). Separate from OrderNo, which keeps its existing lab-accession format and
-- meaning everywhere it's already used (reports, billing, detail page). See
-- create_pathology_token_queue_table.sql for the counter table that allocates this value.
IF COL_LENGTH('dbo.PathologyOrder', 'TokenNumber') IS NULL
BEGIN
  ALTER TABLE dbo.PathologyOrder
    ADD TokenNumber INT NULL;
END
GO
