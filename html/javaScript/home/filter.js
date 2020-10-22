"use strict";
initFilter();
refreshFilter();
function initFilter(){
    document.getElementsByClassName("filter-item-close")[0].onclick = function(){

        let filterSearch = document.getElementById("filter-search");
        let filterSearchEmpty = document.getElementById("filter-search-empty");

        /*
            Sichtbarkeit der Blöcke umschalten
        */
        filterSearch.style.display = "none";
        filterSearchEmpty.style.display = "block";
        /*
            Text bei search löschen
        */
        filterSearch.children[0].innerText = "";
        /*
            url ändern
        */
        let url = new URL(document.location);
        url.searchParams.set("searchValue","");
        history.pushState({},null,url);

        refreshFilter();
    }
    /*
        add Enter-Key listener
    */
    let input = document.getElementById("filter-inputSearch");
    input.addEventListener("keyup", function(event) {
        // Number 13 is the "Enter" key on the keyboard
        if (event.keyCode === 13) {
          // Cancel the default action, if needed
          event.preventDefault();
          // Trigger the button element with a click
          document.getElementById("filter-searcha").click();
        }
    }); 
    document.getElementsByClassName("filter-block")[1].children[1].addEventListener("click",function(event){
        
        let url = new URL(document.location);

        let catString = url.searchParams.get("cat");
        /*
            wenn cat = 0 oder null --> keine Aktion
        */
        if(catString == null || catString == "" || catString == "0"){
            
        }else{
        //wenn cat != 0 und != null --> löschen, all selecten

            catString = "0";

            let element = document.getElementsByClassName("filter-block")[1].children[1];
            element.classList.remove("filter-item");
            element.classList.add("filter-item-selected");

            url.searchParams.set("cat",0);
            history.pushState(null,null,url);
        }
        //let catList = JSON.parse("["+catString.replace(/_/g,',')+"]");
        //
        refreshFilter();

        
    });
    document.getElementsByClassName("filter-block")[2].children[1].addEventListener("click",function(event){
        
        let url = new URL(document.location);

        let subCatString = url.searchParams.get("subcat");
        /*
            wenn cat = 0 oder null --> keine Aktion
        */
        if(subCatString == null || subCatString == "" || subCatString == "0"){
            
        }else{
        //wenn cat != 0 und != null --> löschen, all selecten

        subCatString = "0";

            let element = document.getElementsByClassName("filter-block")[2].children[1];
            element.classList.remove("filter-item");
            element.classList.add("filter-item-selected");

            url.searchParams.set("subcat",0);
            history.pushState(null,null,url);
        }
        refreshFilter();      
    });
}
function refreshFilter(){

    let url = new URL(document.location);
    /*
        element filter-search wird ausgewählt
    */
    let filterSearch = document.getElementById("filter-search");
    let filterSearchEmpty = document.getElementById("filter-search-empty");
    /*
        Suchwert
    */
    let searchValue;
    
    
    if(document.getElementById("filter-searchValue").innerText==""){
        searchValue = document.getElementById("filter-inputSearch").value;
    }else{
        searchValue = document.getElementById("filter-searchValue").innerText;
    }

    /*
        0 = all, Rest CID
    */
    let catString = url.searchParams.get("cat");
    if(catString == null || catString == "" || !arrayExp(catString)) catString = "0";
    
    /*
        Wenn catstring 0 --> all wird selected
    */
    if(catString == "0"){
        let element = document.getElementsByClassName("filter-block")[1].children[1];
        element.classList.remove("filter-item");
        element.classList.add("filter-item-selected");
    }
    
    let catList = JSON.parse("["+catString.replace(/_/g,',')+"]");

    let subCatString = url.searchParams.get("subcat");
    if(subCatString == null || subCatString == "" || !arrayExp(subCatString)) subCatString = "0";

    /*
        wenn subcatstring 0 --> all wird selected
    */
    if(subCatString == "0"){
        let element = document.getElementsByClassName("filter-block")[2].children[1];
        element.classList.remove("filter-item");
        element.classList.add("filter-item-selected");
    }
    
    let subCatList = JSON.parse("["+subCatString.replace(/_/g,',')+"]")


    if(searchValue == ""){
        filterSearch.style.display = "none";
        filterSearchEmpty.style.display = "block";

        filterSearchEmpty.children[0].onclick = function(){
            refreshFilter();
        }
    }else{
        /*
            value von input wird geleert
        */
        filterSearchEmpty.children[1].value="";
        filterSearch.children[0].innerText = searchValue;
        filterSearch.style.display = "block";
        filterSearchEmpty.style.display = "none";

        url.searchParams.set("searchValue",searchValue);
        history.pushState({},null,url);
    }

    $.post("phpFiles/httpRequests/home/getCategory.php",
    {
        searchValue: searchValue,
        cat: catString,
        subcat: subCatString
    },function(data,status){

        let json = data;
            
        let resultCount = json.resultCount;

        let categoryJson = json.category;
        let category = new Array();

        if(document.getElementById("filter-search-num") != null ){
            document.getElementById("filter-search-num").innerHTML = "&nbsp;("+json.resultCount+")&nbsp;";
        }
        //console.log(json);

        /*
            category leeren
        */
        let catItemDOM = document.getElementsByClassName("filter-item-category");
        while(catItemDOM.length>1){
            catItemDOM[1].remove();
        }

        /*
            subcategory leeren
        */
        let subCatItemDOM = document.getElementsByClassName("filter-item-subCategory");
        while(subCatItemDOM.length>1){
            subCatItemDOM[1].remove();
        }
            
        document.getElementsByClassName("filter-item-category")[0].children[1].innerText = "("+resultCount+")";

        document.getElementsByClassName("filter-item-subCategory")[0].children[1].innerText = "("+resultCount+")";

        let subCatDOM = document.getElementsByClassName("filter-block")[2];

        let anySelected = false;

        for(let i=0;i<categoryJson.length;i++){
            let cnode = new CategoryNode(catList.includes(parseFloat(categoryJson[i].CID)),categoryJson[i],subCatList);
            if(cnode.isSelected) anySelected = true;
            cnode.init();
            category.push(cnode);
        }
        
        /*
            Wenn Kategorie selected, wird all deselected
        */
        if(anySelected){
            let element = document.getElementsByClassName("filter-block")[1].children[1];
            element.classList.remove("filter-item-selected");
            element.classList.add("filter-item");
        }
    });

    refreshProducts(0,10);
}

class CategoryNode{
    constructor(isSelected,category,subCatList){
        this.isSelected = isSelected;
        this.cid = parseFloat(category.CID);
        this.name = category.Name;
        this.num = category.Anzahl;
        

        this.subcategory = Array();

        let anySelected = false;

        for(let i = 0;i<category.subCategory.length;i++){
            let scnode = new SubCategoryNode(subCatList.includes(parseFloat(category.subCategory[i].SCID)),category.subCategory[i],this);
            if(scnode.isSelected) anySelected = true;
            scnode.init();
            this.subcategory.push(scnode);
        }

        /*
            Wenn Kategorie selected, wird all deselected
        */
        if(anySelected){
            let element = document.getElementsByClassName("filter-block")[2].children[1];
            element.classList.remove("filter-item-selected");
            element.classList.add("filter-item");
        }
    }
    init(){
        let catDOM = document.getElementsByClassName("filter-block")[1];
        catDOM.appendChild(document.createElement("div"));
        let element = catDOM.children[catDOM.children.length-1];

        if(this.isSelected)
            element.classList.add("filter-item-selected");
        else
            element.classList.add("filter-item");
        element.classList.add("filter-item-category");

        let catNode = this;

        element.innerHTML = 
            "<span class = 'filter-item-name'>"+this.name+"</span>"+
            "<span class = 'filter-item-num'>("+this.num+")</span>"+
            "<span class = 'filter-item-close'>&times;</span>";
        /*
            event-listener um category auszuwählen
        */
        element.addEventListener("click",function(event){

            if(catNode.isSelected){
                catNode.isSelected = false;

                let url = new URL(document.location);

                let catString = url.searchParams.get("cat");
                /*
                    es wird geschaut, ob catString  in url existiert
                */
                if(catString == null || catString == "" || !arrayExp(catString)) catString = "0";
                /*
                    Array wird aus String geparst
                */
                let catList = JSON.parse("["+catString.replace(/_/g,',')+"]");
                
                const index = catList.indexOf(catNode.cid);
                if (index > -1) {
                    catList.splice(index, 1);
                }

                /*
                * CatList wird zurück in URL geschrieben
                */
                catString = JSON.stringify(catList);
                catString = catString.replace(/,/g,'_');
                catString = catString.replace(/\[/g,'');
                catString = catString.replace(/\]/g,'');

                if(catString=="") catString = "0";
                url.searchParams.set("cat",catString);

                history.pushState({},"home",url.href);

                /*
                    btn für category wird deselected
                */
                //console.log(element);
                element.classList.remove("filter-item-selected");
                element.classList.add("filter-item");

            }else{

                catNode.isSelected = true;

                let url = new URL(document.location);

                let catString = url.searchParams.get("cat");
                /*
                    es wird geschaut, ob catString  in url existiert
                */
                if(catString == null || catString == "" || !arrayExp(catString)) catString = "0";
                /*
                    Array wird aus String geparst
                */
                let catList = JSON.parse("["+catString.replace(/_/g,',')+"]");
                /*
                    Wenn erstes Item 0 --> alles ausgewählt, Array wird geleert
                */
                if(catList[0]==0) catList = Array();
                /*
                * neues Item wird hinzugefügt
                */
                if(!catList.includes(parseFloat(catNode.cid)))
                catList.push(parseFloat(catNode.cid));
                /*
                * CatList wird zurück in URL geschrieben
                */
                catString = JSON.stringify(catList);
                catString = catString.replace(/,/g,'_');
                catString = catString.replace(/\[/g,'');
                catString = catString.replace(/\]/g,'');
                url.searchParams.set("cat",catString);
                history.pushState({},null,url);

                /*
                    btnAll wird deselected
                */
                //document.getElementsByClassName("filter-block")[1].children[1].style.display = "none";
                let btnAll = document.getElementsByClassName("filter-block")[1].children[1];
                btnAll.classList.remove("filter-item-selected");
                btnAll.classList.add("filter-item");

                /*
                    btn für category wird selected
                */
                element.classList.remove("filter-item");
                element.classList.add("filter-item-selected");
                //console.log(catNode.name);
            }
            refreshFilter();
        });
        

    }
}
class SubCategoryNode{
    constructor(isSelected,subcategory,parent){
        this.isSelected = isSelected;
        this.scid = subcategory.SCID;
        this.name = subcategory.Name;
        this.num = subcategory.Anzahl;
        this.parent = parent;
    }
    init(){
        let catDOM = document.getElementsByClassName("filter-block")[2];
        catDOM.appendChild(document.createElement("div"));
        let element = catDOM.children[catDOM.children.length-1];

        if(this.isSelected)
            element.classList.add("filter-item-selected");
        else
            element.classList.add("filter-item");
        
        element.classList.add("filter-item-subCategory");

        let subCatNode = this;

        element.innerHTML = 
            "<span class = 'filter-item-name'>"+this.name+"</span>"+
            "<span class = 'filter-item-num'>("+this.num+")</span>"+
            "<span class = 'filter-item-close'>&times;</span>";
        /*
            Event - Listener, um Subcategory auszuwählen
        */
        element.addEventListener("click",function(event){

            if(subCatNode.isSelected){
                subCatNode.isSelected = false;

                let url = new URL(document.location);

                let subCatString = url.searchParams.get("subcat");
                /*
                    es wird geschaut, ob subcatString  in url existiert
                */
                if(subCatString == null || subCatString == "" || !arrayExp(subCatString)) subCatString = "0";
                /*
                    Array wird aus String geparst
                */
                let subCatList = JSON.parse("["+subCatString.replace(/_/g,',')+"]");
                
                const index = subCatList.indexOf(parseFloat(subCatNode.scid));

                if (index > -1) {
                    subCatList.splice(index, 1);
                }

                /*
                * subCatList wird zurück in URL geschrieben
                */
                subCatString = JSON.stringify(subCatList);
                subCatString = subCatString.replace(/,/g,'_');
                subCatString = subCatString.replace(/\[/g,'');
                subCatString = subCatString.replace(/\]/g,'');

                if(subCatString=="") subCatString = "0";
                url.searchParams.set("subcat",subCatString);

                history.pushState(null,null,url.href);

                /*
                    btn für category wird deselected
                */
                //console.log(element);
                element.classList.remove("filter-item-selected");
                element.classList.add("filter-item");

            }else{
                subCatNode.isSelected = true;

                let url = new URL(document.location);

                let subCatString = url.searchParams.get("subcat");
                /*
                    es wird geschaut, ob catString  in url existiert
                */
                if(subCatString == null || subCatString == "" || !arrayExp(subCatString)) subCatString = "0";
                /*
                    Array wird aus String geparst
                */
                let subCatList = JSON.parse("["+subCatString.replace(/_/g,',')+"]");
                /*
                    Wenn erstes Item 0 --> alles ausgewählt, Array wird geleert
                */
                if(subCatList[0]==0) subCatList = Array();
                /*
                * neues Item wird hinzugefügt
                */
                if(!subCatList.includes(parseFloat(subCatNode.scid)))
                subCatList.push(parseFloat(subCatNode.scid));
                /*
                * CatList wird zurück in URL geschrieben
                */
                subCatString = JSON.stringify(subCatList);
                subCatString = subCatString.replace(/,/g,'_');
                subCatString = subCatString.replace(/\[/g,'');
                subCatString = subCatString.replace(/\]/g,'');
                url.searchParams.set("subcat",subCatString);
                history.pushState({},null,url);

                /*
                    btnAll wird deselected
                */
                //document.getElementsByClassName("filter-block")[1].children[1].style.display = "none";
                let btnAll = document.getElementsByClassName("filter-block")[2].children[1];
                btnAll.classList.remove("filter-item-selected");
                btnAll.classList.add("filter-item");

                /*
                    btn für category wird selected
                */
                element.classList.remove("filter-item");
                element.classList.add("filter-item-selected");
            }
            refreshFilter();
        });
    }
}
function arrayExp(text){
    let regex = new RegExp("^\\d\\d*(_\\d\\d*)*_?\\d?$");
    return regex.test(text);
}