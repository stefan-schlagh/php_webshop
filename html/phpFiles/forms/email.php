<div id = "email-container">
    <div id = "msgBox-email" class = "msgContainer msgBox-e"></div>
    <div class = "e-input" id = "e-input">
    <input type = 'text'  name = 'plz' id = "email" value = '' required placeholder="Email">
    <i class="fas fa-save fa-lg input-save e-input-save" id = "e-input-save"></i>
    </div>

    <div class = "changeEmailItem" id = "change-ei">
        <span class = "emailItem" id = "ei"></span>
        <i class="fas fa-edit icon-edit" id = "ei-edit"></i>
    </div>

    <script>
        $(document).ready(function(){
            openEmail();
            /*
                Email wird befüllt
            */
            function openEmail(){
                $.post("phpFiles/httpRequests/options/getEmail.php",
                {

                },function(data,status){
                    if(data.loggedIn){
                        /*
                            Wenn email leer, wird input gezeigt
                        */
                        if(data.Email==""){
                            $("#change-ei").hide();
                            $("#e-input").show();                         
                        }else{
                            $("#e-input").hide();
                            $("#change-ei").show();
                        }
                        $("#ei").html(data.Email);
                        $("#email").val(data.Email);
                    }
                });
            }
            /*
                msgBox email wird initialisiert
            */
            $("msgBox-email").css("background-color","rgb(255, 153, 153)");
            $("msgBox-email").hide();
            /*
                Funktion für edit
            */
            $("#ei-edit").click(function(){
                $("#change-ei").hide();
                $("#e-input").show();
                $("msgBox-email").hide();
            });
            /*
                keylistener, um neben save auch enter nutzen zu können
            */
            $("#email").keydown(function(){
                // 13 --> enter-taste
                if(event.which==13){
                    /*
                        event save wird getriggert
                    */
                    $("#e-input-save").trigger("click");
                }            
            });
            /*
                email wird gespeichert 
            */
            $("#e-input-save").click(function(){
                $.post("phpFiles/httpRequests/options/setEmail.php",
                {
                    email: $("#email").val()
                },function(data,status){
                    if(data.success){
                        //umschalten
                        $("#e-input").hide();
                        $("#change-ei").show();
                        $("#change-ei") = $("#e-input").val();
                        //msgBox wird versteckt
                        $("msgBox-email").hide();
                    }else{
                        $("msgBox-email").html("keine Emailaddresse!");
                        $("msgBox-email").show();
                    }
                });
            });
        });
    </script>
</div>