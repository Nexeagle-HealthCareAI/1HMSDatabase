-- Adds SourceType (OPD/IPD/EMERGENCY/WALK_IN) and IsStat to PathologyOrder. EncounterId/AdmissionId
-- alone don't cleanly distinguish OPD from Emergency (both can carry an EncounterId), so the
-- caller passes SourceType explicitly at order-creation time. Drives the Pathology Workspace's
-- source-filter tabs and STAT/urgent sort-to-top highlighting.
IF COL_LENGTH('dbo.PathologyOrder', 'SourceType') IS NULL
BEGIN
  ALTER TABLE dbo.PathologyOrder
    ADD SourceType NVARCHAR(20) NULL,
        IsStat BIT NOT NULL CONSTRAINT DF_PathologyOrder_IsStat DEFAULT (0);
END
GO
