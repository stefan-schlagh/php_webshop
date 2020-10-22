<?php
header('Content-Type: text/html; charset=ISO-8859-1');
session_start();
//db-Verbindung aufbauen, um username + passwort zu ueberpruefen
include 'phpFiles/database/dbConnection.php';

//Validation Methoden
include 'phpFiles/validation/validationMethods.php';

$UID="";
$rc="";
$successcode=1;
/*
 * TODO: successcode vereinheitlichen
 * 0...success
 * 1...neutral
 * 2...kein gueltiger Link
 * 3...ungueltiges Passwort
 * 4...Passwoerter stimmen nicht ueberein
 * 
 */

/*
 * ist UID und rc in GET definiert?
 * ist UID ein Integer? --> sonst Gefahr einer Sql-Injection
 * sonst: link ungueltig
 */
if(isset($_GET["UID"])&&isset($_GET["rc"])&&validateInteger($_GET["UID"])){
    $UID=$_GET["UID"];
    $rc=$_GET["rc"];
    
    $sql="SELECT PasswortResetCode AS rc FROM user WHERE UID=$UID";
    $result=$conn->query($sql);
    /*
     * ist ein User mit dieser UID vorhanden?
     * sonst: link ungueltig
     */
    if($row=$result->fetch_assoc()){
        /*
         * stimmt rc in der URL mit rc in DB ueberein?
         * sonst: link ungueltig
         */
        if($row["rc"]==$rc){
            /*
             * ist password in POST bereits vorhanden?
             * sonst: link wurde erst aufgerufen, passwort wird daher nicht validiert, es steht ja auch noch keines drin
             */
            if(isset($_POST["password"])){
                $password=$_POST["password"];
                /*
                 * Passwort wird validiert
                 *  -> Methode siehe validationMethods.php
                 *  sonst: ungueltiges Passwort
                 */
                if(validatePassword($password)){
                    /*
                     * sind password1 und 2 gleich?
                     * sonst: Passwoerter stimmen nicht ueberein
                     */
                    if($_POST["password"]==$_POST["repeatPassword"]){
                        /*
                         * da alle Erfordernisse gegeben sind, wird neues Passwort in DB gespeichert
                         */
                        $hash = hashPassword($password);
                        $conn->query("UPDATE user SET Password='$hash', PasswortResetCode = '' WHERE UID='$UID'");
                        $successcode=0;
                    }else{
                        $successcode=4;
                    }
                }else{
                    $successcode=3;
                }
            }
        }else {
            $successcode=2;
        }
    }else{
        $successcode=2;
    }
}else{
    $successcode=2;
}

?>
<!doctype html>
<head>
	<meta charset = "ISO-8859-1" >
	<title>index</title>
    <link rel ='stylesheet' href='CSS/style1.css'>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
    <link rel = "icon" href = "icon.png">
    <script type = "text/javascript" src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.4.1.js"></script>
</head>
<body>
<?php  include  'phpFiles/navbar/navbar.php';?>

	<div class="container">
		<?php 
		/*
		 * entsprechend des errorcodes werden die msgContainer ausgegeben
		 *    wenn Passwort bereits geaendert wurde, oder link nicht gueltig ist, wird form nicht angezeigt
		 *    wenn Passwort nicht passt, schon
		 */
		      if($successcode==0):?>
			<div class="msgContainer" style="background-color: #80ff80;">Password successfully changed!</div>
		
		<?php elseif($successcode==2):?>
			<div class="msgContainer" style="background-color: #ff9999;">link not valid!</div>
		<?php else:
		          if($successcode==3):?>
					<div class="msgContainer" style="background-color: #ff9999;">not a Password!</div>
		<?php 
		          elseif($successcode==4):?>
		  			<div class="msgContainer" style="background-color: #ff9999;">Passwords do not match!</div>
		<?php   
		          endif;
		?>
			<form action = 'enternewPW.php?UID=<?=$UID?>&rc=<?=$rc?>' method = 'post'>
				<label for="password"><b>Password:</b></label><input type = 'password' name = 'password' id = "password" value = '' required placeholder="Enter Password">
				<label for="repeatPassword"><b>Repeat Password:</b></label><input type = 'password' name = 'repeatPassword' id = 'repeatPassword' value = '' required placeholder="Repeat Password">
				<input type = 'submit' class = "btnNext" name = 'btnSubmit' value = 'submit'>
			</form>
	</div>
	<?php endif;?>
	
</body>