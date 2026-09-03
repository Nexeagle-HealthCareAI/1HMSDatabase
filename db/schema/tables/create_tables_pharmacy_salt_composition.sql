-- Pharmacy Phase 3c: normalized Molecule/SaltComposition catalog driving 1-click generic
-- substitution. Global (not per-hospital) — a composition like "Amoxicillin 500mg + Clavulanic
-- Acid 125mg" is the same everywhere, only which brands/items a hospital stocks differs.

IF OBJECT_ID('dbo.Molecule','U') IS NULL
BEGIN
  CREATE TABLE dbo.Molecule
  (
    MoleculeId  UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Molecule_Id DEFAULT NEWSEQUENTIALID(),
    Name        NVARCHAR(150)    NOT NULL,
    CreatedAt   DATETIME2(3)     NOT NULL CONSTRAINT DF_Molecule_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Molecule PRIMARY KEY CLUSTERED (MoleculeId)
  );

  CREATE UNIQUE INDEX UX_Molecule_Name ON dbo.Molecule (Name);
END
GO

IF OBJECT_ID('dbo.SaltComposition','U') IS NULL
BEGIN
  CREATE TABLE dbo.SaltComposition
  (
    SaltCompositionId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_SC_Id DEFAULT NEWSEQUENTIALID(),
    DisplayName       NVARCHAR(300)    NOT NULL,
    DosageForm        NVARCHAR(50)     NULL,
    CreatedAt         DATETIME2(3)     NOT NULL CONSTRAINT DF_SC_CreatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_SaltComposition PRIMARY KEY CLUSTERED (SaltCompositionId)
  );
END
GO

IF OBJECT_ID('dbo.SaltCompositionComponent','U') IS NULL
BEGIN
  CREATE TABLE dbo.SaltCompositionComponent
  (
    SaltCompositionComponentId UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_SCC_Id DEFAULT NEWSEQUENTIALID(),
    SaltCompositionId          UNIQUEIDENTIFIER NOT NULL,
    MoleculeId                 UNIQUEIDENTIFIER NOT NULL,
    StrengthValue              DECIMAL(10,3)    NOT NULL,
    StrengthUnit               NVARCHAR(10)     NOT NULL,

    CONSTRAINT PK_SaltCompositionComponent PRIMARY KEY CLUSTERED (SaltCompositionComponentId),
    CONSTRAINT FK_SCC_Composition FOREIGN KEY (SaltCompositionId) REFERENCES dbo.SaltComposition(SaltCompositionId),
    CONSTRAINT FK_SCC_Molecule FOREIGN KEY (MoleculeId) REFERENCES dbo.Molecule(MoleculeId)
  );

  CREATE INDEX IX_SCC_Composition ON dbo.SaltCompositionComponent (SaltCompositionId);
END
GO
