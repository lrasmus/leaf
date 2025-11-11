/**
 * Update version
 */
UPDATE ref.[Version]
SET [Version] = '3.11.4.1'
GO

/**
 * Add [LastUpdated] to network.[Identity]
 */
IF COLUMNPROPERTY(OBJECT_ID('network.[Identity]'), 'LastUpdated', 'ColumnId') IS NULL
BEGIN
    ALTER TABLE [network].[Identity]
    ADD [LastUpdated] NVARCHAR(50) NULL;
END
GO


IF OBJECT_ID('network.sp_GetIdentity', 'P') IS NOT NULL
    DROP PROCEDURE [network].[sp_GetIdentity];
GO


-- =======================================
-- Author:      Matthew Baumann
-- Create date: 2025/11/5
-- Description: Returns the network.Identity
-- =======================================
CREATE PROCEDURE [network].[sp_GetIdentity]
AS
BEGIN
    SET NOCOUNT ON

    SELECT
        [Name],
        Abbreviation,
        [Description],
        TotalPatients,
        Latitude,
        Longitude,
        PrimaryColor,
        SecondaryColor,
        LastUpdated
    FROM network.[Identity];
END
GO

IF OBJECT_ID('adm.sp_UpsertIdentity', 'P') IS NOT NULL
    DROP PROCEDURE [adm].[sp_UpsertIdentity];
GO

-- =======================================
-- Author:      Matthew Baumann
-- Create date: 2025/11/5
-- Description: Inserts or updates network.Identity.
-- =======================================
CREATE PROCEDURE [adm].[sp_UpsertIdentity]
    @name nvarchar(300),
    @abbr nvarchar(20),
    @desc nvarchar(4000),
    @totalPatients int,
    @lat DECIMAL(7,4),
    @lng DECIMAL(7,4),
    @primColor nvarchar(40),
    @secColor nvarchar(40),
    @lastUpdated nvarchar(50),
    @user auth.[User]
AS
BEGIN
    SET NOCOUNT ON

    IF (app.fn_NullOrWhitespace(@name) = 1)
        THROW 70400, N'NetworkIdentity.Name is required.', 1;

    BEGIN TRAN;

    IF EXISTS (SELECT Lock FROM network.[Identity])
    BEGIN;
        UPDATE network.[Identity]
        SET
            [Name] = @name,
            Abbreviation = @abbr,
            [Description] = @desc,
            TotalPatients = @totalPatients,
            Latitude = @lat,
            Longitude = @lng,
            PrimaryColor = @primColor,
            SecondaryColor = @secColor,
            LastUpdated = @lastUpdated
        OUTPUT
            inserted.Name,
            inserted.Abbreviation,
            inserted.[Description],
            inserted.TotalPatients,
            inserted.Latitude,
            inserted.Longitude,
            inserted.PrimaryColor,
            inserted.SecondaryColor,
            inserted.LastUpdated;
    END;
    ELSE
    BEGIN;
        INSERT INTO network.[Identity] ([Name], Abbreviation, [Description], TotalPatients, Latitude, Longitude, PrimaryColor, SecondaryColor, LastUpdated)
        OUTPUT inserted.Name, inserted.Abbreviation, inserted.[Description], inserted.TotalPatients, inserted.Latitude, inserted.Longitude, inserted.PrimaryColor, inserted.SecondaryColor, inserted.LastUpdated
        VALUES (@name, @abbr, @desc, @totalPatients, @lat, @lng, @primColor, @secColor, @lastUpdated);
    END;

    COMMIT;
END
GO
