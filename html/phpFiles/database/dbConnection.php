<?php
$user ='root';
$pass = 'secret';
$db='webshop';
$url='mariadb';

$conn = new mysqli($url,$user,$pass,$db)or die("Unnable to connect");