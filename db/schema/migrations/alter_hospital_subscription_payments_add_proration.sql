-- Migration: Alter HospitalSubscriptionPayments Table (Add Proration Fields)
-- Description: Supports mid-cycle plan switches (upgrade/downgrade) from the EasyHMS
--              subscription page. When an already-Active hospital switches plans, the unused
--              days on their current plan are credited (prorated off what they actually paid)
--              against the new plan's price. These columns record that breakdown on the payment
--              row so CMS can see/verify it before approving, instead of just a bare Amount.

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[HospitalSubscriptionPayments]') AND name = 'PreviousPlanId'
)
BEGIN
    ALTER TABLE [dbo].[HospitalSubscriptionPayments]
    ADD PreviousPlanId UNIQUEIDENTIFIER NULL,
        PreviousPlanName NVARCHAR(200) NULL,
        ProratedCreditAmount DECIMAL(18,2) NULL,
        IsProratedSwitch BIT NOT NULL CONSTRAINT DF_HospitalSubscriptionPayments_IsProratedSwitch DEFAULT (0);

    PRINT 'Added proration fields to HospitalSubscriptionPayments table';
END
ELSE
BEGIN
    PRINT 'Proration fields already exist in HospitalSubscriptionPayments table';
END
GO
