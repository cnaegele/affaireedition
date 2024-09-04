USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[cn_employe_liste]    Script Date: 04.09.2024 08:21:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



--06.02.2024 by cn
CREATE PROCEDURE [dbo].[cn_employe_liste] @scritere varchar(100), @bactif int = 1, @idOrgUnit int = 0, @maxretour int = 500
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @isactive1 bit, @isactive2 bit
	IF @bactif = 1
	BEGIN
		SELECT @isactive1 = 1, @isactive2 = 1
	END
	ELSE IF @bactif = 0
	BEGIN
		SELECT @isactive1 = 0, @isactive2 = 0
	END
	ELSE
	BEGIN
		SELECT @isactive1 = 0, @isactive2 = 1
	END

	IF @idOrgUnit = 0
	BEGIN
		IF LEN(REPLACE(REPLACE(@scritere, '*', ''), '%', '')) >= 3
		BEGIN
			IF SUBSTRING(@scritere, 1, 3) = 'VDL'
			BEGIN
				IF LEN(REPLACE(REPLACE(@scritere, '*', ''), '%', '')) >= 5
				BEGIN
					IF SUBSTRING(@scritere, LEN(@scritere), 1) <> '%'	SELECT @scritere = @scritere + '%'
					SELECT @scritere = 'LAUSANNE_CH\' + @scritere 
					SELECT	TOP(@maxretour) Employe.IdEmploye AS idemploye
							,Employe.Nom AS nom
							,Employe.Prenom AS prenom
							,SUBSTRING(REPLACE(Employe.MainNtLogin, 'LAUSANNE_CH\', ''), 1, 15) AS login
							,Employe.IsActive AS bactif
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 2
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS directionabr	
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 3
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS serviceabr	
							,(SELECT MIN(OrgUnit.Description)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unite	
							,(SELECT MIN(OrgUnit.DescTreeDenorm)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unitetree	
					FROM dbo.Employe
					WHERE Employe.MainNtLogin LIKE @scritere
						AND Employe.IsActive IN (@isactive1, @isactive2)
					ORDER BY login
				END
			END
			ELSE IF SUBSTRING(@scritere, 5, 1) IN ('0','1','2','3','4','5','6','7','8','9')
			BEGIN
				IF LEN(REPLACE(REPLACE(@scritere, '*', ''), '%', '')) >= 4
				BEGIN
					IF SUBSTRING(@scritere, LEN(@scritere), 1) <> '%'	SELECT @scritere = @scritere + '%'
					SELECT @scritere = 'LAUSANNE_CH\' + @scritere 
					SELECT TOP(@maxretour) Employe.IdEmploye AS idemploye
							,Employe.Nom AS nom
							,Employe.Prenom AS prenom
							,SUBSTRING(REPLACE(Employe.MainNtLogin, 'LAUSANNE_CH\', ''), 1, 15) AS login
							,Employe.IsActive AS bactif
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 2
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS directionabr	
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 3
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS serviceabr	
							,(SELECT MIN(OrgUnit.Description)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unite					
							,(SELECT MIN(OrgUnit.DescTreeDenorm)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unitetree	
					FROM dbo.Employe
					WHERE Employe.MainNtLogin LIKE @scritere
						AND Employe.IsActive IN (@isactive1, @isactive2)
					ORDER BY login
				END
			END
			ELSE
			BEGIN
				SELECT @scritere = REPLACE(@scritere, '*', '%')
				IF SUBSTRING(@scritere, 1, 1) <> '%'	SELECT @scritere = '%' + @scritere
				IF SUBSTRING(@scritere, LEN(@scritere), 1) <> '%'	SELECT @scritere = @scritere + '%'

				SELECT	TOP(@maxretour) Employe.IdEmploye AS idemploye
						,Employe.Nom AS nom
						,Employe.Prenom AS prenom
						,SUBSTRING(REPLACE(Employe.MainNtLogin, 'LAUSANNE_CH\', ''), 1, 15) AS login
						,Employe.IsActive AS bactif
						,(SELECT MIN(OrgUnit.Abreviation)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
												AND	OrgUnit.IdTypeOrgUnit = 2
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS directionabr	
						,(SELECT MIN(OrgUnit.Abreviation)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
												AND	OrgUnit.IdTypeOrgUnit = 3
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS serviceabr	
						,(SELECT MIN(OrgUnit.Description)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
								AND Employe_OrgUnit.LevelOU = 0) AS unite
						,(SELECT MIN(OrgUnit.DescTreeDenorm)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
								AND Employe_OrgUnit.LevelOU = 0) AS unitetree
				FROM dbo.Employe
				WHERE (Employe.Nom + ' ' + Employe.Prenom LIKE @scritere 
					OR Employe.Prenom + ' ' + Employe.Nom LIKE @scritere)
					AND Employe.IsActive IN (@isactive1, @isactive2)
				ORDER BY nom, prenom, bactif DESC, login
			END
		END
	END
	ELSE --IdOrgUnit
	BEGIN
		IF LEN(REPLACE(REPLACE(@scritere, '*', ''), '%', '')) >= 0
		BEGIN
			IF SUBSTRING(@scritere, 1, 3) = 'VDL'
			BEGIN
				IF LEN(REPLACE(REPLACE(@scritere, '*', ''), '%', '')) >= 5
				BEGIN
					IF SUBSTRING(@scritere, LEN(@scritere), 1) <> '%'	SELECT @scritere = @scritere + '%'
					SELECT @scritere = 'LAUSANNE_CH\' + @scritere 
					SELECT	TOP(@maxretour) Employe.IdEmploye AS idemploye
							,Employe.Nom AS nom
							,Employe.Prenom AS prenom
							,REPLACE(Employe.MainNtLogin, 'LAUSANNE_CH\', '') AS login
							,Employe.IsActive AS bactif
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 2
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS directionabr	
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 3
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS serviceabr	
							,(SELECT MIN(OrgUnit.Description)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unite	
							,(SELECT MIN(OrgUnit.DescTreeDenorm)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unitetree	
					FROM dbo.Employe
					INNER JOIN dbo.Employe_OrgUnit uocrit ON uocrit.IdEmploye = Employe.IdEmploye AND uocrit.IdOrgUnit = @idOrgUnit
					WHERE Employe.MainNtLogin LIKE @scritere
						AND Employe.IsActive IN (@isactive1, @isactive2)
					ORDER BY login
				END
			END
			ELSE IF SUBSTRING(@scritere, 5, 1) IN ('0','1','2','3','4','5','6','7','8','9')
			BEGIN
				IF LEN(REPLACE(REPLACE(@scritere, '*', ''), '%', '')) >= 4
				BEGIN
					IF SUBSTRING(@scritere, LEN(@scritere), 1) <> '%'	SELECT @scritere = @scritere + '%'
					SELECT @scritere = 'LAUSANNE_CH\' + @scritere 
					SELECT TOP(@maxretour) Employe.IdEmploye AS idemploye
							,Employe.Nom AS nom
							,Employe.Prenom AS prenom
							,REPLACE(Employe.MainNtLogin, 'LAUSANNE_CH\', '') AS login
							,Employe.IsActive AS bactif
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 2
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS directionabr	
							,(SELECT MIN(OrgUnit.Abreviation)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
													AND	OrgUnit.IdTypeOrgUnit = 3
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS serviceabr	
							,(SELECT MIN(OrgUnit.Description)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unite					
							,(SELECT MIN(OrgUnit.DescTreeDenorm)
								FROM dbo.Employe_OrgUnit
								INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
								WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
									AND Employe_OrgUnit.LevelOU = 0) AS unitetree	
					FROM dbo.Employe
					INNER JOIN dbo.Employe_OrgUnit uocrit ON uocrit.IdEmploye = Employe.IdEmploye AND uocrit.IdOrgUnit = @idOrgUnit
					WHERE Employe.MainNtLogin LIKE @scritere
						AND Employe.IsActive IN (@isactive1, @isactive2)
					ORDER BY login
				END
			END
			ELSE
			BEGIN
				SELECT @scritere = REPLACE(@scritere, '*', '%')
				IF SUBSTRING(@scritere, 1, 1) <> '%'	SELECT @scritere = '%' + @scritere
				IF SUBSTRING(@scritere, LEN(@scritere), 1) <> '%'	SELECT @scritere = @scritere + '%'

				SELECT	TOP(@maxretour) Employe.IdEmploye AS idemploye
						,Employe.Nom AS nom
						,Employe.Prenom AS prenom
						,REPLACE(Employe.MainNtLogin, 'LAUSANNE_CH\', '') AS login
						,Employe.IsActive AS bactif
						,(SELECT MIN(OrgUnit.Abreviation)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
												AND	OrgUnit.IdTypeOrgUnit = 2
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS directionabr	
						,(SELECT MIN(OrgUnit.Abreviation)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
												AND	OrgUnit.IdTypeOrgUnit = 3
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye) AS serviceabr	
						,(SELECT MIN(OrgUnit.Description)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
								AND Employe_OrgUnit.LevelOU = 0) AS unite
						,(SELECT MIN(OrgUnit.DescTreeDenorm)
							FROM dbo.Employe_OrgUnit
							INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
							WHERE Employe_OrgUnit.IdEmploye = Employe.IdEmploye
								AND Employe_OrgUnit.LevelOU = 0) AS unitetree
				FROM dbo.Employe
				INNER JOIN dbo.Employe_OrgUnit uocrit ON uocrit.IdEmploye = Employe.IdEmploye AND uocrit.IdOrgUnit = @idOrgUnit
				WHERE (Employe.Nom + ' ' + Employe.Prenom LIKE @scritere 
					OR Employe.Prenom + ' ' + Employe.Nom LIKE @scritere)
					AND Employe.IsActive IN (@isactive1, @isactive2)
				ORDER BY nom, prenom, bactif DESC, login
			END
		END
	END
END
GO

