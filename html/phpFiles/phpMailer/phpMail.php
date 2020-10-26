<?php

require $_SERVER['DOCUMENT_ROOT'] . '/vendor/autoload.php';

$dotenv = Dotenv\Dotenv::createImmutable("/var/www");
$dotenv->load();

require($_SERVER['DOCUMENT_ROOT'].'/vendor/phpmailer/phpmailer/src/PHPMailer.php');
require($_SERVER['DOCUMENT_ROOT'].'/vendor/phpmailer/phpmailer/src/SMTP.php');

function phpMail($empfaenger,$betreff,$msg){

   $mail = new PHPMailer\PHPMailer\PHPMailer(); // create a new object
   $mail->IsSMTP(); // enable SMTP
   $mail->SMTPDebug = 0; // debugging: 1 = errors and messages, 2 = messages only
   $mail->SMTPAuth = true; // authentication enabled
   $mail->SMTPSecure = 'ssl'; // secure transfer enabled REQUIRED for GMail
   $mail->Host = $_ENV["EMAIL_SERVICE"];;
   $mail->Port = 465; //465 or 587
   $mail->IsHTML(true);
   $mail->Username = $_ENV["EMAIL_USER"];
   $mail->Password = $_ENV["EMAIL_PASSWORD"];
   $mail->SetFrom($_ENV["EMAIL_USER"]);
   $mail->AddAddress($empfaenger);


   $mail->Subject = $betreff;
   $mail->Body = $msg;

   if(!$mail->Send()) {
      return "Mailer Error: " . $mail->ErrorInfo;
   } else {
      return "Message has been sent";
   }
}
?>
