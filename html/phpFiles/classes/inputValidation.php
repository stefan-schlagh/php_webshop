<?php
abstract class InputValidation{
    protected $content;
    protected $errorMsg;
    /**
     * valid wird bei jedem Wechsel des Contents wird es neu aufgerufen
     */
    protected $valid=true;

    function __construct()
    {
        $this->content="";
        $this->errorMsg="";
        /**
         * valid ist standardm??ig true:
         * Dieser Wert wird nur aufgerufen wenn form sich noch nicht in get befindet -> weitere validation wird gar nicht aufgerufen 
         */
        $this->valid=true;
    }

    public function setContent($content){
        $this->content=$content;
        $this->isValid();
    }
    public function getContent(){
        return $this->content;
    }
    public function getErrorMsg(){
        return $this->errorMsg;
    }
    public function getValid(){
        return $this->valid;
    }
    /*
     * geh?rt jeweils an die Bed?rfnisse des jeweiligen Eingabefeldes angepasst
     */
    abstract protected function isValid();
}
class AlreadySavedInputValidation extends InputValidation{
    function isValid(){
        $this->valid=true;
    }
}
/**
 * Neuer Username wird validiert
 * es wird überprüft, ob es ihn noch nicht gibt
 */
class NewUsernameValidation extends InputValidation{
    /**
     * Da es beim registrieren Back-Button gibt, kommt es vor das sich User bereits in DB befindet
     * Um Komplikationen zu vermeiden, gibt es den Wert "alreadySaved", er ist standardmäßig false
     */
    //protected $alreadySaved;
    function __construct(){
        InputValidation::__construct();
    }

    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(strlen($this->getContent())>30||!preg_match('/^\w\w*$/',$this->getContent())){
            /**
             * Stringlaenge muss kleiner gleich 30 sein
             * preg_match returned true wenn passt, wenn nicht passt false -> negierung, um in if Block zu kommen 
             */
            $this->errorMsg="Not a Username!";
            $this->valid=false;
        }else if($this->existsUsername()){
            /**
             * Hier: Username darf nicht existieren
             */
            $this->errorMsg="Username already exists!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
    protected function existsUsername(){
        /**
         * In der DB wird nachgeschaut, ob Username schon existiert
         */
        include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";
        $sql = "SELECT UID FROM user WHERE Username ='$this->content'
                    UNION SELECT UID FROM notverifieduser WHERE Username = '$this->content'";
        $result = $conn->query($sql);
        if($result->fetch_assoc()){
            return true;
        }
        return false;
    }
}
class AlreadySavedUsernameValidation extends InputValidation{
    function isValid(){
        $this->valid=true;
    }
}
class ExistingUsernameValidation extends InputValidation{
    function __construct(){
        InputValidation::__construct();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(strlen($this->getContent())>30||!preg_match('/^\w\w*$/',$this->getContent())){
            /**
             * Stringlaenge muss kleiner gleich 30 sein
             * preg_match returned true wenn passt, wenn nicht passt false -> negierung, um in if Block zu kommen 
             */
            $this->errorMsg="Not a Username!";
            $this->valid=false;
        }else if(!$this->existsUsername()){
            /**
             * Hier: Username muss existieren
             */
            $this->errorMsg="Username does not exist!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
    protected function existsUsername(){
        /**
         * In der DB wird nachgeschaut, ob Username schon existiert
         */
        include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";
        $sql = "SELECT UID FROM user WHERE Username ='$this->content'
                    UNION SELECT UID FROM notverifieduser WHERE Username = '$this->content'";
        $result = $conn->query($sql);
        if($result->fetch_assoc()){
            return true;
        }
        return false;
    }
}
class NewEmailValidation extends InputValidation{
    function __construct(){
        InputValidation::__construct();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(!filter_var($this->content, FILTER_VALIDATE_EMAIL)){
            $this->errorMsg="Not an Email!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }

}
class ExistingEmailValidation extends InputValidation{
    protected $username;
    function __construct(){
        InputValidation::__construct();
        $this->username="";
    }
    function setUsername($username){
        $this->username=$username;
        $this->isValid();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(!filter_var($this->content, FILTER_VALIDATE_EMAIL)){
            $this->errorMsg="Not an Email!";
            $this->valid=false;
        }else if(!$this->isRightEmail()){
            $this->errorMsg="Wrong Email!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
    function isRightEmail(){
        include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";
        $sql = "SELECT Email FROM user WHERE username ='".$this->username."';";   
        $result = $conn->query($sql);
        //ist email in Spalte vorhanden?
        if($row = $result->fetch_assoc()){
            //stimmt Email in DB mit angegebener Mailadresse überein?
            return $this->content==$row["Email"];
        };
        return false;
    }
}
class NewPasswordValidation extends InputValidation{
    protected $content2;//repeatPassword
    protected $alreadySaved;
    function __construct(){
        InputValidation::__construct();
        $this->content2="";
        $this->alreadySaved=false;
    }
    public function setAlreadySaved($alreadySaved){
        /**
         * alreadysaved funktioniert nur dann, wenn im Passwordfield nix drinnensteht
         */
        if($this->content!=""){
            $this->alreadySaved=false;
        }else{
            $this->alreadySaved=$alreadySaved;
        }
    }
    function setContent2($content2){
        $this->content2=$content2;
        $this->isValid();
    }
    function getContent2(){
        return $this->content2;
    }
    function isValid(){
        if($this->alreadySaved){
            $this->valid=true;
        }else if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(strlen($this->content)<5||strlen($this->content)>100){
            $this->errorMsg="Not a password!";
            $this->valid=false;
            /**
             * TODO: Sonderzeichen muessen vorhanden sein
             */
        }else if($this->content!=$this->content2){
            $this->errorMsg="Passwords do not match!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
    public static function hashPassword($password){
        $pepper = "17f4853b10cf212dc70ae2051dd3909a";
        return password_hash($password . $pepper, PASSWORD_BCRYPT, array('cost' => 12));
    }
}
class ExistingPasswordValidation extends InputValidation{
    protected $username;
    function __construct(){
        InputValidation::__construct();
        $this->username="";
    }
    function setUsername($username){
        $this->username=$username;
        $this->isValid();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(!$this->isRightPassword()){
            $this->errorMsg="Wrong Password!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
    private function isRightPassword(){
        include $_SERVER['DOCUMENT_ROOT']."/phpFiles/database/dbConnection.php";
        $sql = "SELECT Password FROM user WHERE username ='".$this->username."';";   
        //$conn->query("SET @p0 = '".$this->username."'");
        //$result = $conn->query("Call 'selectPassword'(@p0)");
        $result = $conn->query($sql);
        if($row = $result->fetch_assoc()){
            $passwordDB=$row["Password"];
            $pepper = "17f4853b10cf212dc70ae2051dd3909a"; 
            return password_verify($this->getContent() . $pepper, $passwordDB);
        };
        return false;
    }
}
 
class OrtValidation extends InputValidation{
    function __construct(){
        InputValidation::__construct();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(!preg_match('/^\w+(([\',. -]\w)?\w*)*$/',$this->content)){
            $this->errorMsg="Not a Town!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
}
class PLZValidation extends InputValidation{
    function __construct(){
        InputValidation::__construct();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(!filter_var($this->content, FILTER_VALIDATE_INT)){
            $this->errorMsg="Not a PLZ!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
}
class StreetValidation extends InputValidation{
    function __construct(){
        InputValidation::__construct();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(!preg_match('/^\w+(([\',. -]\w)?\w*)*$/',$this->content)){
            $this->errorMsg="Not a Street!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
}
class HausNrValidation extends InputValidation{
    function __construct(){
        InputValidation::__construct();
    }
    function isValid(){
        if(strlen($this->getContent())==0){
            $this->errorMsg="required!";
            $this->valid=false;
        }else if(!filter_var($this->content, FILTER_VALIDATE_INT)){
            $this->errorMsg="Not a HNr!";
            $this->valid=false;
        }else{
            $this->valid=true;
        }
    }
}