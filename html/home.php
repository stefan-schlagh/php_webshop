<?php

include_once 'phpFiles/classes/cart.php';

header('Content-Type: text/html; charset=ISO-8859-1');
session_start();
//db-Verbindung aufbauen, um username + passwort zu ueberpruefen
include 'phpFiles/database/dbConnection.php';

//Validation Methoden
include 'phpFiles/validation/validationMethods.php';


$cart = new cart(); 

$cart->initial_cart();

include "phpFiles/methods/createPagination.php";

$start = 0;
if(isset($_GET["start"])){
    $start=$_GET["start"];
    if(!is_numeric($start)||$start<0)
        $start=0;
}

$siteSize = 10;

$searchvalue = "";
if(isset($_GET["searchValue"]))
    $searchvalue = $_GET["searchValue"];

//Die Anzahl der Produkte wird abgefragt
$conn->query("SET @p0 = '$searchvalue'");
//$x = $start+1;
$conn->query("SET @p1 = '$start'");
$conn->query("SET @p2 = '$siteSize'");
$conn->query("SET @p3 = '[]'");//catlist
$conn->query("SET @p4 = '[]'");//subcatlist

$result = $conn->query("CALL `selectProducts1`(@p0)");
$resultCount = $result -> num_rows;
$result->close();
$conn->next_result();

//Produkte für jeweilige Seite werden abgefragt
if($start>$resultCount){
    $conn->query("SET @p1 = '0'");
    $start = 0;
}
$result = $conn->query("CALL `selectProductLimit`(@p0,@p1,@p2,@p3,@p4)") or die($conn->error);

//Result wird in Array gespeichert
$products = array();
while($row = $result->fetch_assoc()){
    array_push($products,$row);
}
$result->close();
$conn->next_result();

//Categorys werden abgefragt
//$result = $conn->query("SELECT CID, Name,'0' AS 'Anzahl' FROM category");
$result = $conn->query("CALL `selectCategorys`(@p0,@p3)") or die($conn->error);
$categories = array();
while($row = $result->fetch_assoc()){
    array_push($categories,$row);
}
$result->close();
$conn->next_result();

?>
<!doctype html>
<html>
    <head>
        
        <meta charset = "ISO-8859-1" >
        <title>webshop</title>
        <link rel ='stylesheet' href='CSS/style1.css'>
        <link rel ='stylesheet' href='CSS/home.css'>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
        <link rel = "icon" href = "icon.png">
        <script type = "text/javascript" src = "javaScript/home/filter.js" defer></script>
        <script type = "text/javascript" src = "javaScript/home/refreshProducts.js"></script>
        <script type = "text/javascript" src = "javaScript/home/review.js" defer></script>
        <script type = "text/javascript" src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.4.1.js"></script>

    </head>
    <body>
        <?php   include  'phpFiles/navbar/navbar.php';
                include "phpFiles/productModal/productModal.php";
        
        ?>
        <div>
            <div class = "filter" id = "filter" style = "display:block;">
                <div class = "filter-top">Filtern nach:</div>
                <div class = "filter-block" style = "border-top: 2px solid var(--border-grey);">
                    <div class = "filter-header">
                        Suche
                    </div>
                    <div class = "filter-item-selected" id = "filter-search">
                        "<span id = "filter-searchValue"><?= $searchvalue ?></span>"
                        <span class = "filter-item-num" id = 'filter-search-num'>(<?=$resultCount?>)</span>
                        <span class = "filter-item-close">&times;</span>
                    </div>
                    <div class = "filter-item-selected" id = "filter-search-empty">
                        <a id = 'filter-searcha'>&#128269;</a><input type = 'text' id = 'filter-inputSearch' placeholder = "search"></input>
                    </div>
                </div>
                <div class = "filter-block">
                    <div class = "filter-header">
                        Kategorie
                    </div>
                     
                    <div class = "filter-item-selected filter-item-category">
                        <span class = "filter-item-name">all</span>
                        <span class = "filter-item-num">(<?=$resultCount?>)</span>
                        <span class = "filter-item-close">&times;</span>
                    </div>
                    
                </div>
                <div class = "filter-block">
                    <div class = "filter-header">
                        Subkategorie
                    </div>
                    <div class = "filter-item-selected filter-item-subCategory">
                        <span class = "filter-item-name">all</span>
                        <span class = "filter-item-num">(<?=$resultCount?>)</span>
                        <span class = "filter-item-close">&times;</span>
                    </div>
                </div>
                <!---div class = "filter-block">
                    <?php
                        /*
                            TODO: ordnen nach
                        */
                    ?>
                </div--->
            </div>
            <div class = "main">
                <div class = "mainHeader">
                    <div class = "resultCount">
                        <span id = "resultCount"><?=$resultCount?></span> results found:
                    </div>
                    <div id="pagination-top" class = "pagination"><?php createPagination();?></div>
                </div>
                <div class = "mainContent" id = "mainContent">
                   
                </div>
                <script type = "text/javascript" defer>
                    refreshProducts(<?=$start?>,<?=$siteSize?>);
                </script>
                <div class = mainFooter>
                    <div id="pagination-bottom" class = "pagination"><?php createPagination();?></div>  
                </div>
            </div>
        </div>
        
    </body>
</html>