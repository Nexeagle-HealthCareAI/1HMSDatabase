/* =========================================================
   easyHMS – Live Chat Tables
   ========================================================= */
SET NOCOUNT ON;
SET XACT_ABORT ON;

IF OBJECT_ID('dbo.SupportSessions', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportSessions (
        SessionId      UNIQUEIDENTIFIER NOT NULL 
            CONSTRAINT PK_SupportSessions PRIMARY KEY
            CONSTRAINT DF_SupportSessions_Id DEFAULT NEWID(),
        
        GuestId        NVARCHAR(100)    NOT NULL, -- For persisting session in localStorage
        GuestName      NVARCHAR(100)    NULL,
        GuestEmail     NVARCHAR(150)    NULL,
        
        Status         NVARCHAR(20)     NOT NULL 
            CONSTRAINT DF_SupportSessions_Status DEFAULT 'Active', -- Active, Closed
            
        StartedAt      DATETIME2(3)     NOT NULL 
            CONSTRAINT DF_SupportSessions_StartedAt DEFAULT SYSUTCDATETIME(),
        ClosedAt       DATETIME2(3)     NULL
    );
    
    CREATE INDEX IX_SupportSessions_GuestId ON dbo.SupportSessions(GuestId);
END
GO

IF OBJECT_ID('dbo.SupportMessages', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SupportMessages (
        MessageId      UNIQUEIDENTIFIER NOT NULL 
            CONSTRAINT PK_SupportMessages PRIMARY KEY
            CONSTRAINT DF_SupportMessages_Id DEFAULT NEWID(),
        
        SessionId      UNIQUEIDENTIFIER NOT NULL,
        
        SenderType     NVARCHAR(20)     NOT NULL, -- 'Guest', 'Agent'
        SenderId       NVARCHAR(100)    NULL,     -- UserID for agents, GuestId for guests
        
        MessageText    NVARCHAR(MAX)    NOT NULL,
        
        SentAt         DATETIME2(3)     NOT NULL 
            CONSTRAINT DF_SupportMessages_SentAt DEFAULT SYSUTCDATETIME(),
            
        CONSTRAINT FK_SupportMessages_Session FOREIGN KEY (SessionId) 
            REFERENCES dbo.SupportSessions(SessionId) ON DELETE CASCADE
    );
    
    CREATE INDEX IX_SupportMessages_SessionId ON dbo.SupportMessages(SessionId);
END
GO

PRINT N'Chat tables created successfully.';
