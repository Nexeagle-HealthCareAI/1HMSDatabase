-- CK_IND_Status was created before ISSUED/PARTIALLY_ISSUED existed as Indent statuses (added by
-- alter_indent_internal_workflow.sql for internal store-to-store transfers via IssueIndent). The
-- constraint was never updated, so every dispatch of an internal request fails at SaveChangesAsync
-- with a generic "An error occurred while saving the entity changes" (CHECK constraint violation)
-- - found live-testing the pharmacy request/dispatch feature.

IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_IND_Status' AND parent_object_id = OBJECT_ID('dbo.Indent'))
BEGIN
  ALTER TABLE dbo.Indent DROP CONSTRAINT CK_IND_Status;
END
GO

ALTER TABLE dbo.Indent ADD CONSTRAINT CK_IND_Status
  CHECK ([Status] IN ('DRAFT','SUBMITTED','APPROVED','REJECTED','CONVERTED_TO_PO','PARTIALLY_ISSUED','ISSUED','CANCELLED'));
GO
