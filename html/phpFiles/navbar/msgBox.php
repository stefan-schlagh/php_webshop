

<div class = "modal" id = "msgBox">
    <div class = "msgBoxModal-content">
        <span id = "msgBox-close" class = "close">&times;</span>
        <div id = "msgBox-header" class = "modal-header">
        </div>
        <div id = "msgBox-text">
        
        </div>
        <div id = "msgBox-ok" class = "msgBox-option">
            <button id = "msgBox-okOption" class = "msgBox-button msgBox-ok">OK</button>
        </div>
        <div id = "msgBox-yesno" class = "msgBox-option">
            <button id = "msgBox-yesOption" class = "msgBox-button msgBox-yes">ja</button>
            <button id = "msgBox-noOption" class = "msgBox-button msgBox-no">nein</button>
        </div>
    </div>
</div>

<script defer>

    /*
        Wenn bei msgBox auf x geklickt --> wird geschlossen
    */
    $("#msgBox-close").click(function(){
        closeMsgBox();
    });
    

    function openOkMsgBox(header,text,okCallback){
        //Überschrift wird gesetzt
        $("#msgBox-header").html(header);
        //Text wird gestzt
        $("#msgBox-text").html(text);

        //Btn- div mit ok wird eigeblendet
        $("#msgBox-ok").show();
        //msgBox zeigen
        $("#msgBox").show();

        //click-function für ok
        $("#msgBox-okOption").click(function(){
            closeMsgBox();
            //Wenn okCallback definiert, wird es aufgerufen
            if(typeof(okCallback)=="function"){
                okCallback();
            }
        });
    }
    function openYesNoMsgBox(header,text,yesCallback,noCallback){
        //Überschrift wird gesetzt
        $("#msgBox-header").html(header);
        //Text wird gestzt
        $("#msgBox-text").html(text);

        //Btn- div mit yesno wird eigeblendet
        $("#msgBox-yesno").show();
        //msgBox zeigen
        $("#msgBox").show();

        //click-function für yes
        $("#msgBox-yesOption").click(function(){
            closeMsgBox();
            //Wenn okCallback definiert, wird es aufgerufen
            if(typeof(yesCallback)=="function"){
                yesCallback();
            }
        });

        //click-function für no
        $("#msgBox-noOption").click(function(){
            closeMsgBox();
            //Wenn okCallback definiert, wird es aufgerufen
            if(typeof(noCallback)=="function"){
                noCallback();
            }
        });
    }
    function closeMsgBox(){
        //divs mit den Optionen werden ausgeblendet
        $(".msgBox-option").each(function(index){
            $(this).hide();
        });
        //event listener von buttons werden entfernt
        $(".msgBox-button").each(function(index){
            $(this).unbind();
        });
        //msgBox wird versteckt
        $("#msgBox").hide();
    }

</script>