-- Migration: Alter HospitalSubscriptions Table (Add Referral Code Tracking)
-- Description: Snapshotted by easyHMSAPI's HospitalRegisterHandler when a valid referral code is
--              entered at registration (RewardKind/Value are copied from CMSDatabase's
--              ReferralCodeType at that moment, so nothing needs to be re-queried later).
--              ReferralCodeRedeemedAt is set by CMSAPI's SubscriptionApprovalController when this
--              hospital's subscription is first activated on a Yearly plan -- NULL means the
--              reward hasn't landed yet, and doubles as an idempotency guard against re-applying
--              it on a later renewal/approval.

IF NOT EXISTS (
    SELECT * FROM sys.columns
    WHERE object_id = OBJECT_ID(N'[dbo].[HospitalSubscriptions]') AND name = 'ReferralCode'
)
BEGIN
    ALTER TABLE [dbo].[HospitalSubscriptions]
    ADD ReferralCode NVARCHAR(30) NULL,
        ReferralCodeRewardKind NVARCHAR(20) NULL,
        ReferralCodeRewardValue DECIMAL(10,2) NULL,
        ReferralCodeRedeemedAt DATETIME2(3) NULL;

    PRINT 'Added ReferralCode fields to HospitalSubscriptions table';
END
ELSE
BEGIN
    PRINT 'ReferralCode fields already exist in HospitalSubscriptions table';
END
GO
