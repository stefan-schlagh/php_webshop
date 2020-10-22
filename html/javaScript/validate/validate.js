class SelectValidator{
    constructor(required,id,msgBox,defaultValue){
        this.required = required;
        this.element = document.getElementById(id);
        this.msgBox = msgBox;
        this.valid = true;

    }
    validate(){
        const e = this.element;
        const land=e.options[e.selectedIndex].value;
        /*
        wenn input valid und errorMessage gezeigt
        */
        if(!this.valid){
            hide(this.msgBox);
            this.valid = true;
            
        /*
            wenn input nicht valid und errorMessage nicht gezeigt
        */
        }else if(this.required && (this.element.value == "" || land == defaultValue)){
            show(this.msgBox);
            this.msgBox.innerHTML = "bitte ausf&uuml;llen!";
            this.valid = false;
        }
        function hide(element){
            element.style.display = "none";
        }
        function show(element){
            element.style.display = "block";
        }
        return this.valid;
    }
}

class InputValidator{
    constructor(required,pattern,element,msgBox){
        this.pattern = pattern;
        this.required = required;
        this.element = element;
        this.msgBox = msgBox;
        this.valid = true;
        
        let v = this;
        element.on("input",function(){
            v.validate();
        });
    }
    validate(){
        let r = new RegExp(this.pattern);
        /*
            Entweder wird Rgex getestet oder es steht nix drin
        */
        let testRegex = this.element.val() == "" || r.test(this.element.val());
        /*
        wenn input valid und errorMessage gezeigt
        */
        if(testRegex&&!this.valid){
            hide(this.msgBox);
            this.valid = true;
            
        /*
            wenn input nicht valid und errorMessage nicht gezeigt
        */
        }else if(!testRegex&&this.valid){
            show(this.msgBox);
            this.msgBox.innerHTML = "Enth&auml;lt ung&uuml;ltige Zeichen!";
            this.valid = false;
        }else if(this.required && this.element.val() == ""){
            show(this.msgBox);
            this.msgBox.innerHTML = "bitte ausf&uuml;llen!";
            this.valid = false;
        }
        function hide(element){
            element.style.display = "none";
        }
        function show(element){
            element.style.display = "block";
        }
        return this.valid;
    }
}