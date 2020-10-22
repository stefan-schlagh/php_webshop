<?php
//remove cookie if set
setcookie("loggedIn", "", time() - 3600, "/");

session_start();
// remove all session variables
session_unset();

// destroy the session
session_destroy(); 