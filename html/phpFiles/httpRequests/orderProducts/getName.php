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
        Es wird der Name von einem User abgefragt
    */
    $uid = $_SESSION["userID"];
    $result = $conn->query("SELECT Vorname, Nachname FROM user WHERE UID = $uid");

    if($row = $result->fetch_assoc()){
        $returnMsg = $row;
    }
    $returnMsg["loggedIn"] = true;
}else{
    $returnMsg["loggedIn"] = false;
}

echo json_encode($returnMsg);