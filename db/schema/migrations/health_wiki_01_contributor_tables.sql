-- =============================================================================
-- Migration: Health Wiki, part 1 of 3 - contributors, access links, OTP, sessions.
-- Description: A contributor is anyone who writes or reviews a Health Wiki article. Hospital doctors link to
--              dbo.Doctors through DoctorId; independent doctors, health workers and writers have no EasyHMS
--              login, so they live only here and sign in with a WhatsApp OTP (ContributorOtp -> ContributorSession).
--              HealthArticleAccessLink holds the single-use invitation links the CMS sends over WhatsApp.
--              Mobile numbers are stored as 10 digits, are never exposed publicly, and codes/tokens are stored hashed.
--              Guarded and idempotent. Part 2 reworks dbo.HealthArticle, part 3 adds reviews, topics and statistics.
-- =============================================================================
IF OBJECT_ID('dbo.HealthWikiContributor', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthWikiContributor (
        ContributorId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWContributor_Id DEFAULT NEWSEQUENTIALID(),
        [Type]               NVARCHAR(20)     NOT NULL,
        FullName             NVARCHAR(200)    NOT NULL,
        Mobile               NVARCHAR(10)     NULL,
        Email                NVARCHAR(200)    NULL,
        PhotoUrl             NVARCHAR(500)    NULL,
        Bio                  NVARCHAR(1000)   NULL,
        Speciality           NVARCHAR(150)    NULL,
        Qualification        NVARCHAR(200)    NULL,
        RegistrationNumber   NVARCHAR(50)     NULL,
        RegistrationCouncil  NVARCHAR(150)    NULL,
        RegistrationYear     INT              NULL,
        RoleTitle            NVARCHAR(150)    NULL,
        Organisation         NVARCHAR(200)    NULL,
        FieldOfWork          NVARCHAR(300)    NULL,
        [Status]             NVARCHAR(10)     NOT NULL CONSTRAINT DF_HWContributor_Status DEFAULT 'PENDING',
        RejectReason         NVARCHAR(500)    NULL,
        EnrolmentSource      NVARCHAR(15)     NOT NULL CONSTRAINT DF_HWContributor_Source DEFAULT 'SELF_ENROLLED',
        DoctorId             UNIQUEIDENTIFIER NULL,
        ConsentAt            DATETIME2(3)     NULL,
        ConsentVersion       NVARCHAR(20)     NULL,
        VerifiedAt           DATETIME2(3)     NULL,
        VerifiedBy           NVARCHAR(200)    NULL,
        LinkSentAt           DATETIME2(3)     NULL,
        CreatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_HWContributor_CreatedAt DEFAULT SYSUTCDATETIME(),
        UpdatedAt            DATETIME2(3)     NOT NULL CONSTRAINT DF_HWContributor_UpdatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWContributor PRIMARY KEY CLUSTERED (ContributorId),
        CONSTRAINT CK_HWContributor_Type CHECK ([Type] IN ('HOSPITAL_DOCTOR','INDEPENDENT_DOCTOR','HEALTH_WORKER','WRITER','STAFF')),
        CONSTRAINT CK_HWContributor_Status CHECK ([Status] IN ('INVITED','PENDING','VERIFIED','REJECTED')),
        CONSTRAINT CK_HWContributor_Source CHECK (EnrolmentSource IN ('INVITED','SELF_ENROLLED')),
        CONSTRAINT CK_HWContributor_Mobile CHECK (Mobile IS NULL OR (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%')),
        -- A doctor is never VERIFIED without the registration the public badge prints.
        CONSTRAINT CK_HWContributor_DoctorReg CHECK (
            [Type] NOT IN ('HOSPITAL_DOCTOR','INDEPENDENT_DOCTOR') OR [Status] <> 'VERIFIED'
            OR (RegistrationNumber IS NOT NULL AND RegistrationCouncil IS NOT NULL)),
        CONSTRAINT CK_HWContributor_HospitalLink CHECK ([Type] <> 'HOSPITAL_DOCTOR' OR DoctorId IS NOT NULL),
        CONSTRAINT FK_HWContributor_Doctor FOREIGN KEY (DoctorId) REFERENCES dbo.Doctors(DoctorID)
    );
END
GO

-- One person, one number: a mobile can belong to a single contributor.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWContributor_Mobile' AND object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    CREATE UNIQUE INDEX UX_HWContributor_Mobile ON dbo.HealthWikiContributor (Mobile) WHERE Mobile IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWContributor_Doctor' AND object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    CREATE UNIQUE INDEX UX_HWContributor_Doctor ON dbo.HealthWikiContributor (DoctorId) WHERE DoctorId IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWContributor_Status' AND object_id = OBJECT_ID('dbo.HealthWikiContributor'))
    CREATE INDEX IX_HWContributor_Status ON dbo.HealthWikiContributor ([Status], [Type], CreatedAt DESC);
GO

-- Invitation links sent over WhatsApp. Only the SHA-256 of the token is stored.
-- ArticleId is null for a JOIN link (invite to enrol, no article yet); the FK to dbo.HealthArticle is added in part 2.
IF OBJECT_ID('dbo.HealthArticleAccessLink', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.HealthArticleAccessLink (
        LinkId           UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWLink_Id DEFAULT NEWSEQUENTIALID(),
        TokenHash        CHAR(64)         NOT NULL,
        [Role]           NVARCHAR(10)     NOT NULL,
        ArticleId        UNIQUEIDENTIFIER NULL,
        ContributorId    UNIQUEIDENTIFIER NULL,
        InviteeName      NVARCHAR(200)    NULL,
        Mobile           NVARCHAR(10)     NOT NULL,
        CreatedByName    NVARCHAR(200)    NULL,
        ExpiresAt        DATETIME2(3)     NOT NULL,
        UsedAt           DATETIME2(3)     NULL,
        RevokedAt        DATETIME2(3)     NULL,
        SendCount        INT              NOT NULL CONSTRAINT DF_HWLink_Sends DEFAULT (0),
        LastSentAt       DATETIME2(3)     NULL,
        CreatedAt        DATETIME2(3)     NOT NULL CONSTRAINT DF_HWLink_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWLink PRIMARY KEY CLUSTERED (LinkId),
        CONSTRAINT CK_HWLink_Role CHECK ([Role] IN ('REVIEW','WRITE','JOIN')),
        CONSTRAINT CK_HWLink_Mobile CHECK (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%'),
        CONSTRAINT CK_HWLink_ArticleRole CHECK ([Role] = 'JOIN' OR ArticleId IS NOT NULL),
        CONSTRAINT FK_HWLink_Contributor FOREIGN KEY (ContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWLink_Token' AND object_id = OBJECT_ID('dbo.HealthArticleAccessLink'))
    CREATE UNIQUE INDEX UX_HWLink_Token ON dbo.HealthArticleAccessLink (TokenHash);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWLink_Article' AND object_id = OBJECT_ID('dbo.HealthArticleAccessLink'))
    CREATE INDEX IX_HWLink_Article ON dbo.HealthArticleAccessLink (ArticleId, [Role]) WHERE ArticleId IS NOT NULL;
GO

-- WhatsApp OTPs. Only a hash of the code is stored; Attempts caps guessing, and the index on
-- (Mobile, CreatedAt) serves the "how many codes did this number ask for lately" rate limit.
IF OBJECT_ID('dbo.ContributorOtp', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ContributorOtp (
        OtpId        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWOtp_Id DEFAULT NEWSEQUENTIALID(),
        Mobile       NVARCHAR(10)     NOT NULL,
        CodeHash     CHAR(64)         NOT NULL,
        LinkId       UNIQUEIDENTIFIER NULL,
        Attempts     INT              NOT NULL CONSTRAINT DF_HWOtp_Attempts DEFAULT (0),
        ExpiresAt    DATETIME2(3)     NOT NULL,
        ConsumedAt   DATETIME2(3)     NULL,
        RequestIp    NVARCHAR(45)     NULL,
        CreatedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_HWOtp_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWOtp PRIMARY KEY CLUSTERED (OtpId),
        CONSTRAINT CK_HWOtp_Mobile CHECK (LEN(Mobile) = 10 AND Mobile NOT LIKE '%[^0-9]%'),
        CONSTRAINT FK_HWOtp_Link FOREIGN KEY (LinkId) REFERENCES dbo.HealthArticleAccessLink(LinkId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWOtp_Mobile' AND object_id = OBJECT_ID('dbo.ContributorOtp'))
    CREATE INDEX IX_HWOtp_Mobile ON dbo.ContributorOtp (Mobile, CreatedAt DESC);
GO

-- Sign-in sessions after OTP. The browser holds an HttpOnly cookie; only its hash is stored here.
IF OBJECT_ID('dbo.ContributorSession', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.ContributorSession (
        SessionId      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_HWSession_Id DEFAULT NEWSEQUENTIALID(),
        ContributorId  UNIQUEIDENTIFIER NOT NULL,
        TokenHash      CHAR(64)         NOT NULL,
        ExpiresAt      DATETIME2(3)     NOT NULL,
        LastSeenAt     DATETIME2(3)     NULL,
        RevokedAt      DATETIME2(3)     NULL,
        CreatedAt      DATETIME2(3)     NOT NULL CONSTRAINT DF_HWSession_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_HWSession PRIMARY KEY CLUSTERED (SessionId),
        CONSTRAINT FK_HWSession_Contributor FOREIGN KEY (ContributorId) REFERENCES dbo.HealthWikiContributor(ContributorId)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HWSession_Token' AND object_id = OBJECT_ID('dbo.ContributorSession'))
    CREATE UNIQUE INDEX UX_HWSession_Token ON dbo.ContributorSession (TokenHash);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_HWSession_Contributor' AND object_id = OBJECT_ID('dbo.ContributorSession'))
    CREATE INDEX IX_HWSession_Contributor ON dbo.ContributorSession (ContributorId, ExpiresAt DESC);
GO
