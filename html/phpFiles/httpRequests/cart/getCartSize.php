<?php
include_once $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/classes/cart.php";
include $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/database/dbConnection.php";

header('Content-Type: application/json charset=ISO-8859-1');
session_start();

$cart = new cart(); 
$cart->initial_cart();

mysqli_set_charset($conn, 'utf8');

$conn->query("SET @p0 = '".$_SESSION['userID']."'");

$result = $conn->query("CALL `selectCart`(@p0)");

$size = array();
if($row = $result->fetch_assoc()){
    $size["dbCart"] = intval($row["cart"]);
}else{
    $size["dbCart"] = 0;
}
$size["sessionCart"] = $cart->getCartCount();

echo json_encode($size);