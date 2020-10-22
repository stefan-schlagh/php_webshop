

<div class = "jumbotron" id = "op-page3">
    <h1>Namen überprüfen:</h1>

    <label for="vorname">Vorname:</label>
    <div id = "msgBox-r-vname" class = "msgContainer msgBox-r"></div>
    <div class = "n-input" id = "n-input-vorname">
        <input type = 'text'  name = 'vorname' id = "n-vorname" value = '' required placeholder="Vorname">
        <i class="fas fa-save fa-lg n-input-save"></i>
    </div>

    <div class = "changeNameItem" id = "change-ni-vorname">
        <span class = "nameItem" id = "ni-vorname"></span>
        <i class="fas fa-edit ni-edit" id = "ni-edit-vorname"></i>
    </div>

    <label for="nachname">Nachname:</label>
    <div id = "msgBox-r-nname" class = "msgContainer msgBox-r"></div>
    <div class = "n-input" id = "n-input-nachname">
        <input type = 'text'  name = 'nachname' id = "n-nachname" value = '' required placeholder="Nachname">
        <i class="fas fa-save fa-lg n-input-save"></i>
    </div>

    <div class = "changeNameItem" id = "change-ni-nachname">
        <span class = "nameItem" id = "ni-nachname"></span>
        <i class="fas fa-edit ni-edit" id = "ni-edit-nachname"></i>
    </div>
    
    <button class = "btnPrev" id = "btnPrev-3">
        <i class="fas fa-chevron-left fa-lg"></i> previous
    </button>

    <button class = "btnNext" id = "btnNext-3">
        next <i class="fas fa-chevron-right fa-lg"></i>
        <div id = "loader-page1" class = "loader1" style = "display:none;"></div>
    </button>

    <script>
        /*
            Farbe von msg-Box wird festgelegt
        */
        $(".msgBox-r").each(function(index){
            $(this).css("background-color","rgb(255, 153, 153)");
            $(this).hide();
        });
        /*
            Name wird befüllt
        */
        function openName(data){
            $("#n-vorname").val(data.Vorname);
            $("#ni-vorname").html(data.Vorname);
            if(data.Vorname == ""){
                $("#n-input-vorname").show();
                $("#change-ni-vorname").hide();
            }else{
                $("#n-input-vorname").hide();
                $("#change-ni-vorname").show();
            }

            $("#n-nachname").val(data.Nachname);
            $("#ni-nachname").html(data.Nachname);
            if(data.Nachname == ""){
                $("#n-input-nachname").show();
                $("#change-ni-nachname").hide();
            }else{
                $("#n-input-nachname").hide();
                $("#change-ni-nachname").show();
            }

        }
        /*
            Action für change
        */
        $(".ni-edit").each(function(index){
            $(this).click(function(){
                $(".n-input")[index].style.display = "block";
                $(".changeNameItem")[index].style.display = "none";
            });
        });
        /*
            Vorname wird direkt validiert
        */
        let vornameValid = true;
        $("#n-vorname").on("input",function(){
            let r = new RegExp("^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df])*$");
            let testRegex = r.test($("#n-vorname").val() || $("#n-vorname").val() == "");
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
        $("#n-nachname").on("input",function(){
            let r = new RegExp("^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df])*$");
            let testRegex = r.test($("#n-nachname").val() || $("#n-nachname").val() == "");
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
        /*
            Action für speichern
        */
        $(".n-input-save").each(function(index){
            $(this).click(function(){
                if(index==0){
                    if(!(vornameValid && $("#n-vorname").val() != "")){
                        if($("#n-vorname").val() == ""){
                            $("#msgBox-r-vname").show();
                            $("#msgBox-r-vname").html("required!");
                            vornameValid = false;
                        }
                    }else{
                        $("#ni-vorname").html($("#n-vorname").val());
                        $(".n-input")[index].style.display = "none";
                        $(".changeNameItem")[index].style.display = "block";
                    }

                }else if(index==1){
                    if(!(nachnameValid && $("#n-nachname").val() != "")){
                        if($("#n-nachname").val() == ""){
                            $("#msgBox-r-nname").show();
                            $("#msgBox-r-nname").html("required!");
                            nachnameValid = false;
                        }
                    }else{
                        $("#ni-nachname").html($("#n-nachname").val());
                        $(".n-input")[index].style.display = "none";
                        $(".changeNameItem")[index].style.display = "block";
                    }
                }
            });
        });
        $("#btnPrev-3").click(function(){
            /*
                es wird nochmal alles validiert
            */
            $(".a-input-save").each(function(index){
                $(this).trigger("click");
            });
            /*
                wenn alles erfolgreich validiert
            */
            if(vornameValid&&nachnameValid){
                /*
                    Name wird gespeichert
                */
                $.post("phpFiles/httpRequests/orderProducts/setName.php",
                {
                    vorname: $("#n-vorname").val(),
                    nachname: $("#n-nachname").val()
                },function(data,status){
                    /*
                    nicht eingeloggt: msgBox
                    */
                    if(!data.loggedIn){
                        openOkMsgBox("Zugriff verweigert!","nicht eingeloggt!");
                    }else{
                        /*
                            Addresse wird geöffnet
                        */
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
                                $("#op-page3").hide();
                                $("#op-page2").show();
                            }
                        });
                    }
                });
            }          
        });    

        $("#btnNext-3").click(function(){
            /*
                es wird nochmal alles validiert
            */
            $(".a-input-save").each(function(index){
                $(this).trigger("click");
            });
            /*
                wenn alles erfolgreich validiert
            */
            if(vornameValid&&nachnameValid){
                /*
                    Name wird gespeichert
                */
                $.post("phpFiles/httpRequests/orderProducts/setName.php",
                {
                    vorname: $("#n-vorname").val(),
                    nachname: $("#n-nachname").val()
                },function(data,status){
                    /*
                    nicht eingeloggt: msgBox
                    */
                    if(!data.loggedIn){
                        openOkMsgBox("Zugriff verweigert!","nicht eingeloggt!");
                    }else{
                        $("#op-page3").hide();
                        $("#op-page4").show();
                    }
                });
            }
        });

    </script>
</div>