<?php

function phpMail($empfaenger,$betreff,$msg){

    /*
    Requires: https://github.com/PHPMailer/PHPMailer/releases/tag/v5.2.6
    */
    require_once($_SERVER['DOCUMENT_ROOT'].'/phpLibs/PHPMailer-5.2.6/class.phpmailer.php');

    $mail = new PHPMailer(); // create a new object
    $mail->IsSMTP(); // enable SMTP
    $mail->SMTPDebug = 0; // debugging: 1 = errors and messages, 2 = messages only
    $mail->SMTPAuth = true; // authentication enabled
    $mail->SMTPSecure = 'ssl'; // secure transfer enabled REQUIRED for GMail
    $mail->Host = "smtp.gmail.com";
    $mail->Port = 465; //465 or 587
    $mail->IsHTML(true);
    $mail->Username = "stefanjkf.test@gmail.com";
    $mail->Password = 'SLKL8LZASe7MKYe';
    $mail->SetFrom("stefanjkf.test@gmail.com");
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
