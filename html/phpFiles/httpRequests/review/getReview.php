<?php

include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php"; 
session_start();

header('Content-Type: application/json; charset=ISO-8859-1');
mysqli_set_charset($conn, 'utf8');

$pid = $_POST["pid1"];
$start = $_POST["start"];
$size = $_POST["size"];


$conn->query("SET @p0 = '$pid'");
$conn->query("SET @p1 = '$start'");
$conn->query("SET @p2 = '$size'");

$result = $conn->query("CALL `selectReview`(@p0,@p1,@p2)");

$reviews = array();

while($row = $result->fetch_assoc()){
    $row["ReviewText"] = nl2br($row["ReviewText"] ,false);
    $reviews[] = $row;
}
$result->close();
$conn->next_result();

echo json_encode($reviews);