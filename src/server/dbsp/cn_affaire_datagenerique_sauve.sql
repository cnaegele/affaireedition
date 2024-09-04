USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[cn_affaire_datagenerique_sauve]    Script Date: 04.09.2024 08:18:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- 27.08.2024 by cn
-- Utilisé pour test interface vuetify édition affaire
-- Ne sera probablement jamais utilisée pour la prod
CREATE PROCEDURE [dbo].[cn_affaire_datagenerique_sauve] 
	 @IdAffaire int
	,@IdEmpCaller int
	,@Name varchar(300)
	,@DateBegin datetime
	,@DateEnd datetime
	,@IsTerminated bit
	,@Description varchar(2000)
	,@Commentaire varchar(2000)

AS
BEGIN
	SET NOCOUNT ON;
	UPDATE dbo.Affaire 
	SET	Name = dbo.CGPurifyInvalidISO88591Chars(@Name)
		,Description = dbo.CGPurifyInvalidISO88591Chars(@Description)
		,Commentaire = dbo.CGPurifyInvalidISO88591Chars(@Commentaire)
		,DateLastModif = GETDATE()
		,DateBegin = @DateBegin
		,DateEnd = @DateEnd
		,IsTerminated = @IsTerminated
		,IdLastModificator = @IdEmpCaller
	WHERE IdAffaire = @IdAffaire
END
GO

