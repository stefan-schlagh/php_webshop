<?php
include_once $_SERVER['DOCUMENT_ROOT']."/phpFiles/classes/cart.php";
include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";

header('Content-Type: text/html; charset=ISO-8859-1');
session_start();

$cart = new cart(); 

$cart->initial_cart();

if(isset($_POST["number"])){
    if($_POST["number"]!="")
        $cart->setNumArray(json_decode($_POST["number"]));
}

if(isset($_POST["indexDelete"])){
    if($_POST["indexDelete"]!=-1)
        $cart->deleteCartValueAtIndex($_POST["indexDelete"]);
}


$cart->getCart();