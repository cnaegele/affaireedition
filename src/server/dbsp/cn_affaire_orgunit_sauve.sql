USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[cn_affaire_orgunit_sauve]    Script Date: 22.08.2024 10:03:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--22.08.2024 CN
-- Sauvegarde de lien affaire orgunit
-- Si idaffaire - idorgunit n'existe pas INSERT
-- Sinon, si données différentes, UPDATE (l'affaire ou lunité org ne peuvent pas changer)
-- =============================================
CREATE PROCEDURE [dbo].[cn_affaire_orgunit_sauve]
	 @idaffaire int
	,@idorgunit int
	,@idrole int
	,@idempcaller int
	,@datedebutparticipe datetime
	,@datefinparticipe datetime
	,@commentaire varchar(500)
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS (SELECT IdAffaire FROM dbo.AffaireOrgUnit WHERE IdAffaire = @idaffaire AND IdOrgUnit = @idorgunit)
	BEGIN
		INSERT dbo.AffaireOrgUnit (IdAffaire, IdOrgUnit, IdRoleOU, IdCreator, DateBeginParticipate, DateEndParticipate, Comment)
		VALUES (@idaffaire, @idorgunit, @idrole, @idempcaller, @datedebutparticipe, @datefinparticipe, @commentaire)
		SELECT 'insert'
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT IdAffaire
										FROM dbo.AffaireOrgUnit
										WHERE		IdAffaire = @idaffaire
												AND	IdOrgUnit = @idorgunit
												AND	IdRoleOU = @idrole
												AND	ISNULL(DateBeginParticipate, '1900-01-01') = ISNULL(@datedebutparticipe, '1900-01-01')
												AND	ISNULL(DateEndParticipate, '1900-01-01') = ISNULL(@datefinparticipe, '1900-01-01')
												AND	ISNULL(Comment, '') = ISNULL(@commentaire, ''))
		BEGIN
			UPDATE dbo.AffaireOrgUnit
			SET  IdRoleOU = @idrole
					,IdCreator = @idempcaller
					,DateBeginParticipate = @datedebutparticipe
					,DateEndParticipate = @datefinparticipe
					,Comment = @commentaire
			WHERE IdAffaire = @idaffaire AND IdOrgUnit = @idorgunit
			SELECT 'update'
		END
		ELSE
		BEGIN
			SELECT 'existe'
		END
	END
END
GO

