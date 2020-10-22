<?php

include_once 'phpFiles/classes/cart.php';

session_start();

//db-Verbindung aufbauen, um username + passwort zu ueberpruefen
include 'phpFiles/database/dbConnection.php';

//Validation Methoden
include 'phpFiles/validation/validationMethods.php';


$cart = new cart();

$cart->initial_cart();

if($cart->getCartCount()==0)
    header("LOCATION: home.php");
?>


<!doctype html>
<head>
    <title>webshop</title>
    <link rel ='stylesheet' href='CSS/style1.css'>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
    <link rel = "icon" href = "icon.png">
    <script type = "text/javascript" src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.4.1.js"></script>

</head>
<body>
    <?php include 'phpFiles/navbar/navbar.php';?>

    <div class = "jumbotron" id = "op-page1">
        <h1>Bestellung überprüfen:</h1>
        <div class = "cartOverview" id = "cartOverview">
            <?php
                $cart->getCartOverview();
            ?>
        </div>

        <button class = "btnNext" id = "btnNext-1">
            next <i class="fas fa-chevron-right fa-lg"></i>
            <div id = "loader-page1" class = "loader1" style = "display:none;"></div>
        </button>

        <script>
            /*
                Wenn btnNext geklickt wird Addresse abgefragt
                    wenn nicht eingeloggt:
                        msgBox, nicht weiter
                    sonst:
                        Addresse wird befüllt, auf nächste Seite umgschalten
            */
            $("#btnNext-1").click(function(){

                $.post("phpFiles/httpRequests/orderProducts/getAddress.php",
                {

                },function(data,status){
                    /*
                        nicht eingeloggt: msgBox
                    */
                    if(!data.loggedIn){
                        openOkMsgBox("Zugriff verweigert!","nicht eingeloggt!");
                    }else{
                        /*
                            Addresse wird befüllt
                        */
                        openAddress(data);
                        $("#op-page1").hide();
                        $("#op-page2").show();
                    }
                });
            });
        </script>
    </div>

    <?php 
        include "phpFiles/orderProducts/address.php";
    ?>

    <?php 
        include "phpFiles/orderProducts/name.php";
    ?>

    <div class = "jumbotron" id = "op-page4">
        <h1>Zahlungsinformationen:</h1>

        <button class = "btnPrev" id = "btnPrev-4">
            <i class="fas fa-chevron-left fa-lg"></i> previous
        </button>

        <button class = "btnNext" id = "btnNext-4">
            next <i class="fas fa-chevron-right fa-lg"></i>
            <div id = "loader-page1" class = "loader1" style = "display:none;"></div>
        </button>
        
        <script>
            $("#btnPrev-4").click(function(){

                $("#op-page4").hide();
                $("#op-page3").show();
                
            });

            $("#btnNext-4").click(function(){

                $("#op-page4").hide();
                $("#op-page5").show();
                /*
                    Bestellung wird durchgeführt
                */
                $.post("phpFiles/httpRequests/orderProducts/orderProduct.php",
                {

                },function(data,status){
                    /*
                        nicht eingeloggt: msgBox
                    */
                    if(!data.loggedIn){
                        openOkMsgBox("Zugriff verweigert!","nicht eingeloggt!");
                    }else{
                        $("#btn-Rechnung").click(function(){
                            window.open("phpFiles/orderProducts/rechnung.php?rnr="+data.bid);
                        });
                        /*
                            TODO: Rechnung erstellen, 
                        */
                        $("#op-page5").hide();
                        $("#op-page6").show();
                    }
                });
            });
        </script>
    </div>

    <div class = "jumbotron" id = "op-page5">
        <h1>Bestellung wird bearbeitet</h1>
    </div>

    <div class = "jumbotron" id = "op-page6">
        <h1>Bestellung ist eingegangen</h1>
        <h3>Die Lieferung erfolgt innerhalb der nächsten Tage (nicht)</h3>
        <div class = "innerContainer">
            Rechnung: <i class="far fa-file-pdf fa-2x pdf-icon" id = "btn-Rechnung"></i>
        </div>
    </div>
    <script>
        //Alle Jumbotrns werden versteckt, ausser erstes
        $(document).ready(function(){
            $(".jumbotron").each(function(index){
                if(index!=0){
                    $(this).hide();
                }
            });
        });

    </script>
</body>