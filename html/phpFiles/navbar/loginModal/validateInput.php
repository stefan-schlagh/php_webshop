<?php

include "../../database/dbConnection.php";
include "../../classes/inputValidation.php";
include_once $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/classes/cart.php";

session_start();

$cart = new cart();
//cart wird vor login mind. einmal initialisiert
$cart->initial_cart();

header('Content-Type: application/json; charset=ISO-8859-1');
mysqli_set_charset($conn, 'utf8');

$returnMsg = array();
$returnMsg["success"] = false;
$username = new ExistingUsernameValidation;
$password=new ExistingPasswordValidation;


if(isset($_POST["username"])&&isset($_POST["password"])){

    $username->setContent($_POST["username"]);
    $password->setContent($_POST["password"]);
    $password->setUsername($username->getContent());

    if($username->getValid()){
        
        if($password->getValid()){
            $sql="SELECT UID FROM user WHERE Username='".$username->getContent()."'";
            $result=$conn->query($sql);
            $row=$result->fetch_assoc();
            $UID=$row["UID"];
            /** 
             * PW + Username i. O.:
            * Session-Cookies zur Useridentifikation werden gesetzt
            */
            $_SESSION["username"]=$username->getContent();
            $_SESSION["userID"]=$UID;
            /*
                * wenn die Checkbox remember gesetzt ist:
                * Cookie wird gesetzt
                */
            if(isset($_POST["remember"])){
                if($_POST["remember"]=="true")
                    setcookie("loggedIn",$UID,time() + (86400), "/");
            }
            $returnMsg["success"] = true;
        }
    }
}

$returnMsg["usernameError"] = $username->getErrorMsg();
$returnMsg["passwordError"] = $password->getErrorMsg();

echo(json_encode($returnMsg));

