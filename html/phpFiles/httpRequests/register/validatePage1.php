<?php

include "../../database/dbConnection.php";
include "../../classes/inputValidation.php";


session_start();
header('Content-Type: application/json; charset=ISO-8859-1');

$username = new NewUsernameValidation();
$email = new NewEmailValidation();
$password = new NewPasswordValidation();
$userNameAlreadySaved;
$uid = 0;
$returnMsg = array();

if(isset($_POST["username"])&&isset($_POST["vorname"])&&isset($_POST["nachname"])&&isset($_POST["email"])&&isset($_POST["password"])&&isset($_POST["password2"])&&isset($_POST["uid"])){
    /*
        usernameAlreadySaved wird aus Post geholt, es muss aber noch geschaut werden ob das stimmt
    */
    $userNameAlreadySaved = json_decode($_POST["usernameAlreadySaved"]);
    /*
        wenn uid 0 ist, wird userNameAlreadySaved false gesetzt
    */
    $uid = $_POST["uid"];
    if($uid==0){
        $userNameAlreadySaved = false;
    }
    /*
        es wird in DB nachgeschaut, ob username gleichgeblieben ist
    */
    else if($userNameAlreadySaved){
        
        $result=$conn->query("SELECT Username FROM notverifieduser WHERE UID = $uid");
        if($row=$result->fetch_assoc()){
            if($row["username"] == $_POST["username"])
                $username = new AlreadySavedUsernameValidation();
            else
                $userNameAlreadySaved = false;
        }else
            $userNameAlreadySaved = false;
   
    }
    

    $username->setContent($_POST["username"]);
    $vorname = $_POST["vorname"];
    $nachname = $_POST["nachname"];
    $email->setContent($_POST["email"]);
    $password->setContent($_POST["password"]);
    $password->setContent2($_POST["password2"]);

    if($username->getValid()&&$email->getValid()&&$password->getValid()){
        $returnMsg["success"] = true;
        /**
         * Passwort wird auf alreadySaved gesetzt, wenn alreadysaved=true
         */
        if($userNameAlreadySaved){
            $password->setAlreadySaved(true);
            /*
                Information werden in DB upgedatet 
            */
            $hash = NewPasswordValidation::hashPassword($password->getContent());
            $conn->query("UPDATE notverifieduser SET 
                    Username = '".$username->getContent()."', Vorname = '$vorname', Nachname = '$nachname',
                    Password = '$hash', Email = '".$email->getContent()."',
                    Land = '$land',Ort = '".$ort->getContent()."',PLZ = ".$plz->getContent()." WHERE UID=$uid");
    
        }else{

            $hash = NewPasswordValidation::hashPassword($password->getContent());
            /*
                user wird in DB gespeichert
            */
            $sql = "INSERT into notverifieduser (Username,Vorname,Nachname,Password,EMail,creationDate,creationTime) 
                    values ('".$username->getContent()."','$vorname','$nachname','$hash','".$email->getContent()."',CURRENT_DATE(),CURRENT_TIME())";
            $conn->query($sql);
            $userNameAlreadySaved = true;
            /**
             * UID des neu angelegten Users wird aus der Datenbank geholt
             */
            $result = mysqli_query($conn,"SELECT UID FROM notverifieduser WHERE Username='".$username->getContent()."'");
            if($row = $result->fetch_assoc()){
               $uid = $row["UID"];
            }
        }
    }else{
        $returnMsg["success"] = false;
    }
}else{
    $returnMsg["success"] = false;
}
$returnMsg["uid"]=$uid;
$returnMsg["usernameAlreadySaved"] = $userNameAlreadySaved;
$returnMsg["usernameError"] = $username->getErrorMsg();
$returnMsg["emailError"] = $email->getErrorMsg();
$returnMsg["pswError"] = $password->getErrorMsg();

echo json_encode($returnMsg);