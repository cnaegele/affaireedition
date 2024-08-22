USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[cn_affaire_acteurrole_supprime]    Script Date: 22.08.2024 10:13:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--13.08.2024 CN
-- Supression de rôles acteur d'une affaire
-- On reçoit les IdActeurRole existant encore dans une chaine séparés par des , et on supprime ceux en trop 
-- =============================================
CREATE PROCEDURE [dbo].[cn_affaire_acteurrole_supprime]  
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
	CREATE TABLE #tmp_cn_affaire_acteurrole_supprime (id int NOT NULL)

	SELECT @sids = REPLACE(@sids, ' ', '')
	SELECT @posi = CHARINDEX(@separe, @sids)
	WHILE @posi > 0
	BEGIN
		SELECT @sid = SUBSTRING(@sids, 1, @posi-1)
		SELECT @id = CAST(@sid AS int)
		INSERT  #tmp_cn_affaire_acteurrole_supprime (id) VALUES (@id)
		SELECT @sids = SUBSTRING(@sids, @posi+1, LEN(@sids)-@posi)
		SELECT @posi = CHARINDEX(@separe, @sids)
	END
	IF NOT @sids = ''
	BEGIN
		SELECT @id = CAST(@sids AS int)
		INSERT  #tmp_cn_affaire_acteurrole_supprime (id) VALUES (@id)
	END

	--Curseur avec la liste des IdActeurRole eb base de données qui ne sont pas dans la liste reçue, donc a supprimer
	DECLARE c_id_supprime CURSOR FOR 
		SELECT ActeurRole.IdActeurRole
		FROM dbo.ActeurRole
		LEFT OUTER JOIN #tmp_cn_affaire_acteurrole_supprime ON #tmp_cn_affaire_acteurrole_supprime.id = ActeurRole.IdActeurRole
		WHERE	ActeurRole.ObjectTableName = 'Affaire'
			AND	ActeurRole.IdObject = @idaffaire
			AND	#tmp_cn_affaire_acteurrole_supprime.id IS NULL

	OPEN c_id_supprime
	FETCH c_id_supprime INTO @id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		DELETE dbo.ActeurRole WHERE IdActeurRole = @id
		SELECT @nsupprime = @nsupprime + 1
		FETCH c_id_supprime INTO @id
	END
	CLOSE c_id_supprime
	DEALLOCATE c_id_supprime

	DROP TABLE #tmp_cn_affaire_acteurrole_supprime
	SELECT @nsupprime
END
GO

