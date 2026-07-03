-- Billing phase.
-- Best-effort treating-doctor attribution for consultant incentive accrual. Populated by the
-- caller (CPOE: ClinicalOrder.OrderedByDoctorId; OT: SurgeryCase.SurgeonDoctorId) when known —
-- left NULL otherwise, same soft-link convention as ClinicalOrder.OrderedByDoctorId (no FK).

IF COL_LENGTH('dbo.BillingChargeEvent','AttributedDoctorId') IS NULL
  ALTER TABLE dbo.BillingChargeEvent ADD AttributedDoctorId UNIQUEIDENTIFIER NULL;
GO
