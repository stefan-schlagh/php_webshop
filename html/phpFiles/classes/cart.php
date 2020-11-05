<?php

include "cartItem.php";

class cart{

    protected $cid;
    protected $cart;

    public function initial_cart(){
        
        $this->cart = array();
        /*
            Wenn Session cart noch nicht gesetzt, wird es initialisiert
        */
        if(!isset($_SESSION["cart"])){
            //dbConnection
            include $_SERVER["DOCUMENT_ROOT"]."/phpFiles/database/dbConnection.php";
            /*
                Wenn userID in Session gesetzt, wird cid aus DB geladen
            */
            if(isset($_SESSION["userID"])){
                $result = $conn->query("SELECT cartId FROM user WHERE UID = ".$_SESSION["userID"]);
                
                if($row=$result->fetch_assoc()){
                    $this->cid=$row["cartId"];
                    if($this->cid==0){
                        $this->getUnusedCartId();
                        $conn->query("UPDATE user SET cartId = '".$this->cid."' WHERE UID = ".$_SESSION["userID"]);
                    }
                }
                /*
                    sonst wird unbenutzte cid aus DB-Tabelle selected
                */
                else{
                    $this->getUnusedCartId();
                }
            }
            /*
                sonst wird unbenutzte cid aus DB-Tabelle selected
            */
            else{
                $this->getUnusedCartId();
            }

            $_SESSION["cid"] = $this->cid;
            $_SESSION["cart"] = $this->cart;
            //wenn eingeloggt, cart laden 
        }else{
            /*
                Wenn Session cart bereits gesetzt, werden Attribute initialisiert
            */
            $this->cid = $_SESSION["cid"];
            $this->cart = $_SESSION["cart"];
        }
        
    }
    private function getUnusedCartId(){
        //dbConnection
        include $_SERVER["DOCUMENT_ROOT"]."/phpFiles/database/dbConnection.php";
        /*
            max cid wird aus DB selected
        */
        $result = $conn->query("SELECT max(CID) AS 'cid' FROM cart") or die($conn->error);
        if($row=$result->fetch_assoc()){
            /*
                erste unbenutze cid (max+1) wird genommen
            */
            $this->cid=intval($row["cid"])+1;
        }
    }
    private function getUnusedCartItemId(){
        //dbConnection
        include $_SERVER["DOCUMENT_ROOT"]."/phpFiles/database/dbConnection.php";
        /*
            max ciid wird aus DB selected
        */
        $result = $conn->query("SELECT max(CIID) AS 'ciid' FROM cart");
        if($row=$result->fetch_assoc()){
            /*
                erste unbenutze ciid (max+1) wird genommen
            */
            return intval($row["ciid"]);
        }
    }
    public function insertArtikel($pid, $name, $preis, $anzahl){
        /*
            dbConnection
        */
        include $_SERVER["DOCUMENT_ROOT"]."/phpFiles/database/dbConnection.php";
        /*
            wenn noch kein Artikel in Cart, nochmal überprüfen wegen max(CID)
        */
        if(count($this->cart)==0){

            $this->getUnusedCartId();
            
            if(isset($_SESSION["userID"]))
                $conn->query("UPDATE user SET cartId = '".$this->cid."' WHERE UID = ".$_SESSION["userID"]);
        }
        /*
            Variable, ob Artikel schon in Warenkorb vorhanden
        */
        $articleInCart = false;
        /*
            Es wird über alle items in cart geloopt, um zu schauen ob Artikel evtl. bereits vorhanden und nur Anzahl erhöht werden muss
        */
        for($i=0;$i<count($this->cart);$i++){
            /*
                Wenn Artikel bereits im Warenkorb vorhanden (gleiche PID)
            */
            if($this->cart[$i]->getPid()===$pid){
                /*
                    Anzahl wird erhöht
                */
                $this->cart[$i]->setNumber($this->cart[$i]->getNumber()+$anzahl);
                $articleInCart=true;
                /*
                    Die Daten in der datenbank werden aktualisiert
                */
                $conn->query("UPDATE cart SET Num = ".$this->cart[$i]->getNumber()." WHERE CIID = ".$this->cart[$i]->getCiid());
            }
        }
        /*
            Wenn Artikel noch nicht im Warenkorb vorhanden
        */
        if(!$articleInCart){
            /*
                Artikel wird in Datenbank eingefügt
            */
            $conn->query("INSERT INTO cart (CID,PID,Num) VALUES (".$this->cid.",$pid,$anzahl)");
            /*
                neues Item wird erstellt
            */
            $article = new cartItem($pid,$this->getUnusedCartItemId(),$name,$preis,$anzahl);
            /*
                Item wird zu Warenkorb hinzugefügt
            */
            array_push($this->cart, $article);
        }
        $_SESSION['cart'] = $this->cart;
        
    } 
    
    public function getcart()
    {
        $cart = $_SESSION['cart'];
        ?>
 
        <body>
            <?php 
            $pid = array();
            $num = array();
            $price = array();

            if(count($cart)==0):?>
                Warenkorb ist leer
            <?php else:?>
            <table class="cart-table">
            <tr class = "cart-header"><th colspan="2">Produkt</th><th>Preis/St&uuml;ck</th><th>Anzahl</th><th>Preis</th>
                <?php 
                $gesamtkosten=0;

                for($i = 0 ; $i < count($cart); $i++)
                {
                    $item = $cart[$i];
                    $gesamtkosten += $item->getGesPreis();
                    $pid[] = intval($item->getPid());
                    $num[] = intval($item->getNumber());
                    $price[] = floatval($item->getPrice());

                    ?><tr class = 'cart-row'>
                        <td class = 'content'><?=$i+1?></td>
                        <td class = 'content'>
                            <a href = "javascript:void(0)" class = "cart-product-link"><?=$item->getName();?></a>
                        </td>
                        <td class = 'content'><?=$item->getPrice();?></td>
                        <td class = 'content'>
                            <span class = "cart-num"><?=$item->getNumber();?></span>
                            <div class = "cart-changeNum">
                                <i class="fas fa-angle-up fa-2x cart-numUp"></i>
                                <i class="fas fa-angle-down fa-2x cart-numDown"></i>
                            </div>
                        </td>
                        <td class = 'content cart-sum'><?=$item->getGesPreis();?></td>             
                        <td class = "cart-delete"><a class = "cart-deleteBtn">&times;</a></td>
                    </tr>
                    <?php
                }
                
                ?>
                <tr class = 'cart-GSum'><td></td><td></td><td colspan="2">Summe:</td><td class="sum1"><?=$gesamtkosten?>&nbsp;&euro;</td></tr>
                </table>
            <?php endif;?>
            <script>
                function getCartPidArray(){
                    return(JSON.parse("<?=json_encode($pid)?>"));
                }
                function getNumberArray(){
                    return(JSON.parse("<?=json_encode($num)?>"));
                }
                function getPriceArray(){
                    return(JSON.parse("<?=json_encode($price)?>"));
                }
            </script>
        </body>
        <?php 
    }
    public function getCartOverview(){
        ?>
            <table class="cartOverview-table">
            <tr class = "cartOverview-header"><th>Produkt</th><th>Anzahl</th><th>Preis</th></tr>
            <?php
            $gesPreis = 0;
            for($i=0;$i<count($this->cart);$i++){
                $item = $this->cart[$i];
                $gesPreis += $item->getGesPreis();
                ?>
                    <tr class = "cartOverview-row">
                        <td class = 'content'><?=$item->getName();?></td>
                        <td class = 'content'><?=$item->getNumber();?></td>
                        <td class = 'content'><?=$item->getPrice();?></td>   
                    </tr>
                <?php
            }
            ?>
            </table>
            <h2>Gesamtpreis: <?=$gesPreis?> &euro;
            <?php
    }
    public function getCid(){
        return $this->cid;
    }
    public function getCartValueAtPoint($point){
        $Array = $_SESSION['cart'];
        return($Array[$point]);
    }
    public function setNumArray($numArr){

        //dbConnection
        include $_SERVER["DOCUMENT_ROOT"]."/phpFiles/database/dbConnection.php";
        /*
            es wird durch cart geloopt und nach Unterschieden in der Anzahl gesucht
        */
        if(count($numArr)==count($this->cart)){
            for($i=0;$i<count($numArr);$i++){
                if($this->cart[$i]->getNumber() != $numArr[$i]){
                    $this->cart[$i]->setNumber($numArr[$i]);
                    /*
                    Die Daten in der datenbank werden aktualisiert
                    */
                    $conn->query("UPDATE cart SET Num = ".$this->cart[$i]->getNumber()." WHERE CIID = ".$this->cart[$i]->getCiid());
                }
            }
        }
        $_SESSION["cart"] = $this->cart;
    }
    public function loadCart($uid){
        /*
            dbConnection
        */
        include $_SERVER["DOCUMENT_ROOT"]."/phpFiles/database/dbConnection.php";
        /*
            Daten werden aus DB gelöscht
        */
        $cid = $this->cid;
        $conn->query("DELETE FROM cart WHERE CID = $cid");
        /*
            Array im Objekt wird überschrieben, vorherige Einträge sind nicht mehr vorhanden
        */
        $this->cart = array();
        /*
            cid wird auf die in der Db Tabelle user befindliche umgeändert
        */
        $result = $conn->query("SELECT cartId FROM user WHERE UID = $uid");
        if($row=$result->fetch_assoc()){
            $this->cid = intval($row["cartId"]);
        }

        $conn->query("SET @p0 = '$uid'");
        $result = $conn->query(" CALL `selectCartContent`(@p0)");

        while($row = $result->fetch_assoc()){
            /*
                neues Item wird erstellt
            */
            $article = new cartItem($row["PID"],$row["CIID"],$row["Bez"],$row["Preis"],$row["Num"]);
            /*
                Item wird zu Warenkorb hinzugefügt
            */
            array_push($this->cart, $article);
        }
        //TODO cart laden
        $_SESSION["cart"] = $this->cart;
    }
    /**
     *
     * Entfernt ein Artikel am index n
     * @param int $index
     */ 
    public function deleteCartValueAtIndex($i)
    {
        /*
            dbConnection
        */
        include $_SERVER["DOCUMENT_ROOT"]."/phpFiles/database/dbConnection.php";
        /*
            delete in DB
        */
        $ciid = $this->cart[$i]->getCiid();
        $conn->query("DELETE FROM cart WHERE CIID = $ciid");
        /*
            delete in Array
        */
        unset($this->cart[$i]);
        $this->cart = array_values($this->cart);
        $_SESSION['cart'] = $this->cart;
    }
    
    public function deleteCart(){
        unset($_SESSION['cart']);
    }
    /**
     *
     * Gibt die Anzahl der Artikel zur?ck
     */ 
    public function getCartCount()
    {
        return count($_SESSION['cart']);
    } 
}