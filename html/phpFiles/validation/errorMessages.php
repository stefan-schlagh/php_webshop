<?php 
function errorMessage($text){
    ?>
    <div class="msgContainer" style="background-color: #ff9999;"><?=$text?></div>
    <?php
}
function errorMessageTable($text,$colspan){
    ?>
    <tr><td colspan="<?=$colspan?>"><div class="msgContainer" style="background-color: #ff9999;"><?=$text?></div></td></tr>
    <?php
}
function successMessage($text){
    ?>
    <div class="msgContainer" style="background-color: #80ff80;"><?=$text?></div>
    <?php
}
?>