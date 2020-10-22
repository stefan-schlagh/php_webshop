<?php
header('Content-Type: text/html; charset=ISO-8859-1');
session_start();

include 'phpFiles/database/dbConnection.php';

include_once 'phpFiles/classes/cart.php';

$cart = new cart();

$cart->initial_cart();
if(!isset($_SESSION["userID"])){
    header("LOCATION: index.php");
    exit;
}
$uid=$_SESSION["userID"];

?>
<!doctype html>
<head>
    <meta charset = "utf8">
    <title>webshop</title>
    <link rel ='stylesheet' href='CSS/style1.css'>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
    <link rel = "stylesheet" href = "https://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.10.5/css/jquery.dataTables.css">
    <link rel = "icon" href = "icon.png">
    <script src = "https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.4.1.js"></script>
    <script src = "https://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.10.5/jquery.dataTables.js"></script>
</head>
<body>
<?php include 'phpFiles/navbar/navbar.php';
//DATE_FORMAT(Datum,'%d.%m.%Y') AS 'Datum'
$sql = 
    "SELECT b.UID, Datum, Uhrzeit, sum(Menge*PPreis) AS 'GesPreis', b.BID
    FROM bestellung b 
    INNER JOIN bestellposition bp
    ON b.BID = bp.BID
    GROUP BY b.BID
    HAVING UID = '$uid'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {//wenn mehr als null Bestellungen vorhanden sind:
    $bid = array();
    ?>
    <div class = "jumbotron-wide">
        <h2>Bestellungen:</h2>
        <table id = "orderTable">
            <thead>
                <tr><th>Datum</th><th>Uhrzeit</th><th>Preis</th><th>Rechnung</th></tr>
            </thead>
            <tbody>
        <?php 
        while ($row = $result->fetch_assoc()) {  

            $bid[]=intval($row["BID"]);

            $date = strtotime($row["Datum"]);
            $dateformat = date('d.m.Y',$date);
            ?>
                <tr>
                    <td data-sort = "<?=$date?>"><?=$dateformat?></td>
                    <td><?=$row["Uhrzeit"]?></td>
                    <td><?=number_format($row["GesPreis"], 2, ',', '')?> Euro</td>
                    <td><i class="far fa-file-pdf fa-lg pdf-icon2"></i></td>
                </tr>

            <?php
        }
        ?>
            </tbody>
        </table>
        
        <script>
            $(document).ready( function () {
                let bid = JSON.parse("<?=json_encode($bid)?>");

                /*
                    Action für Rechnung
                */
                $(".pdf-icon2").each(function(index){
                    $(this).click(function(){
                        window.open("phpFiles/orderProducts/rechnung.php?rnr="+bid[index]);
                    });
                });

                $('#orderTable').DataTable();
            });
        </script>
    </div>  
    <?php 

}else{
    echo "nothing found!";
}
?>

	
	

</body>