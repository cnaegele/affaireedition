<?php
require 'gdt/gautentificationf5.php';
require_once '/data/dataweb/GoelandWeb/webservice/employe/clCNWSEmployeSecurite.php';
require_once 'gdt/cldbgoeland.php';
require_once 'gdt/utf8go.php';
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers:  *");
header("Access-Control-Allow-Methods:  POST");
$idCaller = 0;
if (array_key_exists('empid', $_SESSION)) {
    $idCaller = $_SESSION['empid'];
}
if ($idCaller > 0) {
    $pseudoWSEmployeSecurite = new CNWSEmployeSecurite();
    if ($pseudoWSEmployeSecurite->isInGroupe($idCaller, 'AffaireManager')) {
        $jsonData = file_get_contents('php://input');
        $oData = json_decode($jsonData);
        $idAffaire = $oData->idAffaire;
        //TODO vérification droit sur l'affaire
        //...
        $unitesOrgConcernes = $oData->unitesOrgConcernes;
        //echo json_encode($oData);
        $sidsUO = '';
        foreach ($unitesOrgConcernes as $uniteOrgConcerne) {
            if ($sidsUO === '') {
                $sidsUO .= strval($uniteOrgConcerne->iduniteorg);
            } else {
                $sidsUO .= ',' . strval($uniteOrgConcerne->iduniteorg);
            }
        }
        $dbgo = new DBGoeland();

        $sSql = "cn_affaire_orgunit_supprime $idAffaire, $idCaller, '$sidsUO'";
        //echo '{"message":"OK","sSql":"' . $sSql . '"}';
        $dbgo->queryRetInt($sSql, 'W');
        $nbrDelete = $dbgo->resInt;

        $nbrInsert = 0;
        $nbrUpdate = 0;
        foreach ($unitesOrgConcernes as $uniteOrgConcerne) {
            $idUniteOrg = $uniteOrgConcerne->iduniteorg;
            $idRole = $uniteOrgConcerne->idrole;
            $dateDebutParticipe = $uniteOrgConcerne->datedebutparticipe;
            $dateFinParticipe = $uniteOrgConcerne->datefinparticipe;
            $commentaire = prepareMSSQLvarchar($uniteOrgConcerne->commentaire);
            $sSql = "cn_affaire_orgunit_sauve $idAffaire, $idUniteOrg, $idRole, $idCaller";
            if ($dateDebutParticipe === '') {
                $sSql .= ", NULL";
            } else {
                $sSql .= ", '$dateDebutParticipe'";
            }
            if ($dateFinParticipe === '') {
                $sSql .= ", NULL";
            } else {
                $sSql .= ", '$dateFinParticipe'";
            }
            if ($commentaire === '') {
                $sSql .= ", NULL";
            } else {
                $sSql .= ", '$commentaire'";
            }
            $dbgo->queryRetString($sSql, 'W');
            if ($dbgo->resString == 'insert') {
                $nbrInsert++;
            } elseif ($dbgo->resString == 'update') {
                $nbrUpdate++;
            }
        }
        //echo '{"message":"OK","sSql":"' . $sSql . '"}';

        //unset($dbgo);
        echo '{"message":"OK","informations":"suppression:' . strval($nbrDelete) . ' nouveau: ' . strval($nbrInsert) . ' modification: ' . strval($nbrUpdate) . '"}';
    } else {
        echo '{"message":"ERREUR AffaireManager requis"}';
    }
} else {
    echo '{"message":"ERREUR athentification F5"}';
}

function prepareMSSQLvarchar($str) {
    $str = str_replace("'", "''", $str);
    $str = utf8go_decode($str);
    return $str;
}


