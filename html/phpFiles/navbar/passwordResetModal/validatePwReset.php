<?php

include "../../database/dbConnection.php";
include "../../classes/inputValidation.php";

session_start();

header('Content-Type: application/json; charset=ISO-8859-1');
mysqli_set_charset($conn, 'utf8');

$returnMsg = array();
$returnMsg["success"] = false;
$username = new ExistingUsernameValidation();
$email = new ExistingEmailValidation();

if(isset($_POST["username"])&&isset($_POST["email"])){

    $username->setContent($_POST["username"]);
    $email->setContent($_POST["email"]);
    $email->setUsername($username->getContent());

    if($username->getValid()){
        
        if($email->getValid()){
            //uid wird aus db geholt
            $sql="SELECT UID FROM user WHERE Username='".$username->getContent()."'";
            $result=$conn->query($sql);
            $row=$result->fetch_assoc();
            $uid=$row["UID"];
            /*
                Resetcode wird generiert
            */
            $resetCode=md5(rand());
            /*
            * Resetcode wird in DB eingetragen
            */
            $conn->query("UPDATE user SET PasswortResetCode='$resetCode' WHERE UID = $uid");
            /*
                Email zum Passwort zurücksetzen wird gesendet

             * Daten f�r reset-mail werden definiert
             */
            $empfaenger=$email->getContent();
            $betreff="passwordreset";

            $msg="https://webshop.schlagh.com/enternewPW.php?UID=$uid&rc=$resetCode";
            /*
             * mail wird gesendet
             */
            require_once("../../phpMailer/phpMail.php");
            $returnMsg["mail"] = phpMail($empfaenger,$betreff,$msg);

            $returnMsg["success"] = true;
        }
    }
}

$returnMsg["usernameError"] = $username->getErrorMsg();
$returnMsg["emailError"] = $email->getErrorMsg();

echo(json_encode($returnMsg));