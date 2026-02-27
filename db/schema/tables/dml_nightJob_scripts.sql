/* Seed JobSettings with IST date */

IF NOT EXISTS (SELECT 1 FROM dbo.JobSettings WHERE JobName = N'WhatsAppFollowUp')
BEGIN
    INSERT INTO dbo.JobSettings
    (
        JobName,
        LastExecutionDateUTC
    )
    VALUES
    (
        N'WhatsAppFollowUp',
        CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'India Standard Time' AS DATETIME2(3))
    );
END;


IF NOT EXISTS (SELECT 1 FROM dbo.JobSettings WHERE JobName = N'FutureAppointmentToPresent')
BEGIN
    INSERT INTO dbo.JobSettings
    (
        JobName,
        LastExecutionDateUTC
    )
    VALUES
    (
        N'FutureAppointmentToPresent',
        CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'India Standard Time' AS DATETIME2(3))
    );
END;