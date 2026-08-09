-- =============================================================================
-- Migration: RxNormIngredientCache label fields
-- Description: Adds IndicationsText/AdverseReactionsText, populated from the
--              FDA's openFDA Drug Label API (usage/side-effects content that
--              neither the 1mg import nor RxNorm carries) and cached
--              alongside the existing RxNorm fields in the same row, keyed by
--              the same normalized ingredient name. Guarded ALTER on the
--              already-deployed RxNormIngredientCache table.
-- =============================================================================

IF OBJECT_ID('dbo.RxNormIngredientCache', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.RxNormIngredientCache', 'IndicationsText') IS NULL
        ALTER TABLE dbo.RxNormIngredientCache ADD IndicationsText NVARCHAR(MAX) NULL;

    IF COL_LENGTH('dbo.RxNormIngredientCache', 'AdverseReactionsText') IS NULL
        ALTER TABLE dbo.RxNormIngredientCache ADD AdverseReactionsText NVARCHAR(MAX) NULL;
END
GO
