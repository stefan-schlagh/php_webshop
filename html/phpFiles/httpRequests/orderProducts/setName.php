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
    
    if(isset($_POST["vorname"])&&isset($_POST["nachname"])){

        $vorname = $_POST["vorname"];

        $nachname = $_POST["nachname"];

        /*
        * neue Addresse wird in DB eingetragen
        */
        $conn->query("UPDATE user SET 
            Vorname = '$vorname',Nachname = '$nachname'
            WHERE UID=$uid");

    }
    $returnMsg["loggedIn"] = true;
}else{
    $returnMsg["loggedIn"] = false;
}

echo json_encode($returnMsg);