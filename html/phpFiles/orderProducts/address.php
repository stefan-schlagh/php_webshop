

<div class = "jumbotron" id = "op-page2">
        <h1>Addresse überprüfen:</h1>

        <label for="land">Land:</label><br>
        <?php 
        /**
         * Länder werden aus DB geladen und in Select geschrieben
         */
        $result=$conn->query("SELECT code, en FROM countries ORDER BY en ASC");?>
        <div id = "msgBox-r-land" class = "msgContainer msgBox-r"></div>
        <div class = "a-input" id = "a-input-land">							
            <select name="Land" id = "Land">
                <option default>Select country</option>
                <?php 
                    while($row=$result->fetch_assoc()):
                ?>
                    <option value="<?=$row["code"]?>">
                        <?=$row["en"]?>
                    </option>
                <?php endwhile;?>
            </select>
            <i class="fas fa-save fa-lg a-input-save"></i>
        </div>
        
        <div class = "changeAddressItem" id = "change-ai-land">
            <span class = "addressItem" id = "ai-land"></span>
            <i class="fas fa-edit ai-edit" id = "ai-edit-land"></i>
        </div>
        
        <label for="ort">Ort:</label>
        <div id = "msgBox-r-ort" class = "msgContainer msgBox-r"></div>
        <div class = "a-input" id = "a-input-ort">
            <input type = 'text'  name = 'ort' id = "r-ort" value = '' required placeholder="Ort">
            <i class="fas fa-save fa-lg a-input-save"></i>
        </div>

        <div class = "changeAddressItem" id = "change-ai-ort">
            <span class = "addressItem" id = "ai-ort"></span>
            <i class="fas fa-edit ai-edit" id = "ai-edit-ort"></i>
        </div>


        <label for="plz">PLZ:</label>
        <div id = "msgBox-r-plz" class = "msgContainer msgBox-r"></div>
        <div class = "a-input" id = "a-input-plz">
            <input type = 'text'  name = 'plz' id = "r-plz" value = '' required placeholder="Postleitzahl">
            <i class="fas fa-save fa-lg a-input-save"></i>
        </div>

        <div class = "changeAddressItem" id = "change-ai-plz">
            <span class = "addressItem" id = "ai-plz"></span>
            <i class="fas fa-edit ai-edit" id = "ai-edit-plz"></i>
        </div>


        <label for="street">Strasse:</label>
        <div id = "msgBox-r-street" class = "msgContainer msgBox-r"></div>
        <div class = "a-input" id = "a-input-street">
            <input type = 'text'  name = 'street' id = "r-street" value = '' required placeholder="Strasse">
            <i class="fas fa-save fa-lg a-input-save"></i>
        </div>

        <div class = "changeAddressItem" id = "change-ai-street">
            <span class = "addressItem" id = "ai-street"></span>
            <i class="fas fa-edit ai-edit" id = "ai-edit-street"></i>
        </div>


        <label for="hnr">Hausnummer:</label>
        <div id = "msgBox-r-hnr" class = "msgContainer msgBox-r"></div>
        <div class = "a-input" id = "a-input-hnr">
            <input type = 'text'  name = 'hnr' id = "r-hnr" value = '' required placeholder="Hausnummer">
            <i class="fas fa-save fa-lg a-input-save"></i>
        </div>

        <div class = "changeAddressItem" id = "change-ai-hnr">
            <span class = "addressItem" id = "ai-hnr"></span>
            <i class="fas fa-edit ai-edit" id = "ai-edit-hnr"></i>
        </div>

        
        <button class = "btnPrev" id = "btnPrev-2">
            <i class="fas fa-chevron-left fa-lg"></i> previous
        </button>

        <button class = "btnNext" id = "btnNext-2">
            next <i class="fas fa-chevron-right fa-lg"></i>
            <div id = "loader-page1" class = "loader1" style = "display:none;"></div>
        </button>

        <script>

            /*
                Addresse wird befüllt
            */
            function openAddress(data){
                /*
                    wenn Feld leer: input wird gezeigt und addressinformation ausgeblendet
                */

                const values = Object.values(data);
                $(".changeAddressItem").each(function(index){
                    if(values[index+1] == "" || values[index+1] == null ||values[index+1] == 0){
                        $(".changeAddressItem")[index].style.display = "none";
                        $(".a-input")[index].style.display = "block";
                        $(".addressItem")[index].innerHTML = "";
                    }else
                        //select
                        if(index == 0){
                            $(".a-input select")[0].value = data.cCode;
                        }
                        //input
                        else{
                            $(".a-input input")[index-1].value = values[index+1];
                        }
                        $(".addressItem")[index].innerHTML = values[index+1];
                });
            }
            /*
            keylistener, um neben save auch enter nutzen zu können
                */
            $(".a-input input").each(function(i){
                    $(this).keydown(function(){
                        // 13 --> enter-taste
                        if(event.which==13){
                            /*
                                event save wird getriggert
                            */
                            $(".a-input-save")[i+1].click();
                        }            
                    });
            });
            /*
                Bei Save wird von input auf address-information umgeschalten
                Das passiert nur, wenn auch was drinsteht
            */
            $(".a-input-save").each(function(index){
                $(this).click(function(){

                    let valid;

                    switch(index){
                        case 0:
                            valid = true;
                            break;
                        case 1: 
                            valid = ortValid;
                            break;
                        case 2:
                            valid = plzValid;
                            break;
                        case 3:
                            valid = streetValid;
                            break;
                        case 4: 
                            valid = hnrValid;
                            break;
                    }
                    /*
                        es wird überprüft, ob Feld eh nicht leer ist
                    */
                    //select
                    if(index == 0){
                        let e=document.getElementById("Land");
                        const land=e.options[e.selectedIndex].value;

                        valid = valid && land != "Select country";
                    }
                    //input
                    else{
                        valid = valid && !$(".a-input input")[index-1].value == "";
                    }

                    if(valid){
                        /*
                            es wird umgeschalten
                        */
                        $(".a-input")[index].style.display = "none";
                        $(".changeAddressItem")[index].style.display = "block";
                        /*
                            AddressItem wird geändert
                        */
                        //select
                        if(index == 0){
                            let e=document.getElementById("Land");
                            const land=e.options[e.selectedIndex].innerHTML;
                            $(".addressItem")[index].innerHTML = land;
                        }
                        //input
                        else{
                            $(".addressItem")[index].innerHTML = $(".a-input input")[index-1].value;
                        }
                        /*
                            msg-Box wird geleert und versteckt
                        */
                        $(".msgBox-r")[index].innerHTML = "";
                        $(".msgBox-r")[index].style.display = "none";
                    }else{
                        /*
                            wenn msgBox davor leer war, wird required hineingeschrieben
                        */
                        if($(".msgBox-r")[index].innerHTML == ""){
                            $(".msgBox-r")[index].innerHTML = "required";
                            $(".msgBox-r")[index].style.display = "block";
                        }
                    }
                });
            });
            /*
                Bei click auf Edit wird von address-information auf input umgeschalten
            */
            $(".ai-edit").each(function(index){
                $(this).click(function(){
                    
                    $(".a-input")[index].style.display = "block";
                    $(".changeAddressItem")[index].style.display = "none";
                });
            });
            /*
                Farbe von msg-Box wird festgelegt
            */
            $(".msgBox-r").each(function(index){
                $(this).css("background-color","rgb(255, 153, 153)");
                $(this).hide();
            });
            /*
            /*
                Validation:

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
                Action für btnprev: 
                    container 2 wird ausgeblendet
                    container 1 wird eingeblendet
            */
            $("#btnPrev-2").click(function(){
                /*
                    es wird nochmal alles validiert
                */
                $(".a-input-save").each(function(index){
                    $(this).trigger("click");
                });
                /*
                    wenn keine msgBox mehr offen --> weiter
                */
                let everythingValid = true;
                $(".msgBox-r").each(function(index){
                    if($(".msgBox-r")[index].style.display == "block"){
                        everythingValid = false;
                        return;
                    }
                });

                if(everythingValid){

                    /*
                        Addresse speichern
                    */
                    let e=document.getElementById("Land");
                    const land=e.options[e.selectedIndex].value;
                    $.post("phpFiles/httpRequests/orderProducts/setAddress.php",
                    {
                        land: land,
                        ort: $("#r-ort").val(),
                        plz: $("#r-plz").val(),
                        street: $("#r-street").val(),
                        hnr: $("#r-hnr").val()  
                    },function(data,status){
                        $("#op-page2").hide();
                        $("#op-page1").show();
                    });
                }    
            });
            /*
                Action für btnNext:
            */
            $("#btnNext-2").click(function(){
                /*
                    es wird nochmal alles validiert
                */
                $(".a-input-save").each(function(index){
                    $(this).trigger("click");
                });
                /*
                    wenn keine msgBox mehr offen --> weiter
                */
                let everythingValid = true;
                $(".msgBox-r").each(function(index){
                    if($(".msgBox-r")[index].style.display == "block"){
                        everythingValid = false;
                        return;
                    }
                });

                if(everythingValid){

                    /*
                        Addresse speichern
                    */
                    let e=document.getElementById("Land");
                    const land=e.options[e.selectedIndex].value;
                    $.post("phpFiles/httpRequests/orderProducts/setAddress.php",
                    {
                        land: land,
                        ort: $("#r-ort").val(),
                        plz: $("#r-plz").val(),
                        street: $("#r-street").val(),
                        hnr: $("#r-hnr").val()  
                    },function(data,status){
                        /*
                            Name wird befüllt
                        */
                        $.post("phpFiles/httpRequests/orderProducts/getName.php",
                        {},function(data,status){
                            /*
                                nicht eingeloggt: msgBox
                            */
                            if(!data.loggedIn){
                                openOkMsgBox("Zugriff verweigert!","nicht eingeloggt!");
                            }else{
                                openName(data);
                                $("#op-page2").hide();
                                $("#op-page3").show();
                            }
                        });
                    });
                }
                    
            });
        </script>
    </div>