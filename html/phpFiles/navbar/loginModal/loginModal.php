
<div class = "loginModal modal" id = "loginModal">
    <div id = "loginModal-content" class = "loginModal-content container">
        
        <span class="close" id="ml-close">&times;</span>
        <div id = "ml-msgBox" class = "modal-header" style = "display:none;" >Einloggen, um fortzufahren:</div>

        <label for="username"><b>Username:</b></label>
        <div id = "msgBox-uname" class = "msgContainer"></div>
        <input type = 'text'  name = 'username' id = "mlUsername" value = '' required placeholder="Enter Username">

        <label for="password"><b>Password:</b></label>
        <div id = "msgBox-psw" class = "msgContainer"></div>
        <div class = "input-icon">
            <i class="fas fa-eye-slash" id = "ml-togglePw"></i>
            <input type = 'password'  name = 'password' id="mlPassword" value = '' required placeholder="Enter Password">
        </div>

        <button id = "mlSubmit" class = "mlBtnSubmit">Login</button>
        <div class = "fpr">
            <span id = "mlForgotPassword" class = "forgotPassword"><a href = "javascript:void(0)">Forgot Password?</a></span>
            <label class = "mlRemember"><input type = 'checkbox' id = "mlRemember" name = 'remember' >remember me?</label>
        </div>

    </div>

    <script type = "text/javascript">
        let loginModalCallBack = function(){};
        function setMlCallBack(callBack){
            $("#msgBox-uname").html("");
            $("#msgBox-psw").html("");
            loginModalCallBack = callBack;
        }
        function openLoginModal(text,callBack){
            //Dialog für Login wird geöffnet
            $("#loginModal").show();

            if(typeof(callBack)=="function")
                setMlCallBack(callBack);
            else
                setMlCallBack(function(){});

            //Text wird gesetzt
            $("#ml-msgBox").show();
            $("#ml-msgBox").html(text);

            //Dialog wird verkleinert, da kein Platz für Error-messages gebraucht wird
            $("#loginModal-content").css("height","300px");

            //msg-boxes werden ausgeblendet
            $("#msgBox-uname").html("");
            $("#msgBox-uname").css("background-color","inherit");
            $("#msgBox-psw").html("");
            $("#msgBox-psw").css("background-color","inherit");
        }
        $("#mlSubmit").click(function(){
            
            //input wird validiert
            $.post("phpFiles/navbar/loginModal/validateInput.php",
            {
                username: $("#mlUsername").val(),
                password: $("#mlPassword").val(),
                remember: $("#mlRemember").is(":checked")
            },
            function(data,status){
                
                let success = data.success;

                //Errormessages werden aktualisiert
                if(data.usernameError!=""&&!success){
                    $("#msgBox-uname").html(data.usernameError);
                    $("#msgBox-uname").css("background-color","#f99");
                    $("#loginModal-content").css("height","350px");
                }else{
                    $("#msgBox-uname").html("");
                    $("#msgBox-uname").css("background-color","inherit");
                }

                if(data.passwordError!=""&&!success){
                    $("#msgBox-psw").html(data.passwordError);
                    $("#msgBox-psw").css("background-color","#f99");
                    $("#loginModal-content").css("height","350px");
                }else{
                    $("#msgBox-psw").html("");
                    $("#msgBox-psw").css("background-color","inherit");
                }
                
                //wenn erfolgreich --> "Konto in Navbar wird geändert"
                if(success){
                    $("#loginModal-content").css("height","300px");
                    //Username wird geändert
                    $("#navbar-profile").prev().html($("#mlUsername").val());
                    //Dropdown-Items werden geändert
                    $("#navbar-profile").html(
                        "<a href='userInformation.php' class = 'navlink'>Bestellungen</a>"+
                        "<a href='profileOptions.php' class = 'navlink'>Einstellungen</a>"+
                        "<a href='javascript:void(0)' id = 'navbar-logout' class = 'navlink'>logout</a>"
                    );
                    //Action für logout wird initialisiert
                    initLogout();

                    //Modal wird geschlossen
                    $("#loginModal").hide();

                    //callback wird aufgerufen
                    loginModalCallBack(success);

                    //Cart wird geladen
                    loadCart();
                    
                }else{
                    //callback wird aufgerufen
                    loginModalCallBack(success);
                }
                
                
            });
        });
        function loadCart(){
            
            $.post("phpFiles/httpRequests/cart/getCartSize.php",
            {

            },function(data,status){
                if(data.dbCart==0){
                    /*
                        CID in Tabelle user aendern
                        action = 1
                    */
                    $.post("phpFiles/httpRequests/cart/loadCart.php",
                    {
                        action: 1
                    },function(data,status){

                    });
                }else if(data.sessionCart==0){
                    /*
                        cid bei cart aendern
                        action = 2
                    */
                    $.post("phpFiles/httpRequests/cart/loadCart.php",
                    {
                        action: 2
                    },function(data,status){

                    });
                }else{
                    openYesNoMsgBox(
                        "Warenkorb laden?","Wollen sie ihren Warenkorb &uuml;berschreiben?",
                        function(){
                            /*
                                yes-callback
                            */
                            /*
                                neuen Warenkorb laden
                                action = 3
                            */
                            $.post("phpFiles/httpRequests/cart/loadCart.php",
                            {
                                action: 3
                            },function(data,status){

                            });
                        },
                        function(){
                            /*
                                no-callback
                            */
                            /*
                                CID bei user aendern, cart von user wird gelöscht
                                action = 4
                            */
                            $.post("phpFiles/httpRequests/cart/loadCart.php",
                            {
                                action: 4
                            },function(data,status){

                            });
                        }
                    );
                }
                
            });
        }
        /*
            Wenn forgotPassword geklickt --> Modal wird geöffnet
        */
        $("#mlForgotPassword").click(function(){
            //loginmodal wird versteckt
            $("#loginModal").hide();
            
            //pwResetModal wird gezeigt
            $("#pwResetModal").show();

        });
        /*
            toggle password visibility
        */
        $("#ml-togglePw").click(function(){
            let icon = document.getElementById("ml-togglePw");
            let input = document.getElementById("mlPassword");

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

        /*
            Wenn bei Login-Modal auf x geklickt --> wird geschlossen
        */
        $("#ml-close").click(function(){
            $("#loginModal").css("display","none");
        });

        /*
            wenn ausserhalb von Login-Modal geklickt --> wird geschlossen
        */
        initLoginModalClose();
        function initLoginModalClose(){
            let lmClicked = false;
            $("#loginModal").click(function(){
                lmClicked = true;
                setTimeout(function(){
                    if(lmClicked){
                        $("#loginModal").css("display","none");
                    }
                    lmClicked = false;
                },100);
            });
            $("#loginModal-content").click(function(){
                setTimeout(function(){
                    lmClicked = false;
                },50);
            });
        }
    </script>
</div>