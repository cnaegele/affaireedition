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
        $employesConcernes = $oData->employesConcernes;
        //echo json_encode($oData);
        $sidsEmp = '';
        foreach ($employesConcernes as $employeConcerne) {
            if ($sidsEmp === '') {
                $sidsEmp .= strval($employeConcerne->idemploye);
            } else {
                $sidsEmp .= ',' . strval($employeConcerne->idemploye);
            }
        }
        $dbgo = new DBGoeland();

        $sSql = "cn_affaire_employe_supprime $idAffaire, $idCaller, '$sidsEmp'";
        //echo '{"message":"OK","sSql":"' . $sSql . '"}';
        $dbgo->queryRetInt($sSql, 'W');
        $nbrDelete = $dbgo->resInt;

        $nbrInsert = 0;
        $nbrUpdate = 0;
        foreach ($employesConcernes as $employeConcerne) {
            $idEmploye = $employeConcerne->idemploye;
            $idRole = $employeConcerne->idrole;
            $dateDebutParticipe = $employeConcerne->datedebutparticipe;
            $dateFinParticipe = $employeConcerne->datefinparticipe;
            $commentaire = prepareMSSQLvarchar($employeConcerne->commentaire);
            $sSql = "cn_affaire_employe_sauve $idAffaire, $idEmploye, $idRole, $idCaller";
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
        unset($dbgo);
        echo '{"message":"OK","informations":"suppression:' . strval($nbrDelete) . ' nouveau: ' . strval($nbrInsert) . ' modification: ' . strval($nbrUpdate) . '"}';
    } else {
        echo '{"message":"ERREUR AffaireManager requis"}';
    }
} else {
    echo '{"message":"ERREUR athentification F5"}';
}

function prepareMSSQLvarchar($str) {
    $str = trim($str);
    $str = str_replace("'", "''", $str);
    $str = utf8go_decode($str);
    return $str;
}


