<?php
include $_SERVER['DOCUMENT_ROOT']."/phpProjects/webshop/phpFiles/database/dbConnection.php";

header('Content-Type: application/json; charset=ISO-8859-1');

/*
    Daten aus request werden übernommen
*/
$searchValue = $_POST["searchValue"];
$catString = $_POST["cat"];

/*
    cat-String wird in Array umgewandelt
*/
$catString = "[".str_replace("_",",",$catString)."]";


$subCatString = $_POST["subcat"];
$subCatString = "[".str_replace("_",",",$subCatString)."]";


mysqli_set_charset($conn, 'utf8');

$conn->query("SET @p0 = '$searchValue'");
$conn->query("SET @p3 = '$catString'");//catlist
$conn->query("SET @p4 = '$subCatString'");//subcatlist
$conn->query("SET @p5 = ''");//empty

$result = $conn->query("CALL `selectAllProducts`(@p5,@p5,@p0)");
$resultCount = $result -> num_rows;
$result->close();
$conn->next_result();

$result = $conn->query("CALL `selectCategorys`(@p0,@p5)");

$category = array();
while($row=$result->fetch_assoc()){
    $category[] = $row;
}
$result->close();
$conn->next_result();

for($i=0;$i<count($category);$i++){
    $cat = $category[$i];
    $cid = $cat["CID"];
    $subCategory = array();
    $conn->query("SET @p1 = '$cid'");
    $result = $conn->query("CALL `selectSubCategorys`(@p0,@p1,@p3,@p5)");
    while($row=$result->fetch_assoc()){
        $subCategory[] = $row;
    }
    $cat["subCategory"] = $subCategory;
    $category[$i] = $cat;

    $result->close();
    $conn->next_result();
}

$json = array();
$json["resultCount"] = $resultCount;
$json["category"] = $category;

//echo print_r(json_decode($catString));
echo json_encode($json);