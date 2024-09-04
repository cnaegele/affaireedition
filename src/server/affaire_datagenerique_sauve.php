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
        $oDataGenerique = json_decode($jsonData);
        $idAffaire = $oDataGenerique->id;
        //TODO vérification droit sur l'affaire
        //...
        $nom = prepareMSSQLvarchar($oDataGenerique->nom);
        $description = prepareMSSQLvarchar($oDataGenerique->description);
        $commentaire = prepareMSSQLvarchar($oDataGenerique->commentaire);
        $dateDebut = $oDataGenerique->dateDebut;
        $dateFin = $oDataGenerique->dateFin;
        $bTermine = '0';
        if ($oDataGenerique->bTermine) {
            $bTermine = '1';
        }

        $sSql = "cn_affaire_datagenerique_sauve $idAffaire, $idCaller, '$nom', '$dateDebut'";
        if ($dateFin !== '') {
            $sSql .= ", '$dateFin'";
        } else {
            $sSql .= ", NULL";
        }
        $sSql .= ", $bTermine";
        if ($description !== '') {
            $sSql .= ", '$description'";
        } else {
            $sSql .= ", NULL";
        }
        if ($commentaire !== '') {
            $sSql .= ", '$commentaire'";
        } else {
            $sSql .= ", NULL";
        }
        //echo '{"message":"OK","sSql":"' . $sSql . '"}';
        $dbgo = new DBGoeland();
        $dbgo->queryRetNothing($sSql, 'W');
        unset($dbgo);
        echo '{"message":"OK","informations":"update affaire ' . $idAffaire . '"}';
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


