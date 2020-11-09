<?php
$user ='root';
$pass = 'secret';
$db='webshop';
$url='mariadb';

mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
$conn = new mysqli($url,$user,$pass,$db)or die("Unnable to connect");