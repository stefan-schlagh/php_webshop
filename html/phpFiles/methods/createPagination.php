<?php
function createPagination(){
    global $resultCount,$start,$siteSize,$searchvalue;
    ?>           
        <?=$start+1?> - <?php 
            if($start+$siteSize<$resultCount)
                echo $start+$siteSize;
            else
                echo $resultCount;
            ?>
        <script type = "text/javascript">
            function submitPagination(start){
                window.location.href = "home.php?searchvalue=<?=$searchvalue?>&start="+start;
            }
        </script>
        <?php
            /*if($start!=0){
                createBtn("<",$start-$siteSize,false);
            }*/
            $i=$start-2*$siteSize;
            if($i<=0)
                $i=0;
            else
            createBtn("<",$start-$siteSize,false);
            for(;$i<=$start+($siteSize*2)&&$i<$resultCount;$i+=$siteSize){
                if($i==$start)
                    createBtn($i/$siteSize+1,$i,true);
                else
                    createBtn($i/$siteSize+1,$i,false);
            }
            if($start+$siteSize*3<$resultCount){
                createBtn(">",$start+$siteSize,false);
            }
        ?>
    <?php
}
function createBtn($value,$start,$dark){
    ?>
    
        <button onclick='refreshProducts(<?=$start?>,10)' <?php if($dark): ?> style = "background-color: #2d9f2d;"<?php endif;?>><?=$value?></button>
    <?php
}