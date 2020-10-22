<div id = "address">
    <label for="land">Land:</label><br>
    <?php 
    /**
     * Länder werden aus DB geladen und in Select geschrieben
     */
    $result=$conn->query("SELECT code, en FROM countries ORDER BY en ASC");?>
    <div id = "msgBox-r-land" class = "msgContainer msgBox-a"></div>
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
    <div id = "msgBox-r-ort" class = "msgContainer msgBox-a"></div>
    <div class = "a-input" id = "a-input-ort">
    <input type = 'text'  name = 'ort' id = "r-ort" value = '' required placeholder="Ort">
    <i class="fas fa-save fa-lg a-input-save"></i>
    </div>

    <div class = "changeAddressItem" id = "change-ai-ort">
    <span class = "addressItem" id = "ai-ort"></span>
    <i class="fas fa-edit ai-edit" id = "ai-edit-ort"></i>
    </div>


    <label for="plz">PLZ:</label>
    <div id = "msgBox-r-plz" class = "msgContainer msgBox-a"></div>
    <div class = "a-input" id = "a-input-plz">
    <input type = 'text'  name = 'plz' id = "r-plz" value = '' required placeholder="Postleitzahl">
    <i class="fas fa-save fa-lg a-input-save"></i>
    </div>

    <div class = "changeAddressItem" id = "change-ai-plz">
    <span class = "addressItem" id = "ai-plz"></span>
    <i class="fas fa-edit ai-edit" id = "ai-edit-plz"></i>
    </div>


    <label for="street">Strasse:</label>
    <div id = "msgBox-r-street" class = "msgContainer msgBox-a"></div>
    <div class = "a-input" id = "a-input-street">
    <input type = 'text'  name = 'street' id = "r-street" value = '' required placeholder="Strasse">
    <i class="fas fa-save fa-lg a-input-save"></i>
    </div>

    <div class = "changeAddressItem" id = "change-ai-street">
    <span class = "addressItem" id = "ai-street"></span>
    <i class="fas fa-edit ai-edit" id = "ai-edit-street"></i>
    </div>


    <label for="hnr">Hausnummer:</label>
    <div id = "msgBox-r-hnr" class = "msgContainer msgBox-a"></div>
    <div class = "a-input" id = "a-input-hnr">
    <input type = 'text'  name = 'hnr' id = "r-hnr" value = '' required placeholder="Hausnummer">
    <i class="fas fa-save fa-lg a-input-save"></i>
    </div>

    <div class = "changeAddressItem" id = "change-ai-hnr">
    <span class = "addressItem" id = "ai-hnr"></span>
    <i class="fas fa-edit ai-edit" id = "ai-edit-hnr"></i>
    </div>

    <script>
    $(document).ready(function(){
        openAddress();
        /*
            Addresse wird befüllt
        */
        function openAddress(){
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
            });      
        }
        /*
            keylistener, um neben save auch enter nutzen zu können
        */
       $("#address input").each(function(i){
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
        */
        $(".a-input-save").each(function(index){
            $(this).click(function(){

                let valid = false;
                /*
                    es wird validiert
                */
                //select
                if(index == 0){
                    
                    valid = addressLandValidator.validate();
                }
                //input
                else{
                    valid = addressInputValidator[index-1].validate();
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
                    $(".msgBox-a")[index].innerHTML = "";
                    $(".msgBox-a")[index].style.display = "none";

                    saveAddress();
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
        $(".msgBox-a").each(function(index){
            $(this).css("background-color","rgb(255, 153, 153)");
            $(this).hide();
        });

        /*
            Alles wird gespeichert
        */
        function saveAddress(){
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
                
            });
        }
        
        let addressLandValidator = new SelectValidator(false,"Land",$(".msgBox-a").get(0),"Select country");
        /*
            InputValidators werden erzeugt
        */
       let patterns = 
            ["^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df\\.,-])*$",//ort
            "^\\d\\d*$",//plz
            "^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df\\.,-])*$",//strasse
            "^\\d\\w*$"];//hausnummer
        let addressInputValidator = new Array();
        $("#address input").each(function(i){
            addressInputValidator.push(new InputValidator(false,patterns[i],$(this),$(".msgBox-a").get(i+1)));
        });
    });
    </script>
</div>