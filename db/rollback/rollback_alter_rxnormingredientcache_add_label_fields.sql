IF OBJECT_ID('dbo.RxNormIngredientCache', 'U') IS NOT NULL
BEGIN
    IF COL_LENGTH('dbo.RxNormIngredientCache', 'AdverseReactionsText') IS NOT NULL
        ALTER TABLE dbo.RxNormIngredientCache DROP COLUMN AdverseReactionsText;

    IF COL_LENGTH('dbo.RxNormIngredientCache', 'IndicationsText') IS NOT NULL
        ALTER TABLE dbo.RxNormIngredientCache DROP COLUMN IndicationsText;
END
GO
