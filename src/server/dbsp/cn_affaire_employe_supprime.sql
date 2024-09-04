USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[cn_affaire_employe_supprime]    Script Date: 04.09.2024 08:16:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- 03.09.2024 CN
-- Supression de liens d'une affaire - employé(s)
-- On reçoit les idEmploye existant encore dans une chaine séparés par des , et on supprime ceux en trop 
-- =============================================
CREATE   PROCEDURE [dbo].[cn_affaire_employe_supprime]  
	 @idaffaire int
	,@idemploye int
	,@sids varchar(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @separe char(1) = ','
	DECLARE @sid varchar(10), @id int
	DECLARE @posi int
	DECLARE @nsupprime int = 0
	CREATE TABLE #tmp_cn_affaire_employe_supprime (id int NOT NULL)

	SELECT @sids = REPLACE(@sids, ' ', '')
	SELECT @posi = CHARINDEX(@separe, @sids)
	WHILE @posi > 0
	BEGIN
		SELECT @sid = SUBSTRING(@sids, 1, @posi-1)
		SELECT @id = CAST(@sid AS int)
		INSERT  #tmp_cn_affaire_employe_supprime (id) VALUES (@id)
		SELECT @sids = SUBSTRING(@sids, @posi+1, LEN(@sids)-@posi)
		SELECT @posi = CHARINDEX(@separe, @sids)
	END
	IF NOT @sids = ''
	BEGIN
		SELECT @id = CAST(@sids AS int)
		INSERT  #tmp_cn_affaire_employe_supprime (id) VALUES (@id)
	END

	--Curseur avec la liste des IdEmploye en base de données qui ne sont pas dans la liste reçue, donc a supprimer
	DECLARE c_id_supprime CURSOR FOR 
		SELECT AffaireEmploye.IdEmploye
		FROM dbo.AffaireEmploye
		LEFT OUTER JOIN #tmp_cn_affaire_employe_supprime ON #tmp_cn_affaire_employe_supprime.id = AffaireEmploye.IdEmploye
		WHERE	AffaireEmploye.IdAffaire = @idaffaire
			AND	#tmp_cn_affaire_employe_supprime.id IS NULL

	OPEN c_id_supprime
	FETCH c_id_supprime INTO @id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE dbo.AffaireEmploye WHERE IdAffaire = @idaffaire AND IdEmploye = @id
		SELECT @nsupprime = @nsupprime + 1
		FETCH c_id_supprime INTO @id
	END
	CLOSE c_id_supprime
	DEALLOCATE c_id_supprime

	DROP TABLE #tmp_cn_affaire_employe_supprime
	SELECT @nsupprime
END
GO

