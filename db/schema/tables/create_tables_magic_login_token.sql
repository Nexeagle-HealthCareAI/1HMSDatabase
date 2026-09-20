-- One-tap "magic link" sign-in for staff notification messages (WhatsApp / email). A link carries
-- a random token; only its SHA-256 hash is stored here, so a database read never yields a usable
-- link. Each token is bound to ONE user + ONE hospital + ONE in-app landing path, is single-use
-- (ConsumedAt), and expires (ExpiresAt). Redeemed by POST auth/magic-link/exchange in easyHMSAPI.
-- Rows past their expiry are pruned opportunistically by the API when it creates new links.
IF OBJECT_ID('dbo.MagicLoginToken','U') IS NULL
BEGIN
  CREATE TABLE dbo.MagicLoginToken
  (
    TokenId      UNIQUEIDENTIFIER NOT NULL
      CONSTRAINT DF_MagicLoginToken_Id DEFAULT NEWSEQUENTIALID(),

    -- Lower-case hex SHA-256 of the raw token (64 chars). The raw token is never persisted.
    TokenHash    CHAR(64)         NOT NULL,

    UserId       UNIQUEIDENTIFIER NOT NULL,
    HospitalId   UNIQUEIDENTIFIER NOT NULL,

    -- In-app route the recipient lands on after sign-in (always a relative path, validated by the API).
    TargetPath   NVARCHAR(200)    NOT NULL,
    -- What produced the link, e.g. 'ONLINE_APPOINTMENT_REQUEST'. Audit/diagnostics only.
    Purpose      NVARCHAR(60)     NOT NULL,

    CreatedAt    DATETIME2(3)     NOT NULL CONSTRAINT DF_MagicLoginToken_CreatedAt DEFAULT SYSUTCDATETIME(),
    ExpiresAt    DATETIME2(3)     NOT NULL,

    -- Set when the link is redeemed. NULL = still usable (until ExpiresAt).
    ConsumedAt   DATETIME2(3)     NULL,
    ConsumedIp   NVARCHAR(64)     NULL,

    -- Optimistic-concurrency token: two simultaneous redemptions of the same link cannot both win.
    RowVersion   ROWVERSION       NOT NULL,

    CONSTRAINT PK_MagicLoginToken PRIMARY KEY CLUSTERED (TokenId)
  );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_MagicLoginToken_TokenHash' AND object_id=OBJECT_ID('dbo.MagicLoginToken'))
BEGIN
  CREATE UNIQUE INDEX UX_MagicLoginToken_TokenHash
  ON dbo.MagicLoginToken(TokenHash);
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_MagicLoginToken_ExpiresAt' AND object_id=OBJECT_ID('dbo.MagicLoginToken'))
BEGIN
  CREATE INDEX IX_MagicLoginToken_ExpiresAt
  ON dbo.MagicLoginToken(ExpiresAt);
END
GO
