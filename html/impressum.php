<?php 
header('Content-Type: text/html; charset=ISO-8859-1');
session_start();

//db-Verbindung aufbauen, um username + passwort zu ueberpruefen
include 'phpFiles/database/dbConnection.php';


?>
<!doctype html>
<head>
	<meta charset = "ISO-8859-1" >
	<title>webshop</title>
	<link rel ='stylesheet' href='CSS/style1.css'>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
    <link rel = "icon" href = "icon.png">
	<script src = "https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.4.1.js"></script>
	<script src = "javaScript/validate/validate.js"></script>
</head>
<body>
    <?php  include  'phpFiles/navbar/navbar.php';?>

    <div class = "jumbotron">
        <h1>Impressum</h1>
        <h2>Inhaber</h2>
        <p>Stefan Schlaghuber<br /> Hausnummer 45<br /> 2002 Ringendorf</p> 
        <h2>Kontakt</h2> <p>Telefon: +43 (0) 681 817 872 40<br /> stefan.schlaghuber@gmail.com</p> 

        Diese Website dient rein zu Demonstrationszwecken und stellt keinen wirklichen Online-Shop dar.
    </div>
</body>