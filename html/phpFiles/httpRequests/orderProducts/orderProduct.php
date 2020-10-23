<?php

include_once $_SERVER['DOCUMENT_ROOT']."/phpFiles/classes/cart.php";
include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";

session_start();

header('Content-Type: application/json; charset=ISO-8859-1');
mysqli_set_charset($conn, 'utf8');

$returnMsg = array();

/*
    es wird überprüft, ob User eingeloggt 
    wenn nicht: DB- Abfrage wird nicht durchgeführt
*/
if(isset($_SESSION["userID"])){

    $uid = $_SESSION["userID"];

    $conn->query("SET @p0 = '$uid'");
    $result = $conn->query("CALL `orderProducts`(@p0)");

    if($row=$result->fetch_assoc()){
        $returnMsg["bid"] = $row["bid"];
    }

    $returnMsg["loggedIn"] = true;
}else{
    $returnMsg["loggedIn"] = false;
}

$cart = new cart();

$cart->deleteCart();

echo json_encode($returnMsg);