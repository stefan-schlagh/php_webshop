"use-strict";
initReview();

function initReview(){

    let textArea = document.getElementById("review-text");
    let textValid = true;

    let submitBtn = document.getElementById("submit-ro");
    let msgbox = document.getElementById("msgBox-ro");

    let stars = Array();
    let ratingBox = document.getElementById("rating1");

    let timeOutSet = false;
    let starHovered = false;

    let productRated = false;

    let rating = 0;


    for(let i=0;i<5;i++){
        stars.push(ratingBox.children[i]);
    }

    textArea.addEventListener("input",function(event){
        /*
                    Zeichen     Unicode
        ------------------------------
        Ä, ä        \u00c4, \u00e4
        Ö, ö        \u00d6, \u00f6
        Ü, ü        \u00dc, \u00fc
        ß           \u00df
        */
        let r = new RegExp("^[\\w\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc]([\\w\\n\\s\\u00c4\\u00e4\\u00f6\\u00d6\\u00dc\\u00fc\\u00df!\\?\\.,-:])*$");
        let testRegex = r.test(textArea.value) || textArea.value == "";
        /*
            wenn textArea valid und errorMessage gezeigt
        */
        if(testRegex&&!textValid){
            msgbox.style.display = "none";
            textValid = true;
            
        /*
            wenn textArea nicht valid und errorMessage nicht gezeigt
        */
        }else if(!testRegex&&textValid){
            $("#msgBox-ro").css({"background-color":"#f17272","display":"inline"});
            $("#msgBox-ro").html("Text enth&auml;lt ung&uuml;ltige Zeichen!");
            textValid = false;
        }
    });

    //TODO: Listener für ratingBox
    for(let i=0;i<5;i++){
        stars[i].addEventListener("mouseover",function(event){
            let j=0;
            j=0;
            for(;j<5;j++){
                stars[j].classList.add("checked");
                if(event.srcElement==stars[j]){
                    j++;
                    rating = j;
                    break;
                }
            }
            for(;j<5;j++){
                stars[j].classList.remove("checked");
            }
            starHovered = true;
            setTimeout(function(){
                starHovered=false;
            },200);
        });
    }
    ratingBox.addEventListener("mouseover",function(event){
        if(!timeOutSet){
            setTimeout(function(){
                if(!starHovered){
                    for(let j=0;j<5;j++){           
                        stars[j].classList.remove("checked");
                    }
                }
                timeOutSet = false;
            }, 400);
            timeOutSet = true;
        }
    });
    ratingBox.addEventListener("click",function(event){
        timeOutSet = true;
    });
    
    //Submit eines eigenen reviews wird gehandelt
    $("#submit-ro").click(function(){
        if(rating!=0&&textValid==true&&!productRated){
            $.ajax("phpFiles/httpRequests/review/insertReview.php", {
                type: "POST",
                data: { 
                    pid1: pidNow,
                    rating1: rating,
                    reviewText: textArea.value
                },
                statusCode: {
                    200: function (response) {
                        //alert('200');
                    },
                    201: function (response) {
                        //alert('1');
                    },
                    400: function (response) {
                        //alert('400');
                    },
                    401: function (response) {
                        $("#msgBox-ro").css({"background-color":"#f17272","display":"inline"});
                        $("#msgBox-ro").html("Nicht eingeloggt!");
                        $("#ml-msgBox").show();
                        $("#ml-msgBox").html("Einloggen, um fortzufahren!");

                        //Dialog für Login wird geöffnet
                        $("#loginModal").show();
                        //Dialog wird verkleinert, da kein Platz für Error-messages gebraucht wird
                        $("#loginModal-content").css("height","300px");

                        //msg-boxes werden ausgeblendet
                        $("#msgBox-uname").html("");
                        $("#msgBox-uname").css("background-color","inherit");
                        $("#msgBox-psw").html("");
                        $("#msgBox-psw").css("background-color","inherit");
                        
                        setMlCallBack(function(success){
                            if(success){
                                $("#msgBox-ro").css("display","none");
                                $("#submit-ro").trigger("click");
                            }
                        });
                    }
                }, success: function () {
                    $("#msgBox-ro").css({"background-color":"var(--greenL)","display":"inline"});
                    $("#msgBox-ro").show();
                    $("#msgBox-ro").html("Bewertung hinzugef&uumlgt!");
                    productRated = true;
                },
             });
        }else if(productRated){
            $("#msgBox-ro").css({"background-color":"#f17272","display":"inline"});
            $("#msgBox-ro").html("Produkt wurde bereits bewertet!");
        }else if(rating==0){
            $("#msgBox-ro").css({"background-color":"#f17272","display":"inline"});
            $("#msgBox-ro").html("Bitte Sternewertung angeben!");
        }
    });

    let reviewLoading = false;
    let everythingLoaded = false;
    let reviewStart = 0;
    let reviewSiteSize = 10;

    //scroll
    $("#productModal").scroll(function() {
        /*
            Wenn am unteren Ende des Dialogfensters angekommen, werden ,wenn es noch gibt neue reviews geladen
        */
        if($("#productModal").scrollTop() + $(window).height() > $("#productModal").children().outerHeight()) {
            if(!reviewLoading&&!everythingLoaded){

                $("#review-loadMsg").show();

                reviewLoading = true;
                $.post("phpFiles/httpRequests/review/getReview.php",
                {
                    pid1:  pidNow,
                    start: reviewStart,
                    size: reviewSiteSize
                },
                function(data,status){

                    $("#review-loadMsg").hide();
                    //console.log(data);

                    //let reviews = JSON.parse(data);
                    let reviews = data;

                    everythingLoaded = (data.length==0);

                    for(let i = 0; i<reviews.length;i++){
                        //console.log(reviews[i].Username);
                        let reviewHtml = "";

                        reviewHtml += "<div class = 'review-item'>";


                        reviewHtml += "<div class = 'review-uname'>"+reviews[i].Username+"</div>";
                        let j = 0;
                        for(;j<parseFloat(reviews[i].Rating);j++){
                            reviewHtml += "<span class='fa fa-star checked'></span>"
                        }
                        for(;j<5;j++){
                            reviewHtml += "<span class='fa fa-star'></span>"
                        }
                        reviewHtml += "<div class = 'review-time'>"+reviews[i].ReviewDate+" "+reviews[i].ReviewTime+"</div>";
                        reviewHtml += "<div class = 'review-text1'>"+reviews[i].ReviewText+"</div>";

                        reviewHtml += "</div>";

                        $("#review-box").html($("#review-box").html()+reviewHtml);
                    }

                    reviewStart += reviewSiteSize;
                    reviewLoading = false;
                });
            }
        }
     });
     
    let main = document.getElementById("mainContent");


    main.addEventListener("modalOpened",function(event){
        
        textArea.value = "";
        timeOutSet = false;
        for(let j=0;j<5;j++){           
            stars[j].classList.remove("checked");
        }
        reviewStart = 0;
        $("#msgBox-ro").hide();
        $("#review-box").html("");
        everythingLoaded = false;
        productRated = false;
        rating = 0;

    },false);


     
}
/*
    TODO clear own review
*/