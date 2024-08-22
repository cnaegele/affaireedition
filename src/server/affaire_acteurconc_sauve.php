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
        $acteursConcernes = $oData->acteursConcernes;
        //echo json_encode($oData);
        $sidsAR = '';
        foreach ($acteursConcernes as $acteurConcerne) {
            if ($acteurConcerne->idacrole !== '0') {
                if ($sidsAR === '') {
                    $sidsAR .= strval($acteurConcerne->idacrole);
                } else {
                    $sidsAR .= ',' . strval($acteurConcerne->idacrole);
                }
            }
        }
        $dbgo = new DBGoeland();

        $sSql = "cn_affaire_acteurrole_supprime $idAffaire, $idCaller, '$sidsAR'";
        //echo '{"message":"OK","sSql":"' . $sSql . '"}';
        $dbgo->queryRetInt($sSql, 'W');
        $nbrDelete = $dbgo->resInt;

        $nbrInsert = 0;
        $nbrUpdate = 0;
        foreach ($acteursConcernes as $acteurConcerne) {
            $idActeurRole = $acteurConcerne->idacrole;
            $idActeur = $acteurConcerne->idacteur;
            $idRole = $acteurConcerne->idrole;
            $commentaire = prepareMSSQLvarchar($acteurConcerne->commentaire);
            $sSql = "cn_affaire_acteurrole_sauve $idActeurRole, $idActeur, $idAffaire, $idRole, $idCaller";
            if ($commentaire === '') {
                $sSql .= ", NULL";
            } else {
                $sSql .= ", '$commentaire'";
            }
            $dbgo->queryRetInt($sSql, 'W');
            if ($dbgo->resInt > 0) {
                if ($idActeurRole === 0) {
                    $nbrInsert++;
                } else {
                    $nbrUpdate++;
                }
            }
        }

        unset($dbgo);
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


