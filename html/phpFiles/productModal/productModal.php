<div id="productModal" class="modal">

    <div class="modal-content" id = "productModal-content">
        <span class="close" id = "pm-close">&times;</span>
        <div id = "modal-header" class = "modal-header"></div>
        <span class = "modal-catBox">
            <span id = "modal-cat"></span>
            &nbsp;&rarr;&nbsp;
            <span id = "modal-subcat"></span>
            <br/>
        </span>
        <div class = "pm-main">
            <div class = "pm-main-inner pm-main-left">
                <img id = "productImage1" src="">
            </div>
            <div class = "pm-main-inner pm-main-right">
                <div id = "modal-rating-top" class = "modal-rating-top">
                    <span id = "modal-rating-star"></span>
                    &empty; <span id = "modal-rating-avg"></span>/5&nbsp;bei&nbsp;
                    <span id = "modal-rating-num"></span>&nbsp;
                    <a href = "#rating-modal" id = "modal-rating-link" class = "modal-rating-link"></a>
                </div>
                <span id = "modal-rating-top2" class = "modal-rating-top" style = "display:none;">
                    Noch keine <a href = "#rating-modal" id = "modal-rating-link2" class = "modal-rating-link">Bewertungen</a> vorhanden
                </span>
                <div class = "product-description" id = "product-description">
                    
                </div>
                <div class = "pm-bottom" >
                    <span>Preis pro St&uuml;ck:&nbsp;<span id = "modal-price"></span>&nbsp;&euro;</span><br>
                    <div class = "modal-cart">
                        <input type="number" min = "1" max = "999"  step = "1" value = "1" style="width: 3em" id="modal-num">
                        <span id="price-sum" style = "display: inline-block; width:50px; text-align:right;"></span>&nbsp;&euro;

                        <script type = "text/javascript">
                            $("#modal-num").on("input",function(){
                                const num = parseFloat(document.getElementById("modal-num").value);
                                if(Number.isInteger(num)&&num>0&&num<1000){
                                    $("#modal-num").css("border-color","black");
                                    res=price*num
                                    res = Math.round((res + Number.EPSILON) * 100) / 100;
                                    document.getElementById("price-sum").innerText=res;
                                }else{
                                    $("#modal-num").css("border-color","red");
                                }
                            });
                            function insertProductIntoCart(){
                                const num = parseFloat(document.getElementById('modal-num').value);
                                if(Number.isInteger(num)&&num>0&&num<1000){
                                    $("#modal-num").css("border-color","black");
                                    const bez = $("#modal-header").html();
                                    
                                    $.post("phpFiles/httpRequests/cart/insertProductIntoCart.php",
                                    {
                                        pid: pidNow,
                                        bez: bez,
                                        price: price,
                                        num: num
                                    },function(data,status){
                                        $("#cart").html(data);
                                        initCart();
                                    });
                                    
                                    //Name des Produkts wird angezeigt
                                    document.getElementById("cart-productName").innerText = bez;
                                    //Anzahl wird angezeigt
                                    document.getElementById("cart-productNum").innerText = num +" - mal";

                                    productModal.style.display="none";
                                    cartModal.style.display="block";

                                    $("#productModal").hide();
                                    $("#cartModal").show();
                                    $("#backToProduct").show();
                                    $("#mc-header1").show();
                                }else{
                                    $("#modal-num").css("border-color","red");
                                }
                            }
                        </script>

                        <button onclick="insertProductIntoCart();">in den Warenkorb</button>
                    </div>
                </div>
            </div>
        </div>
        <span id = "rating-modal"></span>
        <div class = "review-modal" style = "display: block;">
            <div class = "review-own">
                <div>Bewerten sie das Produkt:</div>
                <div class="rating" id = "rating1">
                    <span class='fa fa-star'></span>
                    <span class='fa fa-star'></span>
                    <span class='fa fa-star'></span>
                    <span class='fa fa-star'></span>
                    <span class='fa fa-star'></span>
                </div>
                <div id="msgBox-ro" class = "msgBox-ro"></div>
                <textarea id = "review-text" class = "review-text" rows="4" cols="50" placeholder = "Bewertung verfassen..."></textarea>
                <button id = "submit-ro">abschicken</button>
            </div>
            <div id = "review-modal-toggle" class = "review-modal-toggle" style = "display: none;">
                <span class="review-count-text">alle Bewertungen anzeigen :</span>
                <button class = "rating-modal-toggle1">.|.</button>
            </div>
            <div class="review-box" id = "review-box">
                
            </div>
            <div class = "review-loadMsg" id = "review-loadMsg" style = "display:none;">weitere Bewertungen werden geladen <div class = "loader2"></div></div>
        </div>
    </div>


    <script defer>
        /*
            Wenn bei Login-Modal auf x geklickt --> wird geschlossen
        */
        $("#pm-close").click(function(){
            closeProductModal();
        });

        /*
            wenn ausserhalb von Login-Modal geklickt --> wird geschlossen
        */
        initProductModalClose();
        function initProductModalClose(){
            let pmClicked = false;
            $("#productModal").click(function(){
                pmClicked = true;
                setTimeout(function(){
                    if(pmClicked){
                        closeProductModal();
                    }
                    pmClicked = false;
                },100);
            });
            $("#productModal-content").click(function(){
                setTimeout(function(){
                    pmClicked = false;
                },50);
            });
        }

        //var productModal = document.getElementById("productModal");

        function openProductModal(pid1){

            pidNow = pid1;

            //&product=pid in url
            let url = new URL(document.location);
            url.searchParams.set("product",pid1);
            history.pushState(null,null,url);

            productRated = false;

            //Abfrage mit $.ajax --> responsecode verarbeiten
            $.ajax("phpFiles/httpRequests/home/getProductInformation.php",{
                type: "POST",
                data: { 
                    pid: pid1
                },
                statusCode: {
                    404: function(){

                        //TODO: Fehlermeldung anzeigen
                        openOkMsgBox("404...","Dieses Produkt scheint nicht zu existieren");
                    }
                }, success: function(data){
                    //Überschrift wird aktualisiert
                    $("#modal-header").html(data.Bez);

                    //Bild wird aktualisiert
                    $("#productImage1").attr("src",data.ImgSource);

                    //Beschreibung wird aktualisiert
                    $("#product-description").html(data.Beschreibung);

                    //Preis wird aktualisiert
                    price = parseFloat(data.Preis);
                    $("#modal-price").html(data.Preis);

                    //value von number-input auf 1 setzen
                    $("#modal-num").val(1);
                    $("#price-sum").html(data.Preis);

                    //Category wird aktualisiert
                    $("#modal-cat").text(data.Category);

                    //Subcategory wird aktualisiert
                    $("#modal-subcat").html(data.Subcategory);

                    //Rating wird aktualisiert
                    //Rating wird gerendert
                    let starRating = "";
                    const numRating = parseFloat(data.NumRating);
                    const avgRating = Math.round(parseFloat(data.AvgRating) * 100) / 100;

                    let j = 0;
                    for(; j < avgRating ; j++){
                        starRating += "<span class='fa fa-star checked'></span>"
                    }
                    for(;j < 5 ; j++){
                        starRating += "<span class='fa fa-star'></span>"
                    }
                    $("#modal-rating-star").html(starRating);
                    $("#modal-rating-avg").html(avgRating);
                    if(numRating==0){
                        $("#modal-rating-top2").show();
                        $("#modal-rating-top").hide();
                    }else if(numRating==1){
                        $("#modal-rating-top").show();
                        $("#modal-rating-top2").hide();
                        $("#modal-rating-num").html("einer");
                        $("#modal-rating-link").html("Bewertung");
                    }else{
                        $("#modal-rating-top").show();
                        $("#modal-rating-top2").hide();
                        $("#modal-rating-num").html(numRating);
                        $("#modal-rating-link").html("Bewertungen");
                    }

                    //Product-Modal wird gezeigt
                    $("#productModal").show();
                    const event = new CustomEvent("modalOpened");

                    const element = document.getElementById("mainContent");

                    element.dispatchEvent(event);
                }
            });
        }

        function openRatings(pid1){

            openProductModal(pid1);

            //zu Anker springen
            let urlBefore = document.location.href;
            document.location += "#rating-modal";
            history.pushState(null,null,urlBefore);
        }

        function closeProductModal(){
            /*
                Element wird versteckt
            */
            $("#productModal").css("display","none");
            /*
                Parameter product wird entfernt
            */
            let url = new URL(document.location);
            url.searchParams.delete("product");
            history.pushState(null,null,url);
        }

    </script>
    <?php 
        /*
            wenn product in url, wird modal aufgemacht
        */
        if(isset($_GET["product"])){
            ?>
            <script defer>
                setTimeout(function(){
                    openProductModal(<?=$_GET["product"]?>);
                },1000);
            </script>
            <?php
        }
    ?>

</div>