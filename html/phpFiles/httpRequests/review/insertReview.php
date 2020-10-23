<?php

include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php"; 
session_start();

header('Content-Type: txt; charset=ISO-8859-1');
mysqli_set_charset($conn, 'utf8');

$pid = $_POST["pid1"];

$uid = 0;
if(isset($_SESSION["userID"])){
    $uid = $_SESSION["userID"];
    $rating = $_POST["rating1"];
    $reviewText = $_POST["reviewText"];

    $conn->query("SET @p0 = '$pid'");
    $conn->query("SET @p1 = '$uid'");
    $conn->query("SET @p2 = '$rating'");
    $conn->query("SET @p3 = '$reviewText'");

    //$result = $conn->query("SELECT * FROM produkt");
    $result = $conn->query("CALL `insertReview`(@p0,@p1,@p2,@p3)");

}
else http_response_code(401);//no authentification