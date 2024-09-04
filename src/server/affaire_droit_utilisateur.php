<?php
require 'gdt/gautentificationf5.php';
require_once 'gdt/cldbgoeland.php';
header("Access-Control-Allow-Origin: *");
$idCaller = 0;
if (array_key_exists('empid', $_SESSION)) {
    $idCaller = $_SESSION['empid'];
}
if ($idCaller > 0) {
    $bPrmIdAffaireOk = false;
    if (isset($_GET['idaffaire'])) {
        $idAffaire = $_GET['idaffaire'];
        if (strlen($idAffaire) < 11) {
            $pattern = '/^\d+$/';
            if (preg_match($pattern, $idAffaire)) {
                $bPrmIdAffaireOk = true;
            }
        }
    }
    if ($bPrmIdAffaireOk) {
        $contexte = 'nondefini';
        if (isset($_GET['contexte'])) {
            $contexte = $_GET['contexte'];
        }
        $sSql = "CN_AffaireDroitPourEmploye $idCaller,$idAffaire,'$contexte'";
        $dbgo = new DBGoeland();
        $dbgo->queryRetInt($sSql);
        $iDroit = $dbgo->resInt;
        switch ($iDroit) {
            case 0:
                $sDroit = 'NODROIT';
                break;
            case 1:
                $sDroit = 'CONTROLETOTAL';
                break;
            case 2:
                $sDroit = 'MODIFICATION';
                break;
            case 3:
                $sDroit = 'AJOUTSUIVIDOCUMENT';
                break;
            case 4:
                $sDroit = 'CONSULTATION';
                break;
            case 5:
                $sDroit = 'NOACCES';
                break;
            default:
                $sDroit = 'INCONNU';
                break;
        }
        echo '{"droit":"' . $sDroit .'","message":"ok"}';
    } else {
        echo '{"droit":"NODROIT","message":"ERREUR PARAMETRE idaffaire invalide"}';
    }
}  else {
    echo '{"droit":"NODROIT","message":"ERREUR athentification F5"}';
}