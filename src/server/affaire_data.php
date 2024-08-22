<?php
require_once 'gdt/cldbgoeland.php';
header("Access-Control-Allow-Origin: *");
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
    $sSql = "CN_AffaireData $idAffaire";
    $dbgo = new DBGoeland();
    $dbgo->queryRetSpXml2Json($sSql);
    echo $dbgo->resString;
    unset($dbgo);
} else {
    echo '{}';
}