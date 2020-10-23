<?php
include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";

header('Content-Type: application/json; charset=ISO-8859-1');

$searchValue = $_POST["searchValue"];
$start = $_POST["start"];
$siteSize = $_POST["siteSize"];

$catString = $_POST["cat"];
$catString = "[".str_replace("_",",",$catString)."]";

$subCatString = $_POST["subcat"];
$subCatString = "[".str_replace("_",",",$subCatString)."]";

mysqli_set_charset($conn, 'utf8');
//Die Anzahl der Produkte wird abgefragt
$conn->query("SET @p0 = '$searchValue'");
//$x = $start+1;
$conn->query("SET @p1 = '$start'");
$conn->query("SET @p2 = '$siteSize'");
$conn->query("SET @p3 = '$catString'");
$conn->query("SET @p4 = '$subCatString'");
$conn->query("SET @p5 = ''");//empty

$result = $conn->query("CALL `selectAllProducts`(@p3,@p4,@p0)");
$resultCount = $result -> num_rows;
$result->close();
$conn->next_result();

//Produkte für jeweilige Seite werden abgefragt
if($start>$resultCount){
    $conn->query("SET @p1 = '0'");
    settype($start,"integer");
    $start=$resultCount;
}
$result = $conn->query("CALL `selectProductLimit`(@p0,@p1,@p2,@p3,@p4)");

//Result wird in Array gespeichert
$products = array();
/*while($row = $result->fetch_row()){
    $product = new product($row[0],$row[1],$row[2],$row[3],$row[5],$row[7]);
    $products[]= $product->jsonSerialize();
}*/
while($row = $result->fetch_assoc()){
    //$products[] = json_encode($row);
    $products[] = $row;
}
//
//echo count($products);
/*for($i=0;$i<count($products);$i++){
    echo($products[$i]);
}*/
$json = array();
$json["resultCount"]=$resultCount;
$json["start"]=$start;
$json["products"]=$products;
echo json_encode($json);
