-- Training data for the Hinglish symptom -> specialist NLP router (see 1HMS-NLP-Router
-- repo). This is the LIVE, CMS-editable source of truth for the training set — the
-- deployed model itself still reads a git-committed CSV; the offline retrain pipeline is
-- the only thing that reads this table, regenerating that CSV from whatever is IsActive=1
-- here plus correlated production feedback (see dbo.AnalyticsEvents' search_performed /
-- booking_step_reached events) before retraining.
IF OBJECT_ID('dbo.SymptomTrainingExamples','U') IS NULL
BEGIN
  CREATE TABLE dbo.SymptomTrainingExamples
  (
    Id            UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_STE_Id DEFAULT NEWSEQUENTIALID(),

    Text          NVARCHAR(500)    NOT NULL,
    -- One of the 32 canonical patient-facing specialist labels the router outputs (see
    -- MODEL_OUTPUT_MERGES / LABEL_TO_NEXEAGLE_SPECIALTY_ID in the NLP repo) — not
    -- validated against a lookup table here since the taxonomy lives in that repo's code,
    -- not the DB; CMSAPI validates against the same fixed list before insert/update.
    Specialist    NVARCHAR(100)    NOT NULL,
    -- Provenance tag (Original / Specialist Term / Keyword Phrase / Spelling Variation of: .../
    -- Variation of: ... / Production Feedback - Correction / Production Feedback - Accepted /
    -- Manual Edit) — free-form, same convention the CSV's own "type" column already used.
    Type          NVARCHAR(200)    NULL,
    -- How this row entered the table.
    Source        NVARCHAR(50)     NOT NULL CONSTRAINT DF_STE_Source DEFAULT 'Seed',

    IsActive      BIT              NOT NULL CONSTRAINT DF_STE_IsActive DEFAULT 1,
    CreatedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_STE_CreatedAt DEFAULT SYSUTCDATETIME(),
    UpdatedAt     DATETIME2(3)     NOT NULL CONSTRAINT DF_STE_UpdatedAt DEFAULT SYSUTCDATETIME(),
    -- CMS username, when a person (not the seed import or the feedback pipeline) added/edited
    -- this row.
    CreatedBy     NVARCHAR(100)    NULL,

    CONSTRAINT PK_SymptomTrainingExamples PRIMARY KEY CLUSTERED (Id)
  );

  CREATE INDEX IX_SymptomTrainingExamples_Specialist ON dbo.SymptomTrainingExamples (Specialist) WHERE IsActive = 1;
  CREATE INDEX IX_SymptomTrainingExamples_Source ON dbo.SymptomTrainingExamples (Source);
END
GO
