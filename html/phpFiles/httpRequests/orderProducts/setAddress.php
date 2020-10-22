<?php
include $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/database/dbConnection.php";

session_start();

header('Content-Type: application/json; charset=ISO-8859-1');
mysqli_set_charset($conn, 'utf8');

$returnMsg = array();
/*
    es wird überprüft, ob User eingeloggt 
    wenn nicht: DB- Abfrage wird nicht durchgeführt
*/
if(isset($_SESSION["userID"])){
    /*
        Es wird die Addresse von einem User abgefragt
    */
    $uid = $_SESSION["userID"];
    
    if(isset($_POST["land"])&&isset($_POST["ort"])&&isset($_POST["plz"])&&isset($_POST["street"])&&isset($_POST["hnr"])){

        $land = $_POST["land"];

        $ort = $_POST["ort"];

        $plz = $_POST["plz"];

        $street = $_POST["street"];

        $hnr = $_POST["hnr"];

        /*
        * neue Addresse wird in DB eingetragen
        */
        $conn->query("UPDATE user SET 
            Land = '$land',Ort = '$ort',PLZ = $plz ,Strasse='$street',HausNr = $hnr
            WHERE UID=$uid");

    }
    $returnMsg["loggedIn"] = true;
}else{
    $returnMsg["loggedIn"] = false;
}

echo json_encode($returnMsg);