<?php
header('Content-Type: text/html; charset=ISO-8859-1');
session_start();

include 'phpFiles/database/dbConnection.php';

//Validation Methoden
include 'phpFiles/validation/validationMethods.php';


$username = "";
$successcode=1;
/*
 * TODO: successcode vereinheitlichen
 * 0...success
 * 1...neutral
 * 2...Username existiert bereits
 * 3...ung�ltige Einabe
 * 4...Passw�rter stimmen nicht �berein
 * 5...Bereits eingeloggt
 */

/*
 * TODO: wenn bereits angemeldet, keinen Zugang gew�hren
 */
if(isset($_SESSION["username"])){
    $successcode=5;
}

$usernameValidated=false;
$passwordvalidated=false;


/*
 * ist form bereits in Post vorhanden?
 * sonst: link wurde erst aufgerufen, passwort wird daher nicht validiert, es steht ja auch noch keines drin
 */
if(isset($_POST["submitRegister"])){
    $username = $_POST["username"];
    $password1 = $_POST["password"];
    $password2 = $_POST["repeatPassword"];
    /*
     * ist PW g�ltig
     */
    $passwordvalidated=validatePassword($password1);
    /*
     * ist Username g�ltig + Email
     * zur Vermeidung von SQL-Injection
     * sonst: 2...kein g�ltiger Username
     */
    if(validateUsername($username)&&$passwordvalidated){
        $usernameValidated=true;
        /*
         * SQL Abfrage mit Username, um zu versichern, dass dieser noch nicht exisiert
         */
        $sql = "SELECT * FROM user WHERE username ='$username'";
        $result = $conn->query($sql);
        /*
         * hat SQL- Query kein Ergebnis --> Username existiert noch nicht
         * sonst: 2...Username existiert bereits
         */
        if(!($row = $result->fetch_assoc())){
            /*
             * sind die Pass�rter gleich?
             * sonst: 4...Passw�rter stimmen nicht �berein
             */               
            if($password1===$password2){
                $hash = hashPassword($password1);
            
                $sql = "INSERT into user (Username,Password,Vorname,Nachname,Email,Land,Ort,PLZ,Strasse,HausNr) values ('$username','$hash','','','','','',0,'',0)";// user in DB speichern
                mysqli_query($conn,$sql);
                        
                $_SESSION["username"]=$username;
                $_SESSION["userID"]=(($conn->query("SELECT max(UID) FROM `user`"))->fetch_assoc()["max(UID)"]);
                //header("LOCATION: index.php");
                $successcode=0;
            }else{
                $successcode=4;
            }
        }else{
            $successcode=2;
        }
    }else{
        $successcode=3;
    }
}
?>
<!doctype html>
<head>
	<meta charset = "utf8">
	<title>webshop</title>
    <link rel ='stylesheet' href='CSS/style1.css'>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.12.1/css/all.min.css">
    <link rel = "icon" href = "icon.png">
    <script type = "text/javascript" src="https://ajax.aspnetcdn.com/ajax/jQuery/jquery-3.4.1.js"></script>
</head>
<body>
<?php include 'phpFiles/navbar/navbar.php';?>
	<div class="container">
	<?php if($successcode==0):?>
		<div class="msgContainer" style="background-color: #80ff80;">Registration successfull!</div>
	<?php elseif($successcode==5):?>
		<div class="msgContainer" style="background-color: #80ff80;">You are already registrated!</div>
	<?php else:?>
		<form action = 'registerWithoutEmail.php' method = 'post'>
			<?php if($successcode==4):?>
				<div class="msgContainer" style="background-color: #ff9999;">Passwords do not match!</div>
			<?php endif;?>
			
			
			<label for="username"><b>Username:</b></label>
			<?php if($successcode==2):?>
				<div class="msgContainer" style="background-color: #ff9999;">Username already exists!</div>
			<?php elseif(!$usernameValidated&&$successcode!=1):?>
				<div class="msgContainer" style="background-color: #ff9999;">Not a Username!</div>
			<?php endif;?>
			<input type = 'text'  name = 'username' id = "username" value = '<?=$username?>' required placeholder="Enter Username">
			
			
			<label for="password"><b>Password:</b></label>
			<?php if(!$passwordvalidated&&$successcode!=1):?>
				<div class="msgContainer" style="background-color: #ff9999;">not a Password!</div>
			<?php endif;?>
			<input type = 'password' name = 'password' id = "password" value = '' required placeholder="Enter Password">
			<label for="repeatPassword"><b>Repeat Password:</b></label><input type = 'password' name = 'repeatPassword' id = 'repeatPassword' value = '' required placeholder="Repeat Password">
			
			<input type = 'submit' name = 'submitRegister' class = "btnNext" value = 'registrieren'>
		</form>
	<?php endif;?>
	</div>
</body>