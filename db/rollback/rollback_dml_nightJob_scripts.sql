/* =========================================================
   ROLLBACK: Remove seeded JobSettings entries
   Safe to run multiple times
   ========================================================= */

DELETE FROM dbo.JobSettings
WHERE JobName IN
(
    N'WhatsAppFollowUp',
    N'FutureAppointmentToPresent'
);