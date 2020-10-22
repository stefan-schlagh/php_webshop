<div class = "modal pwResetModal" id = "pwResetModal">
    <div id = "pwResetModal-content" class = "pwResetModal-content container">
        
        <span class="close" id="pr-close">&times;</span>
        <div id = "pr-msgBox" class = "modal-header">Passwort zur&uuml;cksetzen:</div>

        <label for="username"><b>Username:</b></label>
        <div id = "pr-msgBox-uname" class = "msgContainer"></div>
        <input type = 'text'  name = 'username' id = "prUsername" value = '' required placeholder="Enter Username">

        <label for="email"><b>Email:</b></label>
        <div id = "pr-msgBox-email" class = "msgContainer"></div>
        <input type = 'email'  name = 'password' id="prEmail" value = '' required placeholder="Enter Email">

        <button id = "prSubmit" class = "mlBtnSubmit">Best&auml;tigen</button><div id = "pr-Loader" class = "loader2"></div>

    </div>

    <script>
        $("#pr-Loader").css({"position":"relative","top":"5px","display":"none"});
        $("#prSubmit").click(function(){
            
            $("#pr-Loader").css("display","inline-block");
            //Input wird validiert
            $.post("phpFiles/navbar/passwordResetModal/validatePwReset.php",
            {
                username: $("#prUsername").val(),
                email: $("#prEmail").val()
            },function(data,status){

                $("#pr-Loader").hide();

                let success = data.success;

                //Errormessages werden aktualisiert
                if(data.usernameError!=""&&!success){
                    $("#pr-msgBox-uname").html(data.usernameError);
                    $("#pr-msgBox-uname").css("background-color","#f99");
                    $("#pwResetModal-content").css("height","350px");
                }else{
                    $("#pr-msgBox-uname").html("");
                    $("#pr-msgBox-uname").css("background-color","inherit");
                }

                if(data.emailError!=""&&!success){
                    $("#pr-msgBox-email").html(data.emailError);
                    $("#pr-msgBox-email").css("background-color","#f99");
                    $("#pwResetModal-content").css("height","350px");
                }else{
                    $("#pr-msgBox-email").html("");
                    $("#pr-msgBox-email").css("background-color","inherit");
                }

                if(success){
                    $("#pwResetModal-content").css("height","300px");

                    $("#pwResetModal").hide();

                    openOkMsgBox("Erfolgreich","Ein Link zum Passwort zur&uuml;cksetzen wurde an ihre Email-Adresse gesendet!");
                }
            });
        });

        /*
            Wenn bei pwReset-Modal auf x geklickt --> wird geschlossen
        */
        $("#pr-close").click(function(){
            $("#pwResetModal").css("display","none");
        });

        /*
            wenn ausserhalb von pwReset-Modal geklickt --> wird geschlossen
        */
        initPwResetModalClose();
        function initPwResetModalClose(){
            let prClicked = false;
            $("#pwResetModal").click(function(){
                prClicked = true;
                setTimeout(function(){
                    if(prClicked){
                        $("#pwResetModal").hide();
                    }
                    prClicked = false;
                },100);
            });
            $("#pwResetModal-content").click(function(){
                setTimeout(function(){
                    prClicked = false;
                },50);
            });
        }
    </script>
</div>