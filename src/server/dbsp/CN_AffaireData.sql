USE [goeland]
GO

/****** Object:  StoredProcedure [dbo].[CN_AffaireData]    Script Date: 04.09.2024 08:23:40 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER ON
GO

--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--TOUTE MODIFICATION A REPORTER DANS :
-- function plpgsql cn_affaire_data /data/dataweb/goeland_pgsql_function/cn_affaire_data.sql
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--07.03.2011 by CN
CREATE Procedure [dbo].[CN_AffaireData] @IdAffaire int
AS
SET NOCOUNT ON
DECLARE @vIdLastSuiviCreator int
DECLARE @vLastSuiviCreator varchar(100)
DECLARE @vDateLastSuiviCreated varchar(10)
DECLARE @vNbrAffaireSuivi int
DECLARE @vNbrSePoDe int
DECLARE @vNbrCirculation int
DECLARE @vNbrAgende int
DECLARE @vNbrCoFi int
DECLARE @vIdAffTopParent int
DECLARE @idAffTP int
DECLARE @nRecur int
DECLARE @nRecurMax int
SELECT @nRecurMax = 20
--Nombre de suivi
SELECT @vNbrAffaireSuivi=COUNT(*) FROM dbo.AffaireSuivi WHERE AffaireSuivi.IdAffaire=@IdAffaire
IF @vNbrAffaireSuivi > 0
BEGIN
	SELECT 	@vDateLastSuiviCreated = dbo.CNShowDateTime(DateCreated),
			@vIdLastSuiviCreator = IdCreator,
			@vLastSuiviCreator=(SELECT Employe.Prenom + ' ' + Employe.Nom FROM Employe WHERE Employe.IdEmploye=AffaireSuivi.IdCreator)
	FROM dbo.AffaireSuivi
	WHERE 	IdAffaire = @IdAffaire AND 
			DateCreated = (SELECT MAX(DateCreated) FROM dbo.AffaireSuivi WHERE IdAffaire = @IdAffaire) 
END
ELSE
BEGIN
	SELECT @vDateLastSuiviCreated = NULL 
	SELECT @vIdLastSuiviCreator = NULL 
	SELECT @vLastSuiviCreator = NULL 
END
--Nombre de lien "Décisionnel" (SePoDe)
SELECT @vNbrSePoDe = COUNT(IdAffaire) FROM dbo.SPDSeanceAffaire WHERE SPDSeanceAffaire.IdAffaire = @IdAffaire AND CodeTypeLien = 1
SELECT @vNbrSePoDe = @vNbrSePoDe + COUNT(IdAffaire) FROM dbo.SPDPointAffaire WHERE SPDPointAffaire.IdAffaire = @IdAffaire AND CodeTypeLien = 1
SELECT @vNbrSePoDe = @vNbrSePoDe + COUNT(IdAffaire) FROM dbo.SPDDecisionAffaire WHERE SPDDecisionAffaire.IdAffaire = @IdAffaire AND CodeTypeLien = 1
--Nombre de circulations pour cette affaire
SELECT @vNbrCirculation=COUNT(*) FROM dbo.AffaireCirculation WHERE AffaireCirculation.IdAffaire=@IdAffaire
--Nombre d'agendé qui concerment cette affaire
SELECT @vNbrAgende=COUNT(*) FROM dbo.Agende WHERE Agende.IdAffaire=@IdAffaire
--Nombre d' ouverture comptable + engagement + ventilation facture qui concerment cette affaire
SELECT @vNbrCoFi = 0
SELECT @vNbrCoFi=@vNbrCoFi+COUNT(*) FROM dbo.CoFiOuvertureComptableCodeCF WHERE CoFiOuvertureComptableCodeCF.IdCodeCF=2 AND CoFiOuvertureComptableCodeCF.CodeCoFi = CONVERT(varchar(100),@IdAffaire)
SELECT @vNbrCoFi=@vNbrCoFi+COUNT(*) FROM dbo.CoFiEngagementCodeCF WHERE CoFiEngagementCodeCF.IdCodeCF=2 AND CoFiEngagementCodeCF.CodeCoFi = CONVERT(varchar(100),@IdAffaire)
SELECT @vNbrCoFi=@vNbrCoFi+COUNT(*) FROM dbo.CoFiVentilationFCodeCF WHERE CoFiVentilationFCodeCF.IdCodeCF=2 AND CoFiVentilationFCodeCF.CodeCoFi = CONVERT(varchar(100),@IdAffaire)
--Recherche de l'affaire "racine" d'une éventuelle hiérarche parent-enfant
SELECT @vIdAffTopParent = @IdAffaire
SELECT @nRecur = 1
WHILE @nRecur <= @nRecurMax
BEGIN
	SELECT @idAffTP = 0
	SELECT @idAffTP = MIN(IdAffaire1) FROM dbo.LienAffaireAffaire WHERE IdAffaire2 = @vIdAffTopParent AND IdTypeLien12 = 2
	IF @idAffTP > 0
	BEGIN	
		SELECT @vIdAffTopParent = @idAffTP
		SELECT @nRecur = @nRecur+1
	END
	ELSE		SELECT @nRecur = 999 
END
IF @nRecur < 999	SELECT @vIdAffTopParent = 0 --Référence cyclique ?
SELECT 1 AS Tag,
	NULL AS Parent,
	@IdAffaire AS 												[Affaire!1!IdAffaire!element],
	Affaire.Name AS 											[Affaire!1!Nom!element],
	Affaire.IdTypeAffaire AS 									[Affaire!1!IdType!element],
	TypeAffaire.Name AS											[Affaire!1!Type!element],
	TypeAffaire.bCouleurSuivi AS								[Affaire!1!BCouleurSuivi!element],
	Affaire.Description AS 										[Affaire!1!Description!element],
	Affaire.Commentaire AS 										[Affaire!1!Commentaire!element],
	Affaire.Archivage AS 										[Affaire!1!Archivage!element],
	dbo.CNShowDateTime(Affaire.DateCreated) AS 					[Affaire!1!DateCre!element],
	dbo.CNShowDate(Affaire.DateLastModif) AS 					[Affaire!1!DateMod!element],
	dbo.CNShowDate(Affaire.DateBegin) AS 						[Affaire!1!DateDebut!element],
	dbo.CNShowDate(Affaire.DateLastSuspended) AS 				[Affaire!1!DateSuspens!element],
	dbo.CNShowDate(Affaire.DateLastReactivation) AS 			[Affaire!1!DateReactivation!element],
	dbo.CNShowDate(Affaire.DateEnd) AS 							[Affaire!1!DateFin!element],
	Affaire.IsSuspended AS 										[Affaire!1!BSuspens!element],
	Affaire.IsTerminated AS 									[Affaire!1!BTermine!element],
	Affaire.IdCreator AS 										[Affaire!1!IdEmpCre!element],
	(SELECT Employe.Prenom + ' ' + Employe.Nom 
	FROM dbo.Employe
	WHERE Employe.IdEmploye = Affaire.IdCreator) AS 			[Affaire!1!EmpCre!element],
	Affaire.IdLastModificator AS 								[Affaire!1!IdEmpMod!element],
	(SELECT Employe.Prenom + ' ' + Employe.Nom 
	FROM dbo.Employe
	WHERE Employe.IdEmploye = Affaire.IdLastModificator) AS 	[Affaire!1!EmpMod!element],
	Affaire.IsConfidential AS 									[Affaire!1!BConfidentiel!element],
	Affaire.bPropagConfidential AS 								[Affaire!1!BPropagConfidentiel!element],
	Affaire.BCreationEnCours AS 								[Affaire!1!BCreationEnCours!element],
	CAST(affaire_georeferencement.GeoRefOE/100.0 AS decimal(9,2)) AS	[Affaire!1!GeoRefOE!element], 
	CAST(affaire_georeferencement.GeoRefSN/100.0 AS  decimal(9,2)) AS	[Affaire!1!GeoRefSN!element], 
	@vDateLastSuiviCreated AS 									[Affaire!1!DateCreLastSuivi!element],
	@vIdLastSuiviCreator AS 									[Affaire!1!IdLastSuiviCreator!element],
	@vLastSuiviCreator AS										[Affaire!1!LastSuiviCreator!element] ,
	@vNbrAffaireSuivi AS										[Affaire!1!NbrAffaireSuivi!element] ,
	@vNbrSePoDe AS 												[Affaire!1!NbrSePoDe!element] ,
	@vNbrCirculation AS											[Affaire!1!NbrCirculation!element] ,
	@vNbrAgende AS												[Affaire!1!NbrAgende!element],
	@vNbrCoFi AS												[Affaire!1!NbrCoFi!element],
	@vIdAffTopParent AS 										[Affaire!1!IdAffTopParent!element],
	
	NULL AS 	[UO!20!UOId!element],			
	NULL AS 	[UO!20!UOIdRole!element],			
	NULL AS 	[UO!20!UORole!element],			
	NULL AS 	[UO!20!OUCROrdre!element],			
	NULL AS 	[UO!20!UONom!element],			
	NULL AS 	[UO!20!UODescTree!element],			
	NULL AS 	[UO!20!UODateDebParticipation!element],		
	NULL AS 	[UO!20!UODateFinParticipation!element],		
	NULL AS 	[UO!20!UOCommentaire!element],
	NULL AS 	[UO!20!UOBActif!element],
	NULL AS 	[UO!20!UOOrdre!element],
	
	NULL AS 	[Emp!30!EmpId!element],			
	NULL AS 	[Emp!30!EmpIdRole!element],			
	NULL AS 	[Emp!30!EmpRole!element],			
	NULL AS 	[Emp!30!EmpCROrdre!element],			
	NULL AS 	[Emp!30!EmpNom!element],			
	NULL AS 	[Emp!30!EmpEmail!element],
	NULL AS 	[Emp!30!EmpTelProf!element],
	NULL AS 	[Emp!30!EmpUniteOrg!element],			
	NULL AS 	[Emp!30!EmpAbrevUO!element],			
	NULL AS 	[Emp!30!EmpDateDebParticipation!element],	
	NULL AS 	[Emp!30!EmpDateFinParticipation!element],		
	NULL AS 	[Emp!30!EmpCommentaire!element],
	NULL AS 	[Emp!30!EmpBActif!element],
			
	NULL AS 	[AcR!40!AcRId!element],		
	NULL AS 	[AcR!40!AcRIdActeur!element],			
	NULL AS 	[AcR!40!AcRNomActeur!element],		
	NULL AS 	[AcR!40!AcRIdRoleActeur!element],		
	NULL AS 	[AcR!40!AcRRoleActeur!element],		
	NULL AS 	[AcR!40!AcRCommentaire!element],
	NULL AS 	[AcR!40!AcRBActif!element],
	
	NULL AS 	[Env!50!EnvId!element],		
	NULL AS 	[Env!50!EnvDOrder!hide],		
	NULL AS 	[Env!50!EnvDateRecepEnvoi!element],		
	NULL AS		[Env!50!EnvEouS!element],		
	NULL AS 	[Env!50!EnvTitre!element],
	
	NULL AS 	[Doc!60!DocId!element],
	NULL AS 	[Doc!60!DocIdType!element],	
	NULL AS 	[Doc!60!DocType!element],	
	NULL AS 	[Doc!60!DocIdFamille!element],		
	NULL AS 	[Doc!60!DocFamille!element],		
	NULL AS 	[Doc!60!DocBExterne!element],	
	NULL AS 	[Doc!60!DocDOrder!element],		
	NULL AS 	[Doc!60!DocDateOf!element],		
	NULL AS 	[Doc!60!DocTitre!element],		
	NULL AS 	[Doc!60!DocSujet!element],
	NULL AS 	[Doc!60!DocNVersion!element],
	NULL AS 	[Doc!60!NbrAffSuiviValid!element],
	
	NULL AS 	[Url!65!UrlId!element],
	NULL AS 	[Url!65!UrlLink!element],
	NULL AS 	[Url!65!UrlTitre!element],
	NULL AS 	[Url!65!UrlCible!element],
	
	NULL AS 	[Obj!70!ObjId!element],			
	NULL AS 	[Obj!70!ObjIdType!element],		
	NULL AS 	[Obj!70!ObjType!element],	
	NULL AS 	[Obj!70!ObjBActif!element],	
	NULL AS 	[Obj!70!ObjNom!element],
	NULL AS 	[Obj!70!MinOE!element],
	NULL AS 	[Obj!70!MinSN!element],
	NULL AS 	[Obj!70!MaxOE!element],
	NULL AS 	[Obj!70!MaxSN!element],
	
	NULL AS 	[Batiment!75!BatId!element],			
	NULL AS 	[Batiment!75!BatNom!element],			
	NULL AS 	[Batiment!75!BatIdEtat!element],			
	NULL AS 	[Batiment!75!BatEtat!element],			
	NULL AS 	[Batiment!75!BatNoteRA!element],
	NULL AS 	[Batiment!75!BatFPBC!element],
				
	NULL AS 	[Parcelle!80!ParId!element],			
	NULL AS 	[Parcelle!80!ParNom!element],			
	NULL AS 	[Parcelle!80!ParOrdre!element],			
	NULL AS 	[Parcelle!80!ParIdEtat!element],			
	NULL AS 	[Parcelle!80!ParEtat!element],			
	NULL AS 	[Parcelle!80!ParResProp!element],		
	NULL AS 	[Parcelle!80!ParRaisonAnnul!element],
	NULL AS		[ParIsos!801!TxtISOS!element],
	
	NULL AS 	[AffL!90!AffLId!element],	
	NULL AS 	[AffL!90!AffLIdTypeLien!element],			
	NULL AS 	[AffL!90!AffLTypeLien!element],			
	NULL AS 	[AffL!90!AffLNom!element],			
	NULL AS 	[AffL!90!AffLDescription!element],			
	NULL AS 	[AffL!90!AffLIdType!element],		
	NULL AS 	[AffL!90!AffLType!element],		
	NULL AS 	[AffL!90!AffLDDebut!element],		
	NULL AS 	[AffL!90!AffLDOrder!element],		
	NULL AS 	[AffL!90!AffLBEnSuspens!element],
	NULL AS 	[AffL!90!AffLBTermine!element],
	
	NULL AS 	[DrEmp!110!DrEmpIdEmp!element],		
	NULL AS 	[DrEmp!110!DrEmpIdDroit!element],		
	NULL AS 	[DrEmp!110!DrEmpDroit!element],			
	NULL AS 	[DrEmp!110!DrEmpNomEmp!element],			
	NULL AS 	[DrEmp!110!DrEmpUOEmp!element],
	NULL AS 	[DrEmp!110!DrEmpBActif!element],
				
	NULL AS 	[DrUO!120!DrUOIdUO!element],			
	NULL AS 	[DrUO!120!DrUOIdDroit!element],			
	NULL AS 	[DrUO!120!DrUODroit!element],			
	NULL AS 	[DrUO!120!DrUONomUO!element],
	NULL AS 	[DrUO!120!DrUOBActif!element],
	
	NULL AS 	[DrGS!125!DrGSIdGS!element],			
	NULL AS 	[DrGS!125!DrGSIdDroit!element],			
	NULL AS 	[DrGS!125!DrGSDroit!element],			
	NULL AS 	[DrGS!125!DrGSNomGS!element],
	NULL AS 	[DrGS!125!DrGSBActif!element],
	
	NULL AS		[AffNomenclature!130!IdNomenclature!element],
	NULL AS		[AffNomenclature!130!Nomenclature!element],
	NULL AS		[AffNoCa!1310!Categorie!element],
	NULL AS		[AffNoCa!1310!CatOrder!hide],
			
	NULL AS 	[Suivi!150!SuiviId!element],
	NULL AS 	[Suivi!150!SuiviColor!element],
	NULL AS 	[Suivi!150!EmpId!element],
	NULL AS 	[Suivi!150!EmpNom!element],
	NULL AS 	[Suivi!150!EmpTel!element],
	NULL AS 	[Suivi!150!UOId!element],
	NULL AS 	[Suivi!150!UODesc!element],
	NULL AS 	[Suivi!150!UOColor!element],
	NULL AS 	[Suivi!150!UOOrder!element],
	NULL AS 	[Suivi!150!CreaId!element],
	NULL AS 	[Suivi!150!CreaNom!element],
	NULL AS 	[Suivi!150!ValidId!element],
	NULL AS 	[Suivi!150!ValidNom!element],
	NULL AS		[Suivi!150!DOrder!element],
	NULL AS 	[Suivi!150!DateOf!element],
	NULL AS 	[Suivi!150!DateCrea!element],
	NULL AS 	[Suivi!150!DateValid!element],
	NULL AS 	[Suivi!150!NbrSePoDe!element],
	NULL AS 	[Suivi!150!Commentaire!element],	 	
	NULL AS 	[DocSuivi!1510!DocId!element],		
	NULL AS 	[DocSuivi!1510!DocTitre!element],				
	NULL AS 	[DocSuivi!1510!DocFamille!element],				
	NULL AS 	[DocSuivi!1510!DocDateOf!element],				
	NULL AS 	[DocSuivi!1510!DocDOrder!element],
	NULL AS 	[DocSuivi!1510!DocNVersion!element],
	NULL AS 	[LSpeSuivi!1520!SpeCode!element],
	NULL AS 	[LSpeSuivi!1520!SpeId!element]
	
	,NULL AS	[Validation!160!IdEmploye!element]
	,NULL AS	[Validation!160!Employe!element]
	,NULL AS	[Validation!160!DateAction!element]
	,NULL AS	[Validation!160!DOrderAction!element]
	,NULL AS	[Validation!160!CodeValidation!element]
	,NULL AS	[Validation!160!DateSuppression!element]
	,NULL AS	[Validation!160!Commentaire!element]

	,NULL AS	[TdBCourrier!170!TdBIdEmploye!element]
	,NULL AS	[TdBCourrier!170!TdBIdEnveloppe!element]
	,NULL AS	[TdBCourrier!170!TdBIdDocument!element]
	,NULL AS	[TdBCourrier!170!TdBIdSuivi!element]
	
	FROM dbo.Affaire
	INNER JOIN dbo.TypeAffaire ON TypeAffaire.IdTypeAffaire = Affaire.IdTypeAffaire
	LEFT OUTER JOIN dbo.affaire_georeferencement ON affaire_georeferencement.IdAffaire = Affaire.IdAffaire
	WHERE Affaire.IdAffaire = @IdAffaire
UNION ALL	
SELECT 20,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	AffaireOrgUnit.IdOrgUnit,
	AffaireOrgUnit.IdRoleOU,
	DicoOrgUnitRole.Role,
	DicoOrgUnitRole.CodeOrdre,
	OrgUnit.Description,
	ISNULL(OrgUnit.DescTreeDenorm,OrgUnit.Description),
	dbo.CNShowDate(AffaireOrgUnit.DateBeginParticipate),
	dbo.CNShowDate(AffaireOrgUnit.DateEndParticipate),
	AffaireOrgUnit.Comment,
	OrgUnit.IsActive,
	ISNULL((SELECT dico.Ordre 
		FROM dbo.Affaire
		INNER JOIN dbo.AffaireOrgunit_dico_ordreuo dico ON dico.IdTypeAffaire=Affaire.IdTypeAffaire
								AND dico.IdOrgUnit=OrgUnit.IdOrgUnit
		WHERE Affaire.IdAffaire = @IdAffaire),9999),
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireOrgUnit
INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit=AffaireOrgUnit.IdOrgUnit
INNER JOIN dbo.DicoOrgUnitRole ON DicoOrgUnitRole.IdRole=AffaireOrgUnit.IdRoleOU
WHERE 	AffaireOrgUnit.IdAffaire = @IdAffaire
UNION ALL	
SELECT 30,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	AffaireEmploye.IdEmploye,
	AffaireEmploye.IdRoleEmp,
	DicoEmployeRole.Role,
	DicoEmployeRole.CodeOrdre,
	Employe.Nom + ' ' + Employe.Prenom,
	Employe.email,
	ISNULL(Employe.TelProf,''),
	OrgUnit.Description,
	OrgUnit.Prefix,
	dbo.CNShowDate(AffaireEmploye.DateBeginParticipate),
	dbo.CNShowDate(AffaireEmploye.DateEndParticipate),
	AffaireEmploye.Comment,
	Employe.IsActive,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireEmploye
INNER JOIN dbo.Employe on Employe.IdEmploye=AffaireEmploye.IdEmploye
INNER JOIN.DicoEmployeRole on DicoEmployeRole.IdRole=AffaireEmploye.IdRoleEmp
INNER JOIN dbo.Employe_OrgUnit on Employe_OrgUnit.IdEmploye = AffaireEmploye.IdEmploye AND Employe_OrgUnit.LevelOU = 0
INNER JOIN dbo.OrgUnit on OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
WHERE 	AffaireEmploye.IdAffaire = @IdAffaire
UNION ALL	
SELECT 40,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	ActeurRole.IdActeurRole,
	ActeurRole.IdActeur,
	Acteur.Name,
	ActeurRole.IdRole,
	DicoActeurRole.Role,	
	ActeurRole.Commentaire,
	Acteur.IsActive,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.ActeurRole
INNER JOIN dbo.DicoActeurRole ON DicoActeurRole.IdRole=ActeurRole.IdRole
INNER JOIN dbo.Acteur on Acteur.IdActeur=ActeurRole.IdActeur
WHERE 	ActeurRole.IdObject=@IdAffaire and
		ActeurRole.ObjectTableName = 'Affaire'
UNION ALL	
SELECT DISTINCT 50,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	Enveloppe.IdEnveloppe,
	Enveloppe.DateReceptionEnvoi,
	dbo.CNShowDate(Enveloppe.DateReceptionEnvoi),
	Enveloppe.EntrantOuSortant,
	Enveloppe.Titre,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.Enveloppe
INNER JOIN dbo.EnveloppeDocument on EnveloppeDocument.IdEnveloppe=Enveloppe.IdEnveloppe
INNER JOIN dbo.LienAffaireDocument on LienAffaireDocument.IdDocument=EnveloppeDocument.IdDocument
LEFT OUTER JOIN dbo.DocumentExcludeForLienAffEnv ON DocumentExcludeForLienAffEnv.IdDocument = EnveloppeDocument.IdDocument
WHERE 	LienAffaireDocument.IdAffaire = @IdAffaire AND
		DocumentExcludeForLienAffEnv.IdDocument IS NULL  --Certain document sont mis en annexe dans un grand nombre de courrier. Ne pas en tenir compte pour les courrier lié
UNION ALL	
SELECT 60,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	Document.IdDocument,
	Document.IdTypeDocument,
	(SELECT TypeDocument.Name FROM dbo.TypeDocument WHERE TypeDocument.IdTypeDocument=Document.IdTypeDocument),
	Document.IdDocFamily,
	(SELECT DocFamily.Name FROM dbo.DocFamily WHERE DocFamily.IdDocFamily = Document.IdDocFamily),
	Document.DocIsFromOutside,
	ISNULL(Document.DocDateOfficielle,'1900-01-01'),
	ISNULL(dbo.CNShowDate(Document.DocDateOfficielle),'Inconnue'),
	Document.DocTitle,
	Document.DocSubject,
	Document.DocNumVer,
	(SELECT COUNT(AffaireSuivi.IdAffaireSuivi)
	FROM dbo.AffaireSuivi
	INNER JOIN dbo.LienAffaireSuiviDocument ON LienAffaireSuiviDocument.IdAffaireSuivi = AffaireSuivi.IdAffaireSuivi
	WHERE	AffaireSuivi.IdAffaire = LienAffaireDocument.IdAffaire AND
			LienAffaireSuiviDocument.IdDocument = LienAffaireDocument.IdDocument AND
			AffaireSuivi.IdValideur IS NOT NULL),
			
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.LienAffaireDocument
INNER JOIN dbo.Document ON Document.IdDocument=LienAffaireDocument.IdDocument
WHERE 	LienAffaireDocument.IdAffaire=@IdAffaire
UNION ALL	
SELECT 65,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	AffaireUrl.Id,
	AffaireUrl.Url,
	ISNULL(AffaireUrl.Titre,AffaireUrl.Url),
	ISNULL(AffaireUrl.Cible,'_blank'),
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireUrl
WHERE 	AffaireUrl.IdAffaire=@IdAffaire
UNION ALL	
SELECT 70,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	Thing.IdThing,
	Thing.IdTypeThing,
	TypeThing.Name,
	Thing.IsActive,
	Thing.Name,
	ThingPosition.MinEO,
	ThingPosition.MinSN,
	ThingPosition.MaxEO,
	ThingPosition.MaxSN,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.LienThingAffaire
INNER JOIN dbo.Thing ON Thing.IdThing=LienThingAffaire.IdThing
INNER JOIN dbo.TypeThing ON TypeThing.IdTypeThing=Thing.IdTypeThing
LEFT OUTER JOIN dbo.ThingPosition ON ThingPosition.IdThing = LienThingAffaire.IdThing
WHERE 	LienThingAffaire.IdAffaire=@IdAffaire
UNION ALL	
SELECT 75,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	Thing.IdThing,
	Thing.Name,
	ThiBuilding.IdCodeStatus,
	(SELECT DicoBuildingCodeStatus.Status FROM dbo.DicoBuildingCodeStatus WHERE DicoBuildingCodeStatus.IdStatus = ThiBuilding.IdCodeStatus),
	--(SELECT MIN(RecensArch2.Note) 
	--FROM dbo.RecensArchLienThing
	--INNER JOIN dbo.RecensArch2 ON RecensArch2.IdGo = RecensArchLienThing.IdRecensGo
	--WHERE  RecensArchLienThing.IdThingGo = Thing.IdThing AND RecensArch2.Note IN (1,2,3,4) ),
	(SELECT MIN(recensement_architectural.Note) 
	FROM dbo.recensement_architectural
	WHERE  recensement_architectural.IdThing = Thing.IdThing AND recensement_architectural.Note IN (1,2,3,4) ),	
	(SELECT COUNT(Document.IdDocument)
	FROM dbo.LienThingDocument
	INNER JOIN dbo.Document ON Document.IdDocument = LienThingDocument.IdDocument AND Document.IdDocFamily = 109
	WHERE LienThingDocument.IdThing = Thing.IdThing),
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.LienThingAffaire
INNER JOIN dbo.ThiBuilding ON ThiBuilding.IdThing=LienThingAffaire.IdThing
INNER JOIN dbo.Thing ON Thing.IdThing=ThiBuilding.IdThing
WHERE 	LienThingAffaire.IdAffaire = @IdAffaire
UNION ALL	
SELECT 80,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	Thing.IdThing,
	Thing.Name,
	dbo.CNNomParcelleOrder(Thing.Name),
	Parcelle.IdEtat,
	(SELECT ParcelleDicoEtat.Etat FROM dbo.ParcelleDicoEtat WHERE ParcelleDicoEtat.IdEtat = Parcelle.IdEtat),
	Parcelle.ResumeProprietaire,
	ParcelleRaisonAnnulation.TxtRaisonAnnulation,

	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.LienThingAffaire
INNER JOIN dbo.Parcelle ON Parcelle.IdThing=LienThingAffaire.IdThing
INNER JOIN dbo.Thing ON Thing.IdThing=Parcelle.IdThing
LEFT OUTER JOIN dbo.ParcelleRaisonAnnulation ON ParcelleRaisonAnnulation.IdThing = Parcelle.IdThing
WHERE 	LienThingAffaire.IdAffaire = @IdAffaire

UNION ALL	
SELECT 801,
	80,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,dbo.CNNomParcelleOrder(Thing.Name),NULL,NULL,NULL,NULL,
	isos_dico_valeur.ISOSValeur,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.LienThingAffaire
INNER JOIN dbo.Parcelle ON Parcelle.IdThing=LienThingAffaire.IdThing
INNER JOIN dbo.Thing ON Thing.IdThing=Parcelle.IdThing
INNER JOIN dbo.thing_isos ON thing_isos.IdThing = Parcelle.IdThing
INNER JOIN dbo.isos_dico_valeur ON isos_dico_valeur.IdISOSValeur = thing_isos.IdISOSValeur
WHERE 	LienThingAffaire.IdAffaire = @IdAffaire

UNION ALL	
SELECT 90,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	LienAffaireAffaire.IdAffaire1,
	LienAffaireAffaire.IdTypeLien12,
	DicoTypeLienAffaireAffaire.DescTypeLien,
	Affaire.Name,
	Affaire.Description,
	Affaire.IdTypeAffaire,
	TypeAffaire.Name,
	dbo.CNShowDate(Affaire.DateBegin),
	Affaire.DateBegin,
	Affaire.IsSuspended,	
	Affaire.IsTerminated,
		
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.LienAffaireAffaire
INNER JOIN dbo.DicoTypeLienAffaireAffaire on DicoTypeLienAffaireAffaire.Id=LienAffaireAffaire.IdTypeLien12
INNER JOIN dbo.Affaire on Affaire.IdAffaire=LienAffaireAffaire.IdAffaire1
INNER JOIN dbo.TypeAffaire on TypeAffaire.IdTypeAffaire = Affaire.IdTypeAffaire
WHERE	LienAffaireAffaire.IdAffaire2 = @IdAffaire
UNION ALL	
SELECT 110,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	AffaireDroitEmpOrOU.IdEmpOrOU,
	AffaireDroitEmpOrOU.IdDroit,
	DicoAffaireDroitEmpOU.Droit,
	Employe.Nom + ' ' + Employe.Prenom,
	OrgUnit.Description,
	Employe.IsActive,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireDroitEmpOrOU
INNER JOIN dbo.Employe ON Employe.IdEmploye=AffaireDroitEmpOrOU.IdEmpOrOU
INNER JOIN dbo.DicoAffaireDroitEmpOU ON DicoAffaireDroitEmpOU.Id=AffaireDroitEmpOrOU.IdDroit
INNER JOIN dbo.Employe_OrgUnit ON Employe_OrgUnit.IdEmploye = Employe.IdEmploye AND Employe_OrgUnit.LevelOU = 0
INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
WHERE 	AffaireDroitEmpOrOU.IdAffaire=@IdAffaire And AffaireDroitEmpOrOU.EmpOrOU='E'
UNION ALL	
SELECT 120,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	AffaireDroitEmpOrOU.IdEmpOrOU,
	AffaireDroitEmpOrOU.IdDroit,
	DicoAffaireDroitEmpOU.Droit,
	OrgUnit.Description,
	OrgUnit.IsActive,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireDroitEmpOrOU
INNER JOIN dbo.OrgUnit on OrgUnit.IdOrgUnit=AffaireDroitEmpOrOU.IdEmpOrOU
INNER JOIN dbo.DicoAffaireDroitEmpOU on DicoAffaireDroitEmpOU.Id=AffaireDroitEmpOrOU.IdDroit
WHERE	AffaireDroitEmpOrOU.IdAffaire=@IdAffaire And AffaireDroitEmpOrOU.EmpOrOU='O'
UNION ALL	
SELECT 125,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	AffaireDroitEmpOrOU.IdEmpOrOU,
	AffaireDroitEmpOrOU.IdDroit,
	DicoAffaireDroitEmpOU.Droit,
	ISNULL(SecuriteGroupe.Commentaire, SecuriteGroupe.GroupName) + ' (' + SecuriteGroupe.GroupName + ')',
	SecuriteGroupe.BActif,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireDroitEmpOrOU
INNER JOIN dbo.SecuriteGroupe on SecuriteGroupe.IdGroupe=AffaireDroitEmpOrOU.IdEmpOrOU
INNER JOIN dbo.DicoAffaireDroitEmpOU on DicoAffaireDroitEmpOU.Id=AffaireDroitEmpOrOU.IdDroit
WHERE	AffaireDroitEmpOrOU.IdAffaire=@IdAffaire And AffaireDroitEmpOrOU.EmpOrOU='G'
UNION ALL	
SELECT DISTINCT 130,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	Nomenclature.IdNomenclature,
	Nomenclature.Nomenclature,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.NomenclatureCategorieAffaire
INNER JOIN dbo.NomenclatureCategorie ON NomenclatureCategorie.IdCategorie = NomenclatureCategorieAffaire.IdCategorie
INNER JOIN dbo.Nomenclature ON Nomenclature.IdNomenclature = NomenclatureCategorie.IdNomenclature
WHERE NomenclatureCategorieAffaire.IdAffaire = @IdAffaire
UNION ALL	
SELECT 1310,
	130,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NomenclatureCategorie.IdNomenclature,NULL,
	NomenclatureCategorie.Categorie,
	NomenclatureCategorie.CatForOrder,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.NomenclatureCategorieAffaire
INNER JOIN dbo.NomenclatureCategorie ON NomenclatureCategorie.IdCategorie = NomenclatureCategorieAffaire.IdCategorie
WHERE NomenclatureCategorieAffaire.IdAffaire = @IdAffaire
UNION ALL	
SELECT 150,
	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	AffaireSuivi.IdAffaireSuivi,
	AffaireSuivi.Color,
	AffaireSuivi.IdEmploye,
	EmployeE.Nom + ' ' + EmployeE.Prenom,
	EmployeE.TelProf,
	Employe_OrgUnit.IdOrgUnit,
	OrgUnit.Description,
	OrgUnit.Color,
	OrgUnit.OrderList,
	AffaireSuivi.IdCreator,
	EmployeC.Nom + ' ' + EmployeC.Prenom,
	AffaireSuivi.IdValideur,
	EmployeV.Nom + ' ' + EmployeV.Prenom,
	AffaireSuivi.DateOfficielle,
	dbo.CNShowDate(AffaireSuivi.DateOfficielle),
	dbo.CNShowDateTime(AffaireSuivi.DateCreated),
	dbo.CNShowDate(AffaireSuivi.DateValidation),
	NbrSePoDe = 	(SELECT COUNT(*) FROM dbo.SPDSeanceAffaireSuivi WHERE SPDSeanceAffaireSuivi.IdAffaireSuivi = AffaireSuivi.IdAffaireSuivi) +
			(SELECT COUNT(*) FROM dbo.SPDPointAffaireSuivi WHERE SPDPointAffaireSuivi.IdAffaireSuivi = AffaireSuivi.IdAffaireSuivi) +
			(SELECT COUNT(*) FROM dbo.SPDDecisionAffaireSuivi WHERE SPDDecisionAffaireSuivi.IdAffaireSuivi = AffaireSuivi.IdAffaireSuivi) ,
	AffaireSuivi.Commentaire,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireSuivi
INNER JOIN dbo.Employe EmployeE ON EmployeE.IdEmploye = AffaireSuivi.IdEmploye
INNER JOIN dbo.Employe_OrgUnit ON Employe_OrgUnit.IdEmploye = AffaireSuivi.IdEmploye AND Employe_OrgUnit.LevelOU = 0
INNER JOIN dbo.OrgUnit ON OrgUnit.IdOrgUnit = Employe_OrgUnit.IdOrgUnit
INNER JOIN dbo.Employe EmployeC ON EmployeC.IdEmploye = AffaireSuivi.IdCreator
LEFT OUTER JOIN dbo.Employe EmployeV ON EmployeV.IdEmploye = AffaireSuivi.IdValideur
WHERE 	AffaireSuivi.IdAffaire = @IdAffaire		
UNION ALL	
SELECT 1510,
	150,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	AffaireSuivi.IdAffaireSuivi,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	LienAffaireSuiviDocument.IdDocument,
	Document.DocTitle,
	(SELECT DocFamily.Name FROM dbo.DocFamily WHERE DocFamily.IdDocFamily = Document.IdDocFamily),
	dbo.CNShowDate(Document.DocDateOfficielle),
	Document.DocDateOfficielle,
	Document.DocNumVer,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireSuivi
INNER JOIN dbo.LienAffaireSuiviDocument ON LienAffaireSuiviDocument.IdAffaireSuivi = AffaireSuivi.IdAffaireSuivi
INNER JOIN dbo.Document ON Document.IdDocument = LienAffaireSuiviDocument.IdDocument
WHERE 	AffaireSuivi.IdAffaire = @IdAffaire
UNION ALL	
SELECT 1520,
	150,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	AffaireSuivi.IdAffaireSuivi,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	AffaireSuiviLienSpe.CodeLienSpe,
	AffaireSuiviLienSpe.IdSpe
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,NULL,NULL,NULL,NULL
FROM dbo.AffaireSuivi
INNER JOIN dbo.AffaireSuiviLienSpe ON AffaireSuiviLienSpe.IdAffaireSuivi = AffaireSuivi.IdAffaireSuivi
WHERE 	AffaireSuivi.IdAffaire = @IdAffaire

UNION ALL	
SELECT 160,	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,affaire_validation.id_employe
	,(SELECT Employe.Nom + ' ' + Employe.Prenom FROM dbo.Employe WHERE Employe.IdEmploye=affaire_validation.id_employe)
	,dbo.CNShowDateTime(affaire_validation.date_action)
	,affaire_validation.date_action
	,affaire_validation.code_validation
	,dbo.CNShowDateTime(affaire_validation.date_supression)
	,affaire_validation.commentaire

	,NULL,NULL,NULL,NULL
FROM dbo.affaire_validation
WHERE	affaire_validation.id_affaire=@IdAffaire

UNION ALL	
SELECT 170,	1,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,'zzz',NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,

	NULL,NULL,NULL,NULL,NULL,
	
	NULL,NULL,
	NULL,NULL,
	
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL,NULL,NULL,NULL,NULL,
	NULL,NULL
	
	,NULL,NULL,NULL,NULL,NULL,NULL,NULL

	,EnveloppeEmployeInteret.IdEmploye
	,EnveloppeEmployeInteret.IdEnveloppe
	,LienAffaireDocument.IdDocument
	,LienAffaireSuiviDocument.IdAffaireSuivi
FROM dbo.LienAffaireDocument
INNER JOIN dbo.EnveloppeDocument ON EnveloppeDocument.IdDocument=LienAffaireDocument.IdDocument
INNER JOIN dbo.EnveloppeEmployeInteret ON EnveloppeEmployeInteret.IdEnveloppe=EnveloppeDocument.IdEnveloppe
LEFT OUTER JOIN dbo.LienAffaireSuiviDocument ON LienAffaireSuiviDocument.IdDocument=LienAffaireDocument.IdDocument
WHERE LienAffaireDocument.IdAffaire=@IdAffaire 

ORDER BY 	[Suivi!150!SuiviId!element],[Parcelle!80!ParOrdre!element],[AffNomenclature!130!IdNomenclature!element],Tag,
			[UO!20!OUCROrdre!element],[UO!20!UOOrdre!element],[UO!20!UONom!element],
			[Emp!30!EmpCROrdre!element],[Emp!30!EmpNom!element],
			[AcR!40!AcRRoleActeur!element],[AcR!40!AcRNomActeur!element],
			[Url!65!UrlTitre!element],
			[Batiment!75!BatNom!element],[Obj!70!ObjNom!element],
			[DrEmp!110!DrEmpIdDroit!element],[DrEmp!110!DrEmpNomEmp!element],
			[DrUO!120!DrUOIdDroit!element],[DrUO!120!DrUONomUO!element],[DrGS!125!DrGSNomGS!element],
			[DocSuivi!1510!DocId!element],[LSpeSuivi!1520!SpeId!element]
			,[Validation!160!DOrderAction!element]
			,[TdBCourrier!170!TdBIdSuivi!element] DESC
FOR XML EXPLICIT
GO

