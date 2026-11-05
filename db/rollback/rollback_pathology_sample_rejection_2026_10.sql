-- Rollback for pathology_sample_rejection_2026_10.sql.
-- Deliberately does NOT drop dbo.PathologySampleRejection: it is the lab's rejection register (quality record).
-- Rolling back the API is enough; the old build never reads the table.
PRINT 'pathology_sample_rejection_2026_10: nothing to roll back (table kept on purpose).';
GO
