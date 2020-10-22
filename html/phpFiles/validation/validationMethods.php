<?php

function validatePassword($password){
    if(strlen($password)<4){
        return false;
    }
    if(strlen($password)>100){
        return false;
    }
    /*
     * TODO:Sonderzeichen muessen vorhanden sein
     */
    return true;
}
function isRightPassword($password,$passwordDB){
    $pepper = "17f4853b10cf212dc70ae2051dd3909a"; 
    return password_verify($password . $pepper, $passwordDB);
}
function hashPassword($password){
    $pepper = "17f4853b10cf212dc70ae2051dd3909a";
    return password_hash($password . $pepper, PASSWORD_BCRYPT, array('cost' => 12));
}
function validateUsername($username){
    /*
     * TODO: gscheit machen
     */
    if(strlen($username)<30)
        return preg_match('/^\w\w*$/',$username);
    return false;
}
function validateInteger($var){
    return filter_var($var, FILTER_VALIDATE_INT);
}
function validateEmail($email){
    return filter_var($email, FILTER_VALIDATE_EMAIL);
}
function validateTown($town){
    /*
        TODO: Regex
    */
    return preg_match('/^\w+(([\',. -]\w)?\w*)*$/',$town);
}
function validatePLZ($plz){
    return validateInteger($plz);
}
function validateStreet($street){
    /*
        TODO: Regex
    */
    return preg_match('/^\w+(([\',. -]\w)?\w*)*$/',$street);
}
function validateHNr($HNr){
    return validateInteger($HNr);
}