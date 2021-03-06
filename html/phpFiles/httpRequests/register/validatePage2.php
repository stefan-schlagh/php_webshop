<?php

include "../../database/dbConnection.php";
include "../../classes/inputValidation.php";


session_start();
header('Content-Type: application/json; charset=ISO-8859-1');

$returnMsg=array();

if(isset($_POST["email"])&&isset($_POST["land"])&&isset($_POST["ort"])&&isset($_POST["plz"])&&isset($_POST["street"])&&isset($_POST["hnr"])){

    $email = $_POST["email"];

    $land = $_POST["land"];
    if($land == "Select country")
        $land="";

    $ort = $_POST["ort"];

    $plz = $_POST["plz"];
    if($plz=="")
        $plz=0;

    $street = $_POST["street"];

    $hnr = $_POST["hnr"];
    if($hnr=="")
        $hnr=0;

    $uid = $_POST["uid"];
    /*
        verificationCode wird zufaellig generiert
    */
    $verificationCode=md5(rand());
    /*
    * verificationCode wird in DB eingetragen
    */
    $conn->query("UPDATE notverifieduser SET 
                    Land = '$land',Ort = '$ort',PLZ = $plz ,Strasse='$street',HausNr = $hnr,
                    verificationCode='$verificationCode' WHERE UID = $uid");
    /*
        * Daten fuer verification-mail werden definiert
        */
    $empfaenger=$email;
    $betreff="verification";

    $msg="https://webshop.schlagh.com/verifyUser.php?UID=$uid&vc=$verificationCode";
    /*
        * mail wird gesendet
    */
    require_once("../../phpMailer/phpMail.php");
    $returnMsg["mail"] = phpMail($empfaenger,$betreff,$msg);

    $returnMsg["success"] = true;

}else{
    $returnMsg["success"] = false;
}

echo json_encode($returnMsg);