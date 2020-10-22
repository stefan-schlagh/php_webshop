<?php

include "../../database/dbConnection.php";
include "../../classes/inputValidation.php";

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
        Es wird die Email von einem User upgedatet
    */
    $uid = $_SESSION["userID"];
    
    if(isset($_POST["email"])){

        $email = new NewEmailValidation();

        $email->setContent($_POST["email"]);

        if($email->getValid() || $email->getContent()==""){
            /*
            * neue Email wird in DB eingetragen
            */
            $conn->query("UPDATE user SET Email = '".$email->getContent()."'
                WHERE UID=$uid");
            $returnMsg["success"] = true;

        }else{
            $returnMsg["success"] = false;
            $returnMsg["error"] = $email->getErrorMsg();
        }

    }
    $returnMsg["loggedIn"] = true;
}else{
    $returnMsg["success"] = false;
    $returnMsg["loggedIn"] = false;
}

echo json_encode($returnMsg);