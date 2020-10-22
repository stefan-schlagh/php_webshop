<?php
include_once $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/classes/cart.php";

header('Content-Type: application/json; charset=ISO-8859-1');
session_start();

$cart = new cart(); 

$cart->initial_cart();

$returnMsg = array();

$returnMsg["cartLength"] = $cart->getCartCount();

if(isset($_SESSION["userID"]))
    $returnMsg["loggedIn"] = true;
else
    $returnMsg["loggedIn"] = false;

echo json_encode($returnMsg);