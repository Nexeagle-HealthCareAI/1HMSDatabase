-- AI Agents dashboard (CMS) and the router's human-approved learning loop (2026-10-19).
-- Written by NexeagleCMSAPI (AgentMonitorController ingest endpoints, fed by 1HMS-NLP-Router's
-- hms_router/telemetry.py); read by the CMS "AI Agents" tab. Run BEFORE deploying the matching
-- NexeagleCMSAPI. Idempotent.
--
--   AgentDecisions       one row per agent decision (/route-symptom or /chat). No patient text except
--                        ReviewText, kept only for outcomes a person has to look at (no match, clarify,
--                        low confidence, emergency). Rows older than 365 days are deleted by the CMS API.
--   AgentLearningItems   the review queue: mistakes and doubtful answers. An admin approves the correct
--                        specialty (the phrase is then added to SymptomTrainingExamples) or rejects it.
--                        ModelVersionLearned is set once a promoted model was trained with it.
--   AgentModelVersions   every rebuild of the route model: validation metrics, promoted or not, and why.

IF OBJECT_ID('dbo.AgentDecisions','U') IS NULL
BEGIN
  CREATE TABLE dbo.AgentDecisions
  (
    DecisionId       UNIQUEIDENTIFIER NOT NULL,
    OccurredAt       DATETIME2(3)     NOT NULL,
    Agent            NVARCHAR(20)     NOT NULL,           -- route | chat
    Caller           NVARCHAR(50)     NULL,               -- API client name: doctordekho, whatsapp, voicerx...
    RequestId        NVARCHAR(64)     NULL,
    Decision         NVARCHAR(20)     NOT NULL,           -- answer | clarify | abstain | emergency | follow_up | recommendation
    RouteDecision    NVARCHAR(20)     NULL,
    TopSpecialtyId   NVARCHAR(60)     NULL,
    TopSpecialist    NVARCHAR(100)    NULL,               -- chat agent: specialist label
    CandidateIds     NVARCHAR(400)    NULL,               -- comma-separated
    Confidence       FLOAT            NULL,
    MatchScore       FLOAT            NULL,
    IsEmergency      BIT              NOT NULL CONSTRAINT DF_AD_IsEmergency DEFAULT 0,
    EmergencySource  NVARCHAR(20)     NULL,
    ClarifyKind      NVARCHAR(30)     NULL,
    NoMatch          BIT              NOT NULL CONSTRAINT DF_AD_NoMatch DEFAULT 0,
    Method           NVARCHAR(40)     NULL,
    UsedReasoner     BIT              NOT NULL CONSTRAINT DF_AD_UsedReasoner DEFAULT 0,
    LatencyMs        FLOAT            NULL,
    ModelVersion     NVARCHAR(60)     NULL,
    QueryLength      INT              NULL,
    QueryHash        NVARCHAR(64)     NULL,
    SessionRef       NVARCHAR(64)     NULL,
    Turn             INT              NULL,
    Degraded         NVARCHAR(200)    NULL,
    ReviewText       NVARCHAR(300)    NULL,
    Notes            NVARCHAR(400)    NULL,
    ReceivedAt       DATETIME2(3)     NOT NULL CONSTRAINT DF_AD_ReceivedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_AgentDecisions PRIMARY KEY CLUSTERED (DecisionId)
  );
  CREATE INDEX IX_AgentDecisions_OccurredAt ON dbo.AgentDecisions (OccurredAt)
    INCLUDE (Agent, Caller, Decision, TopSpecialtyId, Confidence, IsEmergency, NoMatch, UsedReasoner, LatencyMs, ModelVersion);
  CREATE INDEX IX_AgentDecisions_QueryHash ON dbo.AgentDecisions (QueryHash);
END
GO

IF OBJECT_ID('dbo.AgentLearningItems','U') IS NULL
BEGIN
  CREATE TABLE dbo.AgentLearningItems
  (
    ItemId               UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_ALI_Id DEFAULT NEWSEQUENTIALID(),
    CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_ALI_CreatedAt DEFAULT SYSUTCDATETIME(),
    LastSeenAt           DATETIME2(3)     NOT NULL CONSTRAINT DF_ALI_LastSeenAt DEFAULT SYSUTCDATETIME(),
    Occurrences          INT              NOT NULL CONSTRAINT DF_ALI_Occurrences DEFAULT 1,
    -- booking_correction | no_match | low_confidence | clarify | emergency_check | user_feedback
    Source               NVARCHAR(30)     NOT NULL,
    Agent                NVARCHAR(20)     NOT NULL,
    QueryText            NVARCHAR(500)    NOT NULL,
    QueryHash            NVARCHAR(64)     NOT NULL,
    PredictedSpecialtyId NVARCHAR(60)     NULL,
    ActualSpecialtyId    NVARCHAR(60)     NULL,           -- what the patient booked / said was right
    Confidence           FLOAT            NULL,
    ModelVersion         NVARCHAR(60)     NULL,
    Status               NVARCHAR(20)     NOT NULL CONSTRAINT DF_ALI_Status DEFAULT 'pending', -- pending | approved | rejected
    ApprovedSpecialtyId  NVARCHAR(60)     NULL,
    ReviewNote           NVARCHAR(400)    NULL,
    ReviewedBy           NVARCHAR(200)    NULL,
    ReviewedAt           DATETIME2(3)     NULL,
    TrainingExampleId    UNIQUEIDENTIFIER NULL,           -- SymptomTrainingExamples.Id created on approval
    ModelVersionLearned  NVARCHAR(60)     NULL,
    LearnedAt            DATETIME2(3)     NULL,
    CONSTRAINT PK_AgentLearningItems PRIMARY KEY CLUSTERED (ItemId)
  );
  CREATE INDEX IX_AgentLearningItems_Status ON dbo.AgentLearningItems (Status, LastSeenAt);
  CREATE INDEX IX_AgentLearningItems_Hash ON dbo.AgentLearningItems (QueryHash, Source);
  CREATE INDEX IX_AgentLearningItems_TrainingExample ON dbo.AgentLearningItems (TrainingExampleId) WHERE TrainingExampleId IS NOT NULL;
END
GO

IF OBJECT_ID('dbo.AgentModelVersions','U') IS NULL
BEGIN
  CREATE TABLE dbo.AgentModelVersions
  (
    Id                 UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_AMV_Id DEFAULT NEWSEQUENTIALID(),
    ModelVersion       NVARCHAR(60)     NULL,             -- NULL when the rebuild failed
    PreviousVersion    NVARCHAR(60)     NULL,
    BuiltAt            DATETIME2(3)     NOT NULL,
    TriggerReason      NVARCHAR(30)     NULL,             -- manual | deploy
    Promoted           BIT              NOT NULL,
    Verdict            NVARCHAR(1000)   NULL,
    TrainingRows       INT              NULL,
    CmsRows            INT              NULL,
    LearnedItems       INT              NULL,             -- approved review items first included in this version
    ValidationRows     INT              NULL,
    Top1               FLOAT            NULL,
    Top3               FLOAT            NULL,
    Answered           FLOAT            NULL,
    AnsweredAccuracy   FLOAT            NULL,
    ConfidentlyWrong   FLOAT            NULL,
    Abstain            FLOAT            NULL,
    Clarify            FLOAT            NULL,
    EmergencyFlagRate  FLOAT            NULL,
    PrevTop1           FLOAT            NULL,
    PrevConfidentlyWrong FLOAT          NULL,
    DetailsJson        NVARCHAR(MAX)    NULL,
    CONSTRAINT PK_AgentModelVersions PRIMARY KEY CLUSTERED (Id)
  );
  CREATE INDEX IX_AgentModelVersions_BuiltAt ON dbo.AgentModelVersions (BuiltAt);
END
GO
