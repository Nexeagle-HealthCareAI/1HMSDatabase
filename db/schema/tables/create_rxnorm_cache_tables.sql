/* =========================================================
   dbo.RxNormIngredientCache
   Persistent cache of RxNav (RxNorm) lookups, keyed by normalized
   ingredient/salt name. Populated on demand by the "medicine info"
   enrichment endpoint - avoids re-querying NLM's public API for every
   request against a generic name we've already resolved (only a few
   thousand distinct ingredients exist across the whole medicine catalog).
   Found=0 rows cache negative lookups too, for the same reason.
   ========================================================= */
IF OBJECT_ID('dbo.RxNormIngredientCache', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.RxNormIngredientCache (
        IngredientName   VARCHAR(200)   NOT NULL,  -- normalized (trimmed, lowercased) lookup key
        RxCui            VARCHAR(20)    NULL,       -- NULL when RxNorm has no match
        DisplayName      VARCHAR(200)   NULL,       -- name RxNorm actually matched under (may differ, e.g. "Acetaminophen")
        RelatedFormsJson NVARCHAR(MAX)  NULL,        -- cached JSON array of available SCD forms/strengths
        Found            BIT            NOT NULL,

        FetchedAtUtc     DATETIME2(3)   NOT NULL
            CONSTRAINT DF_RxNormIngredientCache_FetchedAtUtc DEFAULT (SYSUTCDATETIME()),

        CONSTRAINT PK_RxNormIngredientCache PRIMARY KEY CLUSTERED (IngredientName)
    );
END
GO
