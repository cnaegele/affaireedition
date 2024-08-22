USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[cn_affaire_acteurrole_sauve]    Script Date: 22.08.2024 10:15:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--13.08.2024 CN
-- Sauvegarde de rôle acteur d'une affaire
-- Si idacteurrole = 0, INSERT
-- Sinon, si idrole ou commentaire différents, UPDATE (l'affaire ou l'acteur ne peuvent pas changer)
-- =============================================
CREATE PROCEDURE [dbo].[cn_affaire_acteurrole_sauve]
	 @idacteurrole int
	,@idacteur int
	,@idaffaire int
	,@idrole int
	,@idemploye int
	,@commentaire varchar(1000)
AS
BEGIN
	SET NOCOUNT ON;
	IF @idacteurrole = 0
	BEGIN
		INSERT dbo.ActeurRole (IdActeur, IdRole, ObjectTableName, IdObject, DateCreated, Commentaire)
		VALUES (@idacteur, @idrole, 'Affaire', @idaffaire, GETDATE(), @commentaire)
		SELECT @@IDENTITY
	END
	ELSE
	BEGIN
		IF NOT EXISTS (SELECT IdActeurRole
										FROM dbo.ActeurRole
										WHERE		IdActeurRole = @idacteurrole
												AND	IdRole = @idrole
												AND	ISNULL(Commentaire, '') = ISNULL(@commentaire, ''))
		BEGIN
			UPDATE dbo.ActeurRole
			SET  IdRole = @idrole
					,Commentaire = @commentaire
			WHERE IdActeurRole = @idacteurrole
			SELECT @idacteurrole
		END
		ELSE
		BEGIN
			SELECT 0
		END
	END
END
GO

