/* ============================================
   ROLLBACK SCRIPT FOR PRESCRIPTION MODULE TABLES
   Drops tables in FK-safe order
   ============================================ */

-- 1) Drop child tables that depend on Prescription
IF OBJECT_ID('dbo.PrescriptionInvestigation', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PrescriptionInvestigation;
END
GO

IF OBJECT_ID('dbo.PrescriptionMedicine', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PrescriptionMedicine;
END
GO

-- 2) Drop attachment table (depends only on Appointments, which we are NOT dropping)
IF OBJECT_ID('dbo.PrescriptionAttachment', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.PrescriptionAttachment;
END
GO

-- 3) Drop main Prescription table
IF OBJECT_ID('dbo.Prescription', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.Prescription;
END
GO

-- 4) Drop MedicineMaster (independent)
IF OBJECT_ID('dbo.MedicineMaster', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.MedicineMaster;
END
GO
