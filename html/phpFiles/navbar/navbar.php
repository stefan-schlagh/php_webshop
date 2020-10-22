<link rel = "stylesheet" href = "CSS/navbar.css">

<div class="navbar">
	<ul>
		<li><a href = "home.php" class = "navlink">Home</a></li>
		<li><a href="javascript:void(0)" id = "navbar-cart" class = "navlink">Warenkorb</a></li>
		<li class="dropdown">
			<?php 
			/*
				user bereits eingeloggt
			*/
			if(isset($_SESSION["username"])){
			?>
				<a href="javascript:void(0)" class="dropbtn"><?=$_SESSION["username"]?></a>
				<div class="dropdown-content" id = "navbar-profile">    
					<a href="userInformation.php" class = "navlink">Bestellungen</a>
					<a href="profileOptions.php" class = "navlink">Einstellungen</a>
					<a href="javascript:void(0)" class = "navlink" id = "navbar-logout">logout</a>
				</div>
			<?php 
			}else if (isset($_COOKIE["loggedIn"])){
				/*
					Wenn cookie gesetzt wird user "eingeloggt"
				*/
				$sql = "SELECT * FROM user WHERE UID ='".$_COOKIE["loggedIn"]."';";
				$result = $conn->query($sql);
				$row = $result->fetch_assoc();
						
				$username=$row["Username"];
				$UID=$row["UID"];
										
				$_SESSION["username"]=$username;
				$_SESSION["userID"]=$UID;

				//cart wird geladen
				?>	
					<script defer>
						setTimeout(function(){
							loadCart();
						},2000);
					</script>
					<a href="javascript:void(0)" class="dropbtn"><?=$_SESSION["username"]?></a>
					<div class="dropdown-content" id = "navbar-profile">    
						<a href="userInformation.php" class = "navlink">Bestellungen</a>
						<a href="profileOptions.php" class = "navlink">Einstellungen</a>
						<a href="javascript:void(0)" class = "navlink" id = "navbar-logout">logout</a>
					</div>
				<?php 
			
			}else{
			?>
				<a href="javascript:void(0)" class="dropbtn">Konto</a>
				<div class="dropdown-content" id = "navbar-profile">    
					<a href="javascript:void(0)" id = "navbar-login" class = "navlink">Login</a>
					<a href="register.php" class = "navlink">Registrieren</a>
				</div>
			<?php }?>
		</li>
		<li><a href="impressum.php" id = "navbar-impressum" class = "navlink">Impressum</a></li>
		<?php
			$searchvalue = "";
			if(isset($_GET["searchValue"]))
				$searchvalue = $_GET["searchValue"];
		?>
		<form action = "home.php" method= "get" class = "navform">
			
			<input type = "submit" value = "&#128269;" style = "cursor:pointer;">
			<input type="text" placeholder = "search" name = "searchValue" value = "<?=$searchvalue?>">
		</form>
	</ul>
	<script defer>

		$("#navbar-cart").click(function(){
			$("#cartModal").show();
			$("#backToProduct").hide();
			$("#mc-header1").hide();

			updateCart();
		});
		
		// Action für Logout wird initialisiert
		initLogout();
		function initLogout(){
			$("#navbar-logout").click(function(){
				//Inhalt des Konto Tabs in Navbar werden geändert
				$("#navbar-profile").prev().html("Konto");
				$("#navbar-profile").html(
                    "<a href='javascript:void(0)' id = 'navbar-login' class = 'navlink'>Login</a>"+
					"<a href='register.php' class = 'navlink'>Registrieren</a>"
				);
				$.ajax("phpFiles/navbar/logout.php", {type: "POST"});
				initLogin();
			});
		}

		// Action für Login wird initialisiert
		initLogin();
		function initLogin(){
			$("#navbar-login").click(function(){
				//Dialog für Login wird geöffnet
				$("#loginModal").show();
				setMlCallBack(function(){});
				//Text wird gesetzt
				$("#ml-msgBox").show();
				$("#ml-msgBox").html("Einloggen");
				//Dialog wird verkleinert, da kein Platz für Error-messages gebraucht wird
				$("#loginModal-content").css("height","300px");
				//msg-boxes werden ausgeblendet
				$("#msgBox-uname").html("");
				$("#msgBox-uname").css("background-color","inherit");
				$("#msgBox-psw").html("");
				$("#msgBox-psw").css("background-color","inherit");
			});
		}
	</script>
</div>


<?php 
		include "loginModal/loginModal.php";
		include "passwordResetModal/passwordResetModal.php";
		include "cartModal/cartModal.php";
		include "msgBox.php";
?>