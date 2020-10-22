<?php
include_once $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/classes/cart.php";
session_start();

include $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/database/dbConnection.php";


$cart = new cart(); 

$cart->initial_cart();

$pid=$_POST["pid"];
$bez=$_POST["bez"];
$price=$_POST["price"];
$num=$_POST["num"];

$cart->insertArtikel($pid,$bez,$price,$num);

$cart->getCart();
