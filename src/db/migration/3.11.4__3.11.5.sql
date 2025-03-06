/**
 * Update version
 */
UPDATE ref.[Version]
SET [Version] = '3.11.5'
GO


/**
 * Add [IsQueryable] to app.Concept
 * Default all concepts to queryable, to preserve existing behavior.
 */
IF COLUMNPROPERTY(OBJECT_ID('app.Concept'), 'IsQueryable', 'ColumnId') IS NULL
BEGIN
    ALTER TABLE app.Concept 
    ADD [IsQueryable] BIT NULL
END  
GO

IF (SELECT COUNT(*) FROM app.Concept WHERE IsQueryable IS NULL) > 0
BEGIN
    UPDATE app.Concept
    SET [IsQueryable] = 1
    WHERE IsQueryable IS NULL
END  
GO

-- Recreate HydratedConceptTable with IsQueryable
IF TYPE_ID('[app].[HydratedConceptTable]') IS NOT NULL
	DROP TYPE [auth].[ResourceConstraintTable];
GO
/****** Object:  UserDefinedTableType [app].[HydratedConceptTable]    Script Date: ******/
CREATE TYPE [app].[HydratedConceptTable] AS TABLE(
	[Id] [uniqueidentifier] NOT NULL,
	[ParentId] [uniqueidentifier] NULL,
	[RootId] [uniqueidentifier] NULL,
	[ExternalId] [nvarchar](200) NULL,
	[ExternalParentId] [nvarchar](200) NULL,
	[UniversalId] [nvarchar](200) NULL,
	[IsNumeric] [bit] NULL,
	[IsEventBased] [bit] NULL,
	[IsParent] [bit] NULL,
	[IsEncounterBased] [bit] NULL,
	[IsPatientCountAutoCalculated] [bit] NULL,
	[IsDropdown] [bit] NULL,
	[SqlSetFrom] [nvarchar](4000) NULL,
	[SqlSetWhere] [nvarchar](1000) NULL,
	[SqlFieldDate] [nvarchar](1000) NULL,
	[SqlFieldNumeric] [nvarchar](1000) NULL,
	[SqlFieldEventId] [nvarchar](400) NULL,
	[UiDisplayName] [nvarchar](400) NULL,
	[UiDisplayText] [nvarchar](1000) NULL,
	[UiDisplayUnits] [nvarchar](50) NULL,
	[UiDisplayTooltip] [nvarchar](max) NULL,
	[UiDisplayPatientCount] [int] NULL,
	[UiDisplayPatientCountByYear] [nvarchar](max) NULL,
	[UiDropdownElements] [nvarchar](max) NULL,
	[UiDropdownDefaultText] [nvarchar](400) NULL,
	[UiNumericDefaultText] [nvarchar](50) NULL,
    [IsQueryable] [bit] NULL
	PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (IGNORE_DUP_KEY = OFF)
)
GO



/****** Object:  StoredProcedure [adm].[sp_CreateConcept]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================
-- Author:      Cliff Spital
-- Create date: 2019/3/29
-- Description: Creates an app.Concept along with auth.ConceptConstraint and rela.ConceptSpecializationGroup.
-- =======================================
ALTER PROCEDURE [adm].[sp_CreateConcept]
    @universalId nvarchar(200),
    @parentId uniqueidentifier,
    @rootId uniqueidentifier,
    @externalId nvarchar(200),
    @externalParentId nvarchar(200),
    @isPatientCountAutoCalculated bit,
    @isNumeric bit,
    @isParent bit,
    @isRoot bit,
    @isSpecializable bit,
    @sqlSetId int,
    @sqlSetWhere nvarchar(1000),
    @sqlFieldNumeric nvarchar(1000),
    @uiDisplayName nvarchar(400),
    @uiDisplayText nvarchar(1000),
    @uiDisplaySubtext nvarchar(100),
	@uiDisplayUnits nvarchar(50),
	@uiDisplayTooltip nvarchar(max),
	@uiDisplayPatientCount int,
	@uiNumericDefaultText nvarchar(50),
    @constraints auth.ResourceConstraintTable READONLY,
    @specializationGroups rela.ConceptSpecializationGroupTable READONLY,
    @user auth.[User],
    -- By default concepts are queryable.  This provides consistency with
    -- how Leaf has worked since its creation.
    @isQueryable bit = 1
AS
BEGIN
    SET NOCOUNT ON

    IF (@parentId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM app.Concept WHERE Id = @parentId))
    BEGIN;
        THROW 70404, N'Parent concept not found.', 1;
    END;

    IF (@rootId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM app.Concept WHERE Id = @rootId))
    BEGIN;
        THROW 70404, N'Root concept not found.', 1;
    END;

    IF ((SELECT COUNT(*) FROM app.SpecializationGroup WHERE Id IN (SELECT SpecializationGroupId FROM @specializationGroups)) != (SELECT COUNT(*) FROM @specializationGroups))
    BEGIN;
        THROW 70404, N'SpecializationGroup not found.', 1;
    END;

    BEGIN TRAN;
    BEGIN TRY
        DECLARE @ids app.ResourceIdTable;

        INSERT INTO app.Concept (
            UniversalId,
            ParentId,
            RootId,
            ExternalId,
            ExternalParentId,
            IsPatientCountAutoCalculated,
            [IsNumeric],
            IsParent,
            IsRoot,
            IsSpecializable,
            SqlSetId,
            SqlSetWhere,
            SqlFieldNumeric,
            UiDisplayName,
            UiDisplayText,
            UiDisplaySubtext,
            UiDisplayUnits,
            UiDisplayTooltip,
            UiDisplayPatientCount,
            UiNumericDefaultText,
            ContentLastUpdateDateTime,
            PatientCountLastUpdateDateTime,
            IsQueryable
        )
        OUTPUT inserted.Id INTO @ids
        SELECT
            UniversalId = @universalId,
            ParentId = @parentId,
            RootId = @rootId,
            ExternalId = @externalId,
            ExternalParentId = @externalParentId,
            IsPatientCountAutoCalculated = @isPatientCountAutoCalculated,
            [IsNumeric] = @isNumeric,
            IsParent = @isParent,
            IsRoot = @isRoot,
            IsSpecializable = @isSpecializable,
            SqlSetId = @sqlSetId,
            SqlSetWhere = @sqlSetWhere,
            SqlFieldNumeric = @sqlFieldNumeric,
            UiDisplayName = @uiDisplayName,
            UiDisplayText = @uiDisplayText,
            UiDisplaySubtext = @uiDisplaySubtext,
            UiDisplayUnits = @uiDisplayUnits,
            UiDisplayTooltip = @uiDisplayTooltip,
            UiDisplayPatientCount = @uiDisplayPatientCount,
            UiNumericDefaultText = @uiNumericDefaultText,
            ContentLastUpdateDateTime = GETDATE(),
            PatientCountLastUpdateDateTime = GETDATE(),
            IsQueryable = @isQueryable

        DECLARE @id UNIQUEIDENTIFIER;
        SELECT TOP 1 @id = Id FROM @ids;

        INSERT INTO auth.ConceptConstraint
        SELECT @id, ConstraintId, ConstraintValue
        FROM @constraints;

        INSERT INTO rela.ConceptSpecializationGroup
        SELECT @id, SpecializationGroupId, OrderId
        FROM @specializationGroups;

		IF (@isRoot = 1)
		BEGIN
			UPDATE app.Concept
			SET RootId = @id
			WHERE Id = @id
		END

        COMMIT;

        EXEC adm.sp_GetConceptById @id;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END
GO

/****** Object:  StoredProcedure [adm].[sp_UpdateConcept]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =======================================
-- Author:      Cliff Spital
-- Create date: 2019/3/29
-- Description: Updates an app.Concept along with auth.ConceptConstraint and rela.ConceptSpecializationGroup.
-- =======================================
ALTER PROCEDURE [adm].[sp_UpdateConcept]
    @id uniqueidentifier,
    @universalId nvarchar(200),
    @parentId uniqueidentifier,
    @rootId uniqueidentifier,
    @externalId nvarchar(200),
    @externalParentId nvarchar(200),
    @isPatientCountAutoCalculated bit,
    @isNumeric bit,
    @isParent bit,
    @isRoot bit,
    @isSpecializable bit,
    @sqlSetId int,
    @sqlSetWhere nvarchar(1000),
    @sqlFieldNumeric nvarchar(1000),
    @uiDisplayName nvarchar(400),
    @uiDisplayText nvarchar(1000),
    @uiDisplaySubtext nvarchar(100),
	@uiDisplayUnits nvarchar(50),
	@uiDisplayTooltip nvarchar(max),
	@uiDisplayPatientCount int,
	@uiNumericDefaultText nvarchar(50),
    @constraints auth.ResourceConstraintTable READONLY,
    @specializationGroups rela.ConceptSpecializationGroupTable READONLY,
    @user auth.[User],
    -- By default concepts are queryable.  This provides consistency with
    -- how Leaf has worked since its creation.
    @isQueryable bit = 1
AS
BEGIN
    SET NOCOUNT ON

    IF NOT EXISTS(SELECT 1 FROM app.Concept WHERE Id = @id)
    BEGIN;
        THROW 70404, N'Concept not found.', 1;
    END;

    IF (@parentId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM app.Concept WHERE Id = @parentId))
    BEGIN;
        THROW 70404, N'Parent concept not found.', 1;
    END;

    IF (@rootId IS NOT NULL AND NOT EXISTS(SELECT 1 FROM app.Concept WHERE Id = @rootId))
    BEGIN;
        THROW 70404, N'Root concept not found.', 1;
    END;

    IF ((SELECT COUNT(*) FROM app.SpecializationGroup WHERE Id IN (SELECT SpecializationGroupId FROM @specializationGroups)) != (SELECT COUNT(*) FROM @specializationGroups))
    BEGIN;
        THROW 70404, N'SpecializationGroup not found.', 1;
    END;

    BEGIN TRAN;
    BEGIN TRY

		DECLARE @oldRootId UNIQUEIDENTIFIER = (SELECT TOP 1 RootId FROM app.Concept WHERE Id = @id)

        UPDATE app.Concept
        SET
            UniversalId = @universalId,
            ParentId = @parentId,
            RootId = @rootId,
            ExternalId = @externalId,
            ExternalParentId = @externalParentId,
            IsPatientCountAutoCalculated = @isPatientCountAutoCalculated,
            [IsNumeric] = @isNumeric,
            IsParent = @isParent,
            IsRoot = @isRoot,
            IsSpecializable = @isSpecializable,
            SqlSetId = @sqlSetId,
            SqlSetWhere = @sqlSetWhere,
            SqlFieldNumeric = @sqlFieldNumeric,
            UiDisplayName = @uiDisplayName,
            UiDisplayText = @uiDisplayText,
            UiDisplaySubtext = @uiDisplaySubtext,
            UiDisplayUnits = @uiDisplayUnits,
            UiDisplayTooltip = @uiDisplayTooltip,
            UiDisplayPatientCount = @uiDisplayPatientCount,
            UiNumericDefaultText = @uiNumericDefaultText,
            ContentLastUpdateDateTime = GETDATE(),
            PatientCountLastUpdateDateTime = CASE WHEN UiDisplayPatientCount = @uiDisplayPatientCount THEN PatientCountLastUpdateDateTime ELSE GETDATE() END,
            IsQueryable = @isQueryable
        WHERE Id = @id;

		IF (@rootId != @oldRootId)

		BEGIN
			; WITH descendents AS
			(
				SELECT Id = @id
				UNION ALL
				SELECT C2.Id
				FROM descendents AS D
					 INNER JOIN app.Concept AS C2
						ON C2.ParentId = D.Id
			)
			SELECT DISTINCT Id
			INTO #descendents
			FROM descendents

			UPDATE app.Concept
			SET RootId = @rootId
			FROM app.Concept AS C
			WHERE EXISTS (SELECT 1 FROM #descendents AS D WHERE C.Id = D.Id)

			UPDATE app.ConceptForwardIndex
			SET RootId = @rootId
			FROM app.Concept C
				 INNER JOIN app.ConceptForwardIndex FI
					ON C.Id = FI.ConceptId
			WHERE EXISTS (SELECT 1 FROM #descendents AS D WHERE C.Id = D.Id)

			DROP TABLE #descendents

		END

        DELETE FROM auth.ConceptConstraint
        WHERE ConceptId = @id;

        INSERT INTO auth.ConceptConstraint
        SELECT @id, ConstraintId, ConstraintValue
        FROM @constraints;

        DELETE FROM rela.ConceptSpecializationGroup
        WHERE ConceptId = @id;

        INSERT INTO rela.ConceptSpecializationGroup
        SELECT @id, SpecializationGroupId, OrderId
        FROM @specializationGroups;

        COMMIT;

        EXEC adm.sp_GetConceptById @id;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH;
END
GO

/****** Object:  StoredProcedure [adm].[sp_GetConceptById]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =======================================
-- Author:      Cliff Spital
-- Create date: 2019/3/19
-- Description: Retrieve a fully hydrated Admin.Concept by Id.
-- =======================================
ALTER PROCEDURE [adm].[sp_GetConceptById]
    @id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON

    -- select concept
    SELECT 
        Id,
        UniversalId,
        ParentId,
        RootId,
        ExternalId,
        ExternalParentId,
        SqlSetId,
        [IsNumeric],
        IsParent,
        IsPatientCountAutoCalculated,
        IsSpecializable,
        SqlSetWhere,
        SqlFieldNumeric,
        UiDisplayName,
        UiDisplayText,
        UiDisplaySubtext,
        UiDisplayUnits,
        UiDisplayTooltip,
        UiDisplayPatientCount,
        UiDisplayPatientCountByYear,
        UiNumericDefaultText,
        IsQueryable
    FROM app.Concept
    WHERE Id = @id;

    -- select specializationgroupids
    SELECT
        SpecializationGroupId,
        OrderId
    FROM rela.ConceptSpecializationGroup csg
    WHERE csg.ConceptId = @id;

    -- select constraints
    SELECT
        ConceptId,
        ConstraintId,
        ConstraintValue
    FROM auth.ConceptConstraint
    WHERE ConceptId = @id;

END



GO


/****** Object:  StoredProcedure [app].[sp_HydrateConceptsByIds]    Script Date: ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =======================================
-- Author:      Cliff Spital, modified by Nic Dobbins
-- Create date: 2018/8/2
-- Modify date: 2019/1/4 - Added Concept Specializations
--              2024/10/4 - Added IsQueryable
-- Description: Hydrates a list of Concept Models by Ids
-- =======================================
ALTER PROCEDURE [app].[sp_HydrateConceptsByIds]
    @ids app.ResourceIdTable READONLY
AS
BEGIN
    SET NOCOUNT ON

	DECLARE @specializedGroups app.ListTable

	-- Get specialization groups for
	-- the concepts to be retrieved
	INSERT INTO @specializedGroups (Id)
	SELECT sg.Id
	FROM app.SpecializationGroup sg
	WHERE EXISTS (SELECT 1 
				  FROM rela.ConceptSpecializationGroup csg
					   INNER JOIN app.Concept c
							ON csg.ConceptId = c.Id
				  WHERE EXISTS (SELECT 1 FROM @ids i WHERE i.Id = c.Id)
						AND c.SqlSetId = sg.SqlSetId
						AND c.IsSpecializable = 1)

	-- Return concepts
    SELECT
        c.Id,
        c.ParentId,
        c.RootId,
        c.ExternalId,
        c.ExternalParentId,
        c.UniversalId,
        c.IsNumeric,
        s.IsEventBased,
        c.IsParent,
        s.IsEncounterBased,
        c.IsPatientCountAutoCalculated,
        c.IsSpecializable,
        s.SqlSetFrom,
        c.SqlSetWhere,
        s.SqlFieldDate,
        c.SqlFieldNumeric,
        s.SqlFieldEvent,
        c.UiDisplayName,
        c.UiDisplayText,
		c.UiDisplaySubtext,
        c.UiDisplayUnits,
        c.UiDisplayTooltip,
        c.UiDisplayPatientCount,
        c.UiDisplayPatientCountByYear,
        e.UiDisplayEventName,
        c.UiNumericDefaultText,
        EventTypeId = e.Id,
        c.IsQueryable
    FROM app.Concept c
		 INNER JOIN app.ConceptSqlSet s
			ON c.SqlSetId = s.Id
         LEFT JOIN app.ConceptEvent e
            ON s.EventId = e.Id
               AND s.IsEventBased = 1
    WHERE EXISTS (SELECT 1 FROM @ids i WHERE c.Id = i.Id)
    ORDER BY c.UiDisplayRowOrder, c.UiDisplayName

	-- Return Specialization groups
	-- with ConceptId context
	SELECT csg.ConceptId
		 , sg.Id
		 , sg.UiDefaultText
		 , csg.OrderId
	FROM rela.ConceptSpecializationGroup csg
		 INNER JOIN app.SpecializationGroup sg
			ON csg.SpecializationGroupId = sg.Id
	WHERE EXISTS (SELECT 1 FROM @ids i WHERE i.Id = csg.ConceptId)
		  AND EXISTS (SELECT 1 FROM @specializedGroups sg WHERE sg.Id = sg.Id)

	-- Return Specializations
	SELECT s.Id
		 , s.SpecializationGroupId	
		 , s.UniversalId
		 , s.UiDisplayText
		 , s.SqlSetWhere
		 , s.OrderId
	FROM app.Specialization s
	WHERE EXISTS (SELECT 1 FROM @specializedGroups sg WHERE sg.Id = s.SpecializationGroupId)

END
