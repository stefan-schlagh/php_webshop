<?php

    include 'phpFiles/database/dbConnection.php';

    header('Content-Type: text/html; charset=ISO-8859-1');
    session_start();

?>

<!doctype html>
<html>
<head>
    <meta charset = "utf8">
    <title>webshop</title>
    <link rel ='stylesheet' href='CSS/style1.css'>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
    <link rel = "icon" href = "icon.png">
    <script type = "text/javascript" src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.4.1.js"></script>
</head>
<body>
    <?php
        include  'phpFiles/navbar/navbar.php';
    ?>
    <div class = "container" id = "r-page1">
        <label for="username"><b>Username:</b></label>
        <div id = "msgBox-r-uname" class = "msgContainer msgBox-r"></div>
        <input type = 'text'  name = 'username' id = "r-username" value = '' required placeholder="Enter Username">

        <label for="vorname"><b>Vorname:</b></label>
        <div id = "msgBox-r-vname" class = "msgContainer msgBox-r"></div>
        <input type = 'text'  name = 'vorname' id = "r-vorname" value = '' required placeholder="Vorname">

        <label for="nachname"><b>Nachname:</b></label>
        <div id = "msgBox-r-nname" class = "msgContainer msgBox-r"></div>
        <input type = 'text'  name = 'nachname' id = "r-nachname" value = '' required placeholder="Nachname">

        <label for="email"><b>E-Mail:</b></label>
        <div id = "msgBox-r-email" class = "msgContainer msgBox-r"></div>
        <input type = 'email' name = 'email' id = "r-email" value = "" required placeholder="Enter email">

        <label for="password"><b>Password:</b></label>
        <div id = "msgBox-r-psw" class = "msgContainer msgBox-r"></div>
        <div class = "input-icon">
            <i class="fas fa-eye-slash" id = "r-togglePw-1"></i>
            <input type = 'password' name = 'password' id = "r-password" value = '' required placeholder="Enter Password">
            <script defer>
                /*
                    toggle password visibility
                */
                $("#r-togglePw-1").click(function(){
                    let icon = document.getElementById("r-togglePw-1");
                    let input = document.getElementById("r-password");

                    if(input.type == "password"){
                        icon.classList.remove("fa-eye-slash");
                        icon.classList.add("fa-eye");
                        input.type = "text";
                    }else{
                        icon.classList.remove("fa-eye");
                        icon.classList.add("fa-eye-slash");
                        input.type = "password";
                    }
                });
            </script>
        </div>

        <label for="repeatPassword"><b>Repeat Password:</b></label>
        <div class = "input-icon">
            <i class="fas fa-eye-slash" id = "r-togglePw-2"></i>
            <input type = 'password' name = 'repeatPassword' id = 'r-repeatPassword' value = '' required placeholder="Repeat Password">
            <script defer>
                /*
                    toggle password visibility
                */
                $("#r-togglePw-2").click(function(){
                    let icon = document.getElementById("r-togglePw-2");
                    let input = document.getElementById("r-repeatPassword");

                    if(input.type == "password"){
                        icon.classList.remove("fa-eye-slash");
                        icon.classList.add("fa-eye");
                        input.type = "text";
                    }else{
                        icon.classList.remove("fa-eye");
                        icon.classList.add("fa-eye-slash");
                        input.type = "password";
                    }
                });
            </script>
        </div>

        <button class = "btnNext" id = "btnNext-1">
            next <i class="fas fa-chevron-right fa-lg"></i>
            <div id = "loader-page1" class = "loader1" style = "display:none;"></div>
        </button>
       
        <a href = "registerWithoutEmail.php">Ohne Email</a>

        <script defer>
            /*
                Username wird direkt validiert
            */
            let usernameValid = true;
            $("#r-username").on("input",function(){
                let r = new RegExp("^\\w\\w*$");
                let testRegex = r.test($("#r-username").val() || $("#r-username").val() == "");
                /*
                    wenn textArea valid und errorMessage gezeigt
                */
                if(testRegex&&!usernameValid){
                    $("#msgBox-r-uname").hide();
                    usernameValid = true;
                    
                /*
                    wenn textArea nicht valid und errorMessage nicht gezeigt
                */
                }else if(!testRegex&&usernameValid){
                    $("#msgBox-r-uname").show();
                    $("#msgBox-r-uname").html("Not a Username!");
                    usernameValid = false;
                }
            });
            /*
                Vorname wird direkt validiert
            */
            let vornameValid = true;
            $("#r-vorname").on("input",function(){
                let r = new RegExp("^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df])*$");
                let testRegex = r.test($("#r-vorname").val() || $("#r-vorname").val() == "");
                /*
                    wenn textArea valid und errorMessage gezeigt
                */
                if(testRegex&&!vornameValid){
                    $("#msgBox-r-vname").hide();
                    vornameValid = true;
                    
                /*
                    wenn textArea nicht valid und errorMessage nicht gezeigt
                */
                }else if(!testRegex&&vornameValid){
                    $("#msgBox-r-vname").show();
                    $("#msgBox-r-vname").html("Ung&uuml;ltige Eingabe!");
                    vornameValid = false;
                }
            });
            /*
                Nachname wird direkt validiert
            */
            let nachnameValid = true;
            $("#r-nachname").on("input",function(){
                let r = new RegExp("^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df])*$");
                let testRegex = r.test($("#r-nachname").val() || $("#r-nachname").val() == "");
                /*
                    wenn textArea valid und errorMessage gezeigt
                */
                if(testRegex&&!nachnameValid){
                    $("#msgBox-r-nname").hide();
                    nachnameValid = true;
                    
                /*
                    wenn textArea nicht valid und errorMessage nicht gezeigt
                */
                }else if(!testRegex&&nachnameValid){
                    $("#msgBox-r-nname").show();
                    $("#msgBox-r-nname").html("Ung&uuml;ltige Eingabe!");
                    nachnameValid = false;
                }
            });

            let usernameAlreadySaved = false;
            let uid = 0;

            $(".msgBox-r").each(function(index){
                $(this).css("background-color","rgb(255, 153, 153)");
                $(this).hide();
            });

            $("#btnNext-1").click(function(){

                $("#loader-page1").show();

                $.post("phpFiles/httpRequests/register/validatePage1.php",
                {
                    usernameAlreadySaved: usernameAlreadySaved,
                    username: $("#r-username").val(),
                    vorname: $("#r-vorname").val(),
                    nachname: $("#r-nachname").val(),
                    email: $("#r-email").val(),
                    password: $("#r-password").val(),
                    password2: $("#r-repeatPassword").val(),
                    uid: uid

                },function(data,status){
                    usernameAlreadySaved = data.usernameAlreadySaved;
                    uid = data.uid;

                    $("#loader-page1").hide();

                    if(!data.success){
                        /*
                            Errormessages werden aktualisiert
                        */
                        if(data.usernameError!=""){
                            $("#msgBox-r-uname").show();
                            $("#msgBox-r-uname").html(data.usernameError);
                        }else
                            $("#msgBox-r-uname").hide();
                        
                        if(data.emailError!=""){
                            $("#msgBox-r-email").show();
                            $("#msgBox-r-email").html(data.emailError);
                        }else
                            $("#msgBox-r-email").hide();
                        
                        if(data.pswError!=""){
                            $("#msgBox-r-psw").show();
                            $("#msgBox-r-psw").html(data.pswError);
                        }else
                            $("#msgBox-r-psw").hide();
                    }
                    /*
                        es wird auf zweite Seite umgeschalten
                    */
                    else{
                        $("#r-page1").hide();
                        $("#r-page2").show();

                    }

                });
            });
        </script>
    </div>
    <div class = "container hidden" id = "r-page2">

        <label for="land"><b>Land:</b></label>
        <?php 
        /**
         * Länder werden aus DB geladen und in Select geschrieben
         */
        $result=$conn->query("SELECT code, en FROM countries ORDER BY en ASC");?>								
        <select name="Land" id="Land">
            <option default>Select country</option>
            <?php 
                while($row=$result->fetch_assoc()):
            ?>
                <option value="<?=$row["code"]?>">
                    <?=$row["en"]?>
                </option>
            <?php endwhile;?>
        </select>
        
        <label for="ort"><b>Ort:</b></label>
        <div id = "msgBox-r-ort" class = "msgContainer msgBox-r"></div>
        <input type = 'text'  name = 'username' id = "r-ort" value = '' required placeholder="Ort">

        <label for="plz"><b>PLZ:</b></label>
        <div id = "msgBox-r-plz" class = "msgContainer msgBox-r"></div>
        <input type = 'text'  name = 'username' id = "r-plz" value = '' required placeholder="Postleitzahl">

        <label for="street"><b>Strasse:</b></label>
        <div id = "msgBox-r-street" class = "msgContainer msgBox-r"></div>
        <input type = 'text'  name = 'username' id = "r-street" value = '' required placeholder="Strasse">

        <label for="hnr"><b>Hausnummer:</b></label>
        <div id = "msgBox-r-hnr" class = "msgContainer msgBox-r"></div>
        <input type = 'text'  name = 'hnr' id = "r-hnr" value = '' required placeholder="Hausnummer">
        
        <button class = "btnPrev" id = "btnPrev-2">
        <i class="fas fa-chevron-left fa-lg"></i> prev 
        </button>

        <button class = "btnNext" id = "btnNext-2">
            registrieren
            <div id = "loader-page2" class = "loader1" style = "display:none;"></div>
        </button>

        <script defer>
            $(".msgBox-r").each(function(index){
                $(this).css("background-color","rgb(255, 153, 153)");
                $(this).hide();
            });
            /*
                Action für Button-zurück
            */
            $("#btnPrev-2").click(function(){

                $("#r-page1").show();
                $("#r-page2").hide();
            });
            /*
                valiation für Ort
            */
            let ortValid = true;
            $("#r-ort").on("input",function(){
                /*
                    Zeichen     Unicode
                ------------------------------
                Ä, ä        \u00c4, \u00e4
                Ö, ö        \u00d6, \u00f6
                Ü, ü        \u00dc, \u00fc
                ß           \u00df
                */
                let r = new RegExp("^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df\\.,-])*$");
                let testRegex = r.test($("#r-ort").val()) || $("#r-ort").val() == "";
                /*
                    wenn textArea valid und errorMessage gezeigt
                */
                if(testRegex&&!ortValid){
                    $("#msgBox-r-ort").hide();
                    ortValid = true;
                    
                /*
                    wenn textArea nicht valid und errorMessage nicht gezeigt
                */
                }else if(!testRegex&&ortValid){
                    $("#msgBox-r-ort").show();
                    $("#msgBox-r-ort").html("Enth&auml;lt ung&uuml;ltige Zeichen!");
                    ortValid = false;
                }
            });
            /*
                Validation für PLZ
            */
            let plzValid = true;
            $("#r-plz").on("input",function(){
                let r = new RegExp("^\\d\\d*$");
                let testRegex = r.test($("#r-plz").val()) || $("#r-plz").val() == "";
                /*
                    wenn textArea valid und errorMessage gezeigt
                */
                if(testRegex&&!plzValid){
                    $("#msgBox-r-plz").hide();
                    plzValid = true;
                    
                /*
                    wenn textArea nicht valid und errorMessage nicht gezeigt
                */
                }else if(!testRegex&&plzValid){
                    $("#msgBox-r-plz").show();
                    $("#msgBox-r-plz").html("Keine PLZ!");
                    plzValid = false;
                }
            });
            /*
                valiation für Strasse
            */
            let streetValid = true;
            $("#r-street").on("input",function(){
                /*
                    Zeichen     Unicode
                ------------------------------
                Ä, ä        \u00c4, \u00e4
                Ö, ö        \u00d6, \u00f6
                Ü, ü        \u00dc, \u00fc
                ß           \u00df
                */
                let r = new RegExp("^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df\\.,-])*$");
                let testRegex = r.test($("#r-street").val()) || $("#r-street").val() == "";
                /*
                    wenn textArea valid und errorMessage gezeigt
                */
                if(testRegex&&!streetValid){
                    $("#msgBox-r-street").hide();
                    streetValid = true;
                    
                /*
                    wenn textArea nicht valid und errorMessage nicht gezeigt
                */
                }else if(!testRegex&&streetValid){
                    $("#msgBox-r-street").show();
                    $("#msgBox-r-street").html("Enthält ung&uuml;ltige Zeichen!");
                    streetValid = false;
                }
            });
            /*
                validation für Hausnummer
            */
            let hnrValid = true;
            $("#r-hnr").on("input",function(){
                let r = new RegExp("^\\d\\w*$");
                let testRegex = r.test($("#r-hnr").val()) || $("#r-hnr").val() == "";
                /*
                    wenn textArea valid und errorMessage gezeigt
                */
                if(testRegex&&!hnrValid){
                    $("#msgBox-r-hnr").hide();
                    hnrValid = true;
                    
                /*
                    wenn textArea nicht valid und errorMessage nicht gezeigt
                */
                }else if(!testRegex&&hnrValid){
                    $("#msgBox-r-hnr").show();
                    $("#msgBox-r-hnr").html("Keine Hausnummer!");
                    hnrValid = false;
                }
            });
            /*
                Action für Button-weiter
            */
            $("#btnNext-2").click(function(){
                /*
                    nur, wenn alles validiert
                */
                if(ortValid&&plzValid&&streetValid&&hnrValid){

                    $("#loader-page2").show();

                    let e=document.getElementById("Land");
                    const land=e.options[e.selectedIndex].value;
                    if(land=="Select+country")
                        lend="";

                    $.post("phpFiles/httpRequests/register/validatePage2.php",
                    {
                        email: $("#r-email").val(),
                        land: land,
                        ort: $("#r-ort").val(),
                        plz: $("#r-plz").val(),
                        street: $("#r-street").val(),
                        hnr: $("#r-hnr").val(),
                        uid: uid

                    },function(data,success){

                        $("#loader-page2").hide();

                        if(data.success)
                            openOkMsgBox("Erfolgreich","Ihnen wurde ein Mail zu Verifizierung des Accounts gesendet",function(){
                                document.location = "home.php";
                            });
                    });
                }

            });
            </script>
    </div>

</body>