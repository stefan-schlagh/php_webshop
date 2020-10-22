/*
    globals
*/

//Variable, auf der der Index, der derzeit im modal geöffnet ist gespeichert wird
let pIndex;

let price;

let pidNow;

function createPagination(start,siteSize,resultCount){
    let paginationTop = document.getElementById("pagination-top");
    let paginationBottom = document.getElementById("pagination-bottom");

    /*
        Start des ausgegebenen Bereichs
    */
    let pagination = (start+1)+" - ";
    /*
        Ende des ausgegebenen Bereichs
            wenn start+ siteSize < resultCount
                Ende des Ergebnisses noch nicht erreicht
                start + siteSize wird ausgegeben
    */
    if(start+siteSize<resultCount){
        pagination+=start+siteSize;
    }
    /*
        sonst 
            Ende des Ergebnisses erreicht
            resultCount wird ausgegeben
    */
    else{
        pagination+=resultCount;
    }
    let i = start-2*siteSize;
    /*
        i kann nicht negativ sein
    */
    if(i<=0)
        i=0;
    
    else // i negativ
        /*
            Wenn nach unten hin noch Seiten existieren (i>0), die noch nicht angezeigt werden:
                Button "<" wird angezeigt
        */
        pagination += createButton("<",start-siteSize);
    for(;i<=start+(siteSize*2)&&i<resultCount;i+=siteSize){
        /*
            Buttons mit Seitenzahlen werden erstellt
        */
        if(i==start)
            pagination += createButton(i/siteSize+1,i,true);
        else
            pagination += createButton(i/siteSize+1,i,false);
    }
    /*
        Wenn nach oben hin noch Seiten existieren, die noch nicht angezeigt werden:
            Button ">" wird angezeigt
    */
    if(start+siteSize*3<resultCount)
        pagination += createButton(">",start+siteSize);

    /*
        paginationTop wird refresht
    */
    paginationTop.innerHTML = pagination;
    /*
        paginationBottom wird refresht
    */
    paginationBottom.innerHTML = pagination;

}
function createButton(value,start,dark){
    let rc =  "&nbsp;<button onclick='refreshProducts("+start+",10)' ";
    if(dark)
        rc += "style = 'background-color: #2d9f2d;'";
    rc += "'>"+value+"</button>";
    return rc;
}
function refreshProducts(start, siteSize){
    
    let url = new URL(document.location);

    url.searchParams.set("start",start);
    history.pushState({},null,url);

    let catString = url.searchParams.get("cat");
    if(!arrayExp(catString)) catString = "0";

    let subCatString = url.searchParams.get("subcat");
    if(!arrayExp(subCatString)) subCatString = "0";

    let searchValue = url.searchParams.get("searchValue");
    if(searchValue==null)
        searchValue = "";

    /*
        http-request um neue Produktliste zu erhalten
    */
    $.post("phpFiles/httpRequests/home/getProductJson.php",
    {
        searchValue: searchValue,
        start: start,
        siteSize: siteSize,
        cat: catString,
        subcat: subCatString
    },function(data,status){
        let productJson = data;
        let resultCount = productJson.resultCount;

        document.getElementById("resultCount").innerText = resultCount;

        createPagination(start,siteSize,resultCount);

        let productArr = productJson.products;
        //console.log(document.getElementById("mainContent").innerHTML);
        let mainContent = "";
        
        // Array der PIDs wird neu initialisiert
        let pid = [];

        for(var i = 0;i<productArr.length;i++){

            let product = productArr[i];

            pid.push(product.PID);

            mainContent += 
            "<div class='product' id=p"+i+">"
                //Trigger/Open The Modal
                +"<a><img class = 'product-image' id = 'p-img"+i+"' src = '"+product.ImgSource+"'></a>"
                +"<div class = 'product-text'>"
                    //Trigger/Open The Modal -->
                    +"<div class = 'head' ><a id='p-head"+i+"'>"+product.Bez+"</a></div>"

                    +"<span id = 'p-Category"+i+"' class = 'p-Category'>"+product.Category+"</span>"
                    +"&nbsp;&rarr;&nbsp;"
                    +"<span id = 'p-Subcategory"+i+"' class = 'p-Subcategory'>"+product.Subcategory+"</span><br>";

            mainContent += "<div class = 'p-rating' id = 'p-rating"+i+"'>"
            
            if(product.NumRating == 0){
                mainContent += "<span class = 'rating'>Noch keine "+
                "<a class = 'p-rating-link' style = 'text-decoration: none;'>Bewertungen</a> vorhanden</span>";
            }else{

                //Rating wird gerendert
                let numRating = parseFloat(product.NumRating);
                let avgRating = Math.round(parseFloat(product.AvgRating) * 100) / 100;

                let j = 0;
                for(; j < avgRating ; j++){
                    mainContent += "<span class='fa fa-star checked'></span>"
                }
                for(;j < 5 ; j++){
                    mainContent += "<span class='fa fa-star'></span>"
                }

                mainContent += "  &empty; "+avgRating+"/5 bei ";
                if(numRating==1){
                    mainContent += "einer <a class = 'p-rating-link'>Bewertung</a>";
                }else{
                    mainContent += numRating+" <a class = 'p-rating-link'>Bewertungen</a>";
                }
            }

            mainContent += "</div>";

            mainContent +=
                    "<span id = 'p-price"+i+"'>"+product.Preis+"</span>&nbsp;&euro;"
                +"</div>"
                +"<button class='product-btnDetails'>Details</button>"
            +"</div>";      
        }
        document.getElementById("mainContent").innerHTML = mainContent;

        const product = Array.from(document.getElementsByClassName("product"));
        
        $(".p-rating-link")[0].addEventListener("click",function(event){
            openRatings(pIndex+1);
        });
        //console.log(document.getElementsByClassName("p-rating-link")[0]);

        product.forEach(function(p,i){
            p.children[0].addEventListener("click",function(){
                openProductModal(pid[i]);
                pIndex = i;
            });
            p.children[1].children[0].addEventListener("click",function(){
                openProductModal(pid[i]);
                pIndex = i;
            });

            p.children[2].addEventListener("click",function(){
                openProductModal(pid[i]);
                pIndex = i;
            });

            document.getElementsByClassName("p-rating-link")[i].addEventListener("click",function(){
                openRatings(pid[i]);
                pIndex = i;
            });
        });
        
    });
}
function arrayExp(text){
    let regex = new RegExp("^\\d\\d*(_\\d\\d*)*_?\\d?$");
    return regex.test(text);
}