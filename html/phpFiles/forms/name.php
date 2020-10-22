<div id = "name">

    <label for="vorname">Vorname:</label>
    <div id = "msgBox-r-vname" class = "msgContainer msgBox-n"></div>
    <div class = "n-input" id = "n-input-vorname">
        <input type = 'text'  name = 'vorname' id = "n-vorname" value = '' required placeholder="Vorname">
        <i class="fas fa-save fa-lg n-input-save"></i>
    </div>

    <div class = "changeNameItem" id = "change-ni-vorname">
        <span class = "nameItem" id = "ni-vorname"></span>
        <i class="fas fa-edit ni-edit" id = "ni-edit-vorname"></i>
    </div>

    <label for="nachname">Nachname:</label>
    <div id = "msgBox-r-nname" class = "msgContainer msgBox-n"></div>
    <div class = "n-input" id = "n-input-nachname">
        <input type = 'text'  name = 'nachname' id = "n-nachname" value = '' required placeholder="Nachname">
        <i class="fas fa-save fa-lg n-input-save"></i>
    </div>

    <div class = "changeNameItem" id = "change-ni-nachname">
        <span class = "nameItem" id = "ni-nachname"></span>
        <i class="fas fa-edit ni-edit" id = "ni-edit-nachname"></i>
    </div>

    <script>
        $(document).ready(function(){
            openName();
            /*
                Name wird befüllt
            */
            function openName(){
                $.post("phpFiles/httpRequests/orderProducts/getName.php",
                {

                },function(data,status){
                    /*
                        nicht eingeloggt: msgBox
                    */
                    if(!data.loggedIn){
                        openOkMsgBox("Zugriff verweigert!","nicht eingeloggt!");
                    }else{
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
                });

            }
            /*
                keylistener, um neben save auch enter nutzen zu können
            */
            $("#name input").each(function(i){
                    $(this).keydown(function(){
                        // 13 --> enter-taste
                        if(event.which==13){
                            /*
                                event save wird getriggert
                            */
                            $(".n-input-save")[i].click();
                        }            
                    });
            });
            /*
                Action für save
            */
            $(".n-input-save").each(function(index){
                $(this).click(function(){
                    const valid = nameInputValidator[index].validate();
                    if(valid){
                        /*
                            es wird umgeschalten
                        */
                        $(".n-input")[index].style.display = "none";
                        $(".changeNameItem")[index].style.display = "block";
                        /*
                            neuer input kommt in nameItem
                        */
                        $(".nameItem")[index].innerHTML = $("#name input")[index].value;
                        /*
                            msg-Box wird geleert und versteckt
                        */
                        $(".msgBox-n")[index].innerHTML = "";
                        $(".msgBox-n")[index].style.display = "none";
                        /*
                            Name wird gespeichert
                        */
                        saveName();
                    }
                });
            });
            /*
                Action für edit
            */
            $(".ni-edit").each(function(index){
                $(this).click(function(){
                    /*
                        es wird umgeschalten
                    */
                    $(".n-input")[index].style.display = "block";
                    $(".changeNameItem")[index].style.display = "none";
                });
            });


            function saveName(){
                /*
                    Name speichern
                */
                $.post("phpFiles/httpRequests/orderProducts/setName.php",
                {
                    vorname: $("#n-vorname").val(),
                    nachname: $("#n-nachname").val()
                },function(data,status){
                    
                });
            }
            /*
                Farbe von msg-Box wird festgelegt
            */
            $(".msgBox-n").each(function(index){
                $(this).css("background-color","rgb(255, 153, 153)");
                $(this).hide();
            });

            let namePattern = "^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df])*$";
            let nameInputValidator = new Array();
            $("#name input").each(function(i){
                nameInputValidator.push(new InputValidator(false,namePattern,$(this),$("msgBox-n").get(i)));
            });
        });
    </script>
</div>