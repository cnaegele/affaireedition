USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[cn_affaire_employe_sauve]    Script Date: 04.09.2024 08:10:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






--03.09.2024 CN
-- Sauvegarde de lien affaire employé
-- Si idaffaire - idemploye n'existe pas INSERT
-- Sinon, si données différentes, UPDATE (l'affaire ou lunité org ne peuvent pas changer)
-- =============================================
CREATE   PROCEDURE [dbo].[cn_affaire_employe_sauve]
	 @idaffaire int
	,@idemploye int
	,@idrole int
	,@idempcaller int
	,@datedebutparticipe datetime
	,@datefinparticipe datetime
	,@commentaire varchar(500)
AS
BEGIN
	SET NOCOUNT ON;
	IF NOT EXISTS (SELECT IdAffaire FROM dbo.AffaireEmploye WHERE IdAffaire = @idaffaire AND IdEmploye = @idemploye)
	BEGIN
		INSERT dbo.AffaireEmploye (IdAffaire, IdEmploye, IdRoleEmp, IdCreator, DateBeginParticipate, DateEndParticipate, Comment)
		VALUES (@idaffaire, @idemploye, @idrole, @idempcaller, @datedebutparticipe, @datefinparticipe, @commentaire)
		SELECT 'insert'
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT IdAffaire
										FROM dbo.AffaireEmploye
										WHERE		IdAffaire = @idaffaire
												AND	IdEmploye = @idemploye
												AND	IdRoleEmp = @idrole
												AND	ISNULL(DateBeginParticipate, '1900-01-01') = ISNULL(@datedebutparticipe, '1900-01-01')
												AND	ISNULL(DateEndParticipate, '1900-01-01') = ISNULL(@datefinparticipe, '1900-01-01')
												AND	ISNULL(Comment, '') = ISNULL(@commentaire, ''))
		BEGIN
			UPDATE dbo.AffaireEmploye
			SET  IdRoleEmp = @idrole
					,IdCreator = @idempcaller
					,DateBeginParticipate = @datedebutparticipe
					,DateEndParticipate = @datefinparticipe
					,Comment = @commentaire
			WHERE IdAffaire = @idaffaire AND IdEmploye = @idemploye
			SELECT 'update'
		END
		ELSE
		BEGIN
			SELECT 'existe'
		END
	END
END
GO

