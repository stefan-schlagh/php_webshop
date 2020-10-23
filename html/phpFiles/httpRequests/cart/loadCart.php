<?php
include_once $_SERVER['DOCUMENT_ROOT']."/phpFiles/classes/cart.php";
include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";

header('Content-Type: text/html; charset=ISO-8859-1');
session_start();

$cart = new cart(); 

$cart->initial_cart();

/*
    -1 --> nichts wird geändert
    1  --> CID in Tabelle user aendern, user hat keinen Warenkorb gespeichert
    2  --> in Session ist kein Warenkorb gespeichert, der von user wird geladen
    3  --> in Session ist Warenkorb gespeichert, wird überschrieben und der von user geladen
    4  --> in Tabelle usr ist Warenkorb vorhanden, wird belassen, CID bei user wird geaendert, cart von user wird gelöscht
*/
$action = -1;
if(isset($_POST["action"])){
    $action = $_POST["action"];
}

$uid = $_SESSION["userID"];
$sessionCid = $cart->getCid();

switch($action){
    case 1:
        $conn->query("UPDATE user SET cartId = '$sessionCid' WHERE UID = $uid");
        break;
    case 2:
        $cart->loadCart($_SESSION["userID"]);
        break;
    case 3:
        $cart->loadCart($_SESSION["userID"]);
        break;
    case 4:
        $uid = $_SESSION["userID"];
        $conn->query("DELETE FROM cart WHERE CID = (SELECT cartId FROM user WHERE UID = $uid)");
        $conn->query("UPDATE user SET cartId = '$sessionCid' WHERE UID = $uid");
        break;
}