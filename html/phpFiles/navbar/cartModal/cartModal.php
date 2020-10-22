

<div id = "cartModal" class = "modal">
    <div class = "modal-content" id = "cartModal-content" style = "padding-top: 80px;">
        <span class="close" id = "cm-close">&times;</span>
        <span class = "back" id = "backToProduct">&lsaquo;</span>
        <div class = "modal-header" id = "mc-header1" style="font-size:16pt; margin-top:5px; margin-left:80px;">
            <span id = "cart-productName"></span> wurde <span id = "cart-productNum"></span> hinzugef&uuml;gt
        </div>
        <div class = "modal-header" style = "margin-left:4%; text-decoration: underline;">Warenkorb:</div>

        <div id="cart" style = "margin-left:4%">

        </div>

        <button id = "btn-orderProducts" class = "btn-orderProducts">bestellen</button>
    </div>
    <script>

        let cartPidArray;
        let numberArray;
        let priceArray;

        function initCart(){
            /*
                action für bestellen
            */
            $("#btn-orderProducts").click(function(){
                /*
                    es wird überprüft, ob user eingeloggt ist und ob cart eh befüllt
                */
                $.post("phpFiles/httpRequests/getLoggedIn.php",{                   
                },function(data,status){
                    /*
                        Wenn Warenkorb leer, kann auch nichts bestellt werden
                    */
                    if(data.cartLength==0){
                        openOkMsgBox("Warenkorb leer","Es gibt nichts, was Sie bestellen k&ouml;nnten");
                    
                    /*
                        Wenn eingeloggt und Warenkorb befüllt, kann weitergeleitet werden
                    */
                    }else if(data.loggedIn){
                        document.location = "orderProducts.php";
                    /*
                        Wenn nicht eingeloggt, wird login-modal geöffnet
                    */
                    }else{
                        openLoginModal("Einloggen um fortzufahren",function(success){
                            if(success)
                                document.location = "orderProducts.php";
                        });
                    }
                });

            });

            cartPidArray = getCartPidArray();
            numberArray = getNumberArray();
            priceArray = getPriceArray();
            
            /*
                Die Summen werden initialisiert, um im richtigen Format dargestellt zu werden
            */
            $(".cart-sum").each(function(index){
                updatePrice(index);
            });
            /*
                Der Link zum Produkt im Product-Modal wird initialisiert
            */
            $(".cart-product-link").each(function(index){
                $(this).click(function(){
                    /*
                        Wenn user sich bereits auf home.php befindet, wird ProductModal geöffnet
                        ,sonst wird home.php mit Parameter product= geladen
                    */
                    if(typeof(openProductModal) == "function"){
                        openProductModal(cartPidArray[index]);
                    }else{
                        document.location="home.php?product="+cartPidArray[index];
                    }
                });
            });
            /*
                Action für Up-Button bei cart.
            */
            $(".cart-numUp").each(function(i){
                $(this).click(function(){
                    numberArray[i]+=1;
                    updatePrice(i);
                });
            });
            /*
                Action für down button bei cart
            */
            $(".cart-numDown").each(function(i){
                $(this).click(function(){
                    /*
                        Anzahl darf nicht kleiner als 1 sein
                    */
                    if(numberArray[i]>1){
                        numberArray[i]-=1;
                        updatePrice(i);
                    }
                });
            });
            /*
                Action für delete - button bei cart
            */
            $(".cart-deleteBtn").each(function(index){
                $(this).click(function(){
                    deleteCartItem(index);
                });
            });

            function updatePrice(i){
                $(".cart-num")[i].innerText = numberArray[i];
                let sum = numberArray[i]*priceArray[i];
                //es wird gerundet
                sum = Math.round((sum+ Number.EPSILON) * 100) / 100;

                let sumText = ""+sum;
                if(sum%1==0){
                    sumText+=".-&nbsp;&euro;";
                }else{
                    sumText+="&nbsp;&euro;";
                }
                $(".cart-sum")[i].innerHTML = sumText;
                $(".sum1")[0].innerHTML = getGespreis();
            }
            function getGespreis(){
                let gesPreis = 0;
                for(let i=0;i<priceArray.length;i++){
                    gesPreis+=numberArray[i]*priceArray[i];
                }
                //es wird gerundet
                gesPreis = Math.round((gesPreis + Number.EPSILON) * 100) / 100;
                let sumText = ""+gesPreis;
                if(gesPreis%1==0){
                    sumText+=".-&nbsp;&euro;";
                }else{
                    sumText+="&nbsp;&euro;";
                }
                return sumText;
            }
        }
        /*
            cartitem wird gelöscht
        */
        function deleteCartItem(i){
                //Item wird gelöscht
                updateCart(i);
            }
        /*
            Warenkorb wird aktualisiert, Werte werden gespeichert
        */
        function updateCart(indexDelete = -1){
            let number;
            if(numberArray!=null)
                number = JSON.stringify(numberArray);
            else
                number = null;
            $.post("phpFiles/httpRequests/cart/getCart.php",
            {
                indexDelete: indexDelete,
                number: number
            },function(data,status){
                $("#cart").html(data);
                initCart();
            });
        }
        /*
            wenn bei cart - modal aufs x geklickt --> wird geschlossen
        */
        $("#cm-close").click(function(){
            closeCartModal();
            updateCart();
        });

        /*
            wenn ausserhalb von Cart-Modal geklickt --> wird geschlossen
        */
        initCartModalClose();
        function initCartModalClose(){
            let cmClicked = false;
            $("#cartModal").click(function(){
                cmClicked = true;
                setTimeout(function(){
                    if(cmClicked){
                        closeCartModal();
                        updateCart();
                    }
                    cmClicked = false;
                },100);
            });
            $("#cartModal-content").click(function(){
                setTimeout(function(){
                    cmClicked = false;
                },50);
            });
        }
        /*
            Wenn BackToProduct geklickt --> cartModal schliessen, zurück zum ProductModal
        */
        $("#backToProduct").click(function(){
            $("#cartModal").hide();
            updateCart();
            $("#productModal").show();
        });

        function closeCartModal(){
            /*
                Element wird versteckt
            */
            $("#cartModal").hide();
            /*
                um Parameter product in url zu entfernen
            */
            if(typeof(closeProductModal)=="function")
                closeProductModal();
        }
    </script>
</div>
