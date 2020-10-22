<?php
header('Content-Type: text/html; charset=ISO-8859-1');
session_start();
//db-Verbindung aufbauen, um username + passwort zu ueberpruefen
include 'phpFiles/database/dbConnection.php';

//Validation Methoden
include 'phpFiles/validation/validationMethods.php';

include "phpFiles/validation/errorMessages.php";

$UID="";
$rc="";
$successcode=1;
/*
 * TODO: successcode vereinheitlichen
 * 0...success
 * 1...neutral
 * 2...error
 * */

if(isset($_GET["UID"])&&isset($_GET["vc"])&&validateInteger($_GET["UID"])){
    $UID=$_GET["UID"];
    $sql="SELECT verificationCode AS vc FROM notverifieduser WHERE UID = $UID";
    $result=mysqli_query($conn,$sql);
    if($row=$result->fetch_assoc()){
        if($row["vc"]==$_GET["vc"]){
            /**
             * Datensatz verschieben
             */
            mysqli_query($conn,"INSERT INTO user (Username,Vorname,Nachname, Password, EMail, Land, Ort, PLZ, Strasse, HausNr, creationDate, creationTime)  
                                SELECT Username,Vorname,Nachname, Password, EMail, Land, Ort, PLZ, Strasse, HausNr, creationDate, creationTime  
                                FROM notverifieduser  WHERE UID = $UID");
            mysqli_query($conn,"DELETE FROM notverifieduser WHERE UID = $UID");
            $successcode=0;
        }else{
            $successcode=2;
        }
    }else{
        $successcode=2;
        $x=1;
    }
}else{
    $successcode=2;
}
?>
<!doctype html>
<head>
	<meta charset = "ISO-8859-1" >
	<title>index</title>
    <link rel ='stylesheet' href='CSS/style1.css'>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
    <link rel = "icon" href = "icon.png">
    <script src = "https://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.10.5/jquery.dataTables.js"></script>
</head>
<body>
<?php  include  'phpFiles/navbar/navbar.php';?>
    <div class="container">
        <?php
    if($successcode==0){
        successMessage("Account erfolgreich verifiziert!");
    }else if($successcode==2){
        errorMessage(("error!"));
    }
    ?>
    </div>
</body>