<?php
include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";

header('Content-Type: application/json; charset=ISO-8859-1');

$pid = $_POST["pid"];

mysqli_set_charset($conn, 'utf8');
$conn->query("SET @p0 = '$pid'");

$result = $conn->query(" CALL `selectProductInformation`(@p0)");

if($row = $result->fetch_assoc()){
    echo json_encode($row);
}else{
    //kein Resultat gefunden
    http_response_code(404);//not found
}